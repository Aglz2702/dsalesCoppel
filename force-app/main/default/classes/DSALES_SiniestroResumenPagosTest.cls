@isTest
global with sharing class DSALES_SiniestroResumenPagosTest {

    @TestSetup
    static void SetUp(){
         

        Claim siniestro = new Claim(Name='SNT',ClaimType='Perdida Total',ClaimReason='Choque unilateral');
        insert siniestro;
        ClaimPaymentSummary testClaim = new ClaimPaymentSummary();
        testClaim.ClaimId = siniestro.Id;
        testClaim.PaymentAmount = 123445;
        testClaim.Name = 'Test';
        testClaim.DSALES_Tipopago__c= 'Test Pago';
        testClaim.PaymentDate = Date.today();
        
        ClaimPaymentSummary testClaimP = new ClaimPaymentSummary();
        testClaimP.ClaimId = siniestro.Id;
        testClaimP.PaymentAmount = 45500;
        testClaimP.Name = 'Test name';
        testClaimP.DSALES_Tipopago__c= 'Test Pago1';
        testClaimP.PaymentDate = Date.today();
		//Test.enableChangeDataCapture();       
       /* ClaimPaymentSummary resumenPago = new ClaimPaymentSummary(Name='Prueba del Test', ClaimId=siniestro.id, PaymentAmount=45678);
        insert resumenPago;*/
        
    }
    @isTest static void CreateRecordTest()
    {
        
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        Claim siniestro = [SELECT Id FROM  Claim  LIMIT 1];
        String body='{"infoResumenPago":"'+siniestro.Id+'","codigoPostal":"45900","nombrePagoSiniestro":"Prueba funcional","tipoPago":"Pago a cliente","fechaPago": "2022-10-11"}';
        request.requestURI='/apexrest/insertClaimPaymentSummary'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_SiniestroRPWrapper.SiniestroRPRequest SiniestroRP = (DSALES_SiniestroRPWrapper.SiniestroRPRequest)JSON.deserialize(body, DSALES_SiniestroRPWrapper.SiniestroRPRequest.class);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        DSALES_SiniestroResumenPagos.createSiniestroRP();
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        
    }
    @isTest static void CreateRecordTestWrong()
    {
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        Claim siniestro = [SELECT Id FROM  Claim  LIMIT 1];
        String body='invalid request body';
        request.requestURI='/apexrest/insertClaimPaymentSummary/'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        Test.startTest();
        DSALES_SiniestroRPWrapper.SiniestroRPResponse resp = DSALES_SiniestroResumenPagos.createSiniestroRP();
        Test.stopTest();
        System.assertEquals(false, resp.exitoso, 'Hay algún problema');
        System.assertEquals(DSALES_Utility.BAD_REQUEST_CODE, resp.codigoError, 'Error de codigo');
        System.assertEquals(DSALES_Utility.BAD_REQUEST_MSJ, resp.mensajeError, 'Error de codigo');
    }
    @isTest static void recordTest(){
        DSALES_SiniestroRPWrapper.ListaSiniestros listSin= new DSALES_SiniestroRPWrapper.ListaSiniestros();
        listSin.cantidadPago = 2233667;
        listSin.nombrePagoSiniestro ='test';
        listSin.tipoPago = 'credito';
        listSin.fechaPago = date.newInstance(1991, 2, 15);
    }
    
    
}