@isTest 
public class DSALES_QuoteSmWrapperRequestTest {
    @testSetup 
    static void setUp(){
        String tipoProducto = 'Producto';
        String message = '';
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Seguro_de_Moto').getRecordTypeId();
        String recordTypeAccountId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Seguro_de_Moto').getRecordTypeId();
        String recordTypeAccountId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        DSALES_Familia__c family = new DSALES_Familia__c();
        family.Name = 'test';
        insert family;
        
        DSALES_Categoria__c category = new DSALES_Categoria__c();
        category.Name = 'test';
        insert category;
        
        DSALES_Clase__c classs = new DSALES_Clase__c();
        classs.Name = 'test';
        insert classs;
        
        Product2 prodRc = new Product2(Name ='RC',dsalesVehiculo__c='sadkncdcs' ,StockKeepingUnit='000089',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Articulo__c='Test',IsActive=true,dsalesOpcionPago__c='M');
        insert prodRc;
        Product2 prodRc = new Product2(Name ='RC',dsalesVehiculo__c='sadkncdcs' ,StockKeepingUnit='000089',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Articulo__c='Test',IsActive=true,dsalesOpcionPago__c='M');
        insert prodRc;
        
        Product2 prodAmp = new Product2(Name ='AMP',dsalesVehiculo__c='23d23d23', StockKeepingUnit='123444',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,DSales_Articulo__c= 'Tast1',IsActive=true);
        insert prodAmp;
        Product2 prodAmp = new Product2(Name ='AMP',dsalesVehiculo__c='23d23d23', StockKeepingUnit='123444',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,DSales_Articulo__c= 'Tast1',IsActive=true);
        insert prodAmp;
        
        Product2 prodRcExc = new Product2(Name ='RCEXC',dsalesVehiculo__c='23d23d33', StockKeepingUnit='123433',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=50,DSales_Articulo__c= 'Tst1',IsActive=true,	dsalesOpcionpago__c='C');
        insert prodRcExc;
        
        Product2 prodM = new Product2(Name ='Moto',dsalesVehiculo__c='lasicndsldicsid',StockKeepingUnit='123121',DSales_Tipo_de_Producto__c='Producto',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40, DSales_Articulo__c='test2',IsActive=true);
        insert prodM;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = prodRc.Id;
        standardPrice.UnitPrice = 1000;
        standardPrice.IsActive = true;
        insert standardPrice;
        
        PricebookEntry standardPriceGEX = new PricebookEntry();
        standardPriceGEX.Pricebook2Id = pricebookId;
        standardPriceGEX.Product2Id = prodAmp.Id;
        standardPriceGEX.UnitPrice = 1000;
        standardPriceGEX.IsActive = true;
        insert standardPriceGEX;
        
        PricebookEntry standardPriceMoto = new PricebookEntry();
        standardPriceMoto.Pricebook2Id = pricebookId;
        standardPriceMoto.Product2Id = prodM.Id;
        standardPriceMoto.UnitPrice = 1000;
        standardPriceMoto.IsActive = true;
        insert standardPriceMoto;
        
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry();
        customPrice.Pricebook2Id = customPB.Id;
        customPrice.Product2Id = prodRc.Id;
        customPrice.UnitPrice = 1200;
        customPrice.IsActive = true;
        insert customPrice;
        
        PricebookEntry customPriceGEX = new PricebookEntry();
        customPriceGEX.Pricebook2Id = customPB.Id;
        customPriceGEX.Product2Id = prodAmp.Id;
        customPriceGEx.UnitPrice = 2000;
        customPriceGEX.IsActive = true;
        insert customPriceGEX;
        
        PricebookEntry customPriceMoto = new PricebookEntry();
        customPriceMoto.Pricebook2Id = customPB.Id;
        customPriceMoto.Product2Id = prodM.Id;
        customPriceMoto.UnitPrice = 2000;
        customPriceMoto.IsActive = true;
        insert customPriceMoto;
        
        
        Account acc = new Account();
        acc.Name = 'test';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.DSALES_ClienteCoppel__c='90001';
        insert acc;
        
        Account accCont = new Account();
        accCont.FirstName = 'Daniela1';
        accCont.LastName = 'Gallegos1';
        accCont.Suffix = 'Ho1';
        accCont.PersonEmail = 'danigallegos@deloittemx.com';
        accCont.Phone = '5563452135';
        accCont.PersonBirthdate = date.today();
        accCont.DSALES_ClienteCoppel__c=null;
        accCont.CP_WalletCustomerNumber__c=null;
        insert accCont;
        
        Account accCont = new Account();
        accCont.FirstName = 'Daniela1';
        accCont.LastName = 'Gallegos1';
        accCont.Suffix = 'Ho1';
        accCont.PersonEmail = 'danigallegos@deloittemx.com';
        accCont.Phone = '5563452135';
        accCont.PersonBirthdate = date.today();
        accCont.DSALES_ClienteCoppel__c=null;
        accCont.CP_WalletCustomerNumber__c=null;
        insert accCont;
        
        Account accContado = new Account();
        accContado.FirstName = 'Daniela';
        accContado.LastName = 'Gallegos';
        accContado.Suffix = 'Ho';
        accContado.Suffix = 'Ho';
        accContado.PersonEmail = 'danigallegos@deloittemx.com';
        accContado.Phone = '5563452135';
        accContado.Phone = '5563452135';
        accContado.PersonBirthdate = date.today();
        accContado.DSALES_ClienteCoppel__c=null;
        accContado.CP_WalletCustomerNumber__c=null;
        accContado.CP_WalletCustomerNumber__c=null;
        insert accContado;
        
        Account accContado2 = new Account();
        accContado2.FirstName = 'Daniela';
        accContado2.LastName = 'Gallegos';
        accContado2.Suffix = 'Ho';
        accContado2.Suffix = 'Ho';
        accContado2.PersonEmail = 'danigegos@deloittemx.com';
        insert accContado2;
        
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '21';
        t.DSales_TiendaID__c =  '21';
        insert t;
        
        Plazo__c plazo1 = new Plazo__c();
        plazo1.Name='12';
        plazo1.dsalesSeguro__c=prodRc.Id;


        plazo1.Dsales_Plazo__c='12';
        plazo1.DSALES_Activo__c=true;
        insert plazo1;
        
        Plazo__c plazo2 = new Plazo__c(Name='12',Dsales_Plazo__c='12',dsalesSeguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazo2;
        
        Quote cotizacion = new Quote(Name='test', OpportunityId = opp.Id, DSales_Tienda__c=t.Id,dsalesValorFactura__c=true, Pricebook2Id =pricebookId,DSALES_RFC__c='testRFC');
        Quote cotizacion = new Quote(Name='test', OpportunityId = opp.Id, DSales_Tienda__c=t.Id,dsalesValorFactura__c=true, Pricebook2Id =pricebookId,DSALES_RFC__c='testRFC');
        insert cotizacion;
        
        
        QuoteLineItem presupuesto = new QuoteLineItem();
        presupuesto.QuoteId = cotizacion.Id;
        presupuesto.PricebookEntryId = standardPrice.Id;
        presupuesto.PricebookEntryId = standardPrice.Id;
        presupuesto.Product2Id = prodRc.Id;
        presupuesto.Quantity = 1;
        presupuesto.UnitPrice = standardPrice.UnitPrice;
        presupuesto.Quantity = 1;
        presupuesto.UnitPrice = standardPrice.UnitPrice;
        presupuesto.DSALES_ListaArticulo__c = 'Producto';
        presupuesto.DSALES_Plazo__c= plazo1.Id;
        presupuesto.dsalesOpcionPago__c='M';
        presupuesto.dsalesQuoteId__c= cotizacion.Id;
        presupuesto.DSALES_Segurogratis__c = false;
        presupuesto.DSALES_Descripcion__c = 'test Description';
        presupuesto.DSALES_Impuestos__c = 125.00;
        presupuesto.dsalesOpcionPago__c='M';
        presupuesto.dsalesQuoteId__c= cotizacion.Id;
        presupuesto.DSALES_Segurogratis__c = false;
        presupuesto.DSALES_Descripcion__c = 'test Description';
        presupuesto.DSALES_Impuestos__c = 125.00;
        insert presupuesto;
        
        DSALES_TipodeUso__c tipoUso = new DSALES_TipodeUso__c(Name='Comercial');
        insert tipoUso;
        DSALES_Tipodevehculo__c tipovehiculo = new DSALES_Tipodevehculo__c(Name='Moto');
        insert tipovehiculo;
        
        
        Campaign camapna = new Campaign();
        camapna.Name='RC';
        camapna.dsalesTipoCampana__c = 'Seguro gratis';
        camapna.IsActive = true;
        camapna.Description='abc Description';
        insert camapna;
        
        Campaign camapnaAmp = new Campaign();
        camapnaAmp.Name='A';
        camapnaAmp.dsalesTipoCampana__c = 'Seguro gratis';
        camapnaAmp.IsActive = true;
        insert camapnaAmp;
        
        DSALES_AsociacionCampanias__c asociacionRc = new DSALES_AsociacionCampanias__c(DSALES_Producto__c=prodRc.Id,DSALES_Campania__c=camapna.Id, DSALES_Activo__c=true);
        DSALES_AsociacionCampanias__c asociacionAmp = new DSALES_AsociacionCampanias__c(DSALES_Producto__c=prodAmp.Id,DSALES_Campania__c=camapnaAmp.Id, DSALES_Activo__c=true);
        insert asociacionRc;
        insert asociacionAmp;
        
        DSales_Asignacion_de_Productos__c asigProducto = new DSales_Asignacion_de_Productos__c();
        asigProducto.DSALES_Activo__c=true;
        asigProducto.DSales_Servicio_Seguro__c=prodRcExc.Id;
        asigProducto.DSales_Producto__c=ProdM.Id;
        asigProducto.Name='RCEXC';
        insert asigProducto;
        
        dsalesAsignacionDeTienda__c asigTienda = new dsalesAsignacionDeTienda__c();
        asigTienda.dsalesActivo__c=true;
        asigTienda.dsalesCampana__c=camapna.Id;
        asigTienda.Producto__c=prodRc.Id;
        asigTienda.dsalesTienda__c=t.Id;
        insert asigTienda;
        
        
        DSales_Asignacion_de_Productos__c asigProducto = new DSales_Asignacion_de_Productos__c();
        asigProducto.DSALES_Activo__c=true;
        asigProducto.DSales_Servicio_Seguro__c=prodRcExc.Id;
        asigProducto.DSales_Producto__c=ProdM.Id;
        asigProducto.Name='RCEXC';
        insert asigProducto;
        
        dsalesAsignacionDeTienda__c asigTienda = new dsalesAsignacionDeTienda__c();
        asigTienda.dsalesActivo__c=true;
        asigTienda.dsalesCampana__c=camapna.Id;
        asigTienda.Producto__c=prodRc.Id;
        asigTienda.dsalesTienda__c=t.Id;
        insert asigTienda;
        
    }
    
    @isTest 
    static void createQuoteCredito(){
        Product2 producto = [SELECT Id, Name, StockKeepingUnit,DSales_Tipo_de_Producto__c, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit='000089' LIMIT 1];        
        Product2 producto = [SELECT Id, Name, StockKeepingUnit,DSales_Tipo_de_Producto__c, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit='000089' LIMIT 1];        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"numeroCliente":"90001","tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"12","rfc":"testRFC","sku":"000089","precioProducto":"213.4","nombre":"","apellidoPaterno":"","apellidoMaterno":"","idTienda":"21","nombreVendedor":"pedro","telefonoCelular":"4545454545","correoElectronico":"ssas@fgmaoc.com","generoContacto":"Masculino","fechaNacimiento":"1990-10-02","codigoPostal":"12","idVehiculo":"sadkncdcs","opcionPago":"Contado","fechaInicio":"2020-10-10"}';
        String body = '{"numeroCliente":"90001","tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"12","rfc":"testRFC","sku":"000089","precioProducto":"213.4","nombre":"","apellidoPaterno":"","apellidoMaterno":"","idTienda":"21","nombreVendedor":"pedro","telefonoCelular":"4545454545","correoElectronico":"ssas@fgmaoc.com","generoContacto":"Masculino","fechaNacimiento":"1990-10-02","codigoPostal":"12","idVehiculo":"sadkncdcs","opcionPago":"Contado","fechaInicio":"2020-10-10"}';
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response= res;
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> plazos = new List<DSALES_QuoteSmWrapper.RespuestaPlazos>();
        List<DSALES_QuoteSmWrapper.Campanias> listaCampanas = new List<DSALES_QuoteSmWrapper.Campanias>();
        List<DSALES_QuoteSmWrapper.Campanias> listaCampanas = new List<DSALES_QuoteSmWrapper.Campanias>();
        DSALES_QuoteSmWrapper.QuoteSmRequest data =(DSALES_QuoteSmWrapper.QuoteSmRequest)JSON.deserialize(body, DSALES_QuoteSmWrapper.QuoteSmRequest.class);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(1));
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(1));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> testCoppel= DSALES_QuoteSmWrapperRequest.coppel(plazos, producto.StockKeepingUnit,producto, listaCampanas);

