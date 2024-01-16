@isTest
public with sharing class DSALES_UpdateEmailQuoteRestTest {
    @TestSetup
    static void setUp(){
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Servicios').getRecordTypeId();
        Id pricebookId = Test.getStandardPricebookId();

        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;

        Account acc = new Account();
        acc.Name = 'test';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.DSALES_ClienteCoppel__c='90001';
        insert acc;

        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;

        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '21';
        t.DSales_TiendaID__c =  '21';
        insert t;

        Quote cotizacion = new Quote(Name='test', OpportunityId = opp.Id, DSales_Tienda__c=t.Id,dsalesValorFactura__c=true, Pricebook2Id =pricebookId,DSALES_RFC__c='testRFC');
        insert cotizacion;
        
        Quote cotizacion2 = new Quote(Name='test2', OpportunityId = opp.Id, DSales_Tienda__c=t.Id,dsalesValorFactura__c=true, Pricebook2Id =pricebookId,DSALES_RFC__c='testRFC', DSALES_Contado__c=true);
        insert cotizacion2;
    }

    @isTest 
    static void updateEmailTest(){
        Quote cotizacion = [SELECT id FROM Quote where name='test' LIMIT 1];
        Opportunity oportunidad = [SELECT id FROM Opportunity LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"idCotizacion": "'+cotizacion.id+'", "correo": "valor_correo", "idOportunidad": "'+oportunidad.id+'"}';
        req.requestURI = '/apexrest/actualizarCotizacion/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteRequest data = (  DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteRequest)JSON.deserialize(body,  DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteRequest.class);
        Test.startTest();
        DSALES_UpdateEmailQuoteRest.actualizarQuote();
        Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
    }
    
    @isTest 
    static void updateEmailErrorTest(){
        Quote cotizacion = [SELECT id FROM Quote where name='test2' LIMIT 1];
        Opportunity oportunidad = [SELECT id FROM Opportunity LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"idCotizacion": "'+cotizacion.id+'", "correo": "valor_correo", "idOportunidad": "'+oportunidad.id+'"}';
        req.requestURI = '/apexrest/actualizarCotizacion/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteRequest data = (  DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteRequest)JSON.deserialize(body,  DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteRequest.class);
        Test.startTest();
        DSALES_UpdateEmailQuoteRest.actualizarQuote();
        Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
    }
}