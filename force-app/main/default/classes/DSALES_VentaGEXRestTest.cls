@isTest
public with sharing class DSALES_VentaGEXRestTest {
    
    @testSetup
    static void crearRegistro(){
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Garantía Extendida').getRecordTypeId();
        String recordTypeQuoteId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Venta de Garantía Extendida').getRecordTypeId();
        Tienda__c t = new Tienda__c();
        t.dsales_TiendaID__c =  'CPPL-UGARTE';
        insert t;

        Account acc = new Account();
        acc.FirstName ='test';
        acc.LastName = 'test';
        acc.PersonEmail = 'test@gmail.com';
        acc.PersonBirthdate = date.today();
        insert acc;
        Opportunity oppor = new Opportunity();
        oppor.AccountId = acc.Id;
        oppor.Name = acc.Name+' '+'GEX';
        oppor.CloseDate = date.today()+30;
        oppor.StageName = 	'Nuevo';
        oppor.RecordTypeId = recordTypeId;
        oppor.DSALES_Tienda__c = t.Id;
        insert oppor;
         Product2 prod2 = new Product2();
        prod2.Name='Testing Test2';
        prod2.StockKeepingUnit='1234689011111';
        prod2.DSales_Tipo_de_Producto__c='Servicio';
        insert prod2;
		
		Product2 produ = new Product2(); 
        produ.Name='test tangible';
        produ.StockKeepingUnit='123468911';
        produ.DSales_Tipo_de_Producto__c='Producto';
        insert produ;
        String pb2Id=Test.getStandardPricebookId();
        
          PricebookEntry pb = New PricebookEntry();
        pb.Product2Id = prod2.Id;
        pb.PriceBook2Id =pb2Id;//Test.getStandardPricebookId();
        pb.UseStandardPrice = false;
        pb.UnitPrice=200;
        //pb.UnitPrice=35;//when we use standarprice book =true thenunit price is readonly field
        pb.isActive=true;
       	insert pb;
        
         Quote cotiza = new Quote();
        cotiza.Name = 'GEX';
        cotiza.OpportunityId = oppor.Id;
        cotiza.RecordTypeId =recordTypeQuoteId;
        cotiza.DSales_Tienda__c = t.Id;
        cotiza.PriceBook2Id=pb2Id;
       // cotiza.DSALES_Regioon__c = 'HERMOSILLO';
        cotiza.DSales_Division__c= '4';
        cotiza.ExpirationDate = date.today()+14;
        insert cotiza;
          QuoteLineItem quote= new QuoteLineItem(QuoteId=cotiza.Id,UnitPrice=2,Quantity=2,PricebookEntryId=pb.Id,Product2Id=prod2.id,Vigencia_meses__c='12');
        insert quote;
        
       
        
               
        
        
       
    }
    
    @isTest 
    static void crearVentaTest(){
        Quote cotiza=[SELECT id FROM Quote LIMIT 1];
        QuoteLineItem qt=[SELECT Id FROM QuoteLineItem LIMIT 1]; 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{ "cliente":{ "numeroCliente":"","nombre": "Daniel","apellidoPaterno": "San Miguel","apellidoMaterno":"Cardona","telefono": "89017829","correoElectronico": "dsanmiguel@deloittemx.com","genero": "F","fechaNacimiento": "1992-08-02","nombreCiudad": "Monterrey","nombreEstado": "Nuevo Leon","domicilio": "Montreal","numeroExterior": "169","numeroInterior": "","colonia":"Valle de las Lomas","codigoPostal":"66758"},"quoteId":"'+cotiza.Id+'","fechaCompra":"1992-08-02","idTienda":"21","numeroCaja":"23","idVendedor":"27","nombreVendedor":"Daniel San Miguel Cárdenas","idFactura":"1233456","listaDeProductos":[{"skuDeTangible" :"123468911", "articulo":"Computadora"}],"listaDeCertificados":[ {  "skuDeTangible" :"123468911",  "idPartidaPresupuesto":"'+qt.id+'","modeloTangible": "Horno","marcaTangible": "Samsung","numeroSerie": "", "precioTangible": "13000","garantiaCoppelProducto" : "12","fechaInicioGarantiaExtendida":"1992-08-02"}   ],"pago":{"precioTotal":5000,"pagoConDineroElectronico":0,"pagoTarjeta":1500,"cheque":0,"reembolso":1500,"porcentajeIva":5,"PartidasDePago": [{"numPago": 1,"tipoDePago": "Efectivo","pago": 10000}]}} ';
        req.requestURI = '/apexrest/ventaGex';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        DSALES_VentaGEX.VentaGexRequest venta = (DSALES_VentaGEX.VentaGexRequest)JSON.deserialize(body, DSALES_VentaGEX.VentaGexRequest.class);
        Test.startTest();
        DSALES_VentaGEX.VentaGexResponse ventaGex= new DSALES_VentaGEX.VentaGexResponse();
       DSALES_VentaGEX.OpporLineItem oporLine = new DSALES_VentaGEX.OpporLineItem();
        oporLine.idPartidaDeOportunidad='test';
        oporLine.nombreProducto='Test';
        oporLine.sku='Test';
        oporLine.tipoProducto='Test';
        oporLine.idProductoAdquirido='Test';
        DSALES_VentaGEX.ServicioCorrespondiente servicio = new  DSALES_VentaGEX.ServicioCorrespondiente();
        servicio.folioCertificado='Test';
        servicio.sku='Test';
        servicio.tipoProducto='Test';
        servicio.idPartidaDeOportunidad='Test';
        DSALES_VentaGEXRest.createVenta();
        Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
        System.assertnotEquals(200, res.statusCode,'El status code no debería ser 200');
    }
     static void crearVentaMalTest(){
        RestRequest req2= new RestRequest(); 
        RestResponse res2= new RestResponse();
        String body2 = '{"":stupurc: "Carl55 6666","movilPhone": "123 456 7890","price": 500,"cash_total": 500,"credit_VAT": 0,"electronic_money": 10,"paymentElectronic_money": 0,"cash_payment": 200,"change": 0,"wonElectronic_money": 1,"GEX_paid": false,"price_noVAT": 200,"price_DiscountVAT": 200,"price_DiscountNoVAT": 200,"sku": "123468901"}]}}';
        req2.httpMethod = 'POST';
        RestContext.request = req2;
        req2.requestBody = Blob.valueof(body2);
        RestContext.response = res2;
        DSALES_VentaGEX.VentaGexRequest venta2 = (DSALES_VentaGEX.VentaGexRequest)JSON.deserialize(body2, DSALES_VentaGEX.VentaGexRequest.class);
        Test.startTest();
        DSALES_VentaGEXRest.createVenta();
        Test.stopTest();
        RestContext.request = req2;
        RestContext.response= res2;
        System.assertEquals(200, res2.statusCode,'El status code no debería ser 200');

    }
    
}