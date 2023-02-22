@isTest
global with sharing class DSALES_IPAssetWrapperRequestActivoTest {
    @testSetup
    static void SetUp(){
        Account ac= new Account(Name='NelsonTest',CP_WalletCustomerNumber__c=90229562);  
        insert ac;
        Opportunity op = new Opportunity(Name='Nelson',CloseDate=Date.today(),StageName='Nuevo');
        insert op;
        InsurancePolicy ip = new InsurancePolicy(Name='Nelson',NameInsuredId=ac.id,DSALES_CorreoElectronico__c='xnelsonvsx@hotmail.com');
        insert ip;
        InsurancePolicy pol = new InsurancePolicy(Name='Sayra test',NameInsuredId=ac.id,DSALES_CorreoElectronico__c='xnelsonvsx@hotmail.com');
        insert pol;
        String recordTypeIdPago=Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_PagosdeVentaenNPVSM_c').getRecordTypeId();
		Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  'CPPL-UGARTE';
        insert t;
        DSALES_InformaciondePago__c pago = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=op.id,DSALES_Cliente__c=ac.Id,DSALES_Poliza__c=ip.id,DSALES_Clave_Tienda__c='1',DSALES_Seguro__c=true);
        insert pago; 
        DSALES_InformaciondePago__c pago2 = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=op.id,DSALES_Cliente__c=ac.Id,DSALES_Poliza__c=pol.id,DSALES_Clave_Tienda__c='2',DSALES_Seguro__c=true);
        insert pago2; 
    }
    @isTest static void CreateRecordTest()
    {
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        DSALES_InformaciondePago__c pago = [SELECT id,DSALES_Poliza__c, DSALES_Motoentregada__c FROM  DSALES_InformaciondePago__c  WHERE DSALES_Clave_Tienda__c='1' LIMIT 1];
        String body='{"emitir_poliza":true,"uso":"Personal","id_tienda":"1","servicio":"Particular","numero_serie":"1334342343","numero_motor":"343434343","modelo":"2022","placas":"XRDH48","clave_vehicular":"023023834","valor_factura":8000,"bajo_demanda":false,"descripcion":"Motocicleta vento xr","marca":"Vento","nombre_activo":"Motocicleta vento xr","id_pago":"'+pago.Id+'"}';
        request.requestURI='/apexrest/insertIPAssetDelivered'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_IPAssetWrapper.IPAssetRequest policyAsset =  (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize (body,DSALES_IPAssetWrapper.IPAssetRequest.class);
        //policyAsset.payment_info=pago.id;
        Test.startTest();
        DSALES_IPAssetWrapperRequestActivo.createIPAsset();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        
    }
    
    @isTest static void CreateRecordErrorTest()
    {
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        DSALES_InformaciondePago__c pago = [SELECT id,DSALES_Poliza__c, DSALES_Motoentregada__c FROM  DSALES_InformaciondePago__c  WHERE DSALES_Clave_Tienda__c='2' LIMIT 1];
        String body='{"emitir_poliza":false,"uso":"Personal","id_tienda":"2","servicio":"Particular","numero_serie":"1334342343","numero_motor":"343434343","modelo":"2022","placas":"XRDH48","clave_vehicular":"023023834","valor_factura":8000,"bajo_demanda":false,"descripcion":"Motocicleta vento xr","marca":"Vento","nombre_activo":"Motocicleta vento xr","id_pago":"xxxxxx"}';
        request.requestURI='/apexrest/insertIPAssetDelivered'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_IPAssetWrapper.IPAssetRequest policyAsset =  (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize (body,DSALES_IPAssetWrapper.IPAssetRequest.class);
        //policyAsset.payment_info=pago.id;
        Test.startTest();
        DSALES_IPAssetWrapperRequestActivo.createIPAsset();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        
    }
    
}