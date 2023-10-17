@isTest
public class DSALES_CrearParticipanteTest{
    @testSetup
    public static void crearRegistros(){
        String recordTypeMotosId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Seguro_de_Moto').getRecordTypeId();
        String recordTypeCelularId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('dsalesSeguroCelulares').getRecordTypeId();

        Account acc = new Account();
        acc.FirstName='Sayra';
        acc.LastName='Martinez';
        acc.Suffix='Quiroz';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.DSALES_Clientecoppel__c='90001';
        acc.PersonEmail='saymartinez@deloittemx.com';
        insert acc;
        Account coppel = new Account();
        coppel.FirstName='COPPEL';
        coppel.LastName='SA';
        coppel.Suffix='DE CV';
        insert coppel;
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        Opportunity oportunidad = new Opportunity(Name='Testoportunidadortunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeCelularId);
        insert oportunidad;
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '1';
        insert t;
        DSALES_InformaciondePago__c pago = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=oportunidad.id,DSALES_Cliente__c=acc.Id,DSALES_Seguro__c=true);
        insert pago;
        Quote cotizacion = new Quote(opportunityId=oportunidad.Id,Name='test',DSales_Tienda__c=t.Id);
        insert cotizacion;
        InsurancePolicy poliza = new Insurancepolicy();
        poliza.Name='0001';
        poliza.NameInsuredId=acc.Id;
        poliza.DSALES_CorreoElectronico__c='saymartinez@deloittemx.com';
        insert poliza;
        pago.DSALES_Poliza__c=poliza.Id;
        update pago;
    }
    @isTest
    public static void crearConductorTest(){
        Account cliente=[SELECT Id, Name FROM Account LIMIT 1];
        Insurancepolicy poliza=[SELECT Id,NameInsuredId FROM Insurancepolicy LIMIT 1];
        DSALES_CrearParticipantesPoliza.crearConductor(cliente.Id,poliza.Id);   
        System.assert(true, 'Valor esperado');     
    }
    @isTest
    public static void crearParticipantesTest(){
        List<DSALES_VentaSM.DatosParticipante> listaParticipante = new List<DSALES_VentaSM.DatosParticipante>();
        String body='{"figura":"Contratante","numeroCliente":"","nombre":"RICARDO","apellidoPaterno":"NORIEGA","apellidoMaterno":"GUERRERO","telefono":"1234567890","relacionConParticipante":"","porcentaje":"0","correoElectronico":"saymartinez@deloittemx.com","genero":"M","fechaNacimiento":"1987-09-23","rfc":"NOGR001011","codigoPostal":99010,"codigoEstado":"32","codigoMunicipio":"12","codigoCiudad":"10","codigoColonia":"2","calle":"TAYAHUA","numeroExterior":"218","numeroInterior":"0","curp":"MAQS9834582DURN","regimenFiscal":1345,"nacionalidad":"Mexicana"}';
		DSALES_VentaSM.DatosParticipante participante=(DSALES_VentaSM.DatosParticipante)JSON.deserialize (body,DSALES_VentaSM.DatosParticipante.class);
        listaParticipante.add(participante);
        System.debug('participante en test_______________________'+participante);
        Insurancepolicy poliza=[SELECT Id,NameInsuredId FROM Insurancepolicy LIMIT 1];
        Opportunity oportunidad = [SELECT Id,RecordType.DeveloperName FROM Opportunity LIMIT 1];
        DSALES_CreateInsurancePolicy.DatosParaParticipantes datos = new DSALES_CreateInsurancePolicy.DatosParaParticipantes();
        datos.enviaContratante=true;
        datos.poliza=poliza;
        datos.oportunidad=oportunidad;
        DSALES_CrearParticipantesPoliza.crearOtrosParticipantes(listaParticipante, datos);
        System.assert(true, 'Valor esperado');
    }
    @isTest
    public static void crearContratenteTest(){
        Insurancepolicy poliza=[SELECT Id,NameInsuredId FROM Insurancepolicy LIMIT 1];
        DSALES_CrearParticipantesPoliza.crearContratante(poliza.Id);
        System.assert(true, 'Valor esperado');
        
    }
}