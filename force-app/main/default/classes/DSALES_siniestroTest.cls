@isTest
public class DSALES_siniestroTest {

    @testSetup
    static void testSetup(){
        String accountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account acc = new Account();
        acc.firstName='albert';
        acc.lastName='procopio';
        acc.PersonEmail= 'asa@as.co';
        acc.Phone = '93617359';
        insert acc;
        
        InsurancePolicy poli = new InsurancePolicy();
        poli.NameInsuredId=acc.Id;
        poli.DSALES_CorreoElectronico__c='asa@as.co';
        poli.dsalesEstatusPoliza__c = 'Vigente';
        poli.Name = '2345';
        insert poli;
        
        Claim siniestro = new Claim();
        siniestro.Name='covertura';
        siniestro.PolicyNumberId = poli.Id;
        siniestro.P_liza__c = poli.Id;
        siniestro.DSALES_SiniestroUid__c = 'iszxxzxaxa';
        siniestro.DSALES_Estatus__c = 'Nuevo';
        siniestro.ClaimType ='Robo total';
        siniestro.ClaimReason='sdsvs';       
        insert siniestro;    
    }
    @isTest 
    static void siniestroRequest(){ 
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();
        String body = '{ "business":"serviciosPoliza", "company":"coppel", "uid":"", "reporte":"000002", "numeroSiniestro":"Asistencia", "tipoSiniestro":"Robo Total", "fechaSiniestro":"28/07/2022 16:40:23", "nombreConductor":"José Juan Resendiz Calavera ", "causa":"choque", "vehiculo":{ "descripcion":"MOTOCICLETA VENTO WORKMAN 125 CC", "anio":"2022", "placa":"123HDF", "serie":"1234DFGERS92871WD" }, "poliza":{ "numeroPoliza":"2345", "inciso":"0001", "fechaInicioVigencia":"23/03/2022", "fechaFinVigencia":"22/03/2023", "nombreAsegurado":"Graciela Guzmán Arreola" }, "comoOcurrio":"Se cayó y chocó", "comentarioDeEstatus":"Se cayó y chocó", "ubicacion":"Calle Orquideas 27", "municipio":"Tampico", "estado":"Tamaulipas", "estatus":"Pagado", "motivodeRechazo":"rechazado", "solucion":"cuenta bancaria", "salesforceid":"", "saldo":"5000", "saldoInsoluto":"4500", "remanente":"500", "tipoPago":"Remanente", "fechaDePago":"2023-05-05" }';
        req.requestURI = '/apexrest/siniestroUpsert';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response= resp;
        DSALES_SiniestroWrapper.SiniestroGet data = (DSALES_SiniestroWrapper.SiniestroGet)JSON.deserialize(body, DSALES_SiniestroWrapper.SiniestroGet.class);

        Test.startTest();
        DSALES_SiniestroWrapper.siniestroPostResponse response1 = DSALES_Siniestro.siniestroUpsert();
        Test.stopTest();
        System.assertNotEquals('Test', body, 'La llamada no debe ser igual');
    }
    @isTest
    static void createSiniestroExceptionTest() {
        String requestBody = 'invalid request body';
        RestRequest restRequest = new RestRequest();
        restRequest.requestURI = '/apexrest/siniestroUpsert';
        restRequest.httpMethod = 'POST';
        restRequest.requestBody = Blob.valueOf(requestBody);
        RestContext.request = restRequest;
        Test.startTest();
        DSALES_SiniestroWrapper.siniestroPostResponse response = DSALES_Siniestro.siniestroUpsert();
        Test.stopTest();
        System.assertEquals(false, response.success, 'Hay algún problema');
        System.assertEquals(DSALES_Utility.BAD_REQUEST_CODE, response.codigoError, 'Error de codigo');
        System.assertEquals(DSALES_Utility.BAD_REQUEST_MSJ, response.mensaje, 'Error de codigo');
    }
    
