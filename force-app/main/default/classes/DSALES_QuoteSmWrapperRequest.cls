@RestResource(urlMapping='/insertQuoteSM/*')
global class DSALES_QuoteSmWrapperRequest {
    public static final String NOMBRE_SERVICIO = 'DSALES_QuoteSM';
    public static final String valor = 'RC'; //nombre campaña
    public static final String tipo = 'Seguro gratis'; //tipo de campaña
    public static final String rc = 'RC Seguro de Moto';
    public static final String amp = 'AMP Seguro de Moto';
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
                    String nombreCompleto=data.first_name;
                    if(data.middle_name!=null){
                        nombreCompleto += ' ' +data.middle_name;  
                      }
                      nombreCompleto += ' ' +data.last_name; 
                      if(data.suffix!=null){
                        nombreCompleto += ' ' +data.suffix;  
                      } 
                    String rfc = DSALES_ConsultaListaNegra.getRFC(data.first_name, data.middle_name, data.last_name, data.suffix, data.contact_birth_date);
                    respuestaListaNegra = DSALES_ConsultaListaNegra.callWebService(rfc, nombreCompleto);
                    System.debug('respuesta de la lista negra:  '+respuestaListaNegra);
                    if(respuestaListaNegra.estatus =='true'){
                        listaNegra = true;
                        message = 'Esta en la Lista negra';
                    }            
                    DSALES_QuoteSmWrapper.QuotePostProvedor datosEnviar = new DSALES_QuoteSmWrapper.QuotePostProvedor();
                    if(data.sku!=''){
                        Product2 temporal = [SELECT Id,DSALES_vehculo__c, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:data.sku LIMIT 1];
                        data.vehicle_id=temporal.DSALES_vehculo__c;  
                    }
                    datosEnviar.business = Label.DSALES_business;
                    datosEnviar.insurance = Label.DSALES_NombreAseguradora; //sales-fijo
                    datosEnviar.contact_name = data.first_name + data.last_name;//combinacion
                    datosEnviar.contact_method = Label.DSALES_ContactMethod;//sales-fijo
                    datosEnviar.contact_phone = data.contact_phone;
                    datosEnviar.contact_email = data.contact_email;
                    datosEnviar.contact_gender = data.contact_gender;
                    datosEnviar.contact_birth_date = data.contact_birth_date.format();
                    datosEnviar.contact_state_code = data.contact_state_code;
                    datosEnviar.contact_township_code = data.contact_township_code;
                    datosEnviar.contact_suburb_code = data.contact_suburb_code;
                    datosEnviar.contact_zip_code = data.contact_zip_code;
                    datosEnviar.contact_now = true;//fijo-sales
                    datosEnviar.vehicle_id = data.vehicle_id;
                    datosEnviar.vehicle_service = Label.DSALES_vehicleService;//fijo-sales
                    datosEnviar.vehicle_use = data.vehicle_use; //Nuevo
                    datosEnviar.vehicle_type = data.vehicle_type; //Nuevo
                    datosEnviar.plazo = data.plazo; //Nuevo hU 001
                    //rfc Nuevo
                    datosEnviar.plazo = data.plazo; //Nuevo
                    //nombre en solo campo
                    datosEnviar.payment_option = data.payment_option;
                    datosEnviar.packagge = '';
                    datosEnviar.promotion_code='No definido';//fijo
                    datosEnviar.associate_id='No definido';//fijo
                    date aux = date.today();
                    aux = date.newInstance(aux.year(), aux.month(), aux.day());
                    datosEnviar.quote_date = aux.format(); //cotiza.DSALES_Fechadecreacionpresupuesto__c.format();//fecha creacion-sales
                    datosEnviar.start_at = data.start_at.format(); //Nuevo revisar
                    datosEnviar.listaPlazos = plazosActivos(data.plazo);
                    if(!listaNegra){
                        respuestaDeProveedor = crearQuoteSm(datosEnviar);
                    }
  
                    Account UniversalAccount = [Select Id from Account WHERE DSALES_ClienteCoppel__c = :numeroCliente LIMIT 1];
                    Tienda__c tienda = [Select Id from Tienda__c WHERE DSales_TiendaID__c =: data.store_id LIMIT 1];
                    Id ClienteId=null; 
                    if(data.client_number == null || data.client_number=='' ||data.client_number==numeroCliente ){
                        List<Account> resul = [Select Id, FirstName, MiddleName, LastName, Fecha_de_Nacimiento__c, Phone, PersonEmail from Account WHERE FirstName=:data.first_name AND MiddleName=:data.middle_name AND LastName=:data.last_name];
                        if(resul.size() == 1){
                            ClienteId = resul[0].Id;
                            oppor = creaOportunidad(data, ClienteId, resul[0].FirstName, resul[0].MiddleName, resul[0].LastName,tienda);
                            cotiza = crearCotizacion(data, oppor.Id, resul[0].FirstName,  resul[0].MiddleName, resul[0].LastName, tienda,listaNegra);
                            plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos, data.sku,listaNegra); 
                            moto = creaPartidaM(cotiza,data.sku,listaNegra);
                        }
                        else{
                            Boolean SinCoincidenciaCuenta = true;
                            if(resul.size() > 1){                
                                for(Account CuentaSimilare: resul){
                                    if(CuentaSimilare.PersonEmail == data.contact_email || CuentaSimilare.Phone == data.contact_phone){
                                        ClienteId = CuentaSimilare.Id;
                                        SinCoincidenciaCuenta = false;
                                        oppor = creaOportunidad(data, ClienteId, data.first_name, data.middle_name, data.last_name, tienda);
                                        cotiza = crearCotizacion(data, oppor.Id, data.first_name, data.middle_name, data.last_name, tienda,listaNegra);
                                        plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra);                                       
                                        moto = creaPartidaM(cotiza,data.sku,listaNegra);
                                        break;
                                    }
                                }                         
                            }
                            if(resul.size() == 0 || SinCoincidenciaCuenta==true){
                                ClienteId = UniversalAccount.Id; 
                                oppor = creaOportunidad(data, ClienteId, data.first_name, data.middle_name, data.last_name, tienda);
                                cotiza = crearCotizacion(data, oppor.Id, data.first_name, data.middle_name, data.last_name, tienda,listaNegra);
                                plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra);
                                moto = creaPartidaM(cotiza,data.sku,listaNegra);
                            }
                        }     
                    }else{
                            List<Account> result = [Select Id,FirstName,MiddleName,LastName from Account WHERE CP_WalletCustomerNumber__c =:Decimal.valueOf(data.client_number)];
                            if(result.size() == 0){
                                client = creaCliente(data);
                                ClienteId = client.Id;
                                oppor = creaOportunidad(data, ClienteId, data.first_name, data.middle_name, data.last_name,tienda);
                                cotiza = crearCotizacion(data, oppor.Id, client.FirstName,  client.MiddleName, client.LastName, tienda,listaNegra);
                                plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra);
                                moto = creaPartidaM(cotiza,data.sku,listaNegra);
                            }else{
                                ClienteId = result[0].Id;
                                oppor = creaOportunidad(data, ClienteId, result[0].FirstName, result[0].MiddleName, result[0].LastName,tienda);
                                cotiza = crearCotizacion(data, oppor.Id, result[0].FirstName,  result[0].MiddleName, result[0].LastName, tienda,listaNegra);
                                plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra);
                                moto = creaPartidaM(cotiza,data.sku,listaNegra);
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
        //llama a inter con datos
        
        
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = new DSALES_QuoteSmWrapper.RespuestaParaNpv();
        response.message =  message;
        response.errorCode = errorCode;
        response.success = succes;
        response.quoteId = cotiza.Id;
        //response.TrackingId = respuestaDeProveedor.tracking_id;
        response.listaNegra = listaNegra;
        //response.plazos = new List<DSALES_QuoteSmWrapper.RespuestaPlazos>();
        response.listaSeguros = plazos;
        if(data.sku!=null && data.sku!=''){
            response.listaproducto = moto;
            response.campanias = buscaCampanias(data.sku);       
        }
        //response.amp = new DSALES_QuoteSmWrapper.Receipt();
        try{
            if(!listaNegra && (respuestaListaNegra!= null) && (respuestaDeProveedor!= null)){
                System.debug('Respuesta Proveedor____: ' + respuestaDeProveedor.plazos[0].data.receipts[0]);    
                //response.rc = respuestaDeProveedor.data.receipts[0];
                //response.amp = respuestaDeProveedor2.data.receipts[0];
        	}        
        }catch(Exception e){
            message = DSALES_Utility.INTERNAL_ERROR_MSJ;
            errorCode = DSALES_Utility.INTERNAL_ERROR_CODE;
            succes = false;
        }
        return response;
    }
    public static List<DSALES_QuoteSmWrapper.Campanias> buscaCampanias(String sku){
        List<DSALES_QuoteSmWrapper.Campanias> listaCampanias = new List<DSALES_QuoteSmWrapper.Campanias>();
        Product2 productoMoto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku LIMIT 1];
        List<DSALES_AsociacionCampanias__c> lista = [SELECT Name, DSALES_Campania__c, DSALES_Producto__c FROM DSALES_AsociacionCampanias__c WHERE DSALES_Producto__c =:productoMoto.Id];
        for(DSALES_AsociacionCampanias__c item:lista){
            Campaign aux = [SELECT Name, DSALES_Tipodecapana__c, Description FROM Campaign WHERE Id =: item.DSALES_Campania__c];
            DSALES_QuoteSmWrapper.Campanias aux2 = new DSALES_QuoteSmWrapper.Campanias();
            aux2.nombre = aux.Name;
            aux2.tipoCampana = aux.DSALES_Tipodecapana__c;
            aux2.descripcion = aux.Description;
            listaCampanias.add(aux2);
        }     
        return listaCampanias;
    }
    public static List<DSALES_QuoteSmWrapper.Plazo> plazosActivos(String plazoMaximo){
        List<DSALES_QuoteSmWrapper.Plazo> plazosSeguros = new List<DSALES_QuoteSmWrapper.Plazo>();
        List<Plazo__c> lista;
        try{
            Product2 seguro = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Name=:rc LIMIT 1];
            lista = [SELECT Name, Dsales_Plazo__c, DSALES_Seguro__c FROM Plazo__c WHERE Dsales_Plazo__c<=:plazoMaximo AND DSALES_Activo__c = true AND DSALES_Seguro__c =:seguro.Id];        
            for(Plazo__c item:lista){
                DSALES_QuoteSmWrapper.Plazo aux = new DSALES_QuoteSmWrapper.Plazo();
                aux.producto = seguro.Name;
                aux.plazo = item.Dsales_Plazo__c;
                plazosSeguros.add(aux);             
            }
            seguro = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Name=:amp LIMIT 1];
            lista = [SELECT Dsales_Plazo__c, DSALES_Seguro__c FROM Plazo__c WHERE Dsales_Plazo__c<=:plazoMaximo AND DSALES_Activo__c = true AND DSALES_Seguro__c =:seguro.Id];
            for(Plazo__c item:lista){
  			   	DSALES_QuoteSmWrapper.Plazo aux = new DSALES_QuoteSmWrapper.Plazo();
               	aux.producto = seguro.Name;
               	aux.plazo = item.Dsales_Plazo__c;
               	plazosSeguros.add(aux);              
            }
        }
        catch(Exception e){
            System.debug('No Se encontraron plazos con las condiciones');        
        }
        //List<>
        return plazosSeguros;
    }
    
    public static DSALES_QuoteSmWrapper.respuestaDelProveedor crearQuoteSm(DSALES_QuoteSmWrapper.QuotePostProvedor obj){
        String body = JSON.serialize(obj);
        System.debug('Campos se envian: '+ body);
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
        cliente.CP_WalletCustomerNumber__c = Decimal.valueOf(data.client_number);
        cliente.FirstName = data.first_name;
        cliente.MiddleName = data.middle_name;
        cliente.LastName = data.last_name;
        cliente.Suffix = data.suffix;
        cliente.PersonBirthdate = data.contact_birth_date;
        cliente.PersonEmail = data.contact_email;
        cliente.AccountNumber = data.client_number;
        cliente.PersonMobilePhone = data.contact_phone;
        insert cliente;
        return cliente;
    }

    public static Opportunity creaOportunidad (DSALES_QuoteSmWrapper.QuoteSmRequest data, Id clienteId, String FirstName,String MiddleName, String LastName,Tienda__c tienda){
        Opportunity oppor = new Opportunity();
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seguro de Moto').getRecordTypeId();
        Pricebook2 precioLista = [SELECT id,Name FROM Pricebook2 WHERE Name= 'Standard Price Book' and IsActive=true LIMIT 1];
        oppor.AccountId = clienteId;
        oppor.Name = FirstName;
        if(MiddleName != null ){
            oppor.Name+=' ' +MiddleName+' '+LastName;
        }else{
            oppor.Name+=' '+LastName;
        }
        if(data.suffix != null ){
            oppor.Name+=' ' +data.suffix;
        }
        oppor.CloseDate = date.today()+30;
        oppor.StageName = 'Nuevo';
        oppor.RecordTypeId = recordTypeId;
        oppor.DSALES_Tiend__c = tienda.Id;
        oppor.Pricebook2Id = precioLista.Id;
        insert oppor;
        return oppor;
    }
    
    public static Quote crearCotizacion (DSALES_QuoteSmWrapper.QuoteSmRequest data, Id oportunidadId, String FirstName,String MiddleName, String LastName, Tienda__c tienda, Boolean listaNegra){
        Quote cotiza = new Quote();
        String recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Venta de Seguro de Motos').getRecordTypeId();
        cotiza.Name = FirstName;
        if(MiddleName != null ){
            cotiza.Name+=' ' +MiddleName+' '+LastName;
        }else{
            cotiza.Name+=' '+LastName;
        }
        if(data.suffix != null ){
            cotiza.Name+=' ' +data.suffix;
        }
        DSALES_TipodeUso__c tipoUso = [Select Id from DSALES_TipodeUso__c WHERE Name =:data.vehicle_use LIMIT 1];
        DSALES_Tipodevehculo__c tipoVehiculo = [Select Id from DSALES_Tipodevehculo__c WHERE Name =: data.vehicle_type LIMIT 1];
        cotiza.OpportunityId = oportunidadId;
        //cotiza.DSALES_FormadePago__c = data.method_payment;
        cotiza.DSales_ID_Tienda__c = data.store_id;
        cotiza.DSales_Tienda__c = tienda.Id;
        cotiza.ExpirationDate = date.today()+7;
        cotiza.RecordTypeId = recordTypeId;
        date aux = date.today();
        cotiza.DSALES_Fechadecreacionpresupuesto__c = date.newInstance(aux.year(), aux.month(), aux.day());
        cotiza.Lista_negra__c = listaNegra;
        cotiza.Motivo_de_lista_negra__c= 'Sin Definir';
        cotiza.Phone = data.contact_phone;
        cotiza.DSALES_Fechadenacimiento__c = data.contact_birth_date;
        cotiza.DSALES_Cdigodeestado__c = data.contact_state_code;
        cotiza.DSALES_Cdigodemunicipio__c = data.contact_township_code;
        cotiza.DSALES_Suburbcode__c = decimal.valueOf(data.contact_suburb_code);
        cotiza.DSALES_Cdigopostal__c = data.contact_zip_code;
        cotiza.DSALES_IDdelvehculo__c = data.vehicle_id;
        cotiza.DSALES_Opcindepago__c = data.payment_option;
        cotiza.DSALES_Cobertura__c = '';
        cotiza.DSales_Vendedor__c = data.vendedor;
        cotiza.DSALES_Gnero__c = data.contact_gender;
        cotiza.DSALES_Fechadecomienzodepliza__c = data.start_at;
        cotiza.Email = data.contact_email;
        cotiza.DSALES_TipoUso__c = tipoUso.Id;
        cotiza.DSALES_Tipodeveihculo__c = tipoVehiculo.Id;
        cotiza.DSALES_RFC__c = data.rfc;
        cotiza.DSALES_Plazoacotizar__c= decimal.valueOf(data.plazo);
        insert cotiza;
        return cotiza;
    }
    
    public static QuoteLineItem creaPartida(String seguro, Quote cotiza, DSALES_QuoteSmWrapper.ArmadoMuleSoft data, String sku){
            Product2 producto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Name=:seguro LIMIT 1];
            PricebookEntry precio = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id =:producto.Id LIMIT 1];
        	Plazo__c plazo = [SELECT Id, Name, DSALES_Activo__c, DSALES_Seguro__r.Name FROM Plazo__c WHERE DSALES_Seguro__r.Name =:seguro AND Name=:data.plazo AND DSALES_Activo__c = true];     	
        	QuoteLineItem partida = new QuoteLineItem();
            partida.QuoteId = cotiza.Id;
            partida.PricebookEntryId = precio.Id;
            partida.Product2Id = precio.Product2Id;
            partida.Quantity = 1;
            partida.UnitPrice = precio.UnitPrice;
            partida.DSALES_Fechadeinicio__c = Date.valueOf(data.data.receipts[0].start_date);
            partida.DSALES_Fechadetermino__c = Date.valueOF(data.data.receipts[0].end_date);
            partida.DSALES_Primaneta__c = decimal.valueOf(data.data.insurance_premium.net_premium);
            partida.UnitPrice = decimal.valueOf(data.data.receipts[0].total_premium);
            partida.DSALES_Derechosdepliza__c = decimal.valueOf(data.data.insurance_premium.right);
            partida.DSALES_Gastosdeoperacindelrecibo__c = decimal.valueOf(data.data.insurance_premium.surcharge);
            partida.DSALES_Impuestos__c = decimal.valueOf(data.data.insurance_premium.tax);
            partida.DSALES_TrackingID__c = data.tracking_id;
        	partida.DSALES_Plazo__c = plazo.Id;
        	partida.DSALES_Comision__c = decimal.valueOf(data.data.insurance_premium.commission);
            partida.DSALES_Recargos__c = decimal.valueOf(data.data.receipts[0].recharge);
        	partida.DSALES_Descripcion__c='Esta cobertura ampara la responsabilidad civil por el tránsito de vehículos en territorio nacional, en que incurra el Asegurado o cualquier persona que con consentimiento del Asegurado use o posea el vehículo descrito en la Póliza con el límite de responsabilidad establecido en la misma, siempre que a consecuencia de dicho uso o posesión, cause a Terceros daños materiales en sus bienes, lesiones corporales, incapacidades temporales y/o permanentes o la muerte, distintos de los ocupantes de dicho vehículo, que considera la Responsabilidad Civil a que se refiere el artículo 63 Bis de la Ley de Caminos, Puentes y Autotransporte Federal.';
        	partida.DSALES_Segurogratis__c = Campana(producto.Name, sku);
            return partida;
    }
    public static Boolean Campana2(String seguro, String tipo, String sku){
        Boolean condicion = false;  
        if(sku!=null && sku!=''){
            Product2 producto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku LIMIT 1];
            List <DSALES_AsociacionCampanias__c> listaCampanas = [SELECT Name, DSALES_Campania__c, DSALES_Producto__c FROM DSALES_AsociacionCampanias__c WHERE DSALES_Producto__c =:producto.Id];
            for(DSALES_AsociacionCampanias__c asoCampana:listaCampanas){         
                //Campaign aux = [SELECT Id, Name, IsActive, DSALES_Tipodecapana__c FROM Campaign WHERE Name=:valor];             
                Campaign aux = [SELECT Id, Name, IsActive, DSALES_Tipodecapana__c FROM Campaign WHERE Id=:asoCampana.DSALES_Campania__c];             
                if(aux!=null){
                    if(aux.IsActive==true && aux.DSALES_Tipodecapana__c==tipo){
                        condicion = true;           
                    }
                }  
        	}         
        }  
        return condicion;
    }
    
    public static Boolean Campana(String seguro,String sku){
        Boolean condicion = false;  
        if(sku!=null && sku!=''){
            Product2 producto = [SELECT Id, Name, StockKeepingUnit,DSales_Tipo_de_Producto__c, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku LIMIT 1];        
            if(seguro == rc){               
            	List <DSALES_AsociacionCampanias__c> listaCampanas = [SELECT Name, DSALES_Campania__c, DSALES_Producto__c,DSALES_Activo__c FROM DSALES_AsociacionCampanias__c WHERE DSALES_Producto__c =:producto.Id AND DSALES_Activo__c=true];
                for(DSALES_AsociacionCampanias__c asoCampana:listaCampanas){                   
                	Campaign aux = [SELECT Id, Name, IsActive, DSALES_Tipodecapana__c FROM Campaign WHERE Id=:asoCampana.DSALES_Campania__c];             
                    if(aux!=null){
                        if(aux.Name == valor && aux.Id== asoCampana.DSALES_Campania__c && aux.IsActive==true && aux.DSALES_Tipodecapana__c==tipo){
                            condicion = true;           
                        }
                    }    
        		}
            }
        }  
        return condicion;
    }
    public static DSALES_QuoteSmWrapper.RespuestaPlazos creaPartidaM(Quote cotiza, String sku, Boolean ListaNegra){      
        DSALES_QuoteSmWrapper.RespuestaPlazos motoVacia = new DSALES_QuoteSmWrapper.RespuestaPlazos();
        if(sku!=null && sku!='' && ListaNegra!=true){
            Product2 productoMoto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku LIMIT 1];
        	PricebookEntry precioM = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id =:productoMoto.Id LIMIT 1];
        	QuoteLineItem partidaM = new QuoteLineItem();
            partidaM.QuoteId = cotiza.Id;
            partidaM.PricebookEntryId = precioM.Id;
            partidaM.Product2Id = precioM.Product2Id;
            partidaM.Quantity = 1;
            partidaM.UnitPrice = precioM.UnitPrice;
            partidaM.DSALES_Segurogratis__c = Campana(rc, sku);
            DSALES_QuoteSmWrapper.RespuestaPlazos aux = new DSALES_QuoteSmWrapper.RespuestaPlazos(); 
            aux.nombreProducto = productoMoto.Name;
            insert partidaM;
            DSALES_QuoteSmWrapper.RespuestaPlazos moto = new DSALES_QuoteSmWrapper.RespuestaPlazos();
            moto.nombreProducto = productoMoto.Name;
            moto.Idpartida = partidaM.Id;
            //moto.costos = precioM.UnitPrice;
            return moto;
        }
        else {
            return motoVacia;
        }
        
        
    }   
    public static List<DSALES_QuoteSmWrapper.RespuestaPlazos> creaPlazos(Quote cotiza, List<DSALES_QuoteSmWrapper.ArmadoMuleSoft> plazos, String sku,Boolean ListaNegra){
        List<QuoteLineItem> listaPartidas = new List<QuoteLineItem>();
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> listaSeguros = new List<DSALES_QuoteSmWrapper.RespuestaPlazos>();
        for(Integer i=0; i<plazos.size(); i++){
            listaPartidas.add(creaPartida(plazos[i].name, cotiza, plazos[i],sku));
            DSALES_QuoteSmWrapper.RespuestaPlazos aux = new DSALES_QuoteSmWrapper.RespuestaPlazos();
            aux.tracking_id = plazos[i].tracking_id;
            aux.nombreProducto = plazos[i].name;
            aux.vigencia = plazos[i].plazo;
            aux.costos = plazos[i].data.receipts[0];
            listaSeguros.add(aux);
        }
        insert listaPartidas;
        for(Integer i=0; i<listaPartidas.size() ; i++){
            listaSeguros[i].Idpartida = listaPartidas[i].Id;    
        }
        return listaSeguros;     
    }
}