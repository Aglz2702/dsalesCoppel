@isTest
public class DSALES_PaymentInfoWrapperTest {
    @testSetup
    static void SetUp(){
       // String idRecortype =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); //PersonAccount
        Account acc = new Account();
       // acc.RecordTypeId=idRecortype;
        acc.Name='testL';
        acc.BillingCity = 'test';
        acc.BillingStreet = 'calle 3 test';
        acc.BillingState = 'CDMX';
        acc.BillingPostalCode = '666666';
        acc.BillingCountry='México';
        //acc.FinServ__BillingAddress__pc='Venustiano Carranza <br> Putla,Oaxaca,12<br>México';
        insert acc;
        String recordTypeId = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_PagosdeVentaenNPVSM_c').getRecordTypeId();
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
       	static void registrarPagoTest(){
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
        Tienda__c tienda =[SELECT Id FROM Tienda__c LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //String body = '{ "opportunity_id":"'+oppor.Id+'","clave_tienda":"CPPL-UGARTE" ,"id_factura":"test2","total_compra":12000, "sku":"650498", "PartidasDePago":[{ "tipo_de_pago": "Efectivo", "pago": 9000 }, { "tipo_de_pago": "Débito", "pago": 3000 }]}';
        String body='{"num_factura":545774,"total_factura":20000,"Seguro":false,"nombre_vendedor":"Nelson Varela","numero_caja":"1","clave_tienda":"CPPL-UGARTE","sku":"1225473","id_oportunidad":"'+ oppty.Id +'","fecha_de_entrega":"2023-01-20","fecha_venta":"2023-01-19","plazos":12,"ListaDePagos":[{"metodo_pago":"Dinero Electrónico","pago":10000}]}';
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
    @isTest 
    static void registrarPagoErrorTest(){
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
        Tienda__c tienda =[SELECT Id FROM Tienda__c LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //String body = '{ "opportunity_id":"'+oppor.Id+'","clave_tienda":"CPPL-UGARTE" ,"id_factura":"test2","total_compra":12000, "sku":"650498", "PartidasDePago":[{ "tipo_de_pago": "Efectivo", "pago": 9000 }, { "tipo_de_pago": "Débito", "pago": 3000 }]}';
        String body='{"num_factura":545774,"total_factura":20000,"Seguro":false,"nombre_vendedor":"Nelson Varela","numero_caja":"1","clave_tienda":"23456789321","sku":"1225473","id_oportunidad":"'+ oppty.Id +'","fecha_de_entrega":"2023-01-20","fecha_venta":"2023-01-19","plazos":12,"ListaDePagos":[{"metodo_pago":"Dinero Electrónico","pago":10000}]}';
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