@isTest 
public class DSALES_ServicioArmadoWrapperRequestTest {
    
    @testSetup
    static void setUp(){
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Servicios').getRecordTypeId();
        DSALES_Familia__c family = new DSALES_Familia__c();
        family.Name = 'test';
        insert family;
        
        DSALES_Categoria__c category = new DSALES_Categoria__c();
        category.Name = 'test';
        insert category;
        
        DSALES_Clase__c classs = new DSALES_Clase__c();
        classs.Name = 'test';
        insert classs;
        
        Product2 prodArmado = new Product2(Name ='testArmado', StockKeepingUnit='1111',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Producto',Description='test001');
        insert prodArmado;
        
        Product2 prodServArmado = new Product2(Name ='testServArmado', StockKeepingUnit='123455',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Servicio',DSales_Aplicaporcentajecobro__c=false,Description='test00222');
        insert prodServArmado;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = prodArmado.Id;
        standardPrice.UnitPrice = 1000;
        standardPrice.IsActive = true;
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry();
        customPrice.Pricebook2Id = customPB.Id;
        customPrice.Product2Id = prodArmado.Id;
        customPrice.UnitPrice = 1200;
        customPrice.IsActive = true;
        insert customPrice;
        
        Account acc = new Account();
        acc.Name='test';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.DSALES_ClienteCoppel__c='90001';
        insert acc;
        
        Asset proAdquirido = new Asset();
        proAdquirido.Name = 'testCertificado';
        proAdquirido.DSALES_TipoProducto__c = 'Producto';
        proAdquirido.AccountId = acc.id;
        proAdquirido.DSALES_ClaseBuscar__c = classs.Id;
        insert proAdquirido;
        
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        
        DSALES_Certificado__c certificado = new DSALES_Certificado__c();
        certificado.DSALES_Cliente__c = acc.Id;
        certificado.DSALES_Oportunidad__c = opp.Id;
        certificado.DSALES_ProductoAdquirido__c = proAdquirido.Id;
        insert certificado;
        
    }
    
    @isTest 
    static void updatestatusArmadoTest(){
        DSALES_Certificado__c nameCertifi = [SELECT Name FROM DSALES_Certificado__c LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{ "ars":[], "estatus":[ { "numeroCertificado":"'+nameCertifi.Name+'", "estatus":"Realizado", "fechaArmado":"2023-10-19 15:50:23" },{ "numeroCertificado":"GEX-000078944444", "estatus":"Realizado", "fechaArmado":"2023-10-19 15:50:23" } ] }';
        req.requestURI = '/apexrest/upsertServices/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        DSALES_ServicioArmadoWrapper.ArmadoRequest data = (DSALES_ServicioArmadoWrapper.ArmadoRequest)JSON.deserialize(body, DSALES_ServicioArmadoWrapper.ArmadoRequest.class);
        Test.startTest();
        DSALES_ServicioArmadoWrapperRequest.upsertServices();
        Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
    }
    
    @isTest 
    static void updateArTest(){
        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        String body2 = '{"ars":[{"ar":11,"skuTangible":"1111"},{"ar":113,"skuTangible":"1444"}],"estatus":[]}';
        req2.requestURI = '/apexrest/upsertServices/*';
        req2.httpMethod = 'POST';
        RestContext.request = req2;
        req2.requestBody = Blob.valueof(body2);
        RestContext.response = res2;
        DSALES_ServicioArmadoWrapper.ArmadoRequest data2 = (DSALES_ServicioArmadoWrapper.ArmadoRequest)JSON.deserialize(body2, DSALES_ServicioArmadoWrapper.ArmadoRequest.class);
        Test.startTest();
        DSALES_ServicioArmadoWrapperRequest.upsertServices();
        Test.stopTest();
        RestContext.request = req2;
        RestContext.response= res2;
        System.assertNotEquals(200, res2.statusCode, 'La llamada no debe devolver un código 200');
    }
}