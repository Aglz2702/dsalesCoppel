@isTest 
public class DSALES_QuoteGexWrapperRequestTest{
    /*
   @testSetup
    static void setUp(){
        String tipoProducto = 'Servicio';
        String message = '';
        String regions = 'Todas las regiones';
        String originalMat = 'Matriz Original';
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Garantía Extendida').getRecordTypeId();
        
        DSALES_Familia__c family = new DSALES_Familia__c();
        family.Name = 'test';
        insert family;
        
        DSALES_Categoria__c category = new DSALES_Categoria__c();
        category.Name = 'test';
        insert category;
        
        DSALES_Clase__c classs = new DSALES_Clase__c();
        classs.Name = 'test';
        insert classs;
        
        Product2 prod = new Product2(Name ='test', StockKeepingUnit='0000',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Producto');
		insert prod;
        
        Product2 prodGEX = new Product2(Name ='testGEX', StockKeepingUnit='123444',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Servicio',DSales_Aplicaporcentajecobro__c=true);
		insert prodGEX;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = prod.Id;
        standardPrice.UnitPrice = 1000;
        standardPrice.IsActive = true;
        insert standardPrice;
        
        PricebookEntry standardPriceGEX = new PricebookEntry();
        standardPriceGEX.Pricebook2Id = pricebookId;
        standardPriceGEX.Product2Id = prodGEX.Id;
        standardPriceGEX.UnitPrice = 1000;
        standardPriceGEX.IsActive = true;
        insert standardPriceGEX;
        
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry();
        customPrice.Pricebook2Id = customPB.Id;
        customPrice.Product2Id = prod.Id;
        customPrice.UnitPrice = 1200;
        customPrice.IsActive = true;
        insert customPrice;
        
        PricebookEntry customPriceGEX = new PricebookEntry();
        customPriceGEX.Pricebook2Id = customPB.Id;
        customPriceGEX.Product2Id = prodGEX.Id;
        customPriceGEx.UnitPrice = 2000;
        customPriceGEX.IsActive = true;
        insert customPriceGEX;
        
        DSales_Asignacion_de_Productos__c asig = new DSales_Asignacion_de_Productos__c();
        asig.Name = 'test';
        asig.DSales_Servicio_Seguro__c =prod.Id;
        asig.dsalesProducto__c = prodGEX.Id;
        asig.dsalesActivo__c = true;
        insert asig;
        
        DSales_Matriz_GEX__c mat = new DSales_Matriz_GEX__c();
        mat.Name= 'test';
        mat.dsalesActivo__c= true;
        mat.dsalesRegion__c ='Hermosillo';
        mat.DSALES_Tiempogex__c = '1 año';
        insert mat;
        
        DSALES_Matriz_de_Cotizacion__c matItem = new DSALES_Matriz_de_Cotizacion__c();
        matItem.DSales_Matriz_GEX__c = mat.Id;
        matItem.SALES_Precio_GEX__c = 3500;
        matItem.DSALES_Rango_interior_GEX__c=7000;
        matItem.DSALES_Rango_Superior_GEX__c = 8500;
        matItem.DSALES_Tiempo_de_Garantia_Extendida_GEX__c = '1 año';
        
        matItem.DSales_Matriz_GEX__c = mat.Id;
        matItem.SALES_Precio_GEX__c = 4500;
        matItem.DSALES_Rango_interior_GEX__c=7000;
        matItem.DSALES_Rango_Superior_GEX__c = 8500;
        matItem.DSALES_Tiempo_de_Garantia_Extendida_GEX__c = '2 años';
        insert matItem;
        
        DASALES_Porcentajedecobro__c percent = new DASALES_Porcentajedecobro__c();
        percent.DSALES_Anios__c = 1;
        percent.DSALES_Porcentaje__c = 10;
        percent.DSALES_Product__c = prodGEX.Id;
        insert percent;
        
        DASALES_Porcentajedecobro__c percent2 = new DASALES_Porcentajedecobro__c();
        percent2.DSALES_Anios__c = 2;
        percent2.DSALES_Porcentaje__c = 15;
        percent2.DSALES_Product__c = prodGEX.Id;
        insert percent2;
        
        DASALES_Porcentajedecobro__c percent3 = new DASALES_Porcentajedecobro__c();
        percent3.DSALES_Anios__c = 3;
        percent3.DSALES_Porcentaje__c = 20;
        percent3.DSALES_Product__c = prodGEX.Id;
        insert percent3;
        
        DASALES_Porcentajedecobro__c percent4 = new DASALES_Porcentajedecobro__c();
        percent4.DSALES_Anios__c = 4;
        percent4.DSALES_Porcentaje__c = 15;
        percent4.DSALES_Product__c = prodGEX.Id;
        insert percent4;
        
        DASALES_Porcentajedecobro__c percent5 = new DASALES_Porcentajedecobro__c();
        percent5.DSALES_Anios__c = 5;
        percent5.DSALES_Porcentaje__c = 15;
        percent5.DSALES_Product__c = prodGEX.Id;
        insert percent5;
        
        DASALES_Porcentajedecobro__c percent6 = new DASALES_Porcentajedecobro__c();
        percent6.DSALES_Anios__c = 6;
        percent6.DSALES_Porcentaje__c = 15;
        percent6.DSALES_Product__c = prodGEX.Id;
        insert percent6;
        
        Account acc = new Account();
        acc.Name='test';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.dsalesClienteCoppel='90001';
        insert acc;
        
        Account accContado = new Account();
        accContado.FirstName = 'Emmanuel';
        accContado.LastName = 'Gonzalez';
        accContado.PersonEmail = 'egl@deloittemx.com';
        accContado.PersonBirthdate = date.today();
        accContado.Suffix = 'Lopez';
        insert accContado;
        
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        
        Tienda__c t = new Tienda__c();
        t.dsalesTiendaID__c =  '21';
        insert t;
        
        Quote cotizacion = new Quote(OpportunityId=opp.Id,Name='test',dsalesTienda=t.Id);
        insert cotizacion;

        QuoteLineItem presupuesto = new QuoteLineItem();
        presupuesto.QuoteId = cotizacion.Id;
        presupuesto.PricebookEntryId = customPrice.Id;
        presupuesto.Product2Id = prod.Id;
        presupuesto.Quantity = 1.0;
        presupuesto.UnitPrice = customPrice.UnitPrice;
        presupuesto.DSALES_ListaArticulo__c = 'Producto';
        insert presupuesto;
        
        Asset proAdquirido = new Asset();
        proAdquirido.Name = 'test';
        proAdquirido.DSALES_TipoProducto__c = 'Producto';
        proAdquirido.AccountId = acc.id;
        proAdquirido.DSALES_ClaseBuscar__c = classs.Id;
        insert proAdquirido;
        
        DSALES_InformacionDePago__c info = new DSALES_InformacionDePago__c();
        info.DSALES_Factura__c = 'FAC001';
        info.DSALES_Oportunidad__c = opp.Id;
        info.DSALES_Cliente__c = acc.Id;
        info.DSALES_Clave_Tienda__c = 'T-7798';
        info.DSALES_ProductoAdquirido__c = proAdquirido.Id;
        insert info;
    }
    
    @isTest 
    static void createQuoteRecordTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{  "idTienda": "21", "productos": [{"skuDeTangible": "0000", "cantidadProductosTangibles": 1.0, "articulo": "Estufa", "marca": "Whirlpool", "modelo": "WFR5000D", "precioTangible": "4650" } ], "apellidoMaterno": "Lopez", "apellidoPaterno": "Gonzalez", "nombre": "Emmanuel", "correoElectronico": "egl@deloittemx.com", "numeroCliente": "", "idFactura": null, "idOportunidad": null }';
        req.requestURI = '/apexrest/insertQuoteGex';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        DSALES_QuoteGexWrapper.QuoteGexRequest data = (DSALES_QuoteGexWrapper.QuoteGexRequest)JSON.deserialize(body, DSALES_QuoteGexWrapper.QuoteGexRequest.class);
        Test.startTest();
        DSALES_QuoteGexWrapperRequest.createQuote();
        Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
    }
    
    @isTest 
    static void createQuoteRecordTest2(){
        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        String body2 = '{ "idTienda": "21", "productos": [ { "skuDeTangible": "0000", "cantidadProductosTangibles": 1.0, "articulo": "Estufa", "marca": "Whirlpool", "modelo": "WFR5000D", "precioTangible": "4650" } ], "apellidoMaterno": "Test", "apellidoPaterno": "Tes", "nombre": "Test", "correoElectronico": "danigallegos@deloittemx.com", "numeroCliente": "45654", "idFactura": null, "idOportunidad": null }';
        req2.requestURI = '/apexrest/insertQuoteGex';
        req2.httpMethod = 'POST';
        RestContext.request = req2;
        req2.requestBody = Blob.valueof(body2);
        RestContext.response = res2;
        DSALES_QuoteGexWrapper.QuoteGexRequest data2 = (DSALES_QuoteGexWrapper.QuoteGexRequest)JSON.deserialize(body2, DSALES_QuoteGexWrapper.QuoteGexRequest.class);
        Test.startTest();
        DSALES_QuoteGexWrapperRequest.createQuote();
        Test.stopTest();
        RestContext.request = req2;
        RestContext.response= res2;
        System.assertNotEquals(200, res2.statusCode, 'La llamada no debe devolver un código 200');
    }
    
    @isTest 
    static void createQuoteRecordTest3(){
        RestRequest req3 = new RestRequest();
        RestResponse res3 = new RestResponse();
        String body3 = '{ "idTienda": "21", "productos": [ { "skuDeTangible": "0000", "cantidadProductosTangibles": 1.0, "articulo": "Estufa", "marca": "Whirlpool", "modelo": "WFR5000D", "precioTangible": "4650" } ], "apellidoMaterno": "Test", "apellidoPaterno": "Tes", "nombre": "Test", "correoElectronico": "danigallegos@deloittemx.com", "numeroCliente": "90001", "idFactura": null, "idOportunidad": null }';
        req3.requestURI = '/apexrest/insertQuoteGex';
        req3.httpMethod = 'POST';
        RestContext.request = req3;
        req3.requestBody = Blob.valueof(body3);
        RestContext.response = res3;
        DSALES_QuoteGexWrapper.QuoteGexRequest data3 = (DSALES_QuoteGexWrapper.QuoteGexRequest)JSON.deserialize(body3, DSALES_QuoteGexWrapper.QuoteGexRequest.class);
        Test.startTest();
        DSALES_QuoteGexWrapperRequest.createQuote();
        Test.stopTest();
        RestContext.request = req3;
        RestContext.response= res3;
        System.assertNotEquals(200, res3.statusCode, 'La llamada no debe devolver un código 200');
    }
    
    @isTest 
    static void createQuoteRecordTest4(){
        RestRequest req4 = new RestRequest();
        RestResponse res4 = new RestResponse();
        String body4 = '{ "idTienda": "21", "productos": [ { "skuDeTangible": "0000", "cantidadProductosTangibles": 1.0, "articulo": "Estufa", "marca": "Whirlpool", "modelo": "WFR5000D", "precioTangible": "4650" } ], "apellidoMaterno": "Test2", "apellidoPaterno": "Test2", "nombre": "Test2", "correoElectronico": "test@deloittemx.com", "numeroCliente": "8765765875", "idFactura": null, "idOportunidad": null }';
        req4.requestURI = '/apexrest/insertQuoteGex';
        req4.httpMethod = 'POST';
        RestContext.request = req4;
        req4.requestBody = Blob.valueof(body4);
        RestContext.response = res4;
        DSALES_QuoteGexWrapper.QuoteGexRequest data4 = (DSALES_QuoteGexWrapper.QuoteGexRequest)JSON.deserialize(body4, DSALES_QuoteGexWrapper.QuoteGexRequest.class);
        Test.startTest();
        DSALES_QuoteGexWrapperRequest.createQuote();
        Test.stopTest();
        RestContext.request = req4;
        RestContext.response= res4;
        System.assertNotEquals(200, res4.statusCode, 'La llamada no debe devolver un código 200');
    }
    
    @isTest 
    static void createQuoteRecordTest5(){
        RestRequest req5 = new RestRequest();
        RestResponse res5 = new RestResponse();
        String body5 = '{ "idTienda": "21", "productos": [ { "skuDeTangible": "0000", "cantidadProductosTangibles": 1.0, "articulo": "Estufa", "marca": "Whirlpool", "modelo": "WFR5000D", "precioTangible": "4650" } ], "apellidoMaterno": "Test", "apellidoPaterno": "Tes", "nombre": "Test", "correoElectronico": "danigallegos@deloittemx.com", "numeroCliente": "444444", "idFactura": "FAC001", "idOportunidad": null }';
        req5.requestURI = '/apexrest/insertQuoteGex';
        req5.httpMethod = 'POST';
        RestContext.request = req5;
        req5.requestBody = Blob.valueof(body5);
        RestContext.response = res5;
        DSALES_QuoteGexWrapper.QuoteGexRequest data5 = (DSALES_QuoteGexWrapper.QuoteGexRequest)JSON.deserialize(body5, DSALES_QuoteGexWrapper.QuoteGexRequest.class);
        Test.startTest();
        DSALES_QuoteGexWrapperRequest.createQuote();
        Test.stopTest();
        RestContext.request = req5;
        RestContext.response= res5;
        System.assertNotEquals(200, res5.statusCode, 'La llamada no debe devolver un código 200');
    }
    */
}