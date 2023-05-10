@RestResource(urlMapping='/insertQuoteSM/*')//
global with sharing class DSALES_QuoteSmWrapperRequest {
    public static final String NOMBRE_SERVICIO = 'DSALES_QuoteSM';
    public static final String VALOR = 'RC'; //nombre campaña
    public static final String TIPO = 'Seguro gratis'; //tipo de campaña
    public static final String RC = 'RC';
    public static final String AMP = 'AMP';
    @HttpPost
    global static DSALES_QuoteSmWrapper.RespuestaParaNpv createQuoteSM(){
        String numeroCliente = DSALES_Utility.NUMERO_CLIENTE_GENERICO;
        String message = '';
        String trackinId='';
        Account client = new Account();
        Opportunity oppor = new Opportunity();
        Quote cotiza = new Quote();
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> plazos = new List<DSALES_QuoteSmWrapper.RespuestaPlazos>();
        DSALES_QuoteSmWrapper.RespuestaPlazos moto = new DSALES_QuoteSmWrapper.RespuestaPlazos();
        DSALES_QuoteSmWrapper.QuoteSmRequest data = new DSALES_QuoteSmWrapper.QuoteSmRequest();
        DSALES_QuoteSmWrapper.respuestaDelProveedor respuestaDeProveedor = new DSALES_QuoteSmWrapper.respuestaDelProveedor();
        DSALES_ListaNegraWrapper.responseListaNegra respuestaListaNegra = new DSALES_ListaNegraWrapper.responseListaNegra();
        Boolean listaNegra = false;
        Integer errorCode;
        Boolean succes = true;
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    data = (DSALES_QuoteSmWrapper.QuoteSmRequest)JSON.deserialize(body, DSALES_QuoteSmWrapper.QuoteSmRequest.class);
                    String nombreCompleto=data.nombre;
                    if(data.apellidoMaterno!=null){
                        nombreCompleto += ' ' +data.apellidoMaterno;  
                      }
                      nombreCompleto += ' ' +data.apellidoPaterno; 
                    String rfc = data.rfc;
                    respuestaListaNegra = DSALES_ConsultaListaNegra.callWebService(rfc, nombreCompleto);
                    if(respuestaListaNegra.estatus =='true'){
                        listaNegra = true;
                        message = 'Esta en la Lista negra';
                    }            
                    DSALES_QuoteSmWrapper.QuotePostProvedor datosEnviar = new DSALES_QuoteSmWrapper.QuotePostProvedor();
                    if(data.sku!=''){
                        Product2 temporal = [SELECT Id,dsalesVehiculo__c, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:data.sku WITH SECURITY_ENFORCED LIMIT 1];
                        data.idVehiculo=temporal.dsalesVehiculo__c;  
                    }
                    datosEnviar.negocio = Label.DSALES_business;
                    datosEnviar.aseguradora = Label.DSALES_NombreAseguradora; //sales-fijo
                    datosEnviar.nombreCompleto = data.nombre + data.apellidoPaterno;//combinacion
                    datosEnviar.metodoContacto = Label.DSALES_ContactMethod;//sales-fijo
                    datosEnviar.telefonoContacto = data.telefonoCelular;
                    datosEnviar.correoContacto = data.correoElectronico;
                    datosEnviar.generoContacto = data.generoContacto;
                    datosEnviar.fechaNacimientoContacto = data.fechaNacimiento.format();
                    datosEnviar.cpContacto = data.codigoPostal;
                    datosEnviar.contactar = false;//fijo-sales
                    datosEnviar.idVehiculo = data.idVehiculo;
                    datosEnviar.servicioVehiculo = Label.DSALES_vehicleService;//fijo-sales
                    datosEnviar.usoVehiculo = data.tipoUso; //Nuevo
                    datosEnviar.tipoVehiculo = data.tipoVehiculo; //Nuevo
                    datosEnviar.plazo = data.plazoCotizar; //Nuevo hU 001
                    datosEnviar.paquete = '';
                    datosEnviar.codigoPromocion='0';//fijo
                    datosEnviar.idAsociado='0';//fijo
                    date aux = date.today();
                    aux = date.newInstance(aux.year(), aux.month(), aux.day());
                    datosEnviar.fechaCotizacion = aux.format(); //cotiza.DSALES_Fechadecreacionpresupuesto__c.format();//fecha creacion-sales
                    datosEnviar.fechaInicio = data.fechaInicio.format(); //Nuevo revisar
                    datosEnviar.listaPlazos = plazosActivos(data.plazoCotizar);
                    if(!listaNegra){
                        respuestaDeProveedor = crearQuoteSm(datosEnviar);
                    }
                    Account universalAccount = [Select Id from Account WHERE DSALES_ClienteCoppel__c = :numeroCliente WITH SECURITY_ENFORCED LIMIT 1];
                    Tienda__c tienda = [Select Id from Tienda__c WHERE dsalesTiendaID__c =: data.idTienda WITH SECURITY_ENFORCED LIMIT 1];
                    Id clienteId=null; 
                    if(data.numeroCliente == null || data.numeroCliente=='' ||data.numeroCliente==numeroCliente ){
                        List<Account> resul = [Select Id, firstName, suffix, lastName, Fecha_de_Nacimiento__c, Phone, PersonEmail from Account WHERE firstName=:data.nombre AND suffix=:data.apellidoMaterno AND lastName=:data.apellidoPaterno WITH SECURITY_ENFORCED];
                        if(resul.size() == 1){
                            clienteId = resul[0].Id;
                            oppor = creaOportunidad(data, clienteId, resul[0].firstName, resul[0].suffix, resul[0].lastName,tienda);
                            cotiza = crearCotizacion(data, oppor.Id, resul[0].firstName,  resul[0].suffix, resul[0].lastName, tienda,listaNegra);
                            plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos, data.sku,listaNegra); 
                            moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);
                        }
                        else{
                            Boolean sinCoincidenciaCuenta = true;
                            if(resul.size() > 1){                
                                for(Account cuentaSimilare: resul){
                                    if(cuentaSimilare.PersonEmail == data.correoElectronico || cuentaSimilare.Phone == data.telefonoCelular){
                                        clienteId = cuentaSimilare.Id;
                                        sinCoincidenciaCuenta = false;
                                        oppor = creaOportunidad(data, clienteId, data.nombre, data.apellidoMaterno, data.apellidoPaterno, tienda);
                                        cotiza = crearCotizacion(data, oppor.Id, data.nombre, data.apellidoMaterno, data.apellidoPaterno, tienda,listaNegra);
                                        plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra);                                       
                                        moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);
                                        break;
                                    }
                                }                         
                            }
                            if(resul.size() == 0 || sinCoincidenciaCuenta==true){
                                clienteId = universalAccount.Id; 
                                oppor = creaOportunidad(data, clienteId, data.nombre, data.apellidoMaterno, data.apellidoPaterno, tienda);
                                cotiza = crearCotizacion(data, oppor.Id, data.nombre, data.apellidoMaterno, data.apellidoPaterno, tienda,listaNegra);
                                plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra);
                                moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);
                            }
                        }     
                    }else{
                            List<Account> result = [Select Id,firstName,suffix,lastName from Account WHERE CP_WalletCustomerNumber__c =:Decimal.valueOf(data.numeroCliente) WITH SECURITY_ENFORCED];
                            if(result.size() == 0){
                                client = creaCliente(data);
                                clienteId = client.Id;
                                oppor = creaOportunidad(data, clienteId, data.nombre, data.apellidoMaterno, data.apellidoPaterno,tienda);
                                cotiza = crearCotizacion(data, oppor.Id, client.firstName,  client.suffix, client.lastName, tienda,listaNegra);
                                plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra);
                                moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);//
                            }else{
                                clienteId = result[0].Id;
                                oppor = creaOportunidad(data, clienteId, result[0].firstName, result[0].suffix, result[0].lastName,tienda);
                                cotiza = crearCotizacion(data, oppor.Id, result[0].firstName,  result[0].suffix, result[0].lastName, tienda,listaNegra);
                                plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra);
                                moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);
                            }       
                    }
                }catch(Exception.JSONException jsonException){
                    message = DSALES_Utility.BAD_REQUEST_MSJ;
                    errorCode = DSALES_Utility.BAD_REQUEST_CODE;
                    succes = false;      
                }catch(Exception e){
                    //ver error en la linea message = e.getMessage()+'Linea: '+e.getLineNumber();
                    message = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    message = e.getMessage()+'Linea: '+e.getLineNumber();
                    errorCode = DSALES_Utility.INTERNAL_ERROR_CODE;
                    succes = false;
                }
            }
        }
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = new DSALES_QuoteSmWrapper.RespuestaParaNpv();
        response.mensaje =  message;
        response.codigoError = errorCode;
        response.success = succes;
        response.idCotizacion = cotiza.Id;
        response.idOportunidad = oppor.Id;
        //response.TrackingId = respuestaDeProveedor.tracking_id; 
        response.listaNegra = listaNegra;
        response.listaSeguros = plazos;
        if(data.sku!=null && data.sku!=''){
            response.listaproducto = moto;
            response.campanias = buscaCampanias(data.sku);       
        }
        return response;
    }
    public static List<DSALES_QuoteSmWrapper.Campanias> buscaCampanias(String sku){
        List<DSALES_QuoteSmWrapper.Campanias> listaCampanias = new List<DSALES_QuoteSmWrapper.Campanias>();
        try{
            Product2 productoMoto = [SELECT Id, Name, StockKeepingUnit, dsalesSeguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku WITH SECURITY_ENFORCED LIMIT 1];
            List<DSALES_AsociacionCampanias__c> lista = [SELECT Name, DSALES_Campania__c, dsalesProducto__c FROM DSALES_AsociacionCampanias__c WHERE dsalesProducto__c =:productoMoto.Id WITH SECURITY_ENFORCED];
            for(DSALES_AsociacionCampanias__c item:lista){
                Campaign aux = [SELECT Name, dsalesTipoCampana__c, Description FROM Campaign WHERE Id =: item.DSALES_Campania__c WITH SECURITY_ENFORCED];
                DSALES_QuoteSmWrapper.Campanias aux2 = new DSALES_QuoteSmWrapper.Campanias();
                aux2.nombre = aux.Name;
                aux2.tipoCampana = aux.dsalesTipoCampana__c;
                aux2.descripcion = aux.Description;
                listaCampanias.add(aux2);
            }
        }catch(Exception e){
            System.debug('No Se encontraron Campanias para el SKU');        
        }    
        return listaCampanias;
    }
    public static List<DSALES_QuoteSmWrapper.Plazo> plazosActivos(String plazoMaximo){
        List<DSALES_QuoteSmWrapper.Plazo> plazosSeguros = new List<DSALES_QuoteSmWrapper.Plazo>();
        List<Plazo__c> lista;
        try{
            Product2 seguro = [SELECT Id, Name, StockKeepingUnit, dsalesSeguro__c, DSales_Articulo__c FROM Product2 WHERE Name=:rc WITH SECURITY_ENFORCED LIMIT 1];
            lista = [SELECT Name, dsalesPlazo__c, dsalesSeguro__c FROM Plazo__c WHERE dsalesPlazo__c<=:plazoMaximo AND dsalesActivo__c = true AND dsalesSeguro__c =:seguro.Id WITH SECURITY_ENFORCED];        
            for(Plazo__c item:lista){
                DSALES_QuoteSmWrapper.Plazo aux = new DSALES_QuoteSmWrapper.Plazo();
                aux.paquete = seguro.Name;
                //aux.plazo = item.dsalesPlazo__c;
                aux.opcionPago = 'A';
                plazosSeguros.add(aux);            
            }
            seguro = [SELECT Id, Name, StockKeepingUnit, dsalesSeguro__c, DSales_Articulo__c FROM Product2 WHERE Name=:amp WITH SECURITY_ENFORCED LIMIT 1];
            lista = [SELECT dsalesPlazo__c, dsalesSeguro__c FROM Plazo__c WHERE dsalesPlazo__c<=:plazoMaximo AND dsalesActivo__c = true AND dsalesSeguro__c =:seguro.Id WITH SECURITY_ENFORCED];
            for(Plazo__c item:lista){
  			   	DSALES_QuoteSmWrapper.Plazo aux = new DSALES_QuoteSmWrapper.Plazo();
               	aux.paquete = seguro.Name;
               	aux.opcionPago = item.dsalesPlazo__c+'M';
               	plazosSeguros.add(aux);              
            }
        }
        catch(Exception e){
            System.debug('No Se encontraron plazos con las condiciones');        
        }
        return plazosSeguros;
    }
    
    public static DSALES_QuoteSmWrapper.respuestaDelProveedor crearQuoteSm(DSALES_QuoteSmWrapper.QuotePostProvedor obj){
        String body = JSON.serialize(obj);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = DSALES_Utility.getEndpoint(NOMBRE_SERVICIO);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
            DSALES_QuoteSmWrapper.respuestaDelProveedor respuesta = (DSALES_QuoteSmWrapper.respuestaDelProveedor) JSON.deserialize(response.getbody(), DSALES_QuoteSmWrapper.respuestaDelProveedor.class);
            return respuesta;     
        }else{
            System.debug('___Fallo____: comuncacion: ' + response.getBody());
            return null;
        }     
    }

    public static Account creaCliente (DSALES_QuoteSmWrapper.QuoteSmRequest data){
        Account cliente = new Account();
        cliente.CP_WalletCustomerNumber__c = Decimal.valueOf(data.numeroCliente);
        cliente.FirstName = data.nombre;
        cliente.LastName = data.apellidoPaterno;
        cliente.Suffix = data.apellidoMaterno;
        cliente.PersonBirthdate = data.fechaNacimiento;
        cliente.PersonEmail = data.correoElectronico;
        cliente.AccountNumber = data.numeroCliente;
        cliente.PersonMobilePhone = data.telefonoCelular;
        if(Schema.sObjectType.Account.isCreateable())
        {
            insert cliente;
        }
       
        return cliente;
    }

    public static Opportunity creaOportunidad (DSALES_QuoteSmWrapper.QuoteSmRequest data, Id clienteId, String firstName,String suffix, String lastName,Tienda__c tienda){
        Opportunity oppor = new Opportunity();
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seguro de Moto').getRecordTypeId();
        Pricebook2 precioLista = [SELECT id,Name FROM Pricebook2 WHERE Name= 'Standard Price Book' and IsActive=true WITH SECURITY_ENFORCED LIMIT 1];
        oppor.AccountId = clienteId;
        oppor.Name = firstName;
        if(data.apellidoMaterno != null ){
            oppor.Name+=' ' +data.apellidoMaterno;
        }
        oppor.Name+=' '+lastName;
        oppor.CloseDate = date.today()+30;
        oppor.StageName = 'Nuevo';
        oppor.RecordTypeId = recordTypeId;
        oppor.dsalesTienda__c = tienda.Id;
        oppor.Pricebook2Id = precioLista.Id;
        if(Schema.sObjectType.Opportunity.isCreateable())
        {
            insert oppor;        
        }
        return oppor;
    }
    
    public static Quote crearCotizacion (DSALES_QuoteSmWrapper.QuoteSmRequest data, Id oportunidadId, String firstName,String suffix, String lastName, Tienda__c tienda, Boolean listaNegra){
        Quote cotiza = new Quote();
        String recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Venta de Seguro de Motos').getRecordTypeId();
        cotiza.Name = firstName;
        if(data.apellidoMaterno != null ){
            cotiza.Name+=' '+data.apellidoMaterno + ' '+lastName;
        }
        else{
            cotiza.Name+= ' '+lastName;
        }
        dsalesTipoUso__c tipoUso = [Select Id from dsalesTipoUso__c WHERE Name =:data.tipoUso WITH SECURITY_ENFORCED LIMIT 1];
        DSALES_Tipodevehculo__c tipoVehiculo = [Select Id from DSALES_Tipodevehculo__c WHERE Name =: data.tipoVehiculo WITH SECURITY_ENFORCED LIMIT 1];
        cotiza.OpportunityId = oportunidadId;
        //cotiza.DSALES_FormadePago__c = data.method_payment;
        cotiza.DSales_ID_Tienda__c = data.idTienda;
        cotiza.DSales_Tienda__c = tienda.Id;
        cotiza.ExpirationDate = date.today()+30;
        cotiza.RecordTypeId = recordTypeId;
        date aux = date.today();
        cotiza.DSALES_Fechadecreacionpresupuesto__c = date.newInstance(aux.year(), aux.month(), aux.day());
        cotiza.dsalesListaNegra__c = listaNegra;
        cotiza.dsalesMotivoDeListaNegra__c= 'Sin Definir';
        cotiza.Phone = data.telefonoCelular;
        cotiza.DSALES_Fechadenacimiento__c = data.fechaNacimiento;
        cotiza.dsalesCodigoPostal__c = data.codigoPostal;
        cotiza.dsalesIdDeVehiculo__c = data.idVehiculo;
        cotiza.dsalesOpcionDePago__c = data.opcionPago;
        cotiza.DSALES_Cobertura__c = '';
        cotiza.DSales_Vendedor__c = data.nombreVendedor;
        cotiza.dsalesGenero__c = data.generoContacto;
        cotiza.dsalesFechaDeComienzoDePoliza__c = data.fechaInicio;
        cotiza.Email = data.correoElectronico;
        cotiza.DSALES_TipoUso__c = tipoUso.Id;
        cotiza.dsalesTipoDeVehiculo__c = tipoVehiculo.Id;
        cotiza.DSALES_RFC__c = data.rfc;
        cotiza.DSALES_Plazoacotizar__c= decimal.valueOf(data.plazoCotizar);
        
        if(Schema.sObjectType.Quote.isCreateable())
        {
            insert cotiza;        
        }
        
        return cotiza;
    }
    
    public static QuoteLineItem creaPartida(String seguro, Quote cotiza, DSALES_QuoteSmWrapper.ArmadoMuleSoft data, String sku){
            Product2 producto = [SELECT Id, Name, StockKeepingUnit, dsalesSeguro__c, DSales_Articulo__c FROM Product2 WHERE Name=:seguro WITH SECURITY_ENFORCED LIMIT 1];
            PricebookEntry precio = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id =:producto.Id LIMIT 1];
        	Plazo__c plazo = [SELECT Id, Name, dsalesActivo__c, DSALES_Seguro__r.Name FROM Plazo__c WHERE DSALES_Seguro__r.Name =:seguro AND Name=:data.plazo AND dsalesActivo__c = true WITH SECURITY_ENFORCED];     	
        	QuoteLineItem partida = new QuoteLineItem();
            partida.QuoteId = cotiza.Id;
            partida.PricebookEntryId = precio.Id;
            partida.Product2Id = precio.Product2Id;
            partida.Quantity = 1;
            partida.UnitPrice = precio.UnitPrice;
            partida.DSALES_Fechadeinicio__c = Date.valueOf(data.data.recibos[0].fechaInicio);
            partida.DSALES_Fechadetermino__c = Date.valueOF(data.data.recibos[0].fechaTermino);
            partida.DSALES_Primaneta__c = decimal.valueOf(data.data.primaSeguro.primaNeta);
            partida.UnitPrice = decimal.valueOf(data.data.recibos[0].primaTotal);
            partida.dsalesDerechosDePoliza__c = decimal.valueOf(data.data.primaSeguro.derecho);
            partida.dsalesGastosDeOperacionDelRecibo__c = decimal.valueOf(data.data.primaSeguro.recargo);
            partida.DSALES_Impuestos__c = decimal.valueOf(data.data.primaSeguro.impuestos);
            partida.DSALES_TrackingID__c = data.trackingId;
        	partida.dsalesPlazo__c = plazo.Id;
        	partida.DSALES_Comision__c = decimal.valueOf(data.data.primaSeguro.comision);
            partida.DSALES_Recargos__c = decimal.valueOf(data.data.recibos[0].recargo);
        	partida.DSALES_Descripcion__c='Esta cobertura ampara la responsabilidad civil por el tránsito de vehículos en territorio nacional, en que incurra el Asegurado o cualquier persona que con consentimiento del Asegurado use o posea el vehículo descrito en la Póliza con el límite de responsabilidad establecido en la misma, siempre que a consecuencia de dicho uso o posesión, cause a Terceros daños materiales en sus bienes, lesiones corporales, incapacidades temporales y/o permanentes o la muerte, distintos de los ocupantes de dicho vehículo, que considera la Responsabilidad Civil a que se refiere el artículo 63 Bis de la Ley de Caminos, Puentes y Autotransporte Federal.';
            partida.DSALES_Descripcion__c = Coberturas(data.data.listaCoberturas);
        	partida.DSALES_Segurogratis__c = Campana(producto.Name, sku);
            return partida;
    }
    public static String coberturas(List<DSALES_QuoteSmWrapper.CoveragesArray> coberturas){
        String body='';
        for(DSALES_QuoteSmWrapper.CoveragesArray item: coberturas){
            body+=', '+item.nombre;
        }
        return body;
    }

    public static Boolean campana2(String seguro, String tipo, String sku){
        Boolean condicion = false;  
        if(sku!=null && sku!=''){
            Product2 producto = [SELECT Id, Name, StockKeepingUnit, dsalesSeguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku WITH SECURITY_ENFORCED LIMIT 1];
            List <DSALES_AsociacionCampanias__c> listaCampanas = [SELECT Name, DSALES_Campania__c, dsalesProducto__c FROM DSALES_AsociacionCampanias__c WHERE dsalesProducto__c =:producto.Id WITH SECURITY_ENFORCED];
            for(DSALES_AsociacionCampanias__c asoCampana:listaCampanas){         
                //Campaign aux = [SELECT Id, Name, IsActive, dsalesTipoCampana__c FROM Campaign WHERE Name=:VALOR];             
                Campaign aux = [SELECT Id, Name, IsActive, dsalesTipoCampana__c FROM Campaign WHERE Id=:asoCampana.DSALES_Campania__c WITH SECURITY_ENFORCED];             
                if(aux!=null){
                    if(aux.IsActive==true && aux.dsalesTipoCampana__c==tipo){
                        condicion = true;           
                    }
                }  
        	}         
        }  
        return condicion;
    }
    
    public static Boolean campana(String seguro,String sku){
        Boolean condicion = false;  
        if(sku!=null && sku!=''){
            Product2 producto = [SELECT Id, Name, StockKeepingUnit,DSales_Tipo_de_Producto__c, dsalesSeguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku WITH SECURITY_ENFORCED LIMIT 1];        
            if(seguro == rc){               
            	List <DSALES_AsociacionCampanias__c> listaCampanas = [SELECT Name, DSALES_Campania__c, dsalesProducto__c,dsalesActivo__c FROM DSALES_AsociacionCampanias__c WHERE dsalesProducto__c =:producto.Id AND dsalesActivo__c=true WITH SECURITY_ENFORCED];
                for(DSALES_AsociacionCampanias__c asoCampana:listaCampanas){                   
                	Campaign aux = [SELECT Id, Name, IsActive, dsalesTipoCampana__c FROM Campaign WHERE Id=:asoCampana.DSALES_Campania__c WITH SECURITY_ENFORCED];             
                    if(aux!=null){
                        if(aux.Name == VALOR && aux.Id== asoCampana.DSALES_Campania__c && aux.IsActive==true && aux.dsalesTipoCampana__c==tipo){
                            condicion = true;           
                        }
                    }    
        		}
            }
        }  
        return condicion;
    }
    public static DSALES_QuoteSmWrapper.RespuestaPlazos creaPartidaM(Quote cotiza, String sku, Boolean listaNegra, String precio){      
        DSALES_QuoteSmWrapper.RespuestaPlazos motoVacia = new DSALES_QuoteSmWrapper.RespuestaPlazos();
        if(sku!=null && sku!='' && listaNegra!=true){
            Product2 productoMoto = [SELECT Id, Name, StockKeepingUnit, dsalesSeguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku WITH SECURITY_ENFORCED LIMIT 1];
        	PricebookEntry precioM = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id =:productoMoto.Id WITH SECURITY_ENFORCED LIMIT 1];
        	QuoteLineItem partidaM = new QuoteLineItem();
            partidaM.QuoteId = cotiza.Id;
            partidaM.PricebookEntryId = precioM.Id;
            partidaM.Product2Id = precioM.Product2Id;
            partidaM.Quantity = 1;
            partidaM.UnitPrice = decimal.valueOf(precio);
            partidaM.DSALES_Segurogratis__c = Campana(rc, sku);
            DSALES_QuoteSmWrapper.RespuestaPlazos aux = new DSALES_QuoteSmWrapper.RespuestaPlazos(); 
            aux.paquete = productoMoto.Name;
            if(Schema.sObjectType.QuoteLineItem.isCreateable())
            {
                insert partidaM;
            }
            DSALES_QuoteSmWrapper.RespuestaPlazos moto = new DSALES_QuoteSmWrapper.RespuestaPlazos();
            moto.paquete = productoMoto.Name;
            moto.idpartida = partidaM.Id;
            return moto;
        }
        else {
            return motoVacia;
        }   
    }
    
    public static List<DSALES_QuoteSmWrapper.RespuestaPlazos> creaPlazos(Quote cotiza, List<DSALES_QuoteSmWrapper.ArmadoMuleSoft> plazos, String sku,Boolean listaNegra){
        List<QuoteLineItem> listaPartidas = new List<QuoteLineItem>();
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> listaSeguros = new List<DSALES_QuoteSmWrapper.RespuestaPlazos>();
        for(Integer i=0; i<plazos.size(); i++){
            listaPartidas.add(creaPartida(plazos[i].nombre, cotiza, plazos[i],sku));
            DSALES_QuoteSmWrapper.RespuestaPlazos aux = new DSALES_QuoteSmWrapper.RespuestaPlazos();
            aux.trackingId = plazos[i].trackingId;
            aux.paquete = plazos[i].nombre;
            aux.vigencia = plazos[i].plazo;
            //aux.costos = traduccion(plazos[i].data.receipts[0]);
            aux.data = plazos[i].data;
            listaSeguros.add(aux);
        }
        insert listaPartidas;
        for(Integer i=0; i<listaPartidas.size() ; i++){
            listaSeguros[i].idpartida = listaPartidas[i].Id;
            listaSeguros[i].descripcion = listaPartidas[i].DSALES_Descripcion__c;
            listaSeguros[i].seguroGratis = listaPartidas[i].DSALES_Segurogratis__c;

        }
        return listaSeguros;     
    }
}