@isTest 
public class DSALES_QuoteScWrapperRequest_Test {
    
    @testSetup 
    static void setUp(){
        String tipoProducto = 'Producto';
        String message = '';
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('dsalesSeguroCelulares').getRecordTypeId();
        String recordTypeAccountId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        
        Product2 prodCell = new Product2();
        prodCell.Name ='Iphone';
        prodCell.StockKeepingUnit='123122';
        prodCell.DSales_Tipo_de_Producto__c='Producto';
        prodCell.DSales_Articulo__c='test2';
        prodCell.IsActive=true;
        insert prodCell;
        
        
        Product2 prodSeguro = new Product2();
        prodSeguro.Name ='Seguro Celular';
        prodSeguro.StockKeepingUnit='000089';
        prodSeguro.DSales_Tipo_de_Producto__c='Seguro';
        prodSeguro.DSales_Articulo__c='Test';
        prodSeguro.IsActive=true;
        prodSeguro.dsalesOpcionPago__c='M';
        insert prodSeguro;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = prodSeguro.Id;
        standardPrice.UnitPrice = 1000;
        standardPrice.IsActive = true;
        insert standardPrice;
        
        PricebookEntry standardPriceGEX = new PricebookEntry();
        standardPriceGEX.Pricebook2Id = pricebookId;
        standardPriceGEX.Product2Id = prodCell.Id;
        standardPriceGEX.UnitPrice = 1000;
        standardPriceGEX.IsActive = true;
        insert standardPriceGEX;
        
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry();
        customPrice.Pricebook2Id = customPB.Id;
        customPrice.Product2Id = prodSeguro.Id;
        customPrice.UnitPrice = 1200;
        customPrice.IsActive = true;
        insert customPrice;
        
        
        
        PricebookEntry customPriceMoto = new PricebookEntry();
        customPriceMoto.Pricebook2Id = customPB.Id;
        customPriceMoto.Product2Id = prodCell.Id;
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
        
        Account accContado = new Account();
        accContado.FirstName = 'Daniela';
        accContado.LastName = 'Gallegos';
        accContado.Suffix = 'Ho';
        accContado.PersonEmail = 'danigallegos@deloittemx.com';
        accContado.Phone = '5563452135';
        accContado.PersonBirthdate = date.today();
        accContado.DSALES_ClienteCoppel__c=null;
        accContado.CP_WalletCustomerNumber__c=null;
        insert accContado;
        
        Account accContado2 = new Account();
        accContado2.FirstName = 'Daniela';
        accContado2.LastName = 'Gallegos';
        accContado2.Suffix = 'Ho';
        accContado2.PersonEmail = 'danigegos@deloittemx.com';
        insert accContado2;
        
        Opportunity opp = new Opportunity();
        opp.Name='TestOpportunity';
        opp.AccountId=acc.Id;
        opp.CloseDate=Date.Today();
        opp.StageName='Nuevo';
        opp.Pricebook2Id=customPB.Id;
        opp.RecordTypeId=recordTypeId;
        insert opp;
        
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '1';
        insert t;
        
        Plazo__c plazo1 = new Plazo__c();
        plazo1.Name='12';
        plazo1.dsalesSeguro__c=prodSeguro.Id;
        plazo1.Dsales_Plazo__c='12';
        plazo1.DSALES_Activo__c=true;
        insert plazo1;
        
        Plazo__c plazo = new Plazo__c();
        plazo.Name='18';
        plazo.dsalesSeguro__c=prodSeguro.Id;
        plazo.Dsales_Plazo__c='18';
        plazo.DSALES_Activo__c=true;
        insert plazo;
        
        Quote cotizacion = new Quote();
        cotizacion.Name='test';
        cotizacion.OpportunityId = opp.Id;
        cotizacion.DSales_Tienda__c=t.Id;
        cotizacion.dsalesValorFactura__c=true;
        cotizacion.Pricebook2Id =pricebookId;
        cotizacion.DSALES_RFC__c='testRFC';
        cotizacion.DSALES_Plazoacotizar__c= 12;
        cotizacion.DSales_Vendedor__c='Luis Perez Sanchez';
        cotizacion.dsalesIdentificadorCoppel__c = 011;
        insert cotizacion;
        
        QuoteLineItem presupuesto = new QuoteLineItem();
        presupuesto.QuoteId = cotizacion.Id;
        presupuesto.PricebookEntryId = standardPrice.Id;
        presupuesto.Product2Id = prodSeguro.Id;
        presupuesto.Quantity = 1;
        presupuesto.UnitPrice = standardPrice.UnitPrice;
        presupuesto.DSALES_ListaArticulo__c = 'Producto';
        presupuesto.DSALES_Plazo__c= plazo1.Id;
        presupuesto.dsalesOpcionPago__c='M';
        presupuesto.dsalesQuoteId__c= cotizacion.Id;
        presupuesto.DSALES_Segurogratis__c = false;
        presupuesto.DSALES_Descripcion__c = 'test Description';
        presupuesto.DSALES_Impuestos__c = 125.00;
        insert presupuesto;
        
        
        
        DSales_Asignacion_de_Productos__c asigProducto = new DSales_Asignacion_de_Productos__c();
        asigProducto.DSALES_Activo__c=true;
        asigProducto.DSales_Servicio_Seguro__c=prodSeguro.Id;
        asigProducto.DSales_Producto__c=ProdCell.Id;
        asigProducto.Name='Seguro Celular';
        insert asigProducto;
        
        dsalesAsignacionDeTienda__c asigTienda = new dsalesAsignacionDeTienda__c();
        asigTienda.dsalesActivo__c=true;
        asigTienda.Producto__c=prodSeguro.Id;
        asigTienda.dsalesTienda__c=t.Id;
        insert asigTienda;
        
    }
    @isTest 
    static void createQuoteTest(){
        String seguro ='Seguro';
        Product2 producto = [SELECT Id, Name, StockKeepingUnit,DSales_Tipo_de_Producto__c, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit='123122' LIMIT 1];
        Quote cotiza =[SELECT Id, Name FROM Quote WHERE Name='test'];        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"idTienda":"1", "numeroCliente":"7934", "nombreVendedor":"Luis Perez Sanchez", "identificadorCoppel":"011", "nombre":"Ana", "apellidoPaterno":"Alivia",  "apellidoMaterno":"Test", "correoElectronico":"martin.perest@gmail.com", "telefonoCelular":"123456789", "fechaNacimiento":"1975-01-17", "rfc":"MIVE901010", "precioCelular":4000,"sku":"123122", "marcaCelular":"Apple", "modeloCelular":"Iphone", "colorCelular":"Blanco", "plazoCotizar":"18", "opcionPago":"Mensual","fechaDeVenta":"", "identificadorDelVendedor":"12", "numeroDeSucursal":"22"}';
        req.requestURI = '/apexrest/insertQuoteSC';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response= res;
        DSALES_QuoteScWrapper.QuoteScRequest data =(DSALES_QuoteScWrapper.QuoteScRequest)JSON.deserialize(body, DSALES_QuoteScWrapper.QuoteScRequest.class);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSc(1));
        DSALES_QuoteScWrapper.QuoteScResponse response = DSALES_QuoteScWrapperRequest.createQuoteSc();
        QuoteLineItem item = DSALES_QuoteScWrapperRequestHelper.insertQuoteLineItem(cotiza, producto.StockKeepingUnit,data.precioCelular);
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
    }
    @isTest 
    static void nullNumeroClienteTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"idTienda":"1", "numeroCliente":null, "nombreVendedor":"Luis Perez Sanchez", "identificadorCoppel":"011", "nombre":"Daniela", "apellidoPaterno":"Gallegos",  "apellidoMaterno":"Ho", "correoElectronico":"martin.perest@gmail.com", "telefonoCelular":"123456789", "fechaNacimiento":"1975-01-17", "rfc":"MIVE901010", "precioCelular":4000,"sku":"123122", "marcaCelular":"Apple", "modeloCelular":"Iphone", "colorCelular":"Blanco", "plazoCotizar":"18", "opcionPago":"Mensual","fechaDeVenta":"", "identificadorDelVendedor":"12", "numeroDeSucursal":"22"}';
        req.requestURI = '/apexrest/insertQuoteSC';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response= res;
        DSALES_QuoteScWrapper.QuoteScRequest data =(DSALES_QuoteScWrapper.QuoteScRequest)JSON.deserialize(body, DSALES_QuoteScWrapper.QuoteScRequest.class);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSc(1));
        DSALES_QuoteScWrapper.QuoteScResponse response = DSALES_QuoteScWrapperRequest.createQuoteSc();
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
    }
    
    @isTest 
    static void quoteScTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"idTienda":"1", "numeroCliente":null, "nombreVendedor":"Luis Perez Sanchez", "identificadorCoppel":"011", "nombre":"Daniela", "apellidoPaterno":"Gallegos",  "apellidoMaterno":"Ho", "correoElectronico":"danigegos@deloittemx.com", "telefonoCelular":"5563452135", "fechaNacimiento":"1975-01-17", "rfc":"MIVE901010", "precioCelular":4000,"sku":"123122", "marcaCelular":"Apple", "modeloCelular":"Iphone", "colorCelular":"Blanco", "plazoCotizar":"18", "opcionPago":"Mensual","fechaDeVenta":"", "identificadorDelVendedor":"12", "numeroDeSucursal":"22"}';
        req.requestURI = '/apexrest/insertQuoteSC';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response= res;
        DSALES_QuoteScWrapper.QuoteScRequest data =(DSALES_QuoteScWrapper.QuoteScRequest)JSON.deserialize(body, DSALES_QuoteScWrapper.QuoteScRequest.class);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSc(1));
        DSALES_QuoteScWrapper.QuoteScResponse response = DSALES_QuoteScWrapperRequest.createQuoteSc();
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
    }
     @isTest
    static void quoteScTest1() {
        List<Account> resul = [Select Id, firstName, suffix, lastName, Fecha_de_Nacimiento__c, Phone, PersonEmail from Account WHERE firstName='Daniela1' AND suffix='Ho1' AND lastName='Gallegos1'];
        Product2 producto = [SELECT Id, Name, StockKeepingUnit,DSales_Tipo_de_Producto__c, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Name='Seguro Celular' LIMIT 1];
        Quote quote= [SELECT Id, Name FROM Quote LIMIT 1];
        String body = '{"idTienda":"1", "numeroCliente":null, "nombreVendedor":"Luis Perez Sanchez", "identificadorCoppel":"011", "nombre":"Daniela1", "apellidoPaterno":"Gallegos1",  "apellidoMaterno":"Ho1", "correoElectronico":"danigegos@deloittemx.com", "telefonoCelular":"5563452135", "fechaNacimiento":"1975-01-17", "rfc":"MIVE901010", "precioCelular":4000,"sku":"123122", "marcaCelular":"Apple", "modeloCelular":"Iphone", "colorCelular":"Blanco", "plazoCotizar":"18", "opcionPago":"Mensual","fechaDeVenta":"", "identificadorDelVendedor":"12", "numeroDeSucursal":"22"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/apexrest/insertQuoteSC'; 
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.request = req;
        RestContext.response = res;
        DSALES_QuoteScWrapper.QuoteScRequest data =(DSALES_QuoteScWrapper.QuoteScRequest)JSON.deserialize(body, DSALES_QuoteScWrapper.QuoteScRequest.class);
        List<DSALES_QuoteScWrapper.InsurancePremium> priceSeg = new List<DSALES_QuoteScWrapper.InsurancePremium>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSc(11));
        DSALES_QuoteScWrapper.QuoteScResponse response = DSALES_QuoteScWrapperRequest.createQuoteSC();
        List<DSALES_QuoteScWrapper.Plazo>  plz =DSALES_QuoteScWrapperRequestHelper.insertPlazos(producto.Name,quote, priceSeg,data.quoteId, data.opcionPago, data.plazoCotizar);
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
    }
    
    @isTest
    static void quoteScTest2() {
        List<Account> result = [Select Id,firstName,suffix,lastName from Account WHERE CP_WalletCustomerNumber__c =45654];
        String body = '{"idTienda":"1", "numeroCliente":45654, "nombreVendedor":"Luis Perez Sanchez", "identificadorCoppel":"011", "nombre":"Dani", "apellidoPaterno":"Min",  "apellidoMaterno":"Ho", "correoElectronico":"danigegos@deloittemx.com", "telefonoCelular":"5563452135", "fechaNacimiento":"1975-01-17", "rfc":"MIVE901010", "precioCelular":4000,"sku":"123122", "marcaCelular":"Apple", "modeloCelular":"Iphone", "colorCelular":"Blanco", "plazoCotizar":"18", "opcionPago":"Mensual","fechaDeVenta":"", "identificadorDelVendedor":"12", "numeroDeSucursal":"22"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/apexrest/insertQuoteSC';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSc(3));
        DSALES_QuoteScWrapper.QuoteScResponse response = DSALES_QuoteScWrapperRequest.createQuoteSC();
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200'); 
        
    }
    
    @isTest 
    static void exceptionTest(){
        RestResponse res = new RestResponse();
        String requestBody = 'invalid body';
        RestRequest req = new RestRequest();
        req.requestURI = '/apexrest/insertQuoteSC';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(requestBody);
        RestContext.request = req;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponseQuoteSc(9));
        DSALES_QuoteScWrapper.QuoteScResponse response= DSALES_QuoteScWrapperRequest.createQuoteSC();
        Test.stopTest();
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
    }
    
}