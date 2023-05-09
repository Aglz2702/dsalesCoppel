@istest
public class DSALES_ControladorCertificadoPDFTest {
    public DSALES_Certificado__c certi = new DSALES_Certificado__c();
    @testSetup
    static void testSetup(){
        Tienda__c tie= new Tienda__c(Name='Danny',dsalesTiendaID__c='21');
        insert tie;
        Account ac= new Account(Name='DannyTest');  
        insert ac;
        Asset asset= new Asset(Name='DannyTest-b',AccountId=ac.Id);
        insert asset;
        DSALES_Certificado__c certi = new DSALES_Certificado__c(DSALES_ProductoAdquirido__c=asset.id,DSALES_Duracion_de_GEX__c = 12,DSALES_Tienda__c='21');
        insert certi;
        DSALES_Generador__C genera= new DSALES_Generador__c(Name='Certificado PDF',DSALES_Plantilla__c='Name,DSALES_Duracion_de_GEX__c');
        insert genera;
    }
    @isTest 
    static void dsalesControladorCertificadoPDF()
    {
        DSALES_Certificado__c certificado= [SELECT id FROM DSALES_Certificado__c];
        PageReference pageRef = Page.DSALES_CertificadoPDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('certificadoId',certificado.Id);
        String certificadoId = pageRef.getParameters().get('certificadoId');
        DSALES_ControladorCertificadoPDF d = new DSALES_ControladorCertificadoPDF();
        System.assertEquals(certificado.Id, certificadoId, 'Iguales');
        
        
    }
    
}