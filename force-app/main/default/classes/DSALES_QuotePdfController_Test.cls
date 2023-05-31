@isTest
public class DSALES_QuotePdfController_Test {
    
    @testSetup 
    static void setUp(){
        // Create test data
        Opportunity opp = new Opportunity(Name='Test Opportunity',StageName='Nuevo',CloseDate=Date.today());
        insert opp;
        
        Product2 prod = new Product2(Name='Test Product', DSales_Tipo_de_Producto__c='Producto');
        insert prod;
        
        String pb2Id=Test.getStandardPricebookId();
        PricebookEntry pb = New PricebookEntry();
        pb.Product2Id = prod.Id;
        pb.PriceBook2Id =pb2Id;
        pb.UseStandardPrice = false;
        pb.UnitPrice=200;
        pb.isActive=true;
        insert pb;
        
        Tienda__c tienda = new Tienda__c( Name= 'Urgarte',dsalesDireccion__c='Test Address', dsalesCodigoPostal__c='12345', DSALES_Ciudad__c='Test City');
        insert tienda;
        
        
        Quote quote = new Quote(Name='Test Quote', OpportunityId=opp.Id,PriceBook2Id=pb2Id,DSales_Tienda__c=tienda.Id );
        insert quote;
        
        
        QuoteLineItem lineItem = new QuoteLineItem(QuoteId=quote.Id, Product2Id=prod.Id, Quantity=1, UnitPrice=10.0, PricebookEntryId=pb.Id);
        insert lineItem;
        
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c(DSALES_Oportunidad__c=opp.Id, DSALES_Fechadeentregaestimada__c=Date.today());
        insert pago;
        DSALES_InformacionDePago__c pago1 = new DSALES_InformacionDePago__c(DSALES_Oportunidad__c=opp.Id, DSALES_Fechadeentregaestimada__c=Date.today());
        insert pago1;
    }
    @isTest
    static void createRecordTest(){
        Quote quotes = [SELECT Id, Name, Opportunity.Name,OpportunityId, DSales_Tienda__c,DSales_Tienda__r.Name FROM Quote WHERE Name='Test Quote' WITH SECURITY_ENFORCED LIMIT 1];
        QuoteLineItem quoteLineItems = [SELECT Id,QuoteId,Product2.Name,DSALES_NombreProducto__c,Dsales_Plazo__c, Dsales_Plazo__r.Dsales_Plazo__c,PricebookEntryId,Product2Id,DSALES_SKU__c,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                        FROM QuoteLineItem  WITH SECURITY_ENFORCED LIMIT 1];
        id oppId =quotes.OpportunityId;
        Tienda__c tienda = [SELECT Id,Name, dsalesDireccion__c, dsalesCodigoPostal__c, DSALES_Ciudad__c, DSALES_Estado__c FROM Tienda__c WHERE Id=:quotes.DSales_Tienda__c AND Name='Urgarte' WITH SECURITY_ENFORCED LIMIT 1];
        List<DSALES_InformacionDePago__c> paym =[SELECT Id,DSALES_Fechadeentregaestimada__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c=:oppId  WITH SECURITY_ENFORCED LIMIT 1];
        
        
        Test.startTest();
        PageReference pageRef = Page.DSALES_CotizationSm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', quotes.Id);
        DSALES_QuotePdfController controller = new DSALES_QuotePdfController();
        Test.stopTest();
        System.assertEquals(quoteLineItems.QuoteId, quotes.Id, 'La llamada debe devolver un código 200');
        
        
        
        
    }
}