    @isTest
    static void testActualizaSiniestro() {
        DSALES_SiniestroWrapper.SiniestroGet testData = new DSALES_SiniestroWrapper.SiniestroGet();
        testData.uid = 'Test UID';
        testData.estatus = 'En revisión'; // Set the desired status for testing
        Claim testClaim = new Claim();
        testClaim.Name = 'test';
        testClaim.DSALES_SiniestroUid__c = testData.uid;
        insert testClaim;
        String result = DSALES_Siniestro.actualizaSiniestro(testData);
        Claim updatedClaim = [SELECT Id, DSALES_Estatus__c FROM Claim WHERE Id = :testClaim.Id];
        System.assertEquals('En trámite', updatedClaim.DSALES_Estatus__c, 'El estado de siniestro es En trámite');
        
        DSALES_SiniestroWrapper.SiniestroGet testData1 = new DSALES_SiniestroWrapper.SiniestroGet();
        testData1.uid = 'Test UID';
        testData1.estatus = 'Documentado'; // Set the desired status for testing
        Claim testClaim1 = new Claim();
        testClaim1.Name = 'test';
        testClaim1.DSALES_SiniestroUid__c = testData1.uid;
        insert testClaim1;
        String result1 = DSALES_Siniestro.actualizaSiniestro(testData1);
        
        DSALES_SiniestroWrapper.SiniestroGet testData2 = new DSALES_SiniestroWrapper.SiniestroGet();
        testData2.uid = 'Test UID';
        testData2.estatus = 'Pendiente de información'; // Set the desired status for testing
        Claim testClaim2 = new Claim();
        testClaim2.Name = 'test';
        testClaim2.DSALES_SiniestroUid__c = testData2.uid;
        insert testClaim2;
        String result2 = DSALES_Siniestro.actualizaSiniestro(testData2);
        Claim updatedClaim2 = [SELECT Id, DSALES_Estatus__c, DSALES_MotivodeDevolucion__c, dsalesSolucionaDevolucion__c FROM Claim WHERE Id = :testClaim2.Id];
        
        DSALES_SiniestroWrapper.SiniestroGet testData3 = new DSALES_SiniestroWrapper.SiniestroGet();
        testData3.uid = 'Test UID';
        testData3.estatus = 'Rechazado'; // Set the desired status for testing
        testData3.motivodeRechazo = 'Test Motivo de Rechazo';
        Claim testClaim3 = new Claim();
        testClaim3.Name = 'test';
        testClaim3.DSALES_SiniestroUid__c = testData3.uid;
        insert testClaim3;
        String result3 = DSALES_Siniestro.actualizaSiniestro(testData3);
        
        DSALES_SiniestroWrapper.SiniestroGet testData5 = new DSALES_SiniestroWrapper.SiniestroGet();
        testData5.uid = 'Test UID';
        testData5.estatus = 'Solicitud de saldo'; 
        testData5.saldoinsoluto = '1000'; 
        testData5.fechaDePago = Date.today();
        Claim testClaim5 = new Claim();
        testClaim5.Name = 'test';
        testClaim5.DSALES_SiniestroUid__c = testData5.uid;
        insert testClaim5;
        String result5 = DSALES_Siniestro.actualizaSiniestro(testData5);
        
        DSALES_SiniestroWrapper.SiniestroGet testData4 = new DSALES_SiniestroWrapper.SiniestroGet();
        testData4.uid = 'Test UID';
        testData4.estatus = 'Pagado'; // Set the desired status for testing
        testData4.saldo = '100.00';
        testData4.remanente = '50.00';
        testData4.saldoInsoluto ='1100';
        testData4.fechaDePago = Date.today();
        Claim testClaim4 = new Claim();
        testClaim4.Name = 'Pago de siniestro';
        testClaim4.DSALES_SiniestroUid__c = testData4.uid;
        insert testClaim4;
        String result4 = DSALES_Siniestro.actualizaSiniestro(testData4);
       
    }
        
}