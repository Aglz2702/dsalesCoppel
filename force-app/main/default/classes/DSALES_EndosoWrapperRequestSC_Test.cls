@isTest 
public class DSALES_EndosoWrapperRequestSC_Test {
    @testSetup 
    static void setUp(){
        Account ac= new Account();
        ac.Name='Test';
        insert ac;
        
        String recordTypeId = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByName().get('Seguro de Celulares').getRecordTypeId();
        
        InsurancePolicy poliza = new InsurancePolicy();
        poliza.NameInsuredId= ac.Id;
        poliza.Name = '044240108109000000';
        poliza.PolicyName = '044240108109000000';
        poliza.DSALES_CorreoElectronico__c = 'test@test.com';
        poliza.DSALES_TelefonoContacto__c = '123-456-7890';
        poliza.DSALES_NombredelAsegurado__c = 'John Doe';
        poliza.DSALES_Placas__c = 'ABC123';
        poliza.DSALES_Numeroserie__c = '1234567890';
        poliza.dsalesNumeroDeMotor__c = '0987654321';
        poliza.RecordTypeId = recordTypeId;
        insert poliza;
        
        DSALES_Endoso__c endoso = new DSALES_Endoso__c();
        endoso.DSALES_uid__c = 'testUid';
        endoso.DSALES_Cliente__c = ac.Id;
        endoso.DSALES_Poliza__c = poliza.Id;
        endoso.DSALES_Estatus__c = 'Nuevo';
        endoso.DSALES_MotivoRechazo__c ='Test';
        endoso.DSALES_MotivoDevolucion__c ='test';
        endoso.DSALES_SolucionDevolucion__c ='test';
        endoso.DSALES_MontoaDevolver__c = 4.55;
        endoso.DSALES_Valor__c = 'Demo';
        endoso.DSALES_Tipodedato__c = 'RFC';
        endoso.DSALES_CorreoElectronico__c = 'nakatore@deloittemx.com';
        insert endoso;        
    }
    
    @isTest static void createRecordTest(){
        DSALES_Endoso__c endosoRecord = [SELECT Id,DSALES_Poliza__c,DSALES_Poliza__r.Name, DSALES_uid__c FROM DSALES_Endoso__c LIMIT 1];
        InsurancePolicy inspol= [SELECT Id, Name FROM InsurancePolicy WHERE ID =:endosoRecord.DSALES_Poliza__c LIMIT 1];
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        String body = '{"uid":"wert123", "numeroPoliza":"044240108109000000","tipoEndoso":"Cambio de placas","tipoDocumento":"Comprobante de domicilio","datos":{"idDato":"1","tipoDato":"RFC","valor":"XRY5658989"},"montoDevolver":4.5,"estatus":"Nuevo","motivoDevolucion":"","solucionDevolucion":"","motivoRechazo":"", "fechaEndoso":"2023-03-08","fechaAplicacion":"2023-03-07","salesforceId":"a356w00000045pbAAA","documentos":null}';
        request.requestURI='/apexrest/insertEndoso'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_EndorsementWrapper.endorsementRequest endoso = (DSALES_EndorsementWrapper.endorsementRequest)JSON.deserialize(body, DSALES_EndorsementWrapper.endorsementRequest.class);
        Test.startTest();               
         DSALES_EndosoWrapperRequestSC.createEndosoSc();
        Test.stopTest();        
        RestContext.request = request;
        RestContext.response= response;
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200'); 

    }
   
    @isTest static void createRecordTest1(){
        DSALES_Endoso__c endosoRecord = [SELECT Id, DSALES_Poliza__c, DSALES_Poliza__r.Name, DSALES_uid__c FROM DSALES_Endoso__c LIMIT 1];
        InsurancePolicy inspol= [SELECT Id, Name FROM InsurancePolicy WHERE ID =:endosoRecord.DSALES_Poliza__c LIMIT 1];
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        String body = '{"uid":"", "numeroPoliza":null,"tipoEndoso":" ","tipoDocumento":"","datos":{"idDato":"","tipoDato":"","valor":""},"montoDevolver":4.5,"estatus":"Authorizado","motivoDevolucion":"Test","solucionDevolucion":"Test","motivoRechazo":"Test", "fechaEndoso":"2023-03-08","fechaAplicacion":"2023-03-07","salesforceId":"a356w00000045pbAAA","documentos":null}';
        request.requestURI='/apexrest/insertEndoso'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_EndorsementWrapper.endorsementRequest endoso = (DSALES_EndorsementWrapper.endorsementRequest)JSON.deserialize(body, DSALES_EndorsementWrapper.endorsementRequest.class);
        Test.startTest();
        DSALES_EndosoWrapperRequestSC.createEndosoSc();
        Test.stopTest();
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200'); 

        
    }
   
