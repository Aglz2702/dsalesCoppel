@isTest 
public class DSALES_QuoteSmWrapperRequestTest {
    @testSetup 
    static void setUp(){
        String tipoProducto = 'Producto';
        String message = '';
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
        
        Product2 prodRc = new Product2(Name ='RC Seguro de Moto',dsalesVehiculo__c='sadkncdcs' ,StockKeepingUnit='0000',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Articulo__c='Test');
		insert prodRc;
        
        Product2 prodAmp = new Product2(Name ='AMP Seguro de Moto',dsalesVehiculo__c='23d23d23', StockKeepingUnit='123444',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,DSales_Articulo__c= 'Tast1');
		insert prodAmp;
        
        Product2 prodM = new Product2(Name ='Moto',dsalesVehiculo__c='lasicndsldicsid',StockKeepingUnit='1231212',DSales_Tipo_de_Producto__c='Producto',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40, DSales_Articulo__c='test2');
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
        
        Account accContado = new Account();
        accContado.FirstName = 'Daniela';
        accContado.LastName = 'Gallegos';
        accContado.Middlename = 'Ho';
        accContado.PersonEmail = 'danigallegos@deloittemx.com';
        accContado.PersonBirthdate = date.today();
        accContado.DSALES_ClienteCoppel__c=null;
        insert accContado;
        
        Account accContado2 = new Account();
        accContado2.FirstName = 'Daniela';
        accContado2.LastName = 'Gallegos';
        accContado2.Middlename = 'Ho';
        accContado2.PersonEmail = 'danigegos@deloittemx.com';
        insert accContado2;
        
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  'CPPL-UGARTE';
        insert t;
        
        Plazo__c plazo1 = new Plazo__c();
        plazo1.Name='12';
        plazo1.dsalesSeguro__c=prodRc.Id;
        plazo1.Dsales_Plazo__c='12';
        plazo1.DSALES_Activo__c=true;
        insert plazo1;
        
        Plazo__c plazo2 = new Plazo__c(Name='12',Dsales_Plazo__c='12',dsalesSeguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazo2;
        
        Quote cotizacion = new Quote(OpportunityId=opp.Id,Name='test',DSales_Tienda__c=t.Id,dsalesValorFactura__c=true);
        insert cotizacion;

        QuoteLineItem presupuesto = new QuoteLineItem();
        presupuesto.QuoteId = cotizacion.Id;
        presupuesto.PricebookEntryId = customPrice.Id;
        presupuesto.Product2Id = prodRc.Id;
        presupuesto.Quantity = 1.0;
        presupuesto.UnitPrice = customPrice.UnitPrice;
        presupuesto.DSALES_ListaArticulo__c = 'Producto';
        presupuesto.DSALES_Plazo__c= plazo1.Id;
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
    }
    
    @isTest 
    static void createQuoteCredito(){
         Product2 producto = [SELECT Id, Name, StockKeepingUnit,DSales_Tipo_de_Producto__c, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Name = 'Moto' LIMIT 1];
        Campaign aux = [SELECT Id, Name, IsActive, dsalesTipoCampana__c FROM Campaign WHERE Name='RC'];                     
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"numeroCliente":"123455","tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"12","rfc":"abcd","sku":"1231212","precioProducto":"213.4","nombre":"hpero","apellidoPaterno":"gonzalez","apellidoMaterno":"lopez","idTienda":"CPPL-UGARTE","nombreVendedor":"pedro","telefonoCelular":"4545454545","correoElectronico":"ssas@fgmaoc.com","generoContacto":"Masculino","fechaNacimiento":"1990-10-02","codigoPostal":"12","idVehiculo":"slknvsaeclskvlams","opcionPago":"Mensual","fechaInicio":"2020-10-10"}';
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response= res;
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> plazos = new List<DSALES_QuoteSmWrapper.RespuestaPlazos>();
        DSALES_QuoteSmWrapper.QuoteSmRequest data =(DSALES_QuoteSmWrapper.QuoteSmRequest)JSON.deserialize(body, DSALES_QuoteSmWrapper.QuoteSmRequest.class);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseSiniestro(5));
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseSiniestro(6));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
        Account acc= DSALES_QuoteSmWrapperRequest.creaCliente (data);
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> testCoppel= DSALES_QuoteSmWrapperRequest.coppel(plazos, data.sku);
        Boolean testCamp = DSALES_QuoteSmWrapperRequest.campana( 'RC', 'sku', producto.Id);
        Boolean rcTrue = DSALES_QuoteSmWrapperRequest.RCEXCESO('rc', 'sku',producto.Id);
		Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
    }
    
    @isTest 
    static void createQuoteCreditoException(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{}';
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseSiniestro(5));
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseSiniestro(6));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
		Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 

    }
    
    @isTest 
    static void createQuoteGenerico(){
        Account universalAccount = [Select Id from Account LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"numeroCliente":null,"tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"12","rfc":"abcd","sku":"","precioProducto":"213.4","nombre":"DanielaD","apellidoPaterno":"Galle535gos","apellidoMaterno":"35","idTienda":"CPPL-UGARTE","nombreVendedor":"pedro","telefonoCelular":"45454554545","correoElectronico":"ssfas@fgmaoc.com","generoContacto":"Masculino","fechaNacimiento":"1990-10-02","codigoPostal":"12","idVehiculo":"slknvsaeclskvlams","opcionPago":"Mensual","fechaInicio":"2020-10-10"}';
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        DSALES_QuoteSmWrapper.RespuestaPlazos testMoto = new DSALES_QuoteSmWrapper.RespuestaPlazos();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseSiniestro(5));
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseSiniestro(6));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
		Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 

    }
    
    @isTest 
    static void createQuoteCreditoo(){
       Account universalAccount = [Select Id, Name from Account WHERE Name='Test' LIMIT 1]; 
       Tienda__c t = [Select Id, DSales_TiendaID__c from Tienda__c WHERE DSales_TiendaID__c ='CPPL-UGARTE']; 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"numeroCliente":"32353112","tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"18","rfc":"abcd","sku":"435167","precioProducto":"213.4","nombre":"DanielaD","apellidoPaterno":"Galle535gos","apellidoMaterno":"35","idTienda":"CPPL-UGARTE","nombreVendedor":"pedro","telefonoCelular":"45454554545","correoElectronico":"ssfas@fgmaoc.com","generoContacto":"Feminine","fechaNacimiento":"1990-10-02","codigoPostal":"12","idVehiculo":"slknvsaeclskvlams","opcionPago":"Contado","fechaInicio":"2020-10-10"}';
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response= res;
        List<DSALES_QuoteSmWrapper.CoveragesArray> coberturas = new List<DSALES_QuoteSmWrapper.CoveragesArray>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseSiniestro(5));
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseSiniestro(6));
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = DSALES_QuoteSmWrapperRequest.createQuoteSM();
        List<DSALES_QuoteSmWrapper.Plazo> plaz = DSALES_QuoteSmWrapperRequest.plazosActivosExterna('12', t.Id,'test');
        String testCobertura = DSALES_QuoteSmWrapperRequest.coberturas(coberturas);
		Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 

    }
 @isTest 
    static void createQuoteCredito3(){
         RestResponse res = new RestResponse();
        String requestBody = 'invalid body';
        RestRequest req = new RestRequest();
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(requestBody);
        RestContext.request = req;
        Test.startTest();
       DSALES_QuoteSmWrapper.RespuestaParaNpv response= DSALES_QuoteSmWrapperRequest.createQuoteSM();
       Test.stopTest();
       System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
    }
  @IsTest
    static void testCrearCotizacion() {
        Account acc =[SELECT Id, Name FROM Account Where Name='test'];
        Quote qt =[SELECT Id, OpportunityId, dsalesValorFactura__c FROM Quote WHERE Name = 'Test' ];
        QuoteLineItem partidaM =[SELECT Id, QuoteId FROM QuoteLineItem WHERE QuoteId= :qt.Id];
        Product2 productoMoto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Name ='RC Seguro de Moto' LIMIT 1];
        PricebookEntry precioM = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry LIMIT 1];
        Tienda__c tienda =[SELECT Id FROM Tienda__c ];
        String body ='{"idTienda":"21","numeroCliente":"12336456885456","nombreVendedor":"Luis Perez Sanchez","nombre":"Martin","apellidoPaterno":"Estrada","apellidoMaterno":"Gonzalez","correoElectronico":"martin.perest@gmail.com","telefonoCelular":"123456789","generoContacto":"F","fechaNacimiento":"1970-01-17","codigoPostal":"03810","rfc":"MIVE901010","sku":"503022","precioProducto":29000,"plazoCotizar":30,"idVehiculo":"","tipoUso":"COMERCIAL","tipoVehiculo":"MOTO","opcionPago":"Contado","fechaInicio":"2022-09-15","valorFactura":true}';
        RestRequest req = new RestRequest();
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.request = req;
        DSALES_QuoteSmWrapper.QuoteSmRequest data = (DSALES_QuoteSmWrapper.QuoteSmRequest)JSON.deserialize(body, DSALES_QuoteSmWrapper.QuoteSmRequest.class);
       
        Id oportunidadId = qt.OpportunityId;
        String firstName = 'John';
        String suffix = 'Jr.';
        String lastName = 'Doe';           
        Boolean listaNegra = false;
        Double precio =123334344;
        Test.startTest();
        Quote result = DSALES_QuoteSmWrapperRequest.crearCotizacion(data, oportunidadId, firstName, suffix, lastName, tienda, listaNegra);
        Opportunity opp= DSALES_QuoteSmWrapperRequest.creaOportunidad ( data, acc.Id, firstName, suffix,  lastName, tienda);
        Test.stopTest();
        }

    @IsTest
    static void testCreaPartida() {
        Quote qt =[SELECT Id, OpportunityId, dsalesValorFactura__c FROM Quote WHERE Name = 'Test'];
        Tienda__c tienda =[SELECT Id FROM Tienda__c ];
        String body = '{"numeroCliente":"323535324","tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"18","rfc":"abcd","sku":"456000","precioProducto":"2340","nombre":"DanielaD","apellidoPaterno":"Galle535gos","apellidoMaterno":"35","idTienda":"CPPL-UGARTE","nombreVendedor":"pedro","telefonoCelular":"123456098","correoElectronico":"ssfas@fgmaoc.com","generoContacto":"Masculino","fechaNacimiento":"1990-10-02","codigoPostal":"12","idVehiculo":"slknvsaeclskvlams","opcionPago":"Mensual","fechaInicio":"2020-10-10"}';
        RestRequest req = new RestRequest();
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.request = req;
        Boolean listaNegra = false;
        DSALES_QuoteSmWrapper.QuoteSmRequest data = (DSALES_QuoteSmWrapper.QuoteSmRequest)JSON.deserialize(body, DSALES_QuoteSmWrapper.QuoteSmRequest.class);
        List<DSALES_QuoteSmWrapper.ArmadoMuleSoft> plazos = new List<DSALES_QuoteSmWrapper.ArmadoMuleSoft>();
        Test.startTest();
        List<DSALES_QuoteSmWrapper.RespuestaPlazos>createPlazo= DSALES_QuoteSmWrapperRequest.creaPlazos( qt, plazos, data.sku, listaNegra, tienda.Id);
        Test.stopTest();  
    }


    /*@IsTest
    static void creaPartidaTest2() {
        Quote qt =[SELECT Id, OpportunityId, dsalesValorFactura__c FROM Quote WHERE Name = 'Test'];
        Tienda__c tienda =[SELECT Id FROM Tienda__c ];
        String body = '{"numeroCliente":"323535324","tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"18","rfc":"abcd","sku":"456000","precioProducto":"2340","nombre":"DanielaD","apellidoPaterno":"Galle535gos","apellidoMaterno":"35","idTienda":"CPPL-UGARTE","nombreVendedor":"pedro","telefonoCelular":"123456098","correoElectronico":"ssfas@fgmaoc.com","generoContacto":"Masculino","fechaNacimiento":"1990-10-02","codigoPostal":"12","idVehiculo":"slknvsaeclskvlams","opcionPago":"Mensual","fechaInicio":"2020-10-10"}';
        RestRequest req = new RestRequest();
        req.requestURI = '/apexrest/insertQuoteSM';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.request = req;
        Boolean listaNegra = false;
        DSALES_QuoteSmWrapper.QuoteSmRequest data = (DSALES_QuoteSmWrapper.QuoteSmRequest)JSON.deserialize(body, DSALES_QuoteSmWrapper.QuoteSmRequest.class);
        List<DSALES_QuoteSmWrapper.ArmadoMuleSoft> plazos = new List<DSALES_QuoteSmWrapper.ArmadoMuleSoft>();
        Test.startTest();
        List<DSALES_QuoteSmWrapper.RespuestaPlazos>createPlazo= DSALES_QuoteSmWrapperRequest.creaPlazos(qt, plazos, data.sku, listaNegra, tienda.Id);
        Test.stopTest();  
    }*/


    /*@IsTest
    static void creaPartidaMTest2() {
        Quote qt =[SELECT Id, OpportunityId, dsalesValorFactura__c FROM Quote WHERE Name = 'Test'];
        Tienda__c tienda =[SELECT Id FROM Tienda__c ];
        String body = '{"numeroCliente":"323535324","tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"18","rfc":"abcd","sku":"456000","precioProducto":"2340","nombre":"DanielaD","apellidoPaterno":"Galle535gos","apellidoMaterno":"35","idTienda":"CPPL-UGARTE","nombreVendedor":"pedro","telefonoCelular":"123456098","correoElectronico":"ssfas@fgmaoc.com","generoContacto":"Masculino","fechaNacimiento":"1990-10-02","codigoPostal":"12","idVehiculo":"slknvsaeclskvlams","opcionPago":"Mensual","fechaInicio":"2020-10-10"}';
        Boolean listaNegra = false;
        DSALES_QuoteSmWrapper.QuoteSmRequest data = (DSALES_QuoteSmWrapper.QuoteSmRequest)JSON.deserialize(body, DSALES_QuoteSmWrapper.QuoteSmRequest.class);
        Decimal precio1=decimal.valueOf(data.precioProducto);
        DSALES_QuoteSmWrapper.RespuestaPlazos moto = new DSALES_QuoteSmWrapper.RespuestaPlazos();
        Test.startTest();
        moto=DSALES_QuoteSmWrapperRequest.creaPartidaM(qt, data.sku, listaNegra, precio1);
        //System.assert(!createdAccounts.isEmpty(),'List should not be empty');
        Test.stopTest();  
    }*/

    /*@IsTest
    static void creaPartidaTest2() {
        Quote qt =[SELECT Id, OpportunityId, dsalesValorFactura__c FROM Quote WHERE Name = 'Test'];
        Tienda__c tienda =[SELECT Id FROM Tienda__c ];
        String body = '{"numeroCliente":"323535324","tipoUso":"Comercial","tipoVehiculo":"Moto","plazoCotizar":"18","rfc":"abcd","sku":"456000","precioProducto":"2340","nombre":"DanielaD","apellidoPaterno":"Galle535gos","apellidoMaterno":"35","idTienda":"CPPL-UGARTE","nombreVendedor":"pedro","telefonoCelular":"123456098","correoElectronico":"ssfas@fgmaoc.com","generoContacto":"Masculino","fechaNacimiento":"1990-10-02","codigoPostal":"12","idVehiculo":"slknvsaeclskvlams","opcionPago":"Mensual","fechaInicio":"2020-10-10"}';
        Boolean listaNegra = false;
        DSALES_QuoteSmWrapper.QuoteSmRequest data = (DSALES_QuoteSmWrapper.QuoteSmRequest)JSON.deserialize(body, DSALES_QuoteSmWrapper.QuoteSmRequest.class);
        Decimal precio1=decimal.valueOf(data.precioProducto);
        String seguro = 'RC Seguro de Moto';
        DSALES_QuoteSmWrapper.ArmadoMuleSoft plazo = new DSALES_QuoteSmWrapper.ArmadoMuleSoft();
        Test.startTest();
        QuoteLineItem cpartida=DSALES_QuoteSmWrapperRequest.creaPartida(seguro,qt,plazo,data.sku);
        //System.assert(!createdAccounts.isEmpty(),'List should not be empty');
        Test.stopTest();  
    }*/
}