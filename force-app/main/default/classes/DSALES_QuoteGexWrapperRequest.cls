@RestResource(urlMapping='/insertQuoteGex/*')
global with sharing class DSALES_QuoteGexWrapperRequest {

    @HttpPost
    global static DSALES_QuoteGexWrapper.respuestaNPV createQuote(){
        
        Boolean success = true;
        String message = '';
        String code = '';
        String regions = 'Todas las regiones';
        String originalMat = 'Matriz Original';
        Account cliente = new Account();
        Opportunity oppor = new Opportunity();
        Quote cotiza = new Quote();
        Map<String, DSALES_QuoteGexWrapper.Product> mapProducts = new  Map<String, DSALES_QuoteGexWrapper.Product>();
        List<QuoteLineItem> listaPartida = new List<QuoteLineItem>();
        List<DSales_Asignacion_de_Productos__c> productAsig = new List<DSales_Asignacion_de_Productos__c>();  
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    DSALES_QuoteGexWrapper.QuoteGexRequest data = (DSALES_QuoteGexWrapper.QuoteGexRequest)JSON.deserialize(body, DSALES_QuoteGexWrapper.QuoteGexRequest.class); 
                     //Map<String, DSALES_QuoteGexWrapper.Product> mapProducts = new  Map<String, DSALES_QuoteGexWrapper.Product>();
                    for(DSALES_QuoteGexWrapper.Product p : data.productos){
                        mapProducts.put(p.skuDeTangible, p);
                        system.debug('mapProductsUpdate:__ '+mapProducts);
                    }
                    system.debug('mapProducts FINAL:__ '+mapProducts);
                    List<Product2> produc = [SELECT Id,Name,StockKeepingUnit,DSALES_Categoria__c,DSALES_Clase__c,DSALES_Familia__c,DSales_Aplicaporcentajecobro__c,DSales_PorcentajeCobro__c FROM Product2 WHERE StockKeepingUnit in: mapProducts.keySet() WITH SECURITY_ENFORCED];
                    system.debug('produc:__ '+produc);
                    productAsig = [SELECT id, Name, DSales_Servicio_Seguro__c, DSales_Producto__c,DSALES_SKU__c FROM DSales_Asignacion_de_Productos__c WHERE DSALES_Activo__c=true AND  DSales_Producto__r.StockKeepingUnit in: mapProducts.keySet() WITH SECURITY_ENFORCED];
                    system.debug('productAsig:__ '+productAsig);
                    List<Id> dsalesProductoSetId = new List<Id>();
                    for(DSales_Asignacion_de_Productos__c da : productAsig){
                        dsalesProductoSetId.add(da.DSales_Servicio_Seguro__c);
                    }
                    system.debug('dsalesProductoSetId:__ '+dsalesProductoSetId);
                    Account universalAccount = [Select Id,DSALES_ClienteCoppel__c from Account WHERE DSALES_ClienteCoppel__c = :DSALES_Utility.NUMERO_CLIENTE_GENERICO WITH SECURITY_ENFORCED LIMIT 1];
                    Tienda__c tienda = [Select Id from Tienda__c WHERE DSales_TiendaID__c =: data.idTienda WITH SECURITY_ENFORCED LIMIT 1];
                    
                    Id clienteId=null;
                    String numeroDeContado=null;
                    Map<String, String> mapNomyId=new Map<String, String>();
                    if(data.numeroCliente == '' || data.numeroCliente == null ){
                        List<Account> clienteContado = [SELECT Id,FirstName,LastName FROM Account WHERE FirstName=: data.nombre and LastName=: data.apellidoPaterno and PersonEmail= :data.correoElectronico WITH SECURITY_ENFORCED];
                        clienteId = clienteContado[0].Id;
                        mapNomyId.put('firstName',clienteContado[0].FirstName);
                        mapNomyId.put('lastName',clienteContado[0].LastName);
                        mapNomyId.put('clienteId',clienteId);
                        oppor = crearOportunidad(data, mapNomyId ,tienda);
                        mapNomyId.put('oportunidadId',oppor.Id);
                        cotiza = crearCotizacion(data, mapNomyId ,tienda);
                        listaPartida = crearPartidas(data, cotiza.Id);
                    }else{
                        if(data.numeroCliente != DSALES_Utility.NUMERO_CLIENTE_GENERICO){
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
                        		    listaPartida = crearPartidas(data, cotiza.Id);
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
                                    listaPartida = crearPartidas(data, cotiza.Id);
                                }
                            }
                        }else{
                            clienteId = universalAccount.Id;
                            numeroDeContado = universalAccount.DSALES_ClienteCoppel__c;
                            mapNomyId.put('firstName',data.nombre);
                            mapNomyId.put('lastName',data.apellidoPaterno);
                            mapNomyId.put('clienteId',clienteId);
                            mapNomyId.put('correo',data.correoElectronico);
                            mapNomyId.put('numeroContado',numeroDeContado);
                            oppor = crearOportunidad(data, mapNomyId,tienda);
                           	mapNomyId.put('oportunidadId',oppor.Id);
                            cotiza = crearCotizacion(data,mapNomyId, tienda);
                        	listaPartida = crearPartidas(data, cotiza.Id);
                        }
                    }    
                }catch(JSONException e){
                    success = false;
                    code = String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    message = DSALES_Utility.BAD_REQUEST_MSJ;
                }catch(Exception e){
                    success = false;
                    code = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    message = DSALES_Utility.INTERNAL_ERROR_MSJ + ' ' +e.getMessage() + ' '+e.getLineNumber() + ' '+ e.getCause();
                }
            }
        }
        DSALES_QuoteGexWrapper.RespuestaNPV respuestaNpvList = new DSALES_QuoteGexWrapper.RespuestaNPV();
        respuestaNpvList.idCotizacion = cotiza.Id;
        respuestaNpvList.idOportunidad = oppor.Id;
        respuestaNpvList.iduVenta = oppor.dsalesIduVenta__c;
        respuestaNpvList.success = success;
        respuestaNpvList.codigoError = code;
        respuestaNpvList.mensajeError = message;
        respuestaNpvList.respuesta =  new List<DSALES_QuoteGexWrapper.QuoteGexResponse>();
        respuestaNpvList.descripciones =  responseDescription('Servicio',cotiza.Id);
        
        List<QuoteLineItem> consultaRespuesta = new List<QuoteLineItem> ();
        List<QuoteLineItem> consultaRespuestaGEX = new List<QuoteLineItem> ();
        
        for(QuoteLineItem item: [Select Id,Product2.Id,Product2.Name,Product2.Description,ListPrice,UnitPrice,Quantity,Vigencia_meses__c,DSALES_SKU__c,Quote.GrandTotal,Product2.DSales_Tipo_de_Producto__c,Product2.DSALES_Familia__r.Name,Product2.DSALES_Clase__r.Name,Product2.DSALES_Categoria__r.Name,Product2.DSales_Aplicaporcentajecobro__c from QuoteLineItem WHERE QuoteId=: cotiza.Id WITH SECURITY_ENFORCED]){
            if(item.Product2.DSales_Tipo_de_Producto__c == 'Producto'){
                consultaRespuesta.add(item);
            }else{
                consultaRespuestaGEX.add(item);
            }
        }
        if(consultaRespuesta.isEmpty()){
            DSALES_QuoteGexWrapper.QuoteGexResponse responsePayloadError = new DSALES_QuoteGexWrapper.QuoteGexResponse();
            responsePayloadError.nombreIntangible = null;
            responsePayloadError.precio = null;
            responsePayloadError.costoTotal = null;
            responsePayloadError.skuDeTangible = null;
            responsePayloadError.skuDePrecio = null;
            responsePayloadError.skuDeServicio = null;
            respuestaNpvList.success = false;
            respuestaNpvList.codigoError = code;
            respuestaNpvList.mensajeError = message;
            //respuestaNpvList.codigoError = String.valueOf(DSALES_Utility.NOASIGNAMENT_REQUEST_CODE);
            //respuestaNpvList.mensajeError = DSALES_Utility.NOASIGNAMENT_ERROR_MSJ;
            respuestaNpvList.respuesta.add(responsePayloadError);
            return respuestaNpvList;
        }else{
            for (QuoteLineItem quoteLineItem : listaPartida) {
                Product2 tipoProducto = [SELECT id,DSales_Tipo_de_Producto__c, StockKeepingUnit,DSales_Aplicaporcentajecobro__c FROM Product2 WHERE id=:quoteLineItem.Product2Id WITH SECURITY_ENFORCED];
                if (tipoProducto.DSales_Tipo_de_Producto__c == 'Servicio') {
                    DSALES_QuoteGexWrapper.QuoteGexResponse responsePayload = new DSALES_QuoteGexWrapper.QuoteGexResponse();
                    DSales_Matriz_GEX__c idMat = obtenerIdMatriz(tipoProducto.Id,regions, originalMat);
                    Id idMatriz = idMat.Id;
                    String nombreIntangible = quoteLineItem.DSALES_NombreProductoServicio__c;
                    String[] partesCadena = nombreIntangible.split(' ');
                    String numeroExtraido = partesCadena[4];
                    Decimal precioTangible = 0.0;
                    if (mapProducts.containsKey(numeroExtraido)) {
                        DSALES_QuoteGexWrapper.Product product = mapProducts.get(numeroExtraido);
                        precioTangible = product.precioTangible;
                    }
                    responsePayload.costoTotal = precioTangible + quoteLineItem.UnitPrice;
                    responsePayload.precio = quoteLineItem.UnitPrice;
                    responsePayload.nombreIntangible = nombreIntangible;
                    responsePayload.skuDeTangible = numeroExtraido;
                    if(tipoProducto.DSales_Aplicaporcentajecobro__c==true){
                             responsePayload.skuDePrecio = null;
                        }else{
                            DSALES_Matriz_de_Cotizacion__c skuPrecio = obtenerSkuPrecio(quoteLineItem.UnitPrice, precioTangible, idMatriz);
                            responsePayload.skuDePrecio = skuPrecio.Name;

                        }
                    responsePayload.skuDeServicio = tipoProducto.StockKeepingUnit;
                    responsePayload.mesesCobertura = quoteLineItem.Vigencia_meses__c;
                    responsePayload.idSecuencia = Integer.valueOf(quoteLineItem.dsalesIdSecuencia__c);
                    responsePayload.idPartidaDePresupuesto = quoteLineItem.Id;
                    respuestaNpvList.respuesta.add(responsePayload);
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
    
    public static Opportunity crearOportunidad (DSALES_QuoteGexWrapper.QuoteGexRequest data,/*Id clienteId, String firstName, String lastName*/Map<String, String> mapNomyId, Tienda__c tienda){
       Opportunity oppor = new Opportunity();
        String clienteId=(String)mapNomyId.get('clienteId');
        String firstName=(String)mapNomyId.get('firstName');
        String lastName=(String)mapNomyId.get('lastName');
        String numComparacion=(String)mapNomyId.get('numeroContado');  
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Garantía Extendida').getRecordTypeId();
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
    
    public static Quote crearCotizacion (DSALES_QuoteGexWrapper.QuoteGexRequest data,/*Id oportunidadId, String firstName, String lastName*/Map<String, String> mapNomyId, Tienda__c tienda){
        Quote cotiza = new Quote();
        String oportunidadId=(String)mapNomyId.get('oportunidadId');
        String firstName=(String)mapNomyId.get('firstName');
        String lastName=(String)mapNomyId.get('lastName');
		String correo=(String)mapNomyId.get('correo');
		String numComparacion=(String)mapNomyId.get('numeroContado');        
        String recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Venta de Garantía Extendida').getRecordTypeId();
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
        if (Schema.sObjectType.Quote.isCreateable()) {
            insert cotiza;
        }
        return cotiza;
    }
    
    public static List<QuoteLineItem> crearPartidas(DSALES_QuoteGexWrapper.QuoteGexRequest data, Id cotizaId){
        String regions = 'Todas las regiones';
        String tipoProducto = 'Servicio';
        String originalMat = 'Matriz Original';
        List<QuoteLineItem> listaPartida = new List<QuoteLineItem>();
        List<PricebookEntry> listaPartida2 = new List<PricebookEntry>();
        PricebookEntry listaentradapre = new PricebookEntry();
        Product2 productos = new Product2(); 
        Pricebook2 listaPrecio = new Pricebook2();
        List<DSales_Asignacion_de_Productos__c> productAsig = new List<DSales_Asignacion_de_Productos__c>();
        
        Map<String, DSALES_QuoteGexWrapper.Product> mapProducts = new  Map<String, DSALES_QuoteGexWrapper.Product>();
        for(DSALES_QuoteGexWrapper.Product p : data.productos){
            mapProducts.put(p.skuDeTangible, p);
        }
        List<Product2> produc = [SELECT Id,Name,StockKeepingUnit,DSALES_Categoria__c,DSALES_Clase__c,DSALES_Familia__c,DSales_Aplicaporcentajecobro__c,DSales_PorcentajeCobro__c FROM Product2 WHERE StockKeepingUnit in: mapProducts.keySet() WITH SECURITY_ENFORCED];
        productAsig = [SELECT id, Name, DSales_Servicio_Seguro__c, DSales_Producto__c,DSALES_SKU__c FROM DSales_Asignacion_de_Productos__c WHERE DSALES_Activo__c=true AND  DSales_Producto__r.StockKeepingUnit in: mapProducts.keySet() WITH SECURITY_ENFORCED];
        List<Id> dsalesProductoSetId = new List<Id>();
        for(DSales_Asignacion_de_Productos__c da : productAsig){
            dsalesProductoSetId.add(da.DSales_Servicio_Seguro__c);
        }
        List<Pricebook2> precioLista = [SELECT id,Name FROM Pricebook2 WHERE Name= 'Standard Price Book' and IsActive=true WITH SECURITY_ENFORCED LIMIT 1];
        List<PricebookEntry> precioEn = [SELECT Id,UnitPrice,Name,Product2Id,Pricebook2Id,Product2.StockKeepingUnit,Product2.DSales_PorcentajeCobro__c,Product2.DSales_Aplicaporcentajecobro__c FROM PricebookEntry WHERE Product2Id =: produc and Pricebook2Id=: precioLista WITH SECURITY_ENFORCED];
        List<PricebookEntry> precioEnGEX = [SELECT Id,Name,UnitPrice,Product2Id,Pricebook2Id,Product2.StockKeepingUnit,Product2.DSales_Tipo_de_Producto__c,Product2.DSales_PorcentajeCobro__c,Product2.DSales_Aplicaporcentajecobro__c FROM PricebookEntry WHERE Product2Id =: dsalesProductoSetId and Pricebook2Id=: precioLista WITH SECURITY_ENFORCED];
        for(PricebookEntry item : precioEn){
            //QuoteLineItem partidapre = new QuoteLineItem();
            
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
            listaPartida.add(partidapre);
            
            String intangibleId;
            for(DSales_Asignacion_de_Productos__c asigProduc: productAsig){
                if(asigProduc.DSales_Producto__c == item.Product2Id){
                    intangibleId = asigProduc.DSales_Servicio_Seguro__c;
                }
            }
            for(PricebookEntry item2 : precioEnGEX){
                if(item2.Product2Id == intangibleId){
                    //for (Integer idSecuencia : p.idSecuencia) {
                    //for (Integer i = 0; i < p.cantidadProductosTangibles; i++) {
                        
                    QuoteLineItem partidapreGEX = new QuoteLineItem();
                    Double price1=0;
                    Double price2=0;
                    Double price3=0;
                    Double price4=0;
                    Double price5=0;
                    Double price6=0;
                    
                    if(item2.Product2.DSales_Aplicaporcentajecobro__c==true){
                        List<DASALES_Porcentajedecobro__c> porcent = obtenerPorcentajeCobro(intangibleId);
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
                    }else{
                        List<DSALES_Matriz_de_Cotizacion__c> matPrice1Year = obtenerMatricesPrecio(intangibleId, regions, originalMat);
                        for(DSALES_Matriz_de_Cotizacion__c mPrice : matPrice1Year){
                            switch on mPrice.DSALES_Tiempo_de_Garantia_Extendida_GEX__c{
                                when '1 año'{
                                    if(mPrice.DSALES_Rango_interior_GEX__c<= p.precioTangible && mPrice.DSALES_Rango_Superior_GEX__c>= p.precioTangible){
                                        price1 = mPrice.SALES_Precio_GEX__c;
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
                        listaPartida.add(partidapreGEX2);
                    }
                    
                }
                }
                //}
            }
        }
        
        if (Schema.sObjectType.QuoteLineItem.isCreateable()) {
            insert listaPartida;
        }
        return listaPartida;
    }
    
    public static DSALES_QuoteGexWrapper.Nodos respuestaDescripcion(String nombre, String cotizaId,String tipoServicio){
        List<Quotelineitem> lstSkus = [SELECT id,Product2.StockKeepingUnit,Product2.Description,Product2.DSALES_ServEspecifico__c FROM Quotelineitem WHERE Quoteid=:cotizaId AND Product2.DSales_Tipo_de_Producto__c='Servicio' AND Product2.Description=:nombre WITH SECURITY_ENFORCED];
        DSALES_QuoteGexWrapper.Nodos nodoAux = new DSALES_QuoteGexWrapper.Nodos();
        nodoAux.Description = nombre;
        nodoAux.tipoDeServicio = tipoServicio;
        nodoAux.sku = new List<String>();
        
        for(Quotelineitem valores :lstSkus){
            String subTipoAux = valores.Product2.DSALES_ServEspecifico__c;
            nodoAux.subTipo = subTipoAux;
            
            String skuAux = valores.Product2.StockKeepingUnit;
            nodoAux.sku.add(skuAux);
        }
        return nodoAux;
    }
    
    public static List<DSALES_QuoteGexWrapper.Nodos> responseDescription(String tipoProducto, String cotizaId){
        List<Quotelineitem> valores = [SELECT id,Product2.StockKeepingUnit,Product2.Description FROM Quotelineitem WHERE Quoteid=:cotizaId AND Product2.DSales_Tipo_de_Producto__c=:tipoProducto WITH SECURITY_ENFORCED ORDER BY Product2.Description];
        List<String> valoresBusqueda = new List<String>();
        if(valores.size()>0){
            String valorDescripcion=valores[0].Product2.Description;
            valoresBusqueda.add(valorDescripcion);
            for(Quotelineitem aux :valores){
                if(valorDescripcion!=aux.Product2.Description){
                    valoresBusqueda.add(aux.Product2.Description);
                    valorDescripcion=aux.Product2.Description;
                }
            }
        }
        List<DSALES_QuoteGexWrapper.Nodos> response = new List<DSALES_QuoteGexWrapper.Nodos>();
        for(String aux :valoresBusqueda){
            DSALES_QuoteGexWrapper.Nodos respuesta = DSALES_QuoteGexWrapperRequest.respuestaDescripcion(aux, cotizaId,'Servicio');
            response.add(respuesta);
        }
        return response;
    }
    public static DSALES_Matriz_de_Cotizacion__c obtenerSkuPrecio(Decimal resIntangible, Decimal resTangible, Id idMat) {
        return [SELECT Id, Name, DSALES_Rango_interior_GEX__c, DSALES_Rango_Superior_GEX__c, DSALES_Tiempo_de_Garantia_Extendida_GEX__c, SALES_Precio_GEX__c, DSales_Matriz_GEX__c 
                FROM DSALES_Matriz_de_Cotizacion__c 
                WHERE SALES_Precio_GEX__c = :resIntangible 
                    AND DSales_Matriz_GEX__r.DSALES_Activo__c = true 
                    AND DSALES_Rango_Superior_GEX__c >= :resTangible AND DSales_Matriz_GEX__c=:idMat
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static List<DASALES_Porcentajedecobro__c> obtenerPorcentajeCobro(Id intangibleId) {
        List<DASALES_Porcentajedecobro__c> porcent = [SELECT Id, Name, DSALES_Anios__c, DSALES_Porcentaje__c FROM DASALES_Porcentajedecobro__c WHERE DSALES_Product__c=:intangibleId WITH SECURITY_ENFORCED];
        return porcent;
    }
    
    public static List<DSALES_Matriz_de_Cotizacion__c> obtenerMatricesPrecio(Id intangibleId, String regions, String originalMat) {
        List<DSales_Matriz_GEX__c> mat = [SELECT id, Name, DSALES_Activo__c, DSales_Region_GEX__c, DSALES_Tipo__c, DSALES_Servicio__c FROM DSales_Matriz_GEX__c WHERE DSALES_Servicio__c = :intangibleId AND DSALES_Activo__c = true AND DSALES_Tipo__c = :originalMat AND DSALES_Region__c INCLUDES (:regions) WITH SECURITY_ENFORCED];
        List<DSALES_Matriz_de_Cotizacion__c> matPrice1Year = [SELECT id, Name, SALES_Precio_GEX__c, DSales_Matriz_GEX__c, DSALES_Rango_interior_GEX__c, DSALES_Rango_Superior_GEX__c, DSALES_Tiempo_de_Garantia_Extendida_GEX__c FROM DSALES_Matriz_de_Cotizacion__c WHERE DSales_Matriz_GEX__c = :mat WITH SECURITY_ENFORCED ORDER BY SALES_Precio_GEX__c DESC];
        return matPrice1Year;
    }
    
    public static DSales_Matriz_GEX__c obtenerIdMatriz(Id intangibleId, String regions, String originalMat) {
        return [SELECT id 
                FROM DSales_Matriz_GEX__c 
                WHERE DSALES_Servicio__c = :intangibleId 
                AND DSALES_Activo__c = true AND DSALES_Tipo__c = :originalMat 
                AND DSALES_Region__c INCLUDES (:regions) 
                WITH SECURITY_ENFORCED LIMIT 1];
    }
    }