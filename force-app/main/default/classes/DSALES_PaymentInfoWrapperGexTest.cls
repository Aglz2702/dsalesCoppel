/**
 * @description       : Test class for PaymentInfoWrapperGex
 * @author            : 
 * @group             : 
 * @last modified on  : 04-18-2023
 * @last modified by  : Juan Antonio Flores
 * Modifications Log 
 * Ver   Date          Author             Modification
 * 1.0   04-18-2023                       Initial Version
**/

@isTest
public class DSALES_PaymentInfoWrapperGexTest {
    @testSetup
    static void setUp(){  
        Account acc = new Account();
        acc.Name='testL';
        insert acc;   
        String recordTypeId = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByName().get('Pagos de Venta en NPV de SM').getRecordTypeId();   
        Opportunity opp = new Opportunity();
        opp.Name = 'testL';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Nuevo';
        insert opp;
    }
    
    @isTest 
    //static void createPaymentRecordTest(){
    static void crearRegistroPagoTest(){      
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"opportunity_name": "testL","payment_method": "Efectivo","bill": "factura 01","customer_adress": "av independencia 12345","sku": "661235","total": "35000","article_description": "Motocicleta honda 200","telephone": "444 789 1999","salesman_name": "Antonio Pedro","cashier_box": "1"}';
        req.requestURI = '/apexrest/insertPaymentInformationGEX';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;  
        DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest pago = (DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest)JSON.deserialize(body, DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest.class);
        Test.startTest();
            DSALES_PaymentInfoWrapperGexRequest.createPayment();
            System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
		Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
    }
}