/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 04-18-2023
 * @last modified by  : Juan Antonio Flores
 * Modifications Log 
 * Ver   Date          Author             Modification
 * 1.0   04-18-2023                       Initial Version
**/

@isTest
//global class DSALES_ReembolsoWrapperTest {
public class DSALES_ReembolsoWrapperTest {

    @testSetup
    //global static void setUp() {
    public static void setUp() {
        Opportunity opp = new Opportunity(Name='Danny',StageName='Closed',CloseDate=Date.today());
        insert opp;
        Account ac= new Account(Name='DannyTest',CP_WalletCustomerNumber__c=123456);  
        insert ac;
         DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c(DSALES_Oportunidad__c=opp.id,DSALES_Factura__c='1234',DSALES_Clave_Tienda__c='1234');
        insert pago;
        DSALES_Cancelacion__c cancelacion = new DSALES_Cancelacion__c(
            DSALES_Canal__c= '.EXE',
            DSALES_FechaCancelacion__c =Date.today(),
            DSALES_FolioCancelacion__c ='76543',
            DSALES_Estatus__c='Cancelado',
            DSALES_MotivoCancelacion__c='A petición del cliente',
            DSALES_NumeroVendedor__c='12',
            DSALES_NombreVendedor__c = 'Sayra Martinez',
            DSALES_Informaciondepago__c=pago.Id
        );
        insert cancelacion;
        
    }
    
    @isTest 
    //global static void createRecordTest() {
    public static void createRecordTest() {
        DSALES_Cancelacion__c cancelacion= [SELECT Id FROM DSALES_Cancelacion__c WHERE DSALES_Estatus__c='Cancelado' LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
        request.requestURI='/apexrest/insertReembolso';
        request.httpMethod='POST';
        RestContext.request=request;
        String body = '[{"numeroCancelacion":"'+cancelacion.Id+'","comentarios":"El cliente decidió cancelar el producto","fechaReembolso":"2023-02-24","nombreProducto":"Televisión","metodoPago":"Efectivo","numeroReferencia":"1123456621","cantidadReembolsada":15005}]';
        List<DSALES_ReembolsoWrapper.ReembolsoRequest>  listaReembolso = (List<DSALES_ReembolsoWrapper.ReembolsoRequest>)JSON.deserialize(body, List<DSALES_ReembolsoWrapper.ReembolsoRequest>.class);
        System.debug('lista reembolsos:'+listaReembolso);
        body=JSON.serialize(listaReembolso);
        request.requestBody=blob.valueOf(body);
        RestContext.response=response;
        //DSALES_ReembolsoWrapper.ReembolsoRequest reembolso =  (DSALES_ReembolsoWrapper.ReembolsoRequest)JSON.deserialize (body,DSALES_ReembolsoWrapper.ReembolsoRequest.class);
        Test.startTest();
        DSALES_ReembolsoWrapperRequest.createReembolso();
        System.assert(true,'correct');
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;    
    }

    @isTest 
    //global static void errorTest() {
    public static void errorTest() {
        DSALES_Cancelacion__c cancelacion= [SELECT Id FROM DSALES_Cancelacion__c WHERE DSALES_Estatus__c='Cancelado' LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
        request.requestURI='/apexrest/insertReembolso';
        request.httpMethod='POST';
        RestContext.request=request;
        String body = '[{"numeroCancelacion":"xxxxxxx","comentarios":"El cliente decidió cancelar el producto","fechaReembolso":"2023-02-24","nombreProducto":"Televisión","metodoPago":"Efectivo","numeroReferencia":"1123456621","cantidadReembolsada":15005}]';
        List<DSALES_ReembolsoWrapper.ReembolsoRequest>  listaReembolso = (List<DSALES_ReembolsoWrapper.ReembolsoRequest>)JSON.deserialize(body, List<DSALES_ReembolsoWrapper.ReembolsoRequest>.class);
        System.debug('lista reembolsos:'+listaReembolso);
        body=JSON.serialize(listaReembolso);
        request.requestBody=blob.valueOf(body);
        RestContext.response=response;
        //DSALES_ReembolsoWrapper.ReembolsoRequest reembolso =  (DSALES_ReembolsoWrapper.ReembolsoRequest)JSON.deserialize (body,DSALES_ReembolsoWrapper.ReembolsoRequest.class);
        Test.startTest();
        DSALES_ReembolsoWrapperRequest.createReembolso();
        System.assert(true,'correct');
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
    }  
}