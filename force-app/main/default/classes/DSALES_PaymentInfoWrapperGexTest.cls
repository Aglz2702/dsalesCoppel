@isTest
public class DSALES_PaymentInfoWrapperGexTest {
    @testSetup
    static void SetUp(){
        
        Account acc = new Account();
        acc.Name='testL';
        acc.BillingCity = 'test';
        acc.BillingStreet = 'calle 3 test';
        acc.BillingState = 'CDMX';
        acc.BillingPostalCode = '666666';
        insert acc;
        
        String recordTypeId = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByName().get('Pagos de venta de servicios').getRecordTypeId();
        
        Opportunity opp = new Opportunity();
        opp.Name = 'testL';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Nuevo';
        insert opp;
        
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  'CPPL-UGARTE';
        insert t;
    }
    
    @isTest 
       	static void CreatePaymentRecordTest(){
        Opportunity oppor = [Select Id From Opportunity LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{ "opportunity_id":"'+oppor.Id+'","clave_tienda":"CPPL-UGARTE" ,"id_factura":"test2","total_compra":12000, "sku":"650498", "PartidasDePago":[{ "tipo_de_pago": "Efectivo", "pago": 9000 }, { "tipo_de_pago": "Débito", "pago": 3000 }]}';
        req.requestURI = '/apexrest/insertPaymentInformationGEX';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest pago = (DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest)JSON.deserialize(body, DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest.class);
        Test.startTest();
		DSALES_PaymentInfoWrapperGexRequest.createPayment();
		Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
    }
    
    @isTest 
    static void CreateSaleTestWrong(){
        Opportunity oppor = [Select Id From Opportunity LIMIT 1];
        RestRequest req2= new RestRequest(); 
        RestResponse res2= new RestResponse();
        String body2 = '{""opportunity_id":"'+oppor.Id+'","clave_tienda":"CPPL-UGARTE" ,"id_factura":"test2","total_compra":12000, "sku":"650498", "PartidasDePago":[{ "tipo_de_pago": "Efectivo", "pago": 9000 }, { "tipo_de_pago": "Débito", "pago": 3000 }]}';
        req2.httpMethod = 'POST';
        RestContext.request = req2;
        req2.requestBody = Blob.valueof(body2);
        RestContext.response = res2;
        DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest pago2 = (DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest)JSON.deserialize(body2, DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest.class);
        Test.startTest();
        DSALES_PaymentInfoWrapperGexRequest.createPayment();
        Test.stopTest();
        RestContext.request = req2;
        RestContext.response= res2;
    }

}