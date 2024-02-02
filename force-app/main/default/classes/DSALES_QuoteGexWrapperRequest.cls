@RestResource(urlMapping='/insertQuoteGex/*')
global with sharing class DSALES_QuoteGexWrapperRequest {
    
    
    @HttpPost
    global static DSALES_QuoteGexWrapper.respuestaNPV createQuote(){
        
        Boolean success = true;
        Boolean cobertura = false;
        Boolean banderaExterno = false;
        String message = '';
        String code = '';
        String regions = 'Todas las regiones';
        String originalMat = 'Matriz Original';
        Account cliente = new Account();
        Opportunity oppor = new Opportunity();
        Quote cotiza = new Quote();
        Tienda__c tienda =  new Tienda__c();
        Map<String, DSALES_QuoteGexWrapper.Product> mapProducts = new  Map<String, DSALES_QuoteGexWrapper.Product>();
        List<QuoteLineItem> listaPartida = new List<QuoteLineItem>();
        List<DSales_Asignacion_de_Productos__c> productAsig = new List<DSales_Asignacion_de_Productos__c>();  
        
        ///////////////////--------------------------////////////////////
        
        Map<String, DSales_Asignacion_de_Productos__c> mapProductsServAm = new  Map<String, DSales_Asignacion_de_Productos__c>();
        
        //////////////////---------------------------////////////////////
        
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    DSALES_QuoteGexWrapper.QuoteGexRequest data = (DSALES_QuoteGexWrapper.QuoteGexRequest)JSON.deserialize(body, DSALES_QuoteGexWrapper.QuoteGexRequest.class); 
                    system.debug('Datos recibidos:___'+body);

                    for(DSALES_QuoteGexWrapper.Product p : data.productos){
                        if(p.skuDeTangible ==null){
                            banderaExterno = true;
                            mapProducts.put(p.articulo, p);
                        }else{
                            mapProducts.put(p.skuDeTangible, p);
                        }
                    }
                    Account universalAccount = [Select Id,DSALES_ClienteCoppel__c from Account WHERE /*ImPisys__c=TRUE AND */DSALES_ClienteCoppel__c = :DSALES_Utility.NUMERO_CLIENTE_GENERICO WITH SECURITY_ENFORCED LIMIT 1];
                    System.debug('universalAccount'+universalAccount);
                    tienda = [Select Id from Tienda__c WHERE DSales_TiendaID__c =: data.idTienda WITH SECURITY_ENFORCED LIMIT 1];
                    System.debug('tienda'+tienda);
                    
                    ////////////////////////////////////----------------------/////////////////////////////////
                    List<DSales_Asignacion_de_Productos__c> asignacionProd=[SELECT Id, DSales_Servicio_Seguro__c,DSales_Servicio_Seguro__r.Name, DSales_Producto__c, DSales_Servicio_Seguro__r.DSALES_ServEspecifico__c, DSales_Producto__r.Name, DSales_Servicio_Seguro__r.Description, DSales_Producto__r.StockKeepingUnit, DSales_Producto__r.dsalesAR__c FROM DSales_Asignacion_de_Productos__c WHERE DSALES_Activo__c=true AND DSales_Producto__r.StockKeepingUnit=: mapProducts.keySet()];
                    for(DSales_Asignacion_de_Productos__c servAM : asignacionProd){
                        if(servAM.DSales_Servicio_Seguro__r.DSALES_ServEspecifico__c=='Armado de muebles' ||servAM.DSales_Servicio_Seguro__r.DSALES_ServEspecifico__c=='Armado de Muebles' || servAM.DSales_Servicio_Seguro__r.Description.contains('Armado')){
                            mapProductsServAm.put(servAM.DSales_Producto__r.StockKeepingUnit, servAM);
                        }
                    }
                    
                    System.debug('ASIGNACION PRODUCTOS TEST::: '+ asignacionProd);////////////////////
                    System.debug('ASIGNACION PRODUCTOS TEST MAP::: '+ mapProductsServAm);/////////////////
                    
                    ///////////////////////////////////-----------------------////////////////////////////////
                    
                    Id clienteId=null;
                    String numeroDeContado=null;
                    Map<String, String> mapNomyId=new Map<String, String>();
                    if(data.idOportunidad!=null){
                        Opportunity accountClient = [SELECT id, AccountId,Account.FirstName, Account.LastName FROM Opportunity WHERE id=:data.idOportunidad WITH SECURITY_ENFORCED LIMIT 1];
                        mapNomyId.put('oportunidadId',data.idOportunidad);
                        mapNomyId.put('firstName',accountClient.Account.FirstName);
                        mapNomyId.put('lastName',accountClient.Account.LastName);
                        cotiza = crearCotizacion(data, mapNomyId ,tienda);
                        if(banderaExterno==true){
                            listaPartida = crearPartidasExterno(data, cotiza.Id,tienda);
                        }else{
                            listaPartida = crearPartidas(data, cotiza.Id,tienda);
                        }
                        
                    }else{
                        if(data.idUniversal!=null){
                            System.debug('Entro a universal______________________________');
                            DSALES_InformacionDePago__c newOpportunity =[Select id,DSALES_Oportunidad__c,DSALES_Oportunidad__r.Name, DSALES_Cliente__c from DSALES_InformacionDePago__c where DSALES_IDUniversal1__c= :data.idUniversal WITH SECURITY_ENFORCED LIMIT 1];
                            clienteId = newOpportunity.DSALES_Cliente__c;
                            Opportunity accountClient = [SELECT id, AccountId,Account.FirstName, Account.LastName FROM Opportunity WHERE id=:newOpportunity.DSALES_Oportunidad__c WITH SECURITY_ENFORCED LIMIT 1];
                            mapNomyId.put('clienteId',clienteId);
                            mapNomyId.put('idUniversal',data.idUniversal);
                            mapNomyId.put('oppPadre',newOpportunity.DSALES_Oportunidad__c);
                            mapNomyId.put('firstName',accountClient.Account.FirstName);
                            mapNomyId.put('lastName',accountClient.Account.LastName);
                            oppor = crearOportunidad(data, mapNomyId ,tienda);
                            mapNomyId.put('oportunidadId',oppor.Id);
                            cotiza = crearCotizacion(data, mapNomyId ,tienda);
                            if(banderaExterno==true){
                                listaPartida = crearPartidasExterno(data, cotiza.Id,tienda);
                            }else{
                                listaPartida = crearPartidasSinTangible(data, cotiza.Id,tienda);
                            }
                        }else{
                            if(data.numeroCliente == '' || data.numeroCliente == null ){
                                List<Account> clienteContado = [SELECT Id,FirstName,LastName FROM Account WHERE FirstName=: data.nombre and LastName=: data.apellidoPaterno and PersonEmail= :data.correoElectronico WITH SECURITY_ENFORCED];
                                clienteId = clienteContado[0].Id;
                                mapNomyId.put('firstName',clienteContado[0].FirstName);
                                mapNomyId.put('lastName',clienteContado[0].LastName);
                                mapNomyId.put('clienteId',clienteId);
                                oppor = crearOportunidad(data, mapNomyId ,tienda);
                                mapNomyId.put('oportunidadId',oppor.Id);
                                cotiza = crearCotizacion(data, mapNomyId ,tienda);
                                if(banderaExterno==true){
                                    listaPartida = crearPartidasExterno(data, cotiza.Id,tienda);
                                }else{
                                    listaPartida = crearPartidas(data, cotiza.Id,tienda);
                                }
                            }else{
                                if(data.numeroCliente != DSALES_Utility.NUMERO_CLIENTE_GENERICO ){
                                    
                                    List<Account> result = [Select Id,FirstName,MiddleName,LastName from Account WHERE CP_WalletCustomerNumber__c =:Decimal.valueOf(data.numeroCliente) WITH SECURITY_ENFORCED];
                                    switch on result.size() {
                                        when 1 {
                                            clienteId = result[0].Id;
                                            mapNomyId.put('firstName',result[0].FirstName);
                                            mapNomyId.put('lastName',result[0].LastName);
                                            mapNomyId.put('clienteId',clienteId);
                                            oppor = crearOportunidad(data, mapNomyId,tienda);
                                            mapNomyId.put('oportunidadId',oppor.Id);
                                            cotiza = crearCotizacion(data, mapNomyId, tienda);
                                            if(banderaExterno==true){
                                                listaPartida = crearPartidasExterno(data, cotiza.Id,tienda);
                                            }else{
                                                listaPartida = crearPartidas(data, cotiza.Id,tienda);
                                            }
                                        }
                                        when 0 {
                                            cliente = crearCliente(data);
                                            clienteId = cliente.Id;
                                            mapNomyId.put('firstName',cliente.FirstName);
                                            mapNomyId.put('lastName',cliente.LastName);
                                            mapNomyId.put('clienteId',clienteId);
                                            oppor = crearOportunidad(data, mapNomyId, tienda);
                                            mapNomyId.put('oportunidadId',oppor.Id);
                                            cotiza = crearCotizacion(data, mapNomyId, tienda);
                                            if(banderaExterno==true){
                                                listaPartida = crearPartidasExterno(data, cotiza.Id,tienda);
                                            }else{
                                                listaPartida = crearPartidas(data, cotiza.Id,tienda);
                                            }
                                        }
                                    }
                                }else{
                                    System.debug('Entro en 90001');
                                    clienteId = universalAccount.Id;
                                    numeroDeContado = universalAccount.DSALES_ClienteCoppel__c;
                                    mapNomyId.put('firstName',data.nombre);
                                    mapNomyId.put('lastName',data.apellidoPaterno);
                                    mapNomyId.put('clienteId',clienteId);
                                    mapNomyId.put('correo',data.correoElectronico);
                                    mapNomyId.put('numeroContado',numeroDeContado);
                                    oppor = crearOportunidad(data, mapNomyId,tienda);
                                    System.debug('oppor'+oppor);
                                    mapNomyId.put('oportunidadId',oppor.Id);
                                    cotiza = crearCotizacion(data,mapNomyId, tienda);
                                    System.debug('cotiza'+cotiza);
                                    if(banderaExterno==true){
                                        listaPartida = crearPartidasExterno(data, cotiza.Id,tienda);
                                    }else{
                                        listaPartida = crearPartidas(data, cotiza.Id,tienda);
                                    }
                                    System.debug('listaPartida'+listaPartida);
                                    
                                }
                            }
                        }
                    }
                    List<dsalesCP__c> codigoPos = DSALES_QuoteGexWrapperRequest_Helper.consultaCodigoPostal(data);
                    if(codigoPos != null && !codigoPos.isEmpty()){
                        cobertura = true;
                    }else{
                        cobertura = false;
                        message = 'No cuenta con cobertura del servicio de Instalación';
                    }
                }catch(JSONException e){
                    success = false;
                    code = String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    message = DSALES_Utility.BAD_REQUEST_MSJ+ ' ' +e.getMessage() + ' '+e.getLineNumber() + ' '+ e.getCause();
                }catch(Exception e){
                    success = false;
                    code = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    message = DSALES_Utility.INTERNAL_ERROR_MSJ + ' ' +e.getMessage() + ' Linea: '+e.getLineNumber() + ' '+ e.getCause();
                }
            }
        }
        DSALES_QuoteGexWrapper.RespuestaNPV respuestaNpvList = new DSALES_QuoteGexWrapper.RespuestaNPV();
        respuestaNpvList.idCotizacion = cotiza.Id;
        respuestaNpvList.idOportunidad = cotiza.OpportunityId;
        respuestaNpvList.iduVenta = oppor.dsalesIduVenta__c;
        respuestaNpvList.exito = success;
        respuestaNpvList.codigoError = code;
        respuestaNpvList.mensaje = message;
        respuestaNpvList.coberturaInstalacion = cobertura;
        respuestaNpvList.respuesta =  new List<DSALES_QuoteGexWrapper.QuoteGexResponse>();
        respuestaNpvList.descripciones =  DSALES_QuoteGexWrapperRequest_Helper.responseDescription('Servicio',cotiza.Id);
        //respuestaNpvList.encuesta = DSALES_QuoteGexWrapperRequest_Helper.obtenerEncuesta(listaPartida);
        
        ////////////////////--------------------/////////////////////////////////
        
        List<QuoteLineItem> consultaRespuesta = new List<QuoteLineItem> ();
        List<QuoteLineItem> consultaRespuestaGEX = new List<QuoteLineItem> ();
        
        for(QuoteLineItem item: [Select Id,Product2.Id,Product2.Name,Product2.Description,ListPrice,UnitPrice,Quantity,Vigencia_meses__c,DSALES_SKU__c,Quote.GrandTotal,Product2.DSales_Tipo_de_Producto__c,Product2.DSALES_Familia__r.Name,Product2.DSALES_Clase__r.Name,Product2.DSALES_Categoria__r.Name,Product2.DSales_Aplicaporcentajecobro__c from QuoteLineItem WHERE QuoteId=: cotiza.Id WITH SECURITY_ENFORCED]){
            if(item.Product2.DSales_Tipo_de_Producto__c == 'Producto'){
                consultaRespuesta.add(item);
            }else{
                consultaRespuestaGEX.add(item);
            }
        }
        if(consultaRespuesta.isEmpty() && consultaRespuestaGEX.isEmpty()){
            respuestaNpvList.exito = false;
            respuestaNpvList.idCotizacion = '';
            respuestaNpvList.idOportunidad = '';
            respuestaNpvList.codigoError = '405';
            respuestaNpvList.iduVenta = '';
            respuestaNpvList.coberturaInstalacion = false;
            respuestaNpvList.mensaje = 'El producto no cuenta con asignacion';
            return respuestaNpvList;
        }else{
            Set<Id> productIds = new Set<Id>();
            for (QuoteLineItem quoteLineItem : listaPartida) {
                productIds.add(quoteLineItem.Product2Id);
            }
            Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, DSales_Tipo_de_Producto__c, StockKeepingUnit, DSales_Aplicaporcentajecobro__c
                                                                  FROM Product2
                                                                  WHERE Id IN :productIds WITH SECURITY_ENFORCED]);
            Set<Id> servicioIds = new Set<Id>();
            for (QuoteLineItem quoteLineItem : listaPartida) {
                Product2 tipoProducto = productMap.get(quoteLineItem.Product2Id);
                if (tipoProducto.DSales_Tipo_de_Producto__c == 'Servicio') {
                    servicioIds.add(tipoProducto.Id);
                }
            }
            Map<Id, dsalesAsignacionDeTienda__c> asignacionTiendaMap = new Map<Id, dsalesAsignacionDeTienda__c>();
            for (dsalesAsignacionDeTienda__c asignacion : [SELECT Id, dsalesMatriz__c,dsalesMatriz__r.DSALES_Servicio__c
                                                           FROM dsalesAsignacionDeTienda__c 
                                                           WHERE dsalesTienda__c = :tienda.Id 
                                                           AND dsalesMatriz__c <> null
                                                           AND dsalesMatriz__r.DSALES_Servicio__c IN :servicioIds 
                                                           WITH SECURITY_ENFORCED]){
                                                               asignacionTiendaMap.put(asignacion.dsalesMatriz__r.DSALES_Servicio__c,asignacion);
                                                           }
            System.debug('Asignacion de tiendas:____'+asignacionTiendaMap);
            Map<Decimal, String> skuPrecios2 = new Map<Decimal, String>();
            for (QuoteLineItem quoteLineItem : listaPartida) {
                Product2 tipoProducto = productMap.get(quoteLineItem.Product2Id);
                if (tipoProducto.DSales_Tipo_de_Producto__c == 'Servicio') {
                    String nombreIntangible = quoteLineItem.DSALES_NombreProductoServicio__c;
                    String[] partesCadena = nombreIntangible.split(' ');
                    String numeroExtraido;
                    System.debug('Nombre del intangible'+nombreIntangible);
                    if (nombreIntangible.contains('ARMADO')) {
                        numeroExtraido = (partesCadena.size() > 3) ? partesCadena[3] : null;
                    } else if (nombreIntangible.contains('GARANTÍA EXTENDIDA')) {
                        System.debug('Entro a gex');
                        numeroExtraido = (partesCadena.size() > 4) ? partesCadena[4] : null;
                    } else if (nombreIntangible.contains('INSTALACION')) {
                        System.debug('entro a instalaciones');
                        numeroExtraido = (partesCadena.size() > 2) ? partesCadena[2] : null;
                    }
                    System.debug('__________________'+numeroExtraido);

                    Decimal precioTangible = 0.0;
                    if (mapProducts.containsKey(numeroExtraido)) {
                        DSALES_QuoteGexWrapper.Product product = mapProducts.get(numeroExtraido);
                        precioTangible = product.precioTangible;
                    }
                    if(nombreIntangible.contains('GARANTÍA EXTENDIDA')){
                        dsalesAsignacionDeTienda__c asigTienda = asignacionTiendaMap.get(tipoProducto.Id); 
                        for(DSALES_Matriz_de_Cotizacion__c matrizPrecio : [SELECT Id,Name,SALES_Precio_GEX__c FROM DSALES_Matriz_de_Cotizacion__c WHERE SALES_Precio_GEX__c = :quoteLineItem.UnitPrice AND DSales_Matriz_GEX__r.DSALES_Activo__c = true AND DSALES_Rango_Superior_GEX__c >= :precioTangible AND DSales_Matriz_GEX__c = :asigTienda.dsalesMatriz__c WITH SECURITY_ENFORCED]){
                            skuPrecios2.put(matrizPrecio.SALES_Precio_GEX__c, matrizPrecio.Name);
                            
                        }
                    }
                    
                }
            }
            system.debug('skuPrecios2:_________'+skuPrecios2);
            for (QuoteLineItem quoteLineItem : listaPartida) {
                Product2 tipoProducto = productMap.get(quoteLineItem.Product2Id);
                
                System.debug('tipoProducto TEST RESPUESTA::: '+ tipoProducto);/////////////////////////
                
                if (tipoProducto.DSales_Tipo_de_Producto__c == 'Servicio') {                        
                    DSALES_QuoteGexWrapper.QuoteGexResponse responsePayload = new DSALES_QuoteGexWrapper.QuoteGexResponse();
                    dsalesAsignacionDeTienda__c asigTienda = asignacionTiendaMap.get(tipoProducto.Id);
                    String nombreIntangible = quoteLineItem.DSALES_NombreProductoServicio__c;
                    Double numAr = quoteLineItem.dsalesAR__c;///////////////////
                    String[] partesCadena = nombreIntangible.split(' ');
                    String numeroExtraido;     
                    if (nombreIntangible.contains('ARMADO')) {
                        numeroExtraido = (partesCadena.size() > 3) ? partesCadena[3] : null;
                    } else if (nombreIntangible.contains('GARANTÍA EXTENDIDA')) {
                        System.debug('Entro a gex');
                        numeroExtraido = (partesCadena.size() > 4) ? partesCadena[4] : null;
                    } else if (nombreIntangible.contains('INSTALACION')) {
                        System.debug('entro a instalaciones');
                        numeroExtraido = (partesCadena.size() > 2) ? partesCadena[2] : null;
                    }
                    System.debug('__________________2'+numeroExtraido);
                    Decimal precioTangible = 0.0;
                    if (mapProducts.containsKey(numeroExtraido)) {
                        DSALES_QuoteGexWrapper.Product product = mapProducts.get(numeroExtraido);
                        precioTangible = product.precioTangible;
                    }
                    Decimal unitPrice = quoteLineItem.UnitPrice.setScale(2);
                    responsePayload.costoTotal = precioTangible + quoteLineItem.UnitPrice;
                    responsePayload.precio = quoteLineItem.UnitPrice;
                    responsePayload.nombreIntangible = nombreIntangible;
                    responsePayload.skuDeTangible = numeroExtraido;
                    if(tipoProducto.DSales_Aplicaporcentajecobro__c==true){
                        responsePayload.skuDePrecio = null;
                    }else{
                        System.debug('skuPrecios2 sku skuuu::: '+skuPrecios2);
                        if(mapProductsServAm.containsKey(numeroExtraido)){
                            String skuPrecio=DSALES_QuoteGexWrapperRequest_Helper.matrizArPrice(numeroExtraido, asigTienda, quoteLineItem);
                            responsePayload.skuDePrecio = skuPrecio;
                        }
                        else{
                            String skuPrecio = skuPrecios2.get(unitPrice);
                            System.debug('skuPrecio GEX::: '+skuPrecio);  
                            responsePayload.skuDePrecio = skuPrecio;                                
                        }
                    }
                    responsePayload.skuDeServicio = tipoProducto.StockKeepingUnit;
                    responsePayload.mesesCobertura = quoteLineItem.Vigencia_meses__c;
                    responsePayload.idSecuencia = Integer.valueOf(quoteLineItem.dsalesIdSecuencia__c);
                    responsePayload.idPartidaDePresupuesto = quoteLineItem.Id;
                    responsePayload.tiempoArmado = quoteLineItem.dsalesAR__c;
                    if(nombreIntangible.contains('INSTALACION')){
                        responsePayload.encuesta = DSALES_QuoteGexWrapperRequest_Helper.obtenerEncuesta(listaPartida,tipoProducto.Id,cotiza.Id, cotiza.Name);
                        responsePayload.proveedorAsignado = quoteLineItem.dSalesProveedor__c;
                    }
                    respuestaNpvList.respuesta.add(responsePayload);    
                    
                    System.debug('responsePayload TEST RESPUESTA::: '+responsePayload);/////////////////////////
                    
                }
            }   
        }
        return respuestaNpvList;
    }
    
    
    public static Account crearCliente (DSALES_QuoteGexWrapper.QuoteGexRequest data){
        Account cliente = new Account();
        cliente.CP_WalletCustomerNumber__c = Decimal.valueOf(data.numeroCliente);
        cliente.FirstName = data.nombre;
        cliente.LastName = data.apellidoPaterno;
        cliente.Suffix =  data.apellidoMaterno;
        cliente.PersonEmail = data.correoElectronico;
        if (Schema.sObjectType.Account.isCreateable()) {
            insert cliente;
        }
        return cliente;
    }
    
    public static Opportunity crearOportunidad (DSALES_QuoteGexWrapper.QuoteGexRequest data, Map<String, String> mapNomyId, Tienda__c tienda){
        Opportunity oppor = new Opportunity();
        String clienteId=(String)mapNomyId.get('clienteId');
        String firstName=(String)mapNomyId.get('firstName');
        String lastName=(String)mapNomyId.get('lastName');
        String numComparacion=(String)mapNomyId.get('numeroContado');
        String idUniversal=(String)mapNomyId.get('idUniversal');
        String oppPadre=(String)mapNomyId.get('oppPadre');
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Servicios').getRecordTypeId();
        Pricebook2 precioLista = [SELECT id,Name FROM Pricebook2 WHERE Name= 'Standard Price Book' and IsActive=true WITH SECURITY_ENFORCED LIMIT 1];
        oppor.AccountId = clienteId;
        oppor.Name = firstName;
        if(LastName != null ){
            oppor.Name+=' '+lastName;
        }else{
            oppor.Name+=' '+lastName;
        }
        if(numComparacion==DSALES_Utility.NUMERO_CLIENTE_GENERICO){
            oppor.DSALES_Nombredelsolicitante__c = firstName+' '+lastName;
        }
        if(idUniversal!=null){
            oppor.DSALES_OppPrin__c = oppPadre;
        }
        oppor.CloseDate = date.today()+30;
        oppor.StageName = 'Nuevo';
        oppor.RecordTypeId = recordTypeId;
        oppor.DSALES_Tienda__c = tienda.Id;
        oppor.Pricebook2Id = precioLista.Id;
        oppor.dsalesIduVenta__c=data.iduVenta;    
        if (Schema.sObjectType.Opportunity.isCreateable()) {
            insert oppor;
        }
        return oppor;
    }
    
    public static Quote crearCotizacion (DSALES_QuoteGexWrapper.QuoteGexRequest data, Map<String, String> mapNomyId, Tienda__c tienda){
        Quote cotiza = new Quote();
        String oportunidadId=(String)mapNomyId.get('oportunidadId');
        String firstName=(String)mapNomyId.get('firstName');
        String lastName=(String)mapNomyId.get('lastName');
        String correo=(String)mapNomyId.get('correo');
        String numComparacion=(String)mapNomyId.get('numeroContado');        
        String recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Venta de Servicios').getRecordTypeId();
        
        Opportunity datos = [SELECT Account.PersonEmail,Account.PersonMobilePhone FROM Opportunity WHERE id=:oportunidadId WITH SECURITY_ENFORCED LIMIT 1];
        cotiza.Name = firstName;
        if(LastName != null ){
            cotiza.Name+=' '+lastName;
        }else{
            cotiza.Name+=' '+lastName;
        }
        if(numComparacion==DSALES_Utility.NUMERO_CLIENTE_GENERICO){
            cotiza.DSALES_EmailNew__c = correo;
        }
        cotiza.OpportunityId = oportunidadId;
        cotiza.RecordTypeId = recordTypeId;
        cotiza.DSales_ID_Tienda__c = data.idTienda;
        cotiza.DSales_Tienda__c = tienda.Id;
        cotiza.ExpirationDate = date.today()+14;
        cotiza.dSalesCP__c = data.codigoPostal;
        if(numComparacion!=DSALES_Utility.NUMERO_CLIENTE_GENERICO){
            cotiza.Phone = datos.Account.PersonMobilePhone;
        }
        if(numComparacion!=DSALES_Utility.NUMERO_CLIENTE_GENERICO){
            cotiza.Email = datos.Account.PersonEmail;
        }
        
        if (Schema.sObjectType.Quote.isCreateable()) {
            insert cotiza;
        }
        return cotiza;
    }
    
    public static List<QuoteLineItem> crearPartidas(DSALES_QuoteGexWrapper.QuoteGexRequest data, Id cotizaId,Tienda__c tienda){
        List<QuoteLineItem> listaPartida = new List<QuoteLineItem>();
        List<DSales_Asignacion_de_Productos__c> productAsig = new List<DSales_Asignacion_de_Productos__c>();       
        Map<String, DSALES_QuoteGexWrapper.Product> mapProducts = new  Map<String, DSALES_QuoteGexWrapper.Product>();
        for(DSALES_QuoteGexWrapper.Product p : data.productos){
            mapProducts.put(p.skuDeTangible, p);
        }
        List<Product2> produc = [SELECT Id,Name,StockKeepingUnit,DSALES_Categoria__c,DSALES_Clase__c,DSALES_Familia__c,DSales_Aplicaporcentajecobro__c,DSales_PorcentajeCobro__c, dsalesAR__c FROM Product2 WHERE StockKeepingUnit in: mapProducts.keySet() WITH SECURITY_ENFORCED];
        productAsig = [SELECT id, Name, DSales_Servicio_Seguro__c,DSales_Servicio_Seguro__r.DSALES_ServEspecifico__c, DSales_Producto__c,DSALES_SKU__c FROM DSales_Asignacion_de_Productos__c WHERE DSALES_Activo__c=true AND  DSales_Producto__r.StockKeepingUnit in: mapProducts.keySet() WITH SECURITY_ENFORCED];
        List<Id> dsalesProductoSetId = new List<Id>();
        for(DSales_Asignacion_de_Productos__c da : productAsig){
            dsalesProductoSetId.add(da.DSales_Servicio_Seguro__c);
        }

        
        List<Pricebook2> precioLista = [SELECT Id,Name FROM Pricebook2 WHERE Name= 'Standard Price Book' and IsActive=true WITH SECURITY_ENFORCED LIMIT 1];
        List<PricebookEntry> precioEn = [SELECT Id,UnitPrice,Name,Product2Id,Pricebook2Id,Product2.StockKeepingUnit,Product2.dsalesAR__c,Product2.DSales_PorcentajeCobro__c,Product2.DSales_Aplicaporcentajecobro__c FROM PricebookEntry WHERE Product2Id =: produc AND Pricebook2Id=: precioLista WITH SECURITY_ENFORCED];
        List<PricebookEntry> precioEnGEX = [SELECT Id,Name,UnitPrice,Product2Id,Pricebook2Id,Product2.StockKeepingUnit,Product2.dsalesAR__c,Product2.DSales_Tipo_de_Producto__c,Product2.DSales_PorcentajeCobro__c,Product2.DSales_Aplicaporcentajecobro__c, Product2.Description,Product2.dsalesFormasCobro__c,Product2.dsalesPrecioUnico__c FROM PricebookEntry WHERE Product2Id =: dsalesProductoSetId and Pricebook2Id=: precioLista WITH SECURITY_ENFORCED];
        for(PricebookEntry item : precioEn){
            DSALES_QuoteGexWrapper.Product p =  mapProducts.get(item.Product2.StockKeepingUnit);
            for (Integer i = 0; i < p.cantidadProductosTangibles; i++) {
                QuoteLineItem partidapre = new QuoteLineItem();
                Product2 producto = new Product2();
                for(Product2 pro: produc){
                    if(pro.StockKeepingUnit == item.Product2.StockKeepingUnit){
                        producto = pro;
                    }
                }
                partidapre.QuoteId = cotizaId;
                partidapre.PricebookEntryId = item.Id;
                partidapre.Product2Id = item.Product2Id;
                partidapre.Quantity = 1;
                partidapre.UnitPrice = p.precioTangible;
                partidapre.DSales_Articulo__c = p.articulo;
                partidapre.DSales_Marca__c = p.marca;
                partidapre.DSales_Modelo__c = p.modelo;
                partidapre.dsalesIdSecuencia__c = i;
                partidapre.DSALES_NombreProductoServicio__c  = p.articulo;
                partidapre.dsalesAR__c=item.Product2.dsalesAR__c;/////////////////////////
                listaPartida.add(partidapre);
                
                //String intangibleId;
                List<String> intangibleIds = new List<String>();
                for(DSales_Asignacion_de_Productos__c asigProduc: productAsig){
                    if(asigProduc.DSales_Producto__c == item.Product2Id){
                        //intangibleId = asigProduc.DSales_Servicio_Seguro__c;
                        intangibleIds.add(asigProduc.DSales_Servicio_Seguro__c);
                    }
                }
                for (String intangibleId : intangibleIds) {
                    for(PricebookEntry item2 : precioEnGEX){
                        if(item2.Product2Id == intangibleId){
                            QuoteLineItem partidapreGEX = new QuoteLineItem();
                            Double price1=0;
                            Double price2=0;
                            Double price3=0;
                            Double price4=0;
                            Double price5=0;
                            Double price6=0;
                            Double priceAm=0;
                            Double priceIns=0;
                            
                            switch on item2.Product2.dsalesFormasCobro__c{
                                when 'Porcentaje de Cobro'{
                                    List<DASALES_Porcentajedecobro__c> porcent = DSALES_QuoteGexWrapperRequest_Helper.obtenerPorcentajeCobro(intangibleId);
                                    for(DASALES_Porcentajedecobro__c percent: porcent){
                                        Integer year = Integer.valueOf(percent.DSALES_Anios__c);
                                        Decimal price = (p.precioTangible * percent.DSALES_Porcentaje__c)/100;
                                        switch on year{
                                            when 1{
                                                price1 = price;
                                            }
                                            when 2{
                                                price2 = price;
                                            }
                                            when 3{
                                                price3 = price;
                                            }
                                            when 4{
                                                price4 = price;
                                            }
                                            when 5{
                                                price5 = price;
                                            }
                                            when 6{
                                                price6 = price;
                                            }
                                        }
                                    }
                                }
                                when 'Matriz de Precios'{
                                    List<dsalesAsignacionDeTienda__c> asigTienda = [SELECT Id, Name, dsalesTienda__r.Name, dsalesMatriz__r.Name, dsalesMatriz__r.DSALES_Servicio__r.Name, dsalesMatriz__r.DSALES_Servicio__c,dsalesActivo__c,dsalesMatriz__c FROM dsalesAsignacionDeTienda__c WHERE dsalesTienda__c=:tienda.Id AND dsalesActivo__c=true AND dsalesMatriz__c<>null AND dsalesMatriz__r.DSALES_Servicio__c=:intangibleId WITH SECURITY_ENFORCED LIMIT 1];
                                    
                                    if(asigTienda.size()>0){    
                                        List<DSALES_Matriz_de_Cotizacion__c> matrizPrecio = DSALES_QuoteGexWrapperRequest_Helper.obtenerMatricesPrecio(asigTienda[0].dsalesMatriz__c);
                                        
                                        
                                        for(DSALES_Matriz_de_Cotizacion__c mPrice : matrizPrecio){
                                            switch on mPrice.DSALES_Tiempo_de_Garantia_Extendida_GEX__c{
                                                when '1 año'{
                                                    if(item2.Product2.DSales_Tipo_de_Producto__c=='Armado de muebles' || item2.Product2.DSales_Tipo_de_Producto__c=='Armado de Muebles' || item2.Product2.Description.contains('Armado')){
                                                        if(mPrice.DSALES_Rango_interior_GEX__c<= item.Product2.dsalesAR__c && mPrice.DSALES_Rango_Superior_GEX__c>=item.Product2.dsalesAR__c){
                                                            priceAm = mPrice.SALES_Precio_GEX__c;
                                                        }
                                                    }
                                                    else{
                                                        if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                                            price1 = mPrice.SALES_Precio_GEX__c;
                                                        }
                                                    }
                                                }
                                                when '2 años'{
                                                    if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                                        price2 = mPrice.SALES_Precio_GEX__c;
                                                    }
                                                }
                                                when '3 años'{
                                                    if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                                        price3 = mPrice.SALES_Precio_GEX__c;
                                                    }
                                                }
                                                when '4 años'{
                                                    if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                                        price4 = mPrice.SALES_Precio_GEX__c;
                                                    }
                                                }
                                                when '5 años'{
                                                    if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                                        price5 = mPrice.SALES_Precio_GEX__c;
                                                    }
                                                }
                                                when '6 años'{
                                                    if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                                        price6 = mPrice.SALES_Precio_GEX__c;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                when 'Costo Fijo'{
                                    List<dsalesCP__c> codigoPos = DSALES_QuoteGexWrapperRequest_Helper.consultaCodigoPostal(data);
                                    if(codigoPos != null && !codigoPos.isEmpty()){
                                        priceIns = item2.Product2.dsalesPrecioUnico__c;
                                    }else{
                                        priceIns = 0.0;
                                    }
                                }   
                            }
                            if (price1 != 0.0) {
                                QuoteLineItem partidapreGEX1 = new QuoteLineItem();
                                partidapreGEX1.QuoteId = cotizaId;
                                partidapreGEX1.PricebookEntryId = item2.Id;
                                partidapreGEX1.Product2Id = item2.Product2Id;
                                partidapreGEX1.Quantity = 1;
                                partidapreGEX1.UnitPrice = price1;
                                partidapreGEX1.Vigencia_meses__c = '12';
                                partidapreGEX1.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX1.DSALES_NombreProductoServicio__c = 'GARANTÍA EXTENDIDA 12M SKU' + ' ' + item.product2.StockKeepingUnit;
                                partidapreGEX1.dsalesIdSecuencia__c = i;
                                partidapreGEX1.dsalesSkuTangible__c = item.product2.StockKeepingUnit;
                                listaPartida.add(partidapreGEX1);
                            }    
                            if (price2 != 0.0) {
                                QuoteLineItem partidapreGEX2 = new QuoteLineItem();
                                partidapreGEX2.QuoteId = cotizaId;
                                partidapreGEX2.PricebookEntryId = item2.Id;
                                partidapreGEX2.Product2Id = item2.Product2Id;
                                partidapreGEX2.Quantity = 1;
                                partidapreGEX2.UnitPrice = price2;
                                partidapreGEX2.Vigencia_meses__c = '24';
                                partidapreGEX2.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX2.DSALES_NombreProductoServicio__c = 'GARANTÍA EXTENDIDA 24M SKU' + ' ' + item.product2.StockKeepingUnit;
                                partidapreGEX2.dsalesIdSecuencia__c = i;
                                partidapreGEX2.dsalesSkuTangible__c =item.product2.StockKeepingUnit;
                                listaPartida.add(partidapreGEX2);
                            }
                            if (price3 != 0.0) {
                                QuoteLineItem partidapreGEX3 = new QuoteLineItem();
                                partidapreGEX3.QuoteId = cotizaId;
                                partidapreGEX3.PricebookEntryId = item2.Id;
                                partidapreGEX3.Product2Id = item2.Product2Id;
                                partidapreGEX3.Quantity = 1;
                                partidapreGEX3.UnitPrice = price3;
                                partidapreGEX3.Vigencia_meses__c = '36';
                                partidapreGEX3.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX3.DSALES_NombreProductoServicio__c = 'GARANTÍA EXTENDIDA 36M SKU' + ' ' + item.product2.StockKeepingUnit;
                                partidapreGEX3.dsalesIdSecuencia__c = i;
                                partidapreGEX3.dsalesSkuTangible__c = item.product2.StockKeepingUnit;
                                listaPartida.add(partidapreGEX3);
                            }    
                            if (price4 != 0.0) {
                                QuoteLineItem partidapreGEX4 = new QuoteLineItem();
                                partidapreGEX4.QuoteId = cotizaId;
                                partidapreGEX4.PricebookEntryId = item2.Id;
                                partidapreGEX4.Product2Id = item2.Product2Id;
                                partidapreGEX4.Quantity = 1;
                                partidapreGEX4.UnitPrice = price4;
                                partidapreGEX4.Vigencia_meses__c = '48';
                                partidapreGEX4.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX4.DSALES_NombreProductoServicio__c = 'GARANTÍA EXTENDIDA 48M SKU' + ' ' + item.product2.StockKeepingUnit;
                                partidapreGEX4.dsalesIdSecuencia__c = i;
                                partidapreGEX4.dsalesSkuTangible__c =item.product2.StockKeepingUnit;
                                listaPartida.add(partidapreGEX4);
                            } 
                            if (price5 != 0.0) {
                                QuoteLineItem partidapreGEX5 = new QuoteLineItem();
                                partidapreGEX5.QuoteId = cotizaId;
                                partidapreGEX5.PricebookEntryId = item2.Id;
                                partidapreGEX5.Product2Id = item2.Product2Id;
                                partidapreGEX5.Quantity = 1;
                                partidapreGEX5.UnitPrice = price5;
                                partidapreGEX5.Vigencia_meses__c = '60';
                                partidapreGEX5.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX5.DSALES_NombreProductoServicio__c = 'GARANTÍA EXTENDIDA 60M SKU' + ' ' + item.product2.StockKeepingUnit;
                                partidapreGEX5.dsalesIdSecuencia__c = i;
                                partidapreGEX5.dsalesSkuTangible__c = item.product2.StockKeepingUnit;
                                listaPartida.add(partidapreGEX5);
                            }    
                            if (price6 != 0.0) {
                                QuoteLineItem partidapreGEX6 = new QuoteLineItem();
                                partidapreGEX6.QuoteId = cotizaId;
                                partidapreGEX6.PricebookEntryId = item2.Id;
                                partidapreGEX6.Product2Id = item2.Product2Id;
                                partidapreGEX6.Quantity = 1;
                                partidapreGEX6.UnitPrice = price6;
                                partidapreGEX6.Vigencia_meses__c = '72';
                                partidapreGEX6.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX6.DSALES_NombreProductoServicio__c = 'GARANTÍA EXTENDIDA 72M SKU' + ' ' + item.product2.StockKeepingUnit;
                                partidapreGEX6.dsalesIdSecuencia__c = i;
                                partidapreGEX6.dsalesSkuTangible__c =item.product2.StockKeepingUnit;
                                listaPartida.add(partidapreGEX6);
                            } 
                            if(priceAm != 0.0){
                                QuoteLineItem partidapreGEX2 = new QuoteLineItem();
                                partidapreGEX2.QuoteId = cotizaId;
                                partidapreGEX2.PricebookEntryId = item2.Id;
                                partidapreGEX2.Product2Id = item2.Product2Id;
                                partidapreGEX2.Quantity = 1;
                                partidapreGEX2.UnitPrice = priceAm;
                                partidapreGEX2.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX2.DSALES_NombreProductoServicio__c = 'ARMADO' + ' ' + item.product2.dsalesAR__c+'MIN SKU'+' '+ item.product2.StockKeepingUnit;
                                partidapreGEX2.dsalesIdSecuencia__c = i;
                                partidapreGEX2.dsalesSkuTangible__c =item.product2.StockKeepingUnit;
                                partidapreGEX2.dsalesAR__c=item.Product2.dsalesAR__c;//////////////////////
                                listaPartida.add(partidapreGEX2);
                            }
                            if(priceIns != 0.0){
                                dsalesCP__c codigosPostales = [SELECT Name, dsalesCiudad__r.Name, dsalesCiudad__r.dsalesRegion__c FROM dsalesCP__c WHERE Name=: data.codigoPostal LIMIT 1];
                                System.debug('Codigo Postal'+codigosPostales );
                                dsalesAsignRegion__c proveedoresAsignados = [SELECT dsalesProveedor__r.Name FROM dsalesAsignRegion__c WHERE dsalesIsActive__c=true AND dsalesRegion__c=:codigosPostales.dsalesCiudad__r.dsalesRegion__c LIMIT 1];
                                System.debug('proveedor Asignado'+proveedoresAsignados );
                                QuoteLineItem partidapreIns = new QuoteLineItem();
                                partidapreIns.QuoteId = cotizaId;
                                partidapreIns.PricebookEntryId = item2.Id;
                                partidapreIns.Product2Id = item2.Product2Id;
                                partidapreIns.Quantity = 1;
                                partidapreIns.UnitPrice = priceIns;
                                partidapreIns.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreIns.DSALES_NombreProductoServicio__c = 'INSTALACION' + ' ' +'SKU'+' '+ item.product2.StockKeepingUnit;
                                partidapreIns.dsalesIdSecuencia__c = i;
                                partidapreIns.dsalesSkuTangible__c =item.product2.StockKeepingUnit;
                                partidapreIns.dSalesProveedor__c=proveedoresAsignados.dsalesProveedor__r.Name;
                                listaPartida.add(partidapreIns);
                            }
                        }
                    }
                }
            }
        }   
        if (Schema.sObjectType.QuoteLineItem.isCreateable()) {
            insert listaPartida;
        }
        return listaPartida;
    }
    
    public static List<QuoteLineItem> crearPartidasSinTangible(DSALES_QuoteGexWrapper.QuoteGexRequest data, Id cotizaId,Tienda__c tienda){
        List<QuoteLineItem> listaPartida = new List<QuoteLineItem>();
        List<DSales_Asignacion_de_Productos__c> productAsig = new List<DSales_Asignacion_de_Productos__c>();       
        Map<String, DSALES_QuoteGexWrapper.Product> mapProducts = new  Map<String, DSALES_QuoteGexWrapper.Product>();
        for(DSALES_QuoteGexWrapper.Product p : data.productos){
            mapProducts.put(p.skuDeTangible, p);
        }
        List<Product2> produc = [SELECT Id,Name,StockKeepingUnit,DSALES_Categoria__c,DSALES_Clase__c,DSALES_Familia__c,DSales_Aplicaporcentajecobro__c,DSales_PorcentajeCobro__c, dsalesAR__c FROM Product2 WHERE StockKeepingUnit in: mapProducts.keySet() WITH SECURITY_ENFORCED];
        productAsig = [SELECT id, Name, DSales_Servicio_Seguro__c,DSales_Servicio_Seguro__r.DSALES_ServEspecifico__c, DSales_Producto__c,DSALES_SKU__c FROM DSales_Asignacion_de_Productos__c WHERE DSALES_Activo__c=true AND  DSales_Producto__r.StockKeepingUnit in: mapProducts.keySet() WITH SECURITY_ENFORCED];
        System.debug('productAsig'+productAsig);
        List<Id> dsalesProductoSetId = new List<Id>();
        for(DSales_Asignacion_de_Productos__c da : productAsig){
            dsalesProductoSetId.add(da.DSales_Servicio_Seguro__c);
        }
        
        System.debug('dsalesProductoSetId TEST::: '+dsalesProductoSetId);////////////////
        
        List<Pricebook2> precioLista = [SELECT Id,Name FROM Pricebook2 WHERE Name= 'Standard Price Book' and IsActive=true WITH SECURITY_ENFORCED LIMIT 1];
        List<PricebookEntry> precioEn = [SELECT Id,UnitPrice,Name,Product2Id,Pricebook2Id,Product2.StockKeepingUnit,Product2.dsalesAR__c,Product2.DSales_PorcentajeCobro__c,Product2.DSales_Aplicaporcentajecobro__c FROM PricebookEntry WHERE Product2Id =: produc AND Pricebook2Id=: precioLista WITH SECURITY_ENFORCED];
        System.debug('precioEn'+precioEn);
        List<PricebookEntry> precioEnGEX = [SELECT Id,Name,UnitPrice,Product2Id,Pricebook2Id,Product2.StockKeepingUnit,Product2.dsalesAR__c,Product2.DSales_Tipo_de_Producto__c,Product2.DSales_PorcentajeCobro__c,Product2.DSales_Aplicaporcentajecobro__c, Product2.Description,Product2.dsalesFormasCobro__c,Product2.dsalesPrecioUnico__c FROM PricebookEntry WHERE Product2Id =: dsalesProductoSetId and Pricebook2Id=: precioLista WITH SECURITY_ENFORCED];
        System.debug('precioEnGEX'+precioEnGEX);        
        for(PricebookEntry item : precioEn){
            DSALES_QuoteGexWrapper.Product p =  mapProducts.get(item.Product2.StockKeepingUnit);
            for (Integer i = 0; i < p.cantidadProductosTangibles; i++) {
                QuoteLineItem partidapre = new QuoteLineItem();
                Product2 producto = new Product2();
                for(Product2 pro: produc){
                    if(pro.StockKeepingUnit == item.Product2.StockKeepingUnit){
                        producto = pro;
                    }
                }
                List<String> intangibleIds = new List<String>();
                for(DSales_Asignacion_de_Productos__c asigProduc: productAsig){
                    if(asigProduc.DSales_Producto__c == item.Product2Id){
                        intangibleIds.add(asigProduc.DSales_Servicio_Seguro__c);
                    }
                }
                for (String intangibleId : intangibleIds) {
                    for(PricebookEntry item2 : precioEnGEX){
                        if(item2.Product2Id == intangibleId){
                            QuoteLineItem partidapreGEX = new QuoteLineItem();
                            Double price1=0;
                            Double price2=0;
                            Double price3=0;
                            Double price4=0;
                            Double price5=0;
                            Double price6=0;
                            Double priceAm=0;
                            Double priceIns=0;
                            
                            switch on item2.Product2.dsalesFormasCobro__c{
                                when 'Porcentaje de Cobro'{
                                    List<DASALES_Porcentajedecobro__c> porcent = DSALES_QuoteGexWrapperRequest_Helper.obtenerPorcentajeCobro(intangibleId);
                                    for(DASALES_Porcentajedecobro__c percent: porcent){
                                        Integer year = Integer.valueOf(percent.DSALES_Anios__c);
                                        Decimal price = (p.precioTangible * percent.DSALES_Porcentaje__c)/100;
                                        switch on year{
                                            when 1{
                                                price1 = price;
                                            }
                                            when 2{
                                                price2 = price;
                                            }
                                            when 3{
                                                price3 = price;
                                            }
                                            when 4{
                                                price4 = price;
                                            }
                                            when 5{
                                                price5 = price;
                                            }
                                            when 6{
                                                price6 = price;
                                            }
                                        }
                                    }
                                }
                                when 'Matriz de Precios'{
                                    System.debug('----Entro a matriz de precio----');
                                    List<dsalesAsignacionDeTienda__c> asigTienda = [SELECT Id, Name, dsalesTienda__r.Name, dsalesMatriz__r.Name, dsalesMatriz__r.DSALES_Servicio__r.Name, dsalesMatriz__r.DSALES_Servicio__c,dsalesActivo__c,dsalesMatriz__c FROM dsalesAsignacionDeTienda__c WHERE dsalesTienda__c=:tienda.Id AND dsalesActivo__c=true AND dsalesMatriz__c<>null AND dsalesMatriz__r.DSALES_Servicio__c=:intangibleId WITH SECURITY_ENFORCED LIMIT 1];
                                    System.debug('TIENDA LISTA::: '+asigTienda);///////////////////////////////
                                    
                                    if(asigTienda.size()>0){    
                                        List<DSALES_Matriz_de_Cotizacion__c> matrizPrecio = DSALES_QuoteGexWrapperRequest_Helper.obtenerMatricesPrecio(asigTienda[0].dsalesMatriz__c);
                                        
                                        System.debug('MATIRZ LISTA::: '+matrizPrecio);////////////////////////
                                        
                                        for(DSALES_Matriz_de_Cotizacion__c mPrice : matrizPrecio){
                                            switch on mPrice.DSALES_Tiempo_de_Garantia_Extendida_GEX__c{
                                                when '1 año'{
                                                    if(item2.Product2.DSales_Tipo_de_Producto__c=='Armado de muebles' || item2.Product2.DSales_Tipo_de_Producto__c=='Armado de Muebles' || item2.Product2.Description.contains('Armado')){
                                                        if(mPrice.DSALES_Rango_interior_GEX__c<= item.Product2.dsalesAR__c && mPrice.DSALES_Rango_Superior_GEX__c>=item.Product2.dsalesAR__c){
                                                            priceAm = mPrice.SALES_Precio_GEX__c;
                                                            System.debug('Precio de armado @@@@@@@@ '+priceAm);
                                                        }
                                                    }
                                                    else{
                                                        if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                                            price1 = mPrice.SALES_Precio_GEX__c;
                                                        }
                                                    }
                                                }
                                                when '2 años'{
                                                    if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                                        price2 = mPrice.SALES_Precio_GEX__c;
                                                    }
                                                }
                                                when '3 años'{
                                                    if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                                        price3 = mPrice.SALES_Precio_GEX__c;
                                                    }
                                                }
                                                when '4 años'{
                                                    if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                                        price4 = mPrice.SALES_Precio_GEX__c;
                                                    }
                                                }
                                                when '5 años'{
                                                    if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                                        price5 = mPrice.SALES_Precio_GEX__c;
                                                    }
                                                }
                                                when '6 años'{
                                                    if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                                        price6 = mPrice.SALES_Precio_GEX__c;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                when 'Costo Fijo'{
                                    List<dsalesCP__c> codigoPos = DSALES_QuoteGexWrapperRequest_Helper.consultaCodigoPostal(data);
                                    if(codigoPos != null && !codigoPos.isEmpty()){
                                        priceIns = item2.Product2.dsalesPrecioUnico__c;
                                    }else{
                                        priceIns = 0.0;
                                    }
                                }   
                            }
                            if (price1 != 0.0) {
                                QuoteLineItem partidapreGEX1 = new QuoteLineItem();
                                partidapreGEX1.QuoteId = cotizaId;
                                partidapreGEX1.PricebookEntryId = item2.Id;
                                partidapreGEX1.Product2Id = item2.Product2Id;
                                partidapreGEX1.Quantity = 1;
                                partidapreGEX1.UnitPrice = price1;
                                partidapreGEX1.Vigencia_meses__c = '12';
                                partidapreGEX1.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX1.DSALES_NombreProductoServicio__c = 'GARANTÍA EXTENDIDA 12M SKU' + ' ' + item.product2.StockKeepingUnit;
                                partidapreGEX1.dsalesIdSecuencia__c = i;
                                partidapreGEX1.dsalesSkuTangible__c = item.product2.StockKeepingUnit;
                                listaPartida.add(partidapreGEX1);
                            }    
                            if (price2 != 0.0) {
                                QuoteLineItem partidapreGEX2 = new QuoteLineItem();
                                partidapreGEX2.QuoteId = cotizaId;
                                partidapreGEX2.PricebookEntryId = item2.Id;
                                partidapreGEX2.Product2Id = item2.Product2Id;
                                partidapreGEX2.Quantity = 1;
                                partidapreGEX2.UnitPrice = price2;
                                partidapreGEX2.Vigencia_meses__c = '24';
                                partidapreGEX2.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX2.DSALES_NombreProductoServicio__c = 'GARANTÍA EXTENDIDA 24M SKU' + ' ' + item.product2.StockKeepingUnit;
                                partidapreGEX2.dsalesIdSecuencia__c = i;
                                partidapreGEX2.dsalesSkuTangible__c =item.product2.StockKeepingUnit;
                                listaPartida.add(partidapreGEX2);
                            }
                            if (price3 != 0.0) {
                                QuoteLineItem partidapreGEX3 = new QuoteLineItem();
                                partidapreGEX3.QuoteId = cotizaId;
                                partidapreGEX3.PricebookEntryId = item2.Id;
                                partidapreGEX3.Product2Id = item2.Product2Id;
                                partidapreGEX3.Quantity = 1;
                                partidapreGEX3.UnitPrice = price3;
                                partidapreGEX3.Vigencia_meses__c = '36';
                                partidapreGEX3.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX3.DSALES_NombreProductoServicio__c = 'GARANTÍA EXTENDIDA 36M SKU' + ' ' + item.product2.StockKeepingUnit;
                                partidapreGEX3.dsalesIdSecuencia__c = i;
                                partidapreGEX3.dsalesSkuTangible__c = item.product2.StockKeepingUnit;
                                listaPartida.add(partidapreGEX3);
                            }    
                            if (price4 != 0.0) {
                                QuoteLineItem partidapreGEX4 = new QuoteLineItem();
                                partidapreGEX4.QuoteId = cotizaId;
                                partidapreGEX4.PricebookEntryId = item2.Id;
                                partidapreGEX4.Product2Id = item2.Product2Id;
                                partidapreGEX4.Quantity = 1;
                                partidapreGEX4.UnitPrice = price4;
                                partidapreGEX4.Vigencia_meses__c = '48';
                                partidapreGEX4.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX4.DSALES_NombreProductoServicio__c = 'GARANTÍA EXTENDIDA 48M SKU' + ' ' + item.product2.StockKeepingUnit;
                                partidapreGEX4.dsalesIdSecuencia__c = i;
                                partidapreGEX4.dsalesSkuTangible__c =item.product2.StockKeepingUnit;
                                listaPartida.add(partidapreGEX4);
                            } 
                            if (price5 != 0.0) {
                                QuoteLineItem partidapreGEX5 = new QuoteLineItem();
                                partidapreGEX5.QuoteId = cotizaId;
                                partidapreGEX5.PricebookEntryId = item2.Id;
                                partidapreGEX5.Product2Id = item2.Product2Id;
                                partidapreGEX5.Quantity = 1;
                                partidapreGEX5.UnitPrice = price5;
                                partidapreGEX5.Vigencia_meses__c = '60';
                                partidapreGEX5.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX5.DSALES_NombreProductoServicio__c = 'GARANTÍA EXTENDIDA 60M SKU' + ' ' + item.product2.StockKeepingUnit;
                                partidapreGEX5.dsalesIdSecuencia__c = i;
                                partidapreGEX5.dsalesSkuTangible__c = item.product2.StockKeepingUnit;
                                listaPartida.add(partidapreGEX5);
                            }    
                            if (price6 != 0.0) {
                                QuoteLineItem partidapreGEX6 = new QuoteLineItem();
                                partidapreGEX6.QuoteId = cotizaId;
                                partidapreGEX6.PricebookEntryId = item2.Id;
                                partidapreGEX6.Product2Id = item2.Product2Id;
                                partidapreGEX6.Quantity = 1;
                                partidapreGEX6.UnitPrice = price6;
                                partidapreGEX6.Vigencia_meses__c = '72';
                                partidapreGEX6.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX6.DSALES_NombreProductoServicio__c = 'GARANTÍA EXTENDIDA 72M SKU' + ' ' + item.product2.StockKeepingUnit;
                                partidapreGEX6.dsalesIdSecuencia__c = i;
                                partidapreGEX6.dsalesSkuTangible__c =item.product2.StockKeepingUnit;
                                listaPartida.add(partidapreGEX6);
                            } 
                            if(priceAm != 0.0){
                                QuoteLineItem partidapreGEX2 = new QuoteLineItem();
                                partidapreGEX2.QuoteId = cotizaId;
                                partidapreGEX2.PricebookEntryId = item2.Id;
                                partidapreGEX2.Product2Id = item2.Product2Id;
                                partidapreGEX2.Quantity = 1;
                                partidapreGEX2.UnitPrice = priceAm;
                                partidapreGEX2.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreGEX2.DSALES_NombreProductoServicio__c = 'ARMADO' + ' ' + item.product2.dsalesAR__c+'MIN SKU'+' '+ item.product2.StockKeepingUnit;
                                partidapreGEX2.dsalesIdSecuencia__c = i;
                                partidapreGEX2.dsalesSkuTangible__c =item.product2.StockKeepingUnit;
                                partidapreGEX2.dsalesAR__c=item.Product2.dsalesAR__c;//////////////////////
                                listaPartida.add(partidapreGEX2);
                            }
                            if(priceIns != 0.0){
                                dsalesCP__c codigosPostales = [SELECT Name, dsalesCiudad__r.Name, dsalesCiudad__r.dsalesRegion__c FROM dsalesCP__c WHERE Name=: data.codigoPostal LIMIT 1];
                                System.debug('Codigo Postal'+codigosPostales );
                                dsalesAsignRegion__c proveedoresAsignados = [SELECT dsalesProveedor__r.Name FROM dsalesAsignRegion__c WHERE dsalesIsActive__c=true AND dsalesRegion__c=:codigosPostales.dsalesCiudad__r.dsalesRegion__c LIMIT 1];
                                System.debug('proveedor Asignado'+proveedoresAsignados );
                                QuoteLineItem partidapreIns = new QuoteLineItem();
                                partidapreIns.QuoteId = cotizaId;
                                partidapreIns.PricebookEntryId = item2.Id;
                                partidapreIns.Product2Id = item2.Product2Id;
                                partidapreIns.Quantity = 1;
                                partidapreIns.UnitPrice = priceIns;
                                partidapreIns.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreIns.DSALES_NombreProductoServicio__c = 'INSTALACION' + ' ' +'SKU'+' '+ item.product2.StockKeepingUnit;
                                partidapreIns.dsalesIdSecuencia__c = i;
                                partidapreIns.dsalesSkuTangible__c =item.product2.StockKeepingUnit;
                                partidapreIns.dSalesProveedor__c=proveedoresAsignados.dsalesProveedor__r.Name;
                                listaPartida.add(partidapreIns);
                            }
                        }
                    }
                }
            }
        }     
        if (Schema.sObjectType.QuoteLineItem.isCreateable()) {
            insert listaPartida;
        }
        return listaPartida;
    }
    
    public static List<QuoteLineItem> crearPartidasExterno(DSALES_QuoteGexWrapper.QuoteGexRequest data, Id cotizaId,Tienda__c tienda){
        System.debug('Entro a externo');
        List<QuoteLineItem> listaPartida = new List<QuoteLineItem>(); 
        
        dsalesCP__c codigosPostales = [SELECT dsalesCiudad__r.Name, dsalesCiudad__r.dsalesRegion__c FROM dsalesCP__c WHERE Name=: data.codigoPostal LIMIT 1];
        System.debug('codigos postales '+codigosPostales);
        dsalesAsignRegion__c proveedoresAsignados = [SELECT Name,dsalesProveedor__c,dsalesProveedor__r.Name FROM dsalesAsignRegion__c WHERE dsalesIsActive__c=true AND dsalesRegion__c=:codigosPostales.dsalesCiudad__r.dsalesRegion__c];
        System.debug('proveedores asignados '+proveedoresAsignados);
        List<dsalesAsignacionProveedores__c> serviciosAsignados = [SELECT Name,dsalesProducto__c,dsalesProducto__r.IsActive,dsalesProducto__r.StockKeepingUnit,dsalesProducto__r.DSALES_ServEspecifico__c,dsalesProducto__r.dsalesPrecioUnico__c, dsalesProducto__r.dsalesFormasCobro__c FROM dsalesAsignacionProveedores__c WHERE dsalesProveedor__c=:proveedoresAsignados.dsalesProveedor__c];
		System.debug('Servicios asignados '+serviciosAsignados);
        List<Id> dsalesProductoSetId = new List<Id>();
        for(dsalesAsignacionProveedores__c da : serviciosAsignados){
            dsalesProductoSetId.add(da.dsalesProducto__c);
        }
		System.debug('@@@@@@@@@@@q '+dsalesProductoSetId);
        List<Pricebook2> precioLista = [SELECT Id,Name FROM Pricebook2 WHERE Name= 'Standard Price Book' and IsActive=true WITH SECURITY_ENFORCED LIMIT 1];
        List<PricebookEntry> precioEntradaInstalacion = [SELECT Id,Name,UnitPrice,Product2Id,Pricebook2Id,Product2.StockKeepingUnit,Product2.dsalesAR__c,Product2.DSales_Tipo_de_Producto__c,Product2.DSales_PorcentajeCobro__c,Product2.DSales_Aplicaporcentajecobro__c, Product2.Description,Product2.dsalesFormasCobro__c,Product2.dsalesPrecioUnico__c FROM PricebookEntry WHERE Product2Id =:dsalesProductoSetId and Pricebook2Id=: precioLista WITH SECURITY_ENFORCED];     
            //for (Integer i = 0; i < p.cantidadProductosTangibles; i++) {
                QuoteLineItem partidapre = new QuoteLineItem();
                    for(PricebookEntry item2 : precioEntradaInstalacion){
                            QuoteLineItem partidapreGEX = new QuoteLineItem();
                            Double priceIns=0;
                            
                            switch on item2.Product2.dsalesFormasCobro__c{
                                when 'Costo Fijo'{
                                    List<dsalesCP__c> codigoPos = DSALES_QuoteGexWrapperRequest_Helper.consultaCodigoPostal(data);
                                    if(codigoPos != null && !codigoPos.isEmpty()){
                                        priceIns = item2.Product2.dsalesPrecioUnico__c;
                                    }else{
                                        priceIns = 0.0;
                                    }
                                }   
                            }
                            if(priceIns != 0.0){
                                QuoteLineItem partidapreIns = new QuoteLineItem();
                                partidapreIns.QuoteId = cotizaId;
                                partidapreIns.PricebookEntryId = item2.Id;
                                partidapreIns.Product2Id = item2.Product2Id;
                                partidapreIns.Quantity = 1;
                                partidapreIns.UnitPrice = priceIns;
                                partidapreIns.DSALES_ListaArticulo__c = item2.Product2.DSales_Tipo_de_Producto__c;
                                partidapreIns.DSALES_NombreProductoServicio__c = 'INSTALACION' + ' ' +'PRODUCTO'+' '+ 'EXTERNO';
                                partidapreIns.dsalesIdSecuencia__c = 0;
                                partidapreIns.dsalesSkuTangible__c ='EXTERN';
                                partidapreIns.dSalesProveedor__c=proveedoresAsignados.dsalesProveedor__r.Name;
                                listaPartida.add(partidapreIns);
                            }
                    }
            //}  
        if (Schema.sObjectType.QuoteLineItem.isCreateable()) {
            insert listaPartida;
        }
        return listaPartida;
    }
}