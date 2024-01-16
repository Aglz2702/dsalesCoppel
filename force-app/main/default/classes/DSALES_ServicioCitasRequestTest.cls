@isTest
public with sharing class DSALES_ServicioCitasRequestTest {
    @TestSetup
    static void setUp(){
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Servicios').getRecordTypeId();
        dsalesProveedores__c proveedor=new dsalesProveedores__c();
        proveedor.name='MABE';
        insert proveedor;

        dsalesRegion__c region= new dsalesRegion__c();
        region.name='TCMC';
        insert region;

        dsalesCiudad__c ciudad= new dsalesCiudad__c();
        ciudad.name='Ecatepec';
        ciudad.dsalesRegion__c=region.id;
        insert ciudad;

        dsalesCP__c cp= new dsalesCP__c();
        cp.name='63733';
        cp.dsalesCiudad__c=ciudad.id;
        insert cp;

        DSALES_Clase__c classs = new DSALES_Clase__c();
        classs.Name = 'test';
        insert classs;

        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;

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
        certificado.name='testCerti';
        certificado.DSALES_Cliente__c = acc.Id;
        certificado.DSALES_Oportunidad__c = opp.Id;
        certificado.DSALES_ProductoAdquirido__c = proAdquirido.Id;
        insert certificado;



        Event evento=new Event();
        evento.dsalesCertificado__c=certificado.id;
        evento.StartDateTime=Date.Today();
        evento.EndDateTime= Date.Today();
        evento.dSalesProveedores__c=proveedor.id;
        evento.dSalesNoCita__c='077';
        evento.dSalesRealizado__c=false;
        evento.dSalesCodigoPostal__c=cp.id;
        insert evento;
        
    }

    @isTest 
    static void crearCitaTest(){
        DSALES_Certificado__c nameCertifi = [SELECT Name FROM DSALES_Certificado__c LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"certificado": "'+nameCertifi.Name+'", "inicio": "2025-01-09 12:05:00", "fin": "2025-01-09 12:05:00", "proveedor": "MABE", "tecnico": "TecY", "asunto": "Reu", "noCita": "0083", "validacion": false, "sku": "777777", "articulo": "ArtX", "marca": "M1", "modelo": "ModA", "cuestionario": "Cue1", "codigoP": "63733", "codigoPCliente": "56732", "direccion": "DireccionX", "estatus": "Programada" }';
        req.requestURI = '/apexrest/upsertServices/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        DSALES_ServicioCitasWrapper.CitasRequest data = ( DSALES_ServicioCitasWrapper.CitasRequest)JSON.deserialize(body,  DSALES_ServicioCitasWrapper.CitasRequest.class);
        Test.startTest();
        DSALES_ServicioCitasRequest.upsertCitasResponse();
        Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
    }
    
    @isTest 
    static void actualizarCitaTest(){
        DSALES_Certificado__c nameCertifi = [SELECT Name FROM DSALES_Certificado__c LIMIT 1];
        dsalesProveedores__c proveedor = [SELECT Name FROM dsalesProveedores__c LIMIT 1];
        dsalesCP__c cp = [SELECT Name FROM dsalesCP__c LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"certificado": "'+nameCertifi.Name+'", "inicio": "2025-01-09 12:05:00", "fin": "2025-01-09 12:05:00", "proveedor": "MABE", "tecnico": "TecY", "asunto": "Reu", "noCita": "077", "validacion": false, "sku": "777777", "articulo": "ArtX", "marca": "M1", "modelo": "ModA", "cuestionario": "Cue1", "codigoP": "63733", "codigoPCliente": "56732", "direccion": "DireccionX", "estatus": "Programada" }';
        req.requestURI = '/apexrest/upsertServices/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        DSALES_ServicioCitasWrapper.CitasRequest data = ( DSALES_ServicioCitasWrapper.CitasRequest)JSON.deserialize(body,  DSALES_ServicioCitasWrapper.CitasRequest.class);
        Test.startTest();
        DSALES_ServicioCitasRequest.upsertCitasResponse();
        Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
        System.assertNotEquals(200, res.statusCode, 'La llamada no debe devolver un código 200');
    }
  
}