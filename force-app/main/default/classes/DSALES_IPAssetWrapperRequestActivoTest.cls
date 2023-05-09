@isTest
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class DSALES_IPAssetWrapperRequestActivoTest {
    @testSetup
    static void setUp(){
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
        t.DSales_Tienda__cID__c =  '1';
        insert t;
        DSALES_InformaciondePago__c pago = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=op.id,DSALES_Cliente__c=ac.Id,DSALES_Poliza__c=ip.id,DSALES_Clave_Tienda__c='1',dsalesSeguro__c=true,DSALES_IDUniversal1__c='2023031400015666666');
        insert pago; 
        DSALES_InformaciondePago__c pago2 = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=op.id,DSALES_Cliente__c=ac.Id,DSALES_Poliza__c=pol.id,DSALES_Clave_Tienda__c='1',dsalesSeguro__c=true,DSALES_IDUniversal1__c='2023031400015666600');
        insert pago2; 
        DSALES_InformaciondePago__c pago3 = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=op.id,DSALES_Cliente__c=ac.Id,DSALES_Poliza__c=pol.id,DSALES_Clave_Tienda__c='1',dsalesSeguro__c=false,DSALES_IDUniversal1__c='2023031400015666634');
        insert pago3;
        InsurancePolicy poliza = new InsurancePolicy(
				SourceOpportunityId=op.Id,
            	DSALES_Estatusdepliza__c='Vigente',
        		NameInsuredId=ac.Id,
                DSALES_Tipodepersona__c='Física',
            	DSALES_CorreoElectronico__c='saymartinez@deloittemx.com',
            	Name=DSALES_Utility.SEGURO_PREDETERMINADO
                
        );
        insert poliza;
    }
    @isTest 
    public static void sinPolizaTest(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        DSALES_InformaciondePago__c pago = [SELECT id,DSALES_Poliza__c,DSALES_IDUniversal1__c, DSALES_Motoentregada__c FROM  DSALES_InformaciondePago__c  WHERE  DSALES_IDUniversal1__c='2023031400015666634'];
        InsurancePolicy poliza = [SELECT Id FROM InsurancePolicy WHERE Id=:pago.DSALES_Poliza__c];
        String body='{"emitir_poliza":false,"id_universal":"2023031400015666634","tipo_folio":"014564","folio_transaccion":"01","uso":"Personal","id_tienda":"1","servicio":"Particular","numero_serie":"1334342343","numero_motor":"343434343","modelo":"2022","placas":"XRDH48","clave_vehicular":"023023834","valor_factura":8000,"descripcion":"VITALIA ITALIKA ","bajo_demanda":false,"marca":"Vento","nombre_activo":"VITALIA ITALIKA "}';
        request.requestURI='/apexrest/insertIPAssetDelivered'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_IPAssetWrapper.IPAssetRequest policyAsset =  (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize (body,DSALES_IPAssetWrapper.IPAssetRequest.class);
        Test.startTest();
        DSALES_IPAssetWrapperRequestActivo.createIPAsset();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        system.assertNotEquals(200, response.statusCode, 'la llamada no debe devolver un código 200');
    }
    
    @isTest 
    public static void sinEmitirTest(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        DSALES_InformaciondePago__c pago = [SELECT id,DSALES_Poliza__c,DSALES_IDUniversal1__c, DSALES_Motoentregada__c FROM  DSALES_InformaciondePago__c  WHERE  DSALES_IDUniversal1__c='2023031400015666600'];
        String body='{"emitir_poliza":false,"id_universal":"2023031400015666600","tipo_folio":"014564","folio_transaccion":"01","uso":"Personal","id_tienda":"1","servicio":"Particular","numero_serie":"1334342343","numero_motor":"343434343","modelo":"2022","placas":"XRDH48","clave_vehicular":"023023834","valor_factura":8000,"descripcion":"VITALIA ITALIKA ","bajo_demanda":false,"marca":"Vento","nombre_activo":"VITALIA ITALIKA "}';
        request.requestURI='/apexrest/insertIPAssetDelivered'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_IPAssetWrapper.IPAssetRequest policyAsset =  (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize (body,DSALES_IPAssetWrapper.IPAssetRequest.class);
        Test.startTest();
        DSALES_IPAssetWrapperRequestActivo.createIPAsset();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        system.assertNotEquals(200, response.statusCode, 'la llamada no debe devolver un código 200');
    }
    @isTest 
    public static void activoTest(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        DSALES_InformaciondePago__c pago = [SELECT id,DSALES_Poliza__c,DSALES_IDUniversal1__c, DSALES_Motoentregada__c FROM  DSALES_InformaciondePago__c  WHERE DSALES_IDUniversal1__c='2023031400015666666'];
        String body='{"emitir_poliza":true,"id_universal":"2023031400015666666","tipo_folio":"014564","folio_transaccion":"01","uso":"Personal","id_tienda":"1","servicio":"Particular","numero_serie":"1334342343","numero_motor":"343434343","modelo":"2022","placas":"XRDH48","clave_vehicular":"023023834","valor_factura":8000,"descripcion":"VITALIA ITALIKA ","bajo_demanda":false,"marca":"Vento","nombre_activo":"VITALIA ITALIKA "}';
        request.requestURI='/apexrest/insertIPAssetDelivered'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_IPAssetWrapper.IPAssetRequest policyAsset =  (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize (body,DSALES_IPAssetWrapper.IPAssetRequest.class);
        Test.startTest();
        DSALES_IPAssetWrapperRequestActivo.createIPAsset();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        system.assertNotEquals(200, response.statusCode, 'la llamada no debe devolver un código 200');
    }
    
    @isTest 
    public static void createRecordErrorTest()
    {
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        DSALES_InformaciondePago__c pago = [SELECT id,DSALES_Poliza__c, DSALES_Motoentregada__c FROM  DSALES_InformaciondePago__c  WHERE DSALES_Clave_Tienda__c='1' LIMIT 1];
        String body='{"emitir_poliza":true,"id_universal":"","tipo_folio":"014564","folio_transaccion":"01","uso":"Personal","id_tienda":"1","servicio":"Particular","numero_serie":"1334342343","numero_motor":"343434343","modelo":"2022","placas":"XRDH48","clave_vehicular":"023023834","valor_factura":8000,"descripcion":"VITALIA ITALIKA ","bajo_demanda":false,"marca":"Vento","nombre_activo":"VITALIA ITALIKA "}';
        request.requestURI='/apexrest/insertIPAssetDelivered'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_IPAssetWrapper.IPAssetRequest policyAsset =  (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize (body,DSALES_IPAssetWrapper.IPAssetRequest.class);
        Test.startTest();
        DSALES_IPAssetWrapperRequestActivo.createIPAsset();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        system.assertNotEquals(200, response.statusCode, 'la llamada no debe devolver un código 200');
    }
    
}