        //Boolean testCamp = DSALES_QuoteSmWrapperRequest.campana( 'RC', 'sku', producto.Id);
        Boolean rcTrue = DSALES_QuoteSmWrapperRequest.rcExceso('RCEXC', 'sku',producto.Id);
        Test.stopTest();
        //System.assertEquals(true, testCamp);
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> testCoppel= DSALES_QuoteSmWrapperRequest.coppel(plazos, producto.StockKeepingUnit,producto, listaCampanas);

        //Boolean testCamp = DSALES_QuoteSmWrapperRequest.campana( 'RC', 'sku', producto.Id);
        Boolean rcTrue = DSALES_QuoteSmWrapperRequest.rcExceso('RCEXC', 'sku',producto.Id);
        Test.stopTest();
        //System.assertEquals(true, testCamp);
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
        
    }
    
    
    
    @isTest 
    static void createQuoteGenerico(){
        Boolean listaNegra= false;
        Product2 temporal = [SELECT Id,dsalesVehiculo__c, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c, dsalesOpcionpago__c FROM Product2 WHERE Name = 'RC' LIMIT 1];
        Tienda__c tienda = [Select Id from Tienda__c WHERE DSales_TiendaID__c ='21' LIMIT 1];
        Quote quote= [SELECT Id, Name, DSALES_Plazoacotizar__c FROM Quote WHERE Name = 'test' LIMIT 1];
        QuoteLineItem item =[SELECT Id, QuoteId, UnitPrice, DSALES_Impuestos__c, DSALES_Comision__c, dsalesAliasSeguro__c, DSALES_Recargos__c FROM QuoteLineItem WHERE QuoteId =:quote.Id];
        Plazo__c plazo = [SELECT Id, Name, DSALES_Activo__c, dsalesSeguro__r.Name FROM Plazo__c WHERE Name='12'AND DSALES_Activo__c = true LIMIT 1];  
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"numeroCliente":"43290","tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"12","rfc":"testRFC","sku":"112234","precioProducto":"1200","nombre":"Daniela","apellidoPaterno":"Gallegos","apellidoMaterno":null,"idTienda":"21","nombreVendedor":"pedro","telefonoCelular":"5563452135","correoElectronico":"danigallegos@deloittemx.com","generoContacto":"Femenino","fechaNacimiento":"2010-10-02","codigoPostal":"12345","idVehiculo":"sadkncdcs","opcionPago":"Mensual","fechaInicio":"2020-10-03"}';
        String body = '{"numeroCliente":"43290","tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"12","rfc":"testRFC","sku":"112234","precioProducto":"1200","nombre":"Daniela","apellidoPaterno":"Gallegos","apellidoMaterno":null,"idTienda":"21","nombreVendedor":"pedro","telefonoCelular":"5563452135","correoElectronico":"danigallegos@deloittemx.com","generoContacto":"Femenino","fechaNacimiento":"2010-10-02","codigoPostal":"12345","idVehiculo":"sadkncdcs","opcionPago":"Mensual","fechaInicio":"2020-10-03"}';
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        DSALES_QuoteSmWrapper.QuoteSmRequest data =(DSALES_QuoteSmWrapper.QuoteSmRequest)JSON.deserialize(body, DSALES_QuoteSmWrapper.QuoteSmRequest.class);
        List<DSALES_QuoteSmWrapper.ArmadoMuleSoft> plazos = new List<DSALES_QuoteSmWrapper.ArmadoMuleSoft>();
        DSALES_QuoteSmWrapper.ArmadoMuleSoft data1 = new DSALES_QuoteSmWrapper.ArmadoMuleSoft();
        List<DSALES_QuoteSmWrapper.Campanias>  campanas = new List<DSALES_QuoteSmWrapper.Campanias>();
        data1.opcionPago = plazo.Name;
        data1.data = new DSALES_QuoteSmWrapper.Data();
        data1.data.quoteId = quote.Id;
        data1.data.primaSeguro =  new DSALES_QuoteSmWrapper.InsurancePremium();
        data1.data.primaSeguro.primaTotal= item.UnitPrice;
        data1.data.primaSeguro.recargo = 1111111000;
        data1.data.primaSeguro.impuestos = item.DSALES_Impuestos__c;
        data1.data.primaSeguro.comision = 1234567;
        data1.data.primaSeguro.primaNeta= 23500;
        data1.data.primaSeguro.derechos = 1239000;
        data1.data.opcionesPago = new List<DSALES_QuoteSmWrapper.PaymentOptionsJson>(); 
        data1.data.recibos = new List<DSALES_QuoteSmWrapper.Receipt>();
        DSALES_QuoteSmWrapper.QuoteSmRequest data =(DSALES_QuoteSmWrapper.QuoteSmRequest)JSON.deserialize(body, DSALES_QuoteSmWrapper.QuoteSmRequest.class);
        List<DSALES_QuoteSmWrapper.ArmadoMuleSoft> plazos = new List<DSALES_QuoteSmWrapper.ArmadoMuleSoft>();
        DSALES_QuoteSmWrapper.ArmadoMuleSoft data1 = new DSALES_QuoteSmWrapper.ArmadoMuleSoft();
        List<DSALES_QuoteSmWrapper.Campanias>  campanas = new List<DSALES_QuoteSmWrapper.Campanias>();
        data1.opcionPago = plazo.Name;
        data1.data = new DSALES_QuoteSmWrapper.Data();
        data1.data.quoteId = quote.Id;
        data1.data.primaSeguro =  new DSALES_QuoteSmWrapper.InsurancePremium();
        data1.data.primaSeguro.primaTotal= item.UnitPrice;
        data1.data.primaSeguro.recargo = 1111111000;
        data1.data.primaSeguro.impuestos = item.DSALES_Impuestos__c;
        data1.data.primaSeguro.comision = 1234567;
        data1.data.primaSeguro.primaNeta= 23500;
        data1.data.primaSeguro.derechos = 1239000;
        data1.data.opcionesPago = new List<DSALES_QuoteSmWrapper.PaymentOptionsJson>(); 
        data1.data.recibos = new List<DSALES_QuoteSmWrapper.Receipt>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(10));
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(10));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> testResp = DSALES_QuoteSmWrapperRequest.creaPlazos(quote, plazos, temporal.StockKeepingUnit, listaNegra,tienda.Id, temporal, campanas);
        DSALES_QuoteSmWrapper.RespuestaPlazos  testResplazo = DSALES_QuoteSmWrapperRequest.creaPartidaM(quote, temporal.StockKeepingUnit, listaNegra, 1200,campanas,temporal );
        List<DSALES_QuoteSmWrapper.Plazo> plaz = DSALES_QuoteSmWrapperRequest.plazosActivosExterna(data.plazoCotizar,tienda.Id, data.opcionPago);
        QuoteLineItem partida = DSALES_QuoteSmWrapperRequest.creaPartida('RC', quote, data1, '112234');
        Test.stopTest();
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> testResp = DSALES_QuoteSmWrapperRequest.creaPlazos(quote, plazos, temporal.StockKeepingUnit, listaNegra,tienda.Id, temporal, campanas);
        DSALES_QuoteSmWrapper.RespuestaPlazos  testResplazo = DSALES_QuoteSmWrapperRequest.creaPartidaM(quote, temporal.StockKeepingUnit, listaNegra, 1200,campanas,temporal );
        List<DSALES_QuoteSmWrapper.Plazo> plaz = DSALES_QuoteSmWrapperRequest.plazosActivosExterna(data.plazoCotizar,tienda.Id, data.opcionPago);
        QuoteLineItem partida = DSALES_QuoteSmWrapperRequest.creaPartida('RC', quote, data1, '112234');
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
        
    }
     @isTest 
    static void opcionDePagos(){
       List<Product2> seguro = [SELECT Id,dsalesVehiculo__c, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c, dsalesOpcionpago__c FROM Product2 ];
        String opPago='Mensual';
        Test.startTest();
        DSALES_QuoteSmWrapperRequest.opcionDePago(seguro, opPago);
        Test.stopTest();
        //System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
    }
    @isTest 
    static void createQuoteCreditoException(){
        RestResponse res = new RestResponse();
        String requestBody = 'invalid body';
        RestRequest req = new RestRequest();
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(requestBody);
        RestContext.request = req;
        List<DSALES_QuoteSmWrapper.CoveragesArray> coberturas = new List<DSALES_QuoteSmWrapper.CoveragesArray>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(9));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response= DSALES_QuoteSmWrapperRequest.createQuoteSM();
        String testCobertura = DSALES_QuoteSmWrapperRequest.coberturas(coberturas);
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
    }
     @isTest 
    static void opcionDePagos(){
       List<Product2> seguro = [SELECT Id,dsalesVehiculo__c, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c, dsalesOpcionpago__c FROM Product2 ];
        String opPago='Mensual';
        Test.startTest();
        DSALES_QuoteSmWrapperRequest.opcionDePago(seguro, opPago);
        Test.stopTest();
        //System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
    }
    @isTest 
    static void createQuoteCreditoException(){
        RestResponse res = new RestResponse();
        String requestBody = 'invalid body';
        RestRequest req = new RestRequest();
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(requestBody);
        RestContext.request = req;
        List<DSALES_QuoteSmWrapper.CoveragesArray> coberturas = new List<DSALES_QuoteSmWrapper.CoveragesArray>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(9));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response= DSALES_QuoteSmWrapperRequest.createQuoteSM();
        String testCobertura = DSALES_QuoteSmWrapperRequest.coberturas(coberturas);
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
    }
    
    @isTest
    static void testCrearCotizacion() {
        List<Account> resul = [Select Id, firstName, suffix, lastName, Fecha_de_Nacimiento__c, Phone, PersonEmail from Account WHERE firstName='Daniela1' AND suffix='Ho1' AND lastName='Gallegos1'];
        Quote quote= [SELECT Id, Name FROM Quote LIMIT 1];
        String body = '{"numeroCliente":null,"tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"12","rfc":"testRFC","sku":"000089","precioProducto":"21300","nombre":"Daniela1","apellidoPaterno":"Gallegos1","apellidoMaterno":"Ho1","idTienda":"21","nombreVendedor":"pedro","telefonoCelular":"5563452135","correoElectronico":"danigallegos@deloittemx.com","generoContacto":"Femenino","fechaNacimiento":"1990-10-02","codigoPostal":"1245","idVehiculo":"sadkncdcs","opcionPago":"Mensual","fechaInicio":"2020-10-10"}';
    @isTest
    static void testCrearCotizacion() {
        List<Account> resul = [Select Id, firstName, suffix, lastName, Fecha_de_Nacimiento__c, Phone, PersonEmail from Account WHERE firstName='Daniela1' AND suffix='Ho1' AND lastName='Gallegos1'];
        Quote quote= [SELECT Id, Name FROM Quote LIMIT 1];
        String body = '{"numeroCliente":null,"tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"12","rfc":"testRFC","sku":"000089","precioProducto":"21300","nombre":"Daniela1","apellidoPaterno":"Gallegos1","apellidoMaterno":"Ho1","idTienda":"21","nombreVendedor":"pedro","telefonoCelular":"5563452135","correoElectronico":"danigallegos@deloittemx.com","generoContacto":"Femenino","fechaNacimiento":"1990-10-02","codigoPostal":"1245","idVehiculo":"sadkncdcs","opcionPago":"Mensual","fechaInicio":"2020-10-10"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(11));
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(11));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
        Test.stopTest();
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
        
    }
    
    @isTest
    static void testCrearCotizacion4() {
    @isTest
    static void testCrearCotizacion4() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"numeroCliente":null,"tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"18","rfc":"testRFC","sku":"123433","precioProducto":"21300","nombre":"Daniela","apellidoPaterno":"Gallegos","apellidoMaterno":"Ho","idTienda":"21","nombreVendedor":"pedro","telefonoCelular":"5563452135","correoElectronico":"danigallegos@deloittemx.com","generoContacto":"Femenino","fechaNacimiento":"","codigoPostal":"1245","idVehiculo":"sadkncdcs","opcionPago":"Contado","fechaInicio":"2020-10-10"}';
        String body = '{"numeroCliente":null,"tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"18","rfc":"testRFC","sku":"123433","precioProducto":"21300","nombre":"Daniela","apellidoPaterno":"Gallegos","apellidoMaterno":"Ho","idTienda":"21","nombreVendedor":"pedro","telefonoCelular":"5563452135","correoElectronico":"danigallegos@deloittemx.com","generoContacto":"Femenino","fechaNacimiento":"","codigoPostal":"1245","idVehiculo":"sadkncdcs","opcionPago":"Contado","fechaInicio":"2020-10-10"}';
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(4));
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(4));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
        Test.stopTest();
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
        
    }
    
    @isTest
    static void testCrearCotizacion1() {
    
    @isTest
    static void testCrearCotizacion1() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"numeroCliente":null,"tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"18","rfc":"testRFC","sku":"000089","precioProducto":"21300","nombre":"null","apellidoPaterno":"null","apellidoMaterno":null,"idTienda":"21","nombreVendedor":"pedro","telefonoCelular":null,"correoElectronico":null,"generoContacto":"Femenino","fechaNacimiento":null,"codigoPostal":"1245","idVehiculo":"sadkncdcs","opcionPago":"Contado","fechaInicio":"2020-10-10"}';
        RestResponse res = new RestResponse();
        String body = '{"numeroCliente":null,"tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"18","rfc":"testRFC","sku":"000089","precioProducto":"21300","nombre":"null","apellidoPaterno":"null","apellidoMaterno":null,"idTienda":"21","nombreVendedor":"pedro","telefonoCelular":null,"correoElectronico":null,"generoContacto":"Femenino","fechaNacimiento":null,"codigoPostal":"1245","idVehiculo":"sadkncdcs","opcionPago":"Contado","fechaInicio":"2020-10-10"}';
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        RestContext.response = res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(5));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(5));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
    }
    @isTest
    static void testCrearCotizacion2() {
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
    }
    @isTest
    static void testCrearCotizacion2() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"numeroCliente":"45454","tipoUso":"Comercial","tipoVehiculo":"","plazoCotizar":"18","rfc":"testRFC","sku":"000089","precioProducto":"21300","nombre":"Daniela","apellidoPaterno":"Gallegos","apellidoMaterno":"Ho","idTienda":"21","nombreVendedor":"coppel","telefonoCelular":"5563452135","correoElectronico":"danigallegos@deloittemx.com","generoContacto":"Femenino","fechaNacimiento":"1990-10-02","codigoPostal":"1245","idVehiculo":"sadkncdcs","opcionPago":"Contado","fechaInicio":"2020-10-10"}';
        RestResponse res = new RestResponse();
        String body = '{"numeroCliente":"45454","tipoUso":"Comercial","tipoVehiculo":"","plazoCotizar":"18","rfc":"testRFC","sku":"000089","precioProducto":"21300","nombre":"Daniela","apellidoPaterno":"Gallegos","apellidoMaterno":"Ho","idTienda":"21","nombreVendedor":"coppel","telefonoCelular":"5563452135","correoElectronico":"danigallegos@deloittemx.com","generoContacto":"Femenino","fechaNacimiento":"1990-10-02","codigoPostal":"1245","idVehiculo":"sadkncdcs","opcionPago":"Contado","fechaInicio":"2020-10-10"}';
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.request = req;
        RestContext.response = res;
        RestContext.response = res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(2));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(2));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
    }
    @isTest
    static void testCrearCotizacion3() {
        List<Account> result = [Select Id,firstName,suffix,lastName from Account WHERE CP_WalletCustomerNumber__c =45654];
        String body = '{"numeroCliente":"45654","tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"18","rfc":"testRFC","sku":"000089","precioProducto":"21300","nombre":"TestN","apellidoPaterno":"TestP","apellidoMaterno":"TestS","idTienda":"21","nombreVendedor":"coppel","telefonoCelular":"5563452135","correoElectronico":"danigallegos@deloittemx.com","generoContacto":"Femenino","fechaNacimiento":"1990-10-02","codigoPostal":"1245","idVehiculo":"sadkncdcs","opcionPago":"Contado","fechaInicio":"2020-10-10"}';
    @isTest
    static void testCrearCotizacion3() {
        List<Account> result = [Select Id,firstName,suffix,lastName from Account WHERE CP_WalletCustomerNumber__c =45654];
        String body = '{"numeroCliente":"45654","tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"18","rfc":"testRFC","sku":"000089","precioProducto":"21300","nombre":"TestN","apellidoPaterno":"TestP","apellidoMaterno":"TestS","idTienda":"21","nombreVendedor":"coppel","telefonoCelular":"5563452135","correoElectronico":"danigallegos@deloittemx.com","generoContacto":"Femenino","fechaNacimiento":"1990-10-02","codigoPostal":"1245","idVehiculo":"sadkncdcs","opcionPago":"Contado","fechaInicio":"2020-10-10"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestResponse res = new RestResponse();
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.request = req;
        RestContext.response = res;
        RestContext.response = res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(3));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
    }
    
    
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSm(3));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
    }
    
    
}