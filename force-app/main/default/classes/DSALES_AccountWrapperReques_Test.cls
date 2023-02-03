@isTest 
public class DSALES_AccountWrapperReques_Test{
    
    @testSetup
    static void SetUp(){
        Account acc = new Account();
        acc.Name='test';
        acc.CP_WalletCustomerNumber__c=87654;
        acc.DSALES_ClienteCoppel__c='90001';
        insert acc;
        
        Account accContado = new Account();
        accContado.FirstName = 'Emmanuel';
        accContado.LastName = 'Gonzalez';
        accContado.PersonEmail = 'egl@deloittemx.com';
        accContado.PersonBirthdate = date.today();
        accContado.Suffix = 'Lopez';
        insert accContado;
    }
    
    @isTest 
    static void CreateRecordTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"numero_de_cliente":"87654","nombre":"Test","apellido_paterno":"Test","apellido_materno":"Prueba","telefono":"89017829","correo_electronico":"dsanmiguel@deloittemx.com","genero":"M","fecha_nacimiento":"1992-08-02","codigo_postal":"06030"}';
        req.requestURI = '/apexrest/insertAccount';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        DSALES_AccountWrapper.AccountRequest cliente = (DSALES_AccountWrapper.AccountRequest)JSON.deserialize(body, DSALES_AccountWrapper.AccountRequest.class);
        Test.startTest();
        DSALES_AccountWrapperRequest.createAccount();
        Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
    }
     @isTest 
    static void CreateRecordTest2(){
        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        String body2 = '{"numero_de_cliente":"","nombre":"Test","apellido_paterno":"Test","apellido_materno":"Prueba","telefono":"89017829","correo_electronico":"dsanmiguel@deloittemx.com","genero":"M","fecha_nacimiento":"1992-08-02","codigo_postal":"06030"}';
        req2.requestURI = '/apexrest/insertAccount';
        req2.httpMethod = 'POST';
        RestContext.request = req2;
        req2.requestBody = Blob.valueof(body2);
        RestContext.response = res2;
        DSALES_AccountWrapper.AccountRequest cliente2 = (DSALES_AccountWrapper.AccountRequest)JSON.deserialize(body2, DSALES_AccountWrapper.AccountRequest.class);
        Test.startTest();
        DSALES_AccountWrapperRequest.createAccount();
        Test.stopTest();
        RestContext.request = req2;
        RestContext.response= res2;
    }
     @isTest 
    static void CreateRecordTest3(){
        RestRequest req3 = new RestRequest();
        RestResponse res3 = new RestResponse();
        String body3 = '{"numero_de_cliente":"","nombre":"Emmanuel","apellido_paterno":"Gonzalez","apellido_materno":"Lopez","telefono":"89017829","correo_electronico":"egl@deloittemx.com","genero":"M","fecha_nacimiento":"1992-08-02","codigo_postal":"06030"}';
        req3.requestURI = '/apexrest/insertAccount';
        req3.httpMethod = 'POST';
        RestContext.request = req3;
        req3.requestBody = Blob.valueof(body3);
        RestContext.response = res3;
        DSALES_AccountWrapper.AccountRequest cliente3 = (DSALES_AccountWrapper.AccountRequest)JSON.deserialize(body3, DSALES_AccountWrapper.AccountRequest.class);
        Test.startTest();
        DSALES_AccountWrapperRequest.createAccount();
        Test.stopTest();
        RestContext.request = req3;
        RestContext.response= res3;
    }
}