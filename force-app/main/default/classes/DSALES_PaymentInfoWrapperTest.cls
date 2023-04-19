@isTest
public class DSALES_PaymentInfoWrapperTest {
    @testSetup
    public static void setUp(){
    	Account acc = new Account();
       	acc.Name='testL';
        acc.BillingCity = 'test';
        acc.BillingStreet = 'calle 3 test';
        acc.BillingState = 'CDMX';
        acc.BillingPostalCode = '666666';
        acc.BillingCountry='México';
        insert acc;
        String recordTypeId = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_PagosdeVentaenNPVSM_c').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.Name = 'testL';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Nuevo';
        insert opp;
        
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '1';
        insert t;
    }
    
    @isTest 
       	static void registrarPagoTest(){
        Account cuenta =[SELECT Id,FinServ__BillingAddress__pc FROM Account];
        System.debug('cliente:'+cuenta);
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        Tienda__c tienda =[SELECT Id FROM Tienda__c LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body='{"id_universal":"20230314000101014564","tipo_folio":"01","folio_transaccion":"012345","total_factura":20000,"Seguro":true,"nombre_vendedor":"Nelson Varela","numero_caja":"1","clave_tienda":"1","sku":"","id_oportunidad":"'+op.Id+'","fecha_de_entrega":"2023-01-20","fecha_venta":"2023-01-19","plazos":18,"ListaDePagos":[{"metodo_pago":"Efectivo","pago":10000},{"metodo_pago":"Efectivo","pago":10000}]}';
        req.requestURI = '/insertPaymentInformationSM/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        DSALES_PaymentInfoWrapper.PaymentRequest pago = (DSALES_PaymentInfoWrapper.PaymentRequest)JSON.deserialize(body, DSALES_PaymentInfoWrapper.PaymentRequest.class);            
        System.debug('PAGO TEST:'+pago);
        Test.startTest();
		DSALES_PaymentInfoWrapperRequest.createPayment();
		Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
    }
    @isTest 
    static void registrarPagoErrorTest(){
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        Tienda__c tienda =[SELECT Id FROM Tienda__c LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //String body = '{ "opportunity_id":"'+oppor.Id+'","clave_tienda":"CPPL-UGARTE" ,"id_factura":"test2","total_compra":12000, "sku":"650498", "PartidasDePago":[{ "tipo_de_pago": "Efectivo", "pago": 9000 }, { "tipo_de_pago": "Débito", "pago": 3000 }]}';
        String body='{"id_universal":"xxxxx","tipo_folio":"01","folio_transaccion":"01","total_factura":20000,"Seguro":true,"nombre_vendedor":"Nelson Varela","numero_caja":"1","clave_tienda":"1","sku":"","id_oportunidad":"'+op.Id+'","fecha_de_entrega":"2023-01-20","fecha_venta":"2023-01-19","plazos":18,"ListaDePagos":[{"metodo_pago":"Efectivo","pago":10000}]}';
        req.requestURI = '/insertPaymentInformationSM/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        DSALES_PaymentInfoWrapper.PaymentRequest pago = (DSALES_PaymentInfoWrapper.PaymentRequest)JSON.deserialize(body, DSALES_PaymentInfoWrapper.PaymentRequest.class);            
        Test.startTest();
		DSALES_PaymentInfoWrapperRequest.createPayment();
		Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
    }
}