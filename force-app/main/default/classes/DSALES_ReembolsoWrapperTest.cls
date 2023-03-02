@isTest
global with sharing class DSALES_ReembolsoWrapperTest {
    @testSetup
    static void SetUp()
    {
        Opportunity opp = new Opportunity(Name='Danny',StageName='Closed',CloseDate=Date.today());
        insert opp;
        Account ac= new Account(Name='DannyTest',CP_WalletCustomerNumber__c=123456);  
        insert ac;
         DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c(DSALES_Oportunidad__c=opp.id,DSALES_Factura__c='1234',DSALES_Clave_Tienda__c='1234');
        insert pago;
        
    }
    
    @isTest static void createRecordTest()
        {
            DSALES_InformacionDePago__c pago= [SELECT DSALES_IDUniversal__c FROM DSALES_InformacionDePago__c WHERE DSALES_Factura__c='1234' LIMIT 1];
            RestRequest request = new RestRequest();
            RestResponse response= new RestResponse();
            request.requestURI='/apexrest/insertReembolso';
            request.httpMethod='POST';
            RestContext.request=request;
             String body = '{"pago_universal": "'+pago.DSALES_IDUniversal__c+'","comentarios": "El cliente decidió cancelar el producto","fecha": "2023-02-24",'+
  '"metodo_pago": "Efectivo","numero_referencia": "1123456621","cantidad": 15005}';
            request.requestBody=blob.valueOf(body);
            RestContext.response=response;
            DSALES_ReembolsoWrapper.ReembolsoRequest reembolso =  (DSALES_ReembolsoWrapper.ReembolsoRequest)JSON.deserialize (body,DSALES_ReembolsoWrapper.ReembolsoRequest.class);
            Test.startTest();
            DSALES_ReembolsoWrapperRequest.createReembolso();
            Test.stopTest();
            RestContext.request = request;
        RestContext.response= response;
            
        }
      
}