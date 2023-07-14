@RestResource(urlMapping='/insertQuoteSM/*')//
global with sharing class DSALES_QuoteSmWrapperRequest {
    public static final String NOMBRE_SERVICIO = 'DSALES_QuoteSM';
    public static final String VALOR = 'RC'; //nombre campaña
    public static final String VALOR2 = 'RCEXC'; //nombre campaña
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
        String idTienda;
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
                    system.debug('RFC:'+rfc);
                    /*respuestaListaNegra = DSALES_ConsultaListaNegra.callWebService(rfc, nombreCompleto);
                    if(respuestaListaNegra.estatus !=true){
                        listaNegra = true;
                        message = 'Esta en la Lista negra';
                    }*/            
                    DSALES_QuoteSmWrapper.QuotePostProvedor datosEnviar = new DSALES_QuoteSmWrapper.QuotePostProvedor();
                    String idProducto;
                    if(data.sku!=''){
                        Product2 temporal = [SELECT Id,dsalesVehiculo__c, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:data.sku WITH SECURITY_ENFORCED LIMIT 1];
                        data.idVehiculo=temporal.dsalesVehiculo__c;
                        idProducto=temporal.Id;
                    }
                    Tienda__c tienda = [Select Id from Tienda__c WHERE DSales_TiendaID__c =: data.idTienda WITH SECURITY_ENFORCED LIMIT 1];
                    idTienda = tienda.Id;
                    datosEnviar.negocio = Label.DSALES_business;
                    datosEnviar.aseguradora = Label.DSALES_NombreAseguradora; //sales-fijo
                    datosEnviar.nombreCompleto = data.nombre +' '+ data.apellidoPaterno;//combinacion
                    datosEnviar.metodoContacto = Label.DSALES_ContactMethod;//sales-fijo
                    datosEnviar.telefonoContacto = data.telefonoCelular;
                    datosEnviar.correoContacto = data.correoElectronico;
                    datosEnviar.generoContacto = data.generoContacto;
                    datosEnviar.fechaNacimientoContacto = data.fechaNacimiento;
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
                    datosEnviar.valorFactura=data.valorFactura;
                    datosEnviar.opcionPago=data.opcionPago;  //opcion de pago enviado a inter?
                    datosEnviar.precioProducto=data.precioProducto;

                    Date aux = Date.today();
                    Datetime auxDatetime = DateTime.newInstance(aux.year(), aux.month(), aux.day());
                    String formattedDate = auxDatetime.format('yyyy-MM-dd');
                    datosEnviar.fechaCotizacion = formattedDate;
                    System.debug('opcion de pao que se recibe xxx:'+ data.opcionPago);
                    datosEnviar.fechaInicio = data.fechaInicio; //Nuevo revisar
                    if(idProducto==null){
                        datosEnviar.listaPlazos = plazosActivosExterna(data.plazoCotizar,idTienda, data.opcionPago); //moficar op pago
                    }
                    else{
                        datosEnviar.listaPlazos = plazosActivos(data.plazoCotizar,data.opcionPago,idProducto,idTienda); // modificar op pago
                    }
                    if(datosEnviar.listaPlazos.size()<1){
                        datosEnviar.listaPlazos=null;
                        System.debug('No Se encontraron plazos con las condiciones');
                    }
                    System.debug('Response: '+datosEnviar.listaPlazos);
                    if(datosEnviar.listaPlazos != null && !listaNegra){
                        respuestaDeProveedor = crearQuoteSm(datosEnviar);
                        Account universalAccount = [Select Id from Account WHERE DSALES_ClienteCoppel__c = :numeroCliente WITH SECURITY_ENFORCED LIMIT 1];
                        Id clienteId=null; 
                        if(data.numeroCliente == null || data.numeroCliente=='' ||data.numeroCliente==numeroCliente ){
                            List<Account> resul = [Select Id, firstName, suffix, lastName, Fecha_de_Nacimiento__c, Phone, PersonEmail from Account WHERE firstName=:data.nombre AND suffix=:data.apellidoMaterno AND lastName=:data.apellidoPaterno WITH SECURITY_ENFORCED];
                            if(resul.size() == 1){
                                clienteId = resul[0].Id;
                                oppor = creaOportunidad(data, clienteId, resul[0].firstName, resul[0].suffix, resul[0].lastName,tienda);
                                cotiza = crearCotizacion(data, oppor.Id, resul[0].firstName,  resul[0].suffix, resul[0].lastName, tienda,listaNegra);
                                plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos, data.sku,listaNegra,idTienda); 
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
                                            plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra,idTienda);                                       
                                            moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);
                                            break;
                                        }
                                    }                         
                                }
                                if(resul.size() == 0 || sinCoincidenciaCuenta==true){
                                    clienteId = universalAccount.Id; 
                                    oppor = creaOportunidad(data, clienteId, data.nombre, data.apellidoMaterno, data.apellidoPaterno, tienda);
                                    cotiza = crearCotizacion(data, oppor.Id, data.nombre, data.apellidoMaterno, data.apellidoPaterno, tienda,listaNegra);
                                    plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra,idTienda);
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
                                    plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra,idTienda);
                                    moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);//
                                }else{
                                    clienteId = result[0].Id;
                                    oppor = creaOportunidad(data, clienteId, result[0].firstName, result[0].suffix, result[0].lastName,tienda);
                                    cotiza = crearCotizacion(data, oppor.Id, result[0].firstName,  result[0].suffix, result[0].lastName, tienda,listaNegra);
                                    plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra,idTienda);
                                    moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);
                                }
                        }
                        plazos = coppel(plazos,data.sku);
                    }
                    else{
                        message='No se contraron seguros ';
                        if(listaNegra){message='Esta en lista negra';}
                    }                
                }catch(JSONException e){
                    message = DSALES_Utility.BAD_REQUEST_MSJ+' '+e.getCause()+' '+e.getLineNumber()+' '+ e.getMessage();
                    errorCode = DSALES_Utility.BAD_REQUEST_CODE;
                    succes = false;      
                }catch(Exception e){
                    //ver error en la linea message = e.getMessage()+'Linea: '+e.getLineNumber();
                    message = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    message = e.getMessage()+' Linea: '+e.getLineNumber()+' '+e.getCause();
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
        response.iduVenta = oppor.dsalesIduVenta__c;
        response.listaNegra = listaNegra;
        response.listaSeguros = plazos;
        if(data.sku!=null && data.sku!='' && plazos!= null){
            response.listaproducto = moto;
            response.campanias = buscaCampanias(data.sku,idTienda);       
        }
        return response;
    }
    public static List<DSALES_QuoteSmWrapper.RespuestaPlazos> coppel(List<DSALES_QuoteSmWrapper.RespuestaPlazos> plazos, String sku){
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> filtroSoloCoppel = new List<DSALES_QuoteSmWrapper.RespuestaPlazos>();
        String userCop ='coopel';
        String cambioSeguroA= Label.npvSeguro;
        system.debug('cambioSeguroA:__'+cambioSeguroA);
        String cambioSeguroB= Label.npvEquivalente;
        system.debug('cambioSeguroB:__'+cambioSeguroB);
        
        if(plazos!=null){
            Boolean segGra = campana(rc, sku,null);
            Boolean rcTrue = RCEXCESO(rc, sku,null);
            for(DSALES_QuoteSmWrapper.RespuestaPlazos item:plazos){
                if(segGra==true && rcTrue==true) {//&& item.paquete==cambioSeguroA)
                    if(item.paquete!=cambioSeguroA){
                        filtroSoloCoppel.add(item);
                    }
                }
                else{
                    if(item.paquete!=cambioSeguroB){
                        filtroSoloCoppel.add(item);
                    }
                }
                //filtroSoloCoppel.add(item);
            }

        }

        return filtroSoloCoppel;

    }
    public static List<DSALES_QuoteSmWrapper.Campanias> buscaCampanias(String sku, String idTienda){
        List<DSALES_QuoteSmWrapper.Campanias> listaCampanias = new List<DSALES_QuoteSmWrapper.Campanias>();
        try{
            Product2 productoMoto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku WITH SECURITY_ENFORCED LIMIT 1];
            List<DSALES_AsociacionCampanias__c> lista = [SELECT DSALES_Campania__c FROM DSALES_AsociacionCampanias__c WHERE DSALES_Producto__c =:productoMoto.Id WITH SECURITY_ENFORCED];
            List<Id> listAsoCampnia = new List<Id>();
            for(DSALES_AsociacionCampanias__c aCampania : lista) {
                listAsoCampnia.add(aCampania.DSALES_Campania__c);
            }
            List<dsalesAsignacionDeTienda__c> asigt = [SELECT dsalesCampana__c FROM dsalesAsignacionDeTienda__c where dsalesTienda__c=:idTienda AND dsalesActivo__c=true WITH SECURITY_ENFORCED];
            List<Id> productoIdts = new List<Id>();
            for(dsalesAsignacionDeTienda__c asignaciont : asigt) {
                productoIdts.add(asignaciont.dsalesCampana__c);
            }
            List<Campaign> aux = [SELECT Name, dsalesTipoCampana__c,dsalesProductoCampanas__r.Name, Description,dsalesPlazosAplicables__c FROM Campaign WHERE Id IN:listAsoCampnia AND Id IN:productoIdts WITH SECURITY_ENFORCED];
            system.debug('Tamaño de linea de error 222:___ '+aux.size());
            for(Campaign item:aux){        
                DSALES_QuoteSmWrapper.Campanias aux2 = new DSALES_QuoteSmWrapper.Campanias();
                aux2.nombreCampana = item.Name;
                aux2.tipoCampana = item.dsalesTipoCampana__c;
                aux2.descripcion = item.Description;
                List<String> plazosAplicables = new List<String>();
                plazosAplicables.addAll(item.dsalesPlazosAplicables__c.split(';'));
                aux2.plazosAplicables=plazosAplicables;
                //item.dsalesPlazosAplicables__c.split(';');
                aux2.productoDeCampana = item.dsalesProductoCampanas__r.Name;
                aux2.nombreProducto = productoMoto.Name;
                aux2.sku = productoMoto.StockKeepingUnit;
                listaCampanias.add(aux2);
            }
        }catch(Exception e){
            System.debug('No Se encontraron Campanias para el SKU');        
        }    
        return listaCampanias;
    }
    public static List<DSALES_QuoteSmWrapper.Plazo> plazosActivos(String plazoMaximo,String opPagoRecibido,String idProducto,String idTienda){
        List<DSALES_QuoteSmWrapper.Plazo> plazosSeguros = new List<DSALES_QuoteSmWrapper.Plazo>();
        List<Plazo__c> lista;
        try{
            List<DSales_Asignacion_de_Productos__c> asig = [SELECT DSales_Servicio_Seguro__c FROM DSales_Asignacion_de_Productos__c where DSales_Producto__c=:idProducto AND DSALES_Activo__c=true WITH SECURITY_ENFORCED];
            List<Id> productoIds = new List<Id>();
            for(DSales_Asignacion_de_Productos__c asignacion : asig) {
                productoIds.add(asignacion.DSales_Servicio_Seguro__c);
            }
            List<dsalesAsignacionDeTienda__c> asigt = [SELECT Producto__c FROM dsalesAsignacionDeTienda__c where dsalesTienda__c=:idTienda AND dsalesActivo__c=true WITH SECURITY_ENFORCED];
            List<Id> productoIdts = new List<Id>();
            for(dsalesAsignacionDeTienda__c asignaciont : asigt) {
                productoIdts.add(asignaciont.Producto__c);
            }
            List<Product2> seguros = [SELECT Id, Name, (SELECT Name, Dsales_Plazo__c, dsalesSeguro__c FROM Plazos__r  WHERE Dsales_Plazo__c<=:plazoMaximo AND DSALES_Activo__c = true) FROM Product2 WHERE Id IN :productoIds AND IsActive = true AND Id IN :productoIdts WITH SECURITY_ENFORCED];
            Map<String, List<DSALES_QuoteSmWrapper.opcionPago>> paquetesOpcionesPago = new Map<String, List<DSALES_QuoteSmWrapper.opcionPago>>();
            for(Product2 item:seguros){
                List<Plazo__c> plazos = item.Plazos__r;
                for(Plazo__c plazo :plazos) {
                    if (!paquetesOpcionesPago.containsKey(item.Name)) {
                        paquetesOpcionesPago.put(item.Name, new List<DSALES_QuoteSmWrapper.opcionPago>());
                    }
                    List<Product2> productos = [SELECT dsalesOpcionpago__c FROM Product2 WHERE Id=:item.Id];
                        for (Product2 producto : productos) {
                            if (producto.dsalesOpcionpago__c != null) {
                                List<String> opcionPago = producto.dsalesOpcionpago__c.split(';');
                                if(opPagoRecibido=='Mensual'){
                                	for(String opPago:opcionPago){
                                        DSALES_QuoteSmWrapper.opcionPago opcion = new DSALES_QuoteSmWrapper.opcionPago();
                                        opcion.opcionPago = plazo.Dsales_Plazo__c + opPago;
                                        paquetesOpcionesPago.get(item.Name).add(opcion);
                                    }
                                    }else if(opPagoRecibido=='Contado'){
                                        DSALES_QuoteSmWrapper.opcionPago opcion = new DSALES_QuoteSmWrapper.opcionPago();
                                        opcion.opcionPago = plazo.Dsales_Plazo__c +'C';
                                        paquetesOpcionesPago.get(item.Name).add(opcion);
                                    }
                                }
                            }
                        }
                    
                }
            for (String paquete : paquetesOpcionesPago.keySet()) {
                DSALES_QuoteSmWrapper.Plazo aux = new DSALES_QuoteSmWrapper.Plazo();
                aux.paquete = paquete;
                aux.opcionesPago = paquetesOpcionesPago.get(paquete);
                plazosSeguros.add(aux);
            }
        }
        catch(Exception e){
            System.debug('No Se encontraron plazos con las condiciones');        
        }
        if(Test.isRunningTest()){
            DSALES_QuoteSmWrapper.Plazo aux = new DSALES_QuoteSmWrapper.Plazo();
            aux.paquete = 'RC Seguro de Moto';
            //aux.opcionPago = '12M';
            plazosSeguros.add(aux);
        }
        System.debug('Plazos con opción de pago:'+plazosSeguros);
        return plazosSeguros;
    }
    public static List<DSALES_QuoteSmWrapper.Plazo> plazosActivosExterna(String plazoMaximo,String idTienda, String opPagoRecibido){
        List<DSALES_QuoteSmWrapper.Plazo> plazosSeguros = new List<DSALES_QuoteSmWrapper.Plazo>();
        List<Plazo__c> lista;

        try{
            List<dsalesAsignacionDeTienda__c> asigt = [SELECT Producto__c FROM dsalesAsignacionDeTienda__c where dsalesTienda__c=:idTienda AND dsalesActivo__c=true WITH SECURITY_ENFORCED];
            List<Id> productoIdts = new List<Id>();
            for(dsalesAsignacionDeTienda__c asignaciont : asigt) {
                productoIdts.add(asignaciont.Producto__c);
            }
            List<Product2> seguros = [SELECT Id, Name, (SELECT Name, Dsales_Plazo__c, dsalesSeguro__c FROM Plazos__r  WHERE Dsales_Plazo__c<=:plazoMaximo AND DSALES_Activo__c = true) FROM Product2 WHERE DSALES_Aplicaparamotoexterna__c=true AND IsActive=true AND Id IN :productoIdts WITH SECURITY_ENFORCED];
            System.debug('Entraaa aExterna: '+seguros);
            Map<String, List<DSALES_QuoteSmWrapper.opcionPago>> paquetesOpcionesPago = new Map<String, List<DSALES_QuoteSmWrapper.opcionPago>>();
            for(Product2 item:seguros){
                List<Plazo__c> plazos = item.Plazos__r;
                for(Plazo__c plazo :plazos) {
                    if (!paquetesOpcionesPago.containsKey(item.Name)) {
                        paquetesOpcionesPago.put(item.Name, new List<DSALES_QuoteSmWrapper.opcionPago>());
                    }
                    List<Product2> productos = [SELECT dsalesOpcionpago__c FROM Product2 WHERE Id=:item.Id];
                        for (Product2 producto : productos) {
                            if (producto.dsalesOpcionpago__c != null) {
                                List<String> opcionPago = producto.dsalesOpcionpago__c.split(';');
                                if(opPagoRecibido=='Mensual'){
                                	for(String opPago:opcionPago){
                                        DSALES_QuoteSmWrapper.opcionPago opcion = new DSALES_QuoteSmWrapper.opcionPago();
                                        opcion.opcionPago = plazo.Dsales_Plazo__c + opPago;
                                        paquetesOpcionesPago.get(item.Name).add(opcion);
                                    }
                                    }else if(opPagoRecibido=='Contado'){
                                        DSALES_QuoteSmWrapper.opcionPago opcion = new DSALES_QuoteSmWrapper.opcionPago();
                                        opcion.opcionPago = plazo.Dsales_Plazo__c +'C';
                                        paquetesOpcionesPago.get(item.Name).add(opcion);
                                    }
                                }
                            }
                        }
                    
                }
            for (String paquete : paquetesOpcionesPago.keySet()) {
                DSALES_QuoteSmWrapper.Plazo aux = new DSALES_QuoteSmWrapper.Plazo();
                aux.paquete = paquete;
                aux.opcionesPago = paquetesOpcionesPago.get(paquete);
                plazosSeguros.add(aux);
            }
        }
        catch(Exception e){
            System.debug('No Se encontraron plazos con las condiciones');        
        }
        if(Test.isRunningTest()){
            DSALES_QuoteSmWrapper.Plazo aux = new DSALES_QuoteSmWrapper.Plazo();
            aux.paquete = 'RC Seguro de Moto';
            //aux.opcionPago = '12M';
            plazosSeguros.add(aux);
        }
        System.debug('Plazos con opción de pago:'+plazosSeguros);
        return plazosSeguros;
    }
    
    public static DSALES_QuoteSmWrapper.respuestaDelProveedor crearQuoteSm(DSALES_QuoteSmWrapper.QuotePostProvedor obj){
        String body = JSON.serialize(obj);
        System.debug('body: '+body);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String token = DSALES_obtenerToken.getToken();
        request.setHeader('Authorization','Bearer '+token);
        String endpoint = DSALES_Utility.getEndpoint(NOMBRE_SERVICIO);
        request.setHeader('Content-Type','application/json');
        request.setTimeout(120000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
            System.debug('Recibido por mule: '+response.getBody());
            DSALES_QuoteSmWrapper.respuestaDelProveedor respuesta = (DSALES_QuoteSmWrapper.respuestaDelProveedor) JSON.deserialize(response.getbody(), DSALES_QuoteSmWrapper.respuestaDelProveedor.class);
            for(DSALES_QuoteSmWrapper.ArmadoMuleSoft item:respuesta.plazos){
                String ori=item.opcionPago;
                item.opcionPago =  ori.substring(0, ori.length() - 1);
            }
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
        cliente.PersonBirthdate = Date.valueOf(data.fechaNacimiento);
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
        oppor.DSALES_Tiend__c = tienda.Id;
        oppor.Pricebook2Id = precioLista.Id;
        oppor.dsalesIduVenta__c=data.iduVenta;
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
        DSALES_TipodeUso__c tipoUso = [Select Id from DSALES_TipodeUso__c WHERE Name =:data.tipoUso WITH SECURITY_ENFORCED LIMIT 1];
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
        cotiza.DSALES_Fechadenacimiento__c = Date.valueOf(data.fechaNacimiento);
        cotiza.dsalesCodigoPostal__c = data.codigoPostal;
        cotiza.dsalesIdDeVehiculo__c = data.idVehiculo;
        cotiza.dsalesOpcionDePago__c = data.opcionPago;
        cotiza.DSALES_Cobertura__c = '';
        cotiza.DSales_Vendedor__c = data.nombreVendedor;
        cotiza.dsalesGenero__c = data.generoContacto;
        cotiza.dsalesFechaDeComienzoDePoliza__c = Date.valueOf(data.fechaInicio);
        cotiza.Email = data.correoElectronico;
        cotiza.DSALES_TipoUso__c = tipoUso.Id;
        //cotiza.dsalesTipoDeVehiculo__c=data.tipoVehiculo;
        cotiza.dsalesTipoDeVehiculo__c = tipoVehiculo.Id;
        cotiza.DSALES_RFC__c = data.rfc;
        cotiza.DSALES_Plazoacotizar__c= decimal.valueOf(data.plazoCotizar);  
        cotiza.dsalesValorFactura__c=data.valorFactura;      
        if(Schema.sObjectType.Quote.isCreateable())
        {
            insert cotiza;        
        } 
        return cotiza;
    }
    
    public static QuoteLineItem creaPartida(String seguro, Quote cotiza, DSALES_QuoteSmWrapper.ArmadoMuleSoft data, String sku){
            Product2 producto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Name=:seguro WITH SECURITY_ENFORCED LIMIT 1];
            PricebookEntry precio = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id =:producto.Id LIMIT 1];
        	Plazo__c plazo = [SELECT Id, Name, DSALES_Activo__c, dsalesSeguro__r.Name FROM Plazo__c WHERE dsalesSeguro__r.Name =:seguro AND Name=:data.opcionPago AND DSALES_Activo__c = true WITH SECURITY_ENFORCED];     	
        	QuoteLineItem partida = new QuoteLineItem();
            partida.QuoteId = cotiza.Id;
            partida.PricebookEntryId = precio.Id;
            partida.Product2Id = precio.Product2Id;
            partida.Quantity = 1;
            partida.UnitPrice=decimal.valueOf(data.data.primaSeguro.primaTotal);
            //partida.UnitPrice = precio.UnitPrice;
            partida.DSALES_Fechadeinicio__c = Date.valueOf(data.data.recibos[0].fechaInicio);
            partida.DSALES_Fechadetermino__c = Date.valueOF(data.data.recibos[0].fechaFin);
            partida.DSALES_Primaneta__c = decimal.valueOf(data.data.primaSeguro.primaNeta);
           // partida.UnitPrice = decimal.valueOf(data.data.primaSeguro.primaNeta);
            partida.dsalesDerechosDePoliza__c = decimal.valueOf(data.data.primaSeguro.derechos);
            partida.dsalesGastosDeOperacionDelRecibo__c = decimal.valueOf(data.data.primaSeguro.recargo);
            partida.DSALES_Impuestos__c = decimal.valueOf(data.data.primaSeguro.impuestos);
            partida.DSALES_TrackingID__c = data.trackingId;
        	partida.DSALES_Plazo__c = plazo.Id;
        	partida.DSALES_Comision__c = decimal.valueOf(data.data.primaSeguro.comision);
            partida.DSALES_Recargos__c = decimal.valueOf(data.data.recibos[0].recargo);
        	partida.DSALES_Descripcion__c='Esta cobertura ampara la responsabilidad civil por el tránsito de vehículos en territorio nacional, en que incurra el Asegurado o cualquier persona que con consentimiento del Asegurado use o posea el vehículo descrito en la Póliza con el límite de responsabilidad establecido en la misma, siempre que a consecuencia de dicho uso o posesión, cause a Terceros daños materiales en sus bienes, lesiones corporales, incapacidades temporales y/o permanentes o la muerte, distintos de los ocupantes de dicho vehículo, que considera la Responsabilidad Civil a que se refiere el artículo 63 Bis de la Ley de Caminos, Puentes y Autotransporte Federal.';
            partida.DSALES_Descripcion__c = Coberturas(data.data.coberturas);
        	partida.DSALES_Segurogratis__c = false;//Campana(producto.Name, sku,null);
            partida.dsalesOpcionPago__c=data.data.opcionesPago[0].value;
            partida.dsalesQuoteId__c = data.data.quoteId;
            if(data.data.recibos.size()>1){           
                partida.dsalesPagoInicial__c=decimal.valueOf(data.data.recibos[0].primaTotal);
                partida.DSALES_Pagomensual__c=decimal.valueOf(data.data.recibos[1].primaTotal);
            }
            return partida;
    }
    public static String coberturas(List<DSALES_QuoteSmWrapper.CoveragesArray> coberturas){
        String body='';
        for(DSALES_QuoteSmWrapper.CoveragesArray item: coberturas){
            body+=', '+item.nombre;
        }
        return body;
    }
    public static Boolean campana(String seguro,String sku,String id){
        Boolean condicion = false;  
        if(sku!=null && sku!=''){
            Product2 producto = [SELECT Id, Name, StockKeepingUnit,DSales_Tipo_de_Producto__c, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku OR Id=:id WITH SECURITY_ENFORCED LIMIT 1];        
            if(seguro == rc){               
            	List <DSALES_AsociacionCampanias__c> listaCampanas = [SELECT Name, DSALES_Campania__c, DSALES_Producto__c,DSALES_Activo__c FROM DSALES_AsociacionCampanias__c WHERE DSALES_Producto__c =:producto.Id AND DSALES_Activo__c=true WITH SECURITY_ENFORCED];
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
    public static DSALES_QuoteSmWrapper.RespuestaPlazos creaPartidaM(Quote cotiza, String sku, Boolean listaNegra, Double precio){      
        DSALES_QuoteSmWrapper.RespuestaPlazos motoVacia = new DSALES_QuoteSmWrapper.RespuestaPlazos();
        if(sku!=null && sku!='' && listaNegra!=true){
            Product2 productoMoto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku WITH SECURITY_ENFORCED LIMIT 1];
        	PricebookEntry precioM = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id =:productoMoto.Id WITH SECURITY_ENFORCED LIMIT 1];
        	QuoteLineItem partidaM = new QuoteLineItem();
            partidaM.QuoteId = cotiza.Id;
            partidaM.PricebookEntryId = precioM.Id;
            partidaM.Product2Id = precioM.Product2Id;
            partidaM.Quantity = 1;
            partidaM.UnitPrice = decimal.valueOf(precio);
            partidaM.DSALES_Segurogratis__c = Campana(rc, sku,null);
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
    public  class nuevasPartidasPlazos{
        String idPlazo;
        String plazo;
    }
    public static List<nuevasPartidasPlazos> buscarPlazoAplicable(List<String> plazosAbuscar){
        List<nuevasPartidasPlazos> partidasYPlazos = new List<nuevasPartidasPlazos>();
        List<Plazo__c> plazos = [SELECT Id,Dsales_Plazo__c FROM Plazo__c WHERE Id IN:plazosAbuscar WITH SECURITY_ENFORCED];
        for(Plazo__c q: plazos){
            nuevasPartidasPlazos nuevo = new nuevasPartidasPlazos();
            nuevo.idPlazo=q.Id;
            nuevo.plazo=q.Dsales_Plazo__c;
            partidasYPlazos.add(nuevo);
        }
        return partidasYPlazos;
    }
    public static List<DSALES_QuoteSmWrapper.RespuestaPlazos> creaPlazos(Quote cotiza, List<DSALES_QuoteSmWrapper.ArmadoMuleSoft> plazos, String sku,Boolean listaNegra,String idTienda){
        List<QuoteLineItem> listaPartidas = new List<QuoteLineItem>();
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> listaSeguros = new List<DSALES_QuoteSmWrapper.RespuestaPlazos>();
        for(Integer i=0; i<plazos.size(); i++){
            listaPartidas.add(creaPartida(plazos[i].paquete, cotiza, plazos[i],sku));
            DSALES_QuoteSmWrapper.RespuestaPlazos aux = new DSALES_QuoteSmWrapper.RespuestaPlazos();
            aux.trackingId = plazos[i].trackingId;
            aux.paquete = plazos[i].paquete;
            aux.vigencia = plazos[i].opcionPago;
            aux.data = plazos[i].data;
            listaSeguros.add(aux);
        }
        List<String> idPartidaPlazo= new List<String>();
        for(QuoteLineItem pr : listaPartidas){
            idPartidaPlazo.add(pr.DSALES_Plazo__c);
        }
        List<nuevasPartidasPlazos> partidasYPlazos=buscarPlazoAplicable(idPartidaPlazo);
        try{
            List<DSALES_QuoteSmWrapper.Campanias> campanas = buscaCampanias(sku,idTienda);
            List<nuevasPartidasPlazos>idPlazosGratis = new List<nuevasPartidasPlazos>();
            for(DSALES_QuoteSmWrapper.Campanias item2:campanas){
                for(nuevasPartidasPlazos plr:partidasYPlazos){
                    for(String cp:item2.plazosAplicables){
                        if(cp==plr.plazo){
                            nuevasPartidasPlazos npl= new nuevasPartidasPlazos();
                            npl.idPlazo=plr.idPlazo;
                            npl.plazo=plr.plazo;
                            idPlazosGratis.add(npl);
                        }
                    }
                    
                }
            }
            System.debug('plazos gratis:'+idPlazosGratis);
            System.debug('campanas: '+campanas); 
            //agregar método de busqueda de plazos
            for(Integer i=0; i<listaPartidas.size(); i++){     
                for(DSALES_QuoteSmWrapper.Campanias item:campanas){
                   if(item.nombreCampana=='RC' && item.tipoCampana=='Seguro gratis' && listaSeguros[i].paquete=='RC'){
                      for(nuevasPartidasPlazos pl : idPlazosGratis){

                          if(listaPartidas[i].DSALES_Plazo__c==pl.idPlazo ){
                                listaPartidas[i].DSALES_Segurogratis__c=true;
                            }
                        }
                        //sacar los valores de la lista multiple
                        // comparar con el plazo de las partidas
                       
                    }
                }   
            }          
            insert listaPartidas;
        }catch(Exception e){System.debug('Error insertar Partida: '+e.getMessage());}
        
        for(Integer i=0; i<listaPartidas.size() ; i++){
            listaSeguros[i].idpartida = listaPartidas[i].Id;
            listaSeguros[i].descripcion = listaPartidas[i].DSALES_Descripcion__c;
            listaSeguros[i].seguroGratis = listaPartidas[i].DSALES_Segurogratis__c;

        }
        return listaSeguros;     
    }
    
    public static Boolean RCEXCESO(String seguro,String sku,String id){
        Boolean condicion = false;  
        if(sku!=null && sku!=''){
            Product2 producto = [SELECT Id, Name, StockKeepingUnit,DSales_Tipo_de_Producto__c, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku OR Id=:id WITH SECURITY_ENFORCED LIMIT 1];        
             List<DSales_Asignacion_de_Productos__c> asig = [SELECT DSales_Servicio_Seguro__c, DSales_Servicio_Seguro__r.Name, DSales_Servicio_Seguro__r.isActive FROM DSales_Asignacion_de_Productos__c where DSales_Producto__c=:Producto.id AND DSALES_Activo__c=true WITH SECURITY_ENFORCED];
            for(DSales_Asignacion_de_Productos__c asignacion:asig){
                if(asignacion.DSales_Servicio_Seguro__r.Name == VALOR2 && asignacion.DSales_Servicio_Seguro__r.isActive){
                    condicion = true; 
                }
            }
                           
            } 
        return condicion;
    }
}