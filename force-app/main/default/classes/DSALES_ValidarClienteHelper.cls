public class DSALES_ValidarClienteHelper {    
    public static void deleteUnpurchasedItem(List<DSALES_AssetWrapper.AssetRequest> listAssets, List<DSALES_CertificadoWrapper.CertificadoRequest> certificado, String quoteId) {
        Quote originalQuote = [SELECT Id, Name,OpportunityId, DSALES_EmailNew__c, Pricebook2Id, RecordTypeId, Status, DSALES_Enviarcotizacion__c, DSales_Tienda__c, DSales_Vendedor__c,
                               DSALES_Fechadecreacionpresupuesto__c, ExpirationDate, DSALES_esClon__c FROM Quote WHERE Id = :quoteId ]; 
        
        List<QuoteLineItem> unpurchasedItems= new List<QuoteLineItem>();        
        List<String> productSKUs = new List<String>();
        for(DSALES_AssetWrapper.AssetRequest a:listAssets){
            productSKUs.add(a.sku_de_tangible);
        }
        If(listAssets!= null){
            List<QuoteLineItem>quoteLineMap= [SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2Id,DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Producto'AND DSALES_SKU__c NOT IN:productSKUs ]; 
            unpurchasedItems.addAll(quoteLineMap);
            
        }
        If(listAssets== null){
            List<QuoteLineItem>quoteLineMap= [SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2Id, DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Producto']; 
            unpurchasedItems.addAll(quoteLineMap);
            
        }
        
        List<String> quoteLineItemId = new List<String>();
        List<String> lstSku = new List<String>();
        //List<id> lstwotId= new List<id>();
        List<String> lstwotId = new List<String>();
        
        for(DSALES_CertificadoWrapper.CertificadoRequest cer:certificado){
            quoteLineItemId.add(cer.id_partida_presupuesto);
            lstSku.add(cer.sku);
        }
        List<QuoteLineItem>warrantyMap= [SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2.StockKeepingUnit,Product2Id, DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Servicio'AND Id NOT IN:quoteLineItemId AND DSALES_SKU__c  IN:lstSku ];
       
            delete warrantyMap;
        
        List<QuoteLineItem>quoteLineMap=[SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2.StockKeepingUnit,Product2Id, DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Servicio'AND Id NOT IN:quoteLineItemId];
           unpurchasedItems.addAll(quoteLineMap);

        
        If(certificado== null){
            List<QuoteLineItem>quoteLine= [SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2Id, DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Servicio']; 
            unpurchasedItems.addAll(quoteLine);
            
        }
        If(unpurchasedItems.size()>0){
            Quote unpurchasedQuote = originalQuote.clone(false, true);
            //unpurchasedQuote.RecordTypeId=originalQuote.RecordTypeId;
            unpurchasedQuote.Name = originalQuote.Name;
            unpurchasedQuote.OpportunityId=originalQuote.OpportunityId;            
            unpurchasedQuote.DSALES_Enviarcotizacion__c = false;
            try{   
                insert unpurchasedQuote;
                List<QuoteLineItem> item= new List<QuoteLineItem>();
                for (QuoteLineItem items : unpurchasedItems) {              
                    QuoteLineItem newItem = new QuoteLineItem();
                    newItem.QuoteId = unpurchasedQuote.Id;
                    newItem.Quantity= items.Quantity;
                    newItem.PricebookEntryId= items.PricebookEntryId;
                    newItem.UnitPrice= items.UnitPrice;
                    newItem.Product2Id= items.Product2Id;
                    newItem.DSALES_ListaArticulo__c= items.DSALES_ListaArticulo__c;
                    newItem.Vigencia_meses__c= items.Vigencia_meses__c;
                    item.add(newItem);  
                } 
                
                insert item;
                DELETE unpurchasedItems;
                
                unpurchasedQuote.Status = 'Enviada';
                unpurchasedQuote.DSALES_Enviarcotizacion__c=true;
                unpurchasedQuote.DSALES_esClon__c=true;
                system.debug('Id del quote a borrar: '+unpurchasedQuote.Id);
                update unpurchasedQuote;
                //actualizarCotizacion(quoteId);
                //DELETE unpurchasedQuote;
            }  catch (DmlException e) {
                System.debug('Error occured: ' + e);
            }
             
        }  
        
       
    }
    
    //@future(callout=true)
    public static void actualizarCotizacion(String quoteId,DSALES_VentaGEX.VentaGexResponse ventaGEX){
        Quote cotizacion = [SELECT Id,AccountId,Name,OpportunityId,Opportunity.AccountId FROM Quote WHERE Id= :quoteId];
        List<QuoteLineItem> partida = [SELECT DSALES_NombreProductoServicio__c,DSALES_SKU__c FROM QuoteLineItem WHERE QuoteId=:quoteId]; 
 
        List<Opportunity> oppor= new List<Opportunity>();
        List<OpportunityLineItem> opLine = new List<OpportunityLineItem>();
        oppor = [SELECT Id, StageName,SyncedQuoteId FROM opportunity WHERE Id=:cotizacion.OpportunityId ];
        If(oppor.size()>0){
            System.debug(oppor);
            for(Opportunity opp:oppor){
                opp.StageName='Cerrada ganada';
                opp.SyncedQuoteId=cotizacion.Id;
            } 
            opLine=[SELECT Id,Name,Product2.StockKeepingUnit FROM OpportunityLineItem WHERE OpportunityId=:oppor[0].id];
            if(opLine.size()>0)
            {
               system.debug('Size del opLine '+opLine.size());
                List<DSALES_VentaGEX.OpporLineItem> listaDeOportunidades = new List<DSALES_VentaGEX.OpporLineItem>();
                for(OpportunityLineItem op:opLine)
                    {
                         DSALES_VentaGEX.OpporLineItem opportunityLine = new DSALES_VentaGEX.OpporLineItem();
                        opportunityLine.id_OpportunityLineItem=op.Id;
                       opportunityLine.sku=op.Product2.StockKeepingUnit;
                        for(QuoteLineItem p:partida)
                        {
                            if(p.DSALES_SKU__c==op.Product2.StockKeepingUnit)
                            {
                                opportunityLine.articulo=p.DSALES_NombreProductoServicio__c;
                            }
                            
                        }
                       
                        listaDeOportunidades.add(opportunityLine);
                       
                    }
                ventaGEX.opportunity_line_item=listaDeOportunidades;
            }
            try{
                Update oppor;
                
            }catch(DmlException e){
                System.debug('Error occured: ' + e);  
            }
        }
    }
    
       
    
    
}