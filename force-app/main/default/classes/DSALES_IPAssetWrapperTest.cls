@isTest
global with sharing class DSALES_IPAssetWrapperTest {
    @testSetup
    static void SetUp(){
        Account ac= new Account(Name='DannyTest',CP_WalletCustomerNumber__c=90229562);  
        insert ac;
        Opportunity op = new Opportunity(Name='Danny',CloseDate=Date.today(),StageName='Nuevo');
        insert op;
         InsurancePolicy ip = new InsurancePolicy(Name='Danny',NameInsuredId=ac.id,DSALES_CorreoElectronico__c='kvothe.sanmiguel@gmail.com');
        insert ip;
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  'CPPL-UGARTE';
        insert t;
        /*Asset producto= new Asset(Name='Danny',AccountId=ac.id);
        insert producto;*/
        DSALES_InformaciondePago__c pago = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=op.id,DSALES_Cliente__c=ac.Id,DSALES_Poliza__c=ip.id,DSALES_Seguro__c=true);
        insert pago;
    }
    @isTest static void CreateRecordTest()
    {
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        DSALES_InformaciondePago__c pago = [SELECT id,DSALES_Poliza__c FROM  DSALES_InformaciondePago__c  LIMIT 1];
        Tienda__c tienda =[SELECT Id FROM Tienda__c LIMIT 1];
        String body='{"emitir_poliza":true,"uso":"Personal","id_tienda":"CPPL","servicio":"Particular","numero_serie":"1334342343","numero_motor":"343434343","modelo":"2022","placas":"XRDH48","clave_vehicular":"023023834","valor_factura":8000,"bajo_demanda":true,"descripcion":"Motocicleta vento xr","marca":"Vento","nombre_activo":"Motocicleta vento xr","id_pago":"'+pago.Id+'"}';
        request.requestURI='/apexrest/insertIPAsset'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_IPAssetWrapper.IPAssetRequest policyAsset =  (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize (body,DSALES_IPAssetWrapper.IPAssetRequest.class);
        //policyAsset.payment_info=pago.id;
        Test.startTest();
        DSALES_IPAssetWrapperRequest.createIPAsset();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        
    }
    @isTest static 
	void CreateRecordErrorTest(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        DSALES_InformaciondePago__c pago = [SELECT id,DSALES_Poliza__c FROM  DSALES_InformaciondePago__c  LIMIT 1];
        Tienda__c tienda =[SELECT Id FROM Tienda__c LIMIT 1];
        String body='{"emitir_poliza":true,"uso":"Personal","id_tienda":"CPPL","servicio":"Particular","numero_serie":"1334342343","numero_motor":"343434343","modelo":"2022","placas":"XRDH48","clave_vehicular":"023023834","valor_factura":8000,"bajo_demanda":true,"descripcion":"Motocicleta vento xr","marca":"Vento","nombre_activo":"Motocicleta vento xr","id_pago":"xxxxxxx"}';
        request.requestURI='/apexrest/insertIPAsset'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_IPAssetWrapper.IPAssetRequest policyAsset =  (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize (body,DSALES_IPAssetWrapper.IPAssetRequest.class);
        //policyAsset.payment_info=pago.id;
        Test.startTest();
        DSALES_IPAssetWrapperRequest.createIPAsset();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        
    }
    
}