     @isTest
    static void createEndosoExceptionTest() {
        String requestBody = 'invalid request body';
        RestRequest restRequest = new RestRequest();
        restRequest.requestURI = '/apexrest/insertEndoso';
        restRequest.httpMethod = 'POST';
        restRequest.requestBody = Blob.valueOf(requestBody);
        RestContext.request = restRequest;
        Test.startTest();
        DSALES_EndorsementWrapper.endorsementResponse response = DSALES_EndosoWrapperRequestSC.createEndosoSc();
        Test.stopTest();
        System.assert(!response.success, 'Hay algún problema');
        System.assertEquals(String.valueOf(DSALES_Utility.BAD_REQUEST_CODE), response.codigoError, 'Error de codigo');
        //System.assertEquals(DSALES_Utility.BAD_REQUEST_MSJ + ' 0 null null', response.mensajeError);
    }
    
    @isTest static void testUpdateEndoso() {
        DSALES_Endoso__c endoso = [SELECT Id,DSALES_Poliza__c,DSALES_uid__c,DSALES_Valor__c,DSALES_Tipodedato__c,DSALES_CorreoElectronico__c, DSALES_MontoaDevolver__c,DSALES_Estatus__c, 
                                   DSALES_MotivoRechazo__c,DSALES_MotivoDevolucion__c, DSALES_SolucionDevolucion__c FROM DSALES_Endoso__c WHERE DSALES_Estatus__c = 'Nuevo' LIMIT 1];
        
        InsurancePolicy poliza = [SELECT Id, DSALES_TelefonoContacto__c, DSALES_CorreoElectronico__c,DSALES_NombredelAsegurado__c, DSALES_Placas__c, DSALES_Numeroserie__c,
                                  dsalesNumeroDeMotor__c, ChangeSubtype FROM InsurancePolicy WHERE Id=:endoso.DSALES_Poliza__c];
        
        
        // Test update with 'Requerimiento de Información' status
        DSALES_EndorsementWrapper.endorsementRequest request2 = new DSALES_EndorsementWrapper.endorsementRequest();
        request2.uid = 'testUid';
        request2.estatus = 'requiere información';
        request2.solucion = 'Test Solucion Devolucion';
        DSALES_EndorsementWrapper.endorsementResponse response2 = DSALES_EndosoWrapperRequestHelper.updateEndosoSc(request2);
        
        // Test update with 'Rechazado' status
        DSALES_EndorsementWrapper.endorsementRequest request3 = new DSALES_EndorsementWrapper.endorsementRequest();
        request3.uid = 'testUid';
        request3.estatus = 'Rechazado';
        request3.estatusComentario = 'Test Motivo Rechazo';
        DSALES_EndorsementWrapper.endorsementResponse response3 = DSALES_EndosoWrapperRequestHelper.updateEndosoSc(request3);
        
        // Test update with 'Autorizado' status
        DSALES_EndorsementWrapper.endorsementRequest request4 = new DSALES_EndorsementWrapper.endorsementRequest();
        request4.uid = 'testUid';
        request4.estatus = 'Autorizado';
        DSALES_EndosoWrapperRequestHelper.updateEndosoSc(request4);
               
        DSALES_EndorsementWrapper.endorsementRequest endosos = new DSALES_EndorsementWrapper.endorsementRequest();
        endosos.uid = 'testUid';
        endosos.estatus = 'Autorizado';
        endosos.datos = new DSALES_EndorsementWrapper.dato();
        
        endosos.tipoEndoso = 'Actualización de correo electrónico';
        endosos.datos.valor= 'new@test.com';       
        DSALES_EndosoWrapperRequestHelper.updatePolicySc(endosos);
        
        endosos.tipoEndoso = 'Actualización de teléfono';
        endosos.datos.valor = '555-555-5555';
        DSALES_EndosoWrapperRequestHelper.updatePolicySc(endosos);
       
        endosos.tipoEndoso = 'Corrección de nombre';
        endosos.datos.valor = 'Jane Doe';
        DSALES_EndosoWrapperRequestHelper.updatePolicySc(endosos);
        
        
        endosos.tipoEndoso = 'Cancelación de póliza';
        DSALES_EndosoWrapperRequestHelper.updatePolicySc(endosos);
        poliza = [SELECT dsalesEstatusPoliza__c, ChangeSubtype FROM InsurancePolicy WHERE Id = :poliza.Id LIMIT 1];
        System.assertEquals('Cancelada', poliza.dsalesEstatusPoliza__c, 'Estatus de Póliza de Cancelada');
        System.assertEquals('Endosada', poliza.ChangeSubtype, 'ChangeSubtype de póliza de seguro es Endosada');
        
        
        
    }
    
    
    
    
}