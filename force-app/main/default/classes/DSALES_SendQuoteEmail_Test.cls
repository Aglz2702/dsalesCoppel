@isTest
public class DSALES_SendQuoteEmail_Test {
    @isTest
    static void testScheduledJob(){
        Id sc = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Venta de Seguro de Celulares').getRecordTypeId();
        Opportunity op = new Opportunity(Name='oppTest',StageName='Nuevo',CloseDate=Date.today());
        insert op;
        Quote testQuote = new Quote();
        testQuote.Name = 'Test';
        testQuote.OpportunityId = op.Id;
        testQuote.DSALES_Enviarcotizacion__c= true;
        testQuote.Email = 'nakatore@deloittemx.com';
        testQuote.DSALES_Contado__c = true;
        testQuote.DSALES_EmailNew__c ='nakatore@deloittemx.com';
        testQuote.DSALES_Fechadecreacionpresupuesto__c= Date.TODAY().addDays(-4);
        testQuote.dsalesFechaEnvioCotizacion__c = null;
        testQuote.RecordTypeId = sc;
        insert testQuote;
        
        Test.startTest();
        DSALES_SendQuoteEmail sendEmail = new DSALES_SendQuoteEmail();
        System.schedule('Test SendQuoteEmail','0 0 0 1 1 ?', sendEmail);
        Test.stopTest();
        Quote updatedQuote = [SELECT dsalesFechaEnvioCotizacion__c FROM Quote WHERE Id =:testQuote.Id];
        System.AssertNotEquals(null,updatedQuote.dsalesFechaEnvioCotizacion__c, Date.TODAY());
    }

}