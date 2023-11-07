/*********************************************************************************************************************************************************************
@ Class Name :DSALES_QuotePdfController  
@ Author : Namrata Katore
@ Purpose : controller class to create a vf page
@ Date : 10/5/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/

public with sharing class DSALES_QuotePdfController {
    public Quote quote {get; set;}
    public List<QuoteLineItem> quoteLineItems {get; set;}
    public Tienda__c tienda { get; set; }
    public DSALES_InformacionDePago__c pago {get; set;}
    public string quoteId {get;set;}
    
    public DSALES_QuotePdfController() {
        try{
            Id quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            List<Quote> quotes = [SELECT Id, Name, Opportunity.Name,OpportunityId, DSALES_EmailNew__c, DSales_Tienda__c,DSales_Vendedor__c,DSALES_Plazoacotizar__c,DSALES_Fechadecreacionpresupuesto__c,Opportunity.DSALES_InformacionDePago__r.DSALES_Fechadeentregaestimada__c,
                                  ExpirationDate,QuoteNumber,DSALES_fechadecreacion__c,Email,dsalesOpcionDePago__c, RecordType.Name FROM Quote WHERE Id = :quoteId WITH SECURITY_ENFORCED LIMIT 1];
            
            if (quotes.size() > 0) {
                quote = quotes[0];
                quoteLineItems = [SELECT Id,QuoteId,Product2.Name,DSALES_NombreProducto__c,Dsales_Plazo__c, Dsales_Plazo__r.Dsales_Plazo__c,PricebookEntryId,Product2Id,DSALES_SKU__c,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                  FROM QuoteLineItem WHERE QuoteId = :quoteId WITH SECURITY_ENFORCED LIMIT 10];
                tienda = [SELECT Id, Name, dsalesDireccion__c, dsalesCodigoPostal__c, dsalesCiudad__r.Name, DSALES_Estado__c FROM Tienda__c WHERE Id = :quote.DSales_Tienda__c  LIMIT 1];
                System.debug(quote.DSales_Tienda__c);
                pago =[SELECT Id,DSALES_Fechadeentregaestimada__c, DSALES_FolioTransaccion__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c=:quote.OpportunityId WITH SECURITY_ENFORCED LIMIT 1];
                
            }
        } catch(System.QueryException e){
            System.debug('error--------->'+e.getLineNumber() + e.getMessage());
        }
    }
    
    
}