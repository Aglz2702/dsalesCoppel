public without sharing class  DSALES_ValidarClienteHelper {
   
    public static void deleteUnpurchasedItem(List<DSALES_AssetWrapper.AssetRequest> listAssets, List<DSALES_CertificadoWrapper.CertificadoRequest> certificado, String quoteId) {
        Quote originalQuote = [SELECT Id, Name,OpportunityId, DSALES_EmailNew__c, Pricebook2Id, RecordTypeId, Status, DSALES_Enviarcotizacion__c, DSales_Tienda__c, DSales_Vendedor__c,
                               DSALES_Fechadecreacionpresupuesto__c, ExpirationDate, DSALES_esClon__c FROM Quote WHERE Id = :quoteId WITH SECURITY_ENFORCED]; 
        
        List<QuoteLineItem> unpurchasedItems= new List<QuoteLineItem>();        
        List<String> productSKUs = new List<String>();
        for(DSALES_AssetWrapper.AssetRequest a:listAssets){
            productSKUs.add(a.skuDeTangible);
        }
        If(listAssets!= null){
            List<QuoteLineItem>quoteLineMap= [SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2Id,DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Producto'AND DSALES_SKU__c NOT IN:productSKUs WITH SECURITY_ENFORCED]; 
            unpurchasedItems.addAll(quoteLineMap);
            
        }
        If(listAssets== null){
            List<QuoteLineItem>quoteLineMap= [SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2Id, DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Producto' WITH SECURITY_ENFORCED]; 
            unpurchasedItems.addAll(quoteLineMap);
            
        }
        
        List<String> quoteLineItemId = new List<String>();
        List<String> lstSku = new List<String>();
        //List<id> lstwotId= new List<id>();
        List<String> lstwotId = new List<String>();
        
        for(DSALES_CertificadoWrapper.CertificadoRequest cer:certificado){
            quoteLineItemId.add(cer.idPartidaPresupuesto);
            lstSku.add(cer.sku);
        }
        List<QuoteLineItem>warrantyMap= [SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2.StockKeepingUnit,Product2Id, DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Servicio'AND Id NOT IN:quoteLineItemId AND DSALES_SKU__c  IN:lstSku WITH SECURITY_ENFORCED ];
        
        if(Schema.sObjectType.QuoteLineItem.isDeletable()) {

            delete warrantyMap;
            }else{
            
            System.debug('Permisos insuficientes para eliminar');
            }
            
        
        List<QuoteLineItem>quoteLineMap=[SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2.StockKeepingUnit,Product2Id, DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Servicio'AND Id NOT IN:quoteLineItemId WITH SECURITY_ENFORCED];
           unpurchasedItems.addAll(quoteLineMap);

        
        If(certificado== null){
            List<QuoteLineItem>quoteLine= [SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2Id, DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Servicio' WITH SECURITY_ENFORCED]; 
            unpurchasedItems.addAll(quoteLine);
            
        }
        If(unpurchasedItems.size()>0){
            Quote unpurchasedQuote = originalQuote.clone(false, true);
            //unpurchasedQuote.RecordTypeId=originalQuote.RecordTypeId;
            unpurchasedQuote.Name = originalQuote.Name;
            unpurchasedQuote.OpportunityId=originalQuote.OpportunityId;            
            unpurchasedQuote.DSALES_Enviarcotizacion__c = false;
            try{   
                if(Schema.sObjectType.Quote.isCreateable()) {

                    insert unpurchasedQuote;
                    }else{
                    
                    System.debug('Permisos insuficientes para crear');
                    }
                
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

                if(Schema.sObjectType.QuoteLineItem.isCreateable()) {
                    insert item;
                    }else{
                    System.debug('Permisos insuficientes para crear');
                }
                DELETE unpurchasedItems;
                
                unpurchasedQuote.Status = 'Enviada';
                unpurchasedQuote.DSALES_Enviarcotizacion__c=true;
                unpurchasedQuote.DSALES_esClon__c=true;
                system.debug('Id del quote a borrar: '+unpurchasedQuote.Id);

                if(Schema.sObjectType.Quote.isUpdateable()) {
                    update unpurchasedQuote;
                    }else{
                    System.debug('Permisos insuficientes para Actualizar datos');
                    }
                //actualizarCotizacion(quoteId);
                //DELETE unpurchasedQuote;
            }  catch (DmlException e) {
                System.debug('Error occured: ' + e);
            }
             
        }  
        
       
    }
    
    //@future(callout=true)
    public static void actualizarCotizacion(String quoteId,DSALES_VentaGEX.VentaGexResponse ventaGEX,Map<String,String> mapAssets,Map<String,String>mapCertifieds){
    
        Quote cotizacion = [SELECT Id,AccountId,Name,OpportunityId,Opportunity.AccountId FROM Quote WHERE Id= :quoteId WITH SECURITY_ENFORCED];
        List<QuoteLineItem> partida = [SELECT DSALES_NombreProductoServicio__c,DSALES_SKU__c FROM QuoteLineItem WHERE QuoteId=:quoteId];
        //Map<String,DSALES_Certificado__c> listaCertificados =[SELECT Id,Name FROM DSALES_Certificado__c WHERE DSALES_SKU__c IN:mapCertifieds.keySet() ];
        Map<String,DSALES_Certificado__c> mapaNombreCertificado = new Map<String,DSALES_Certificado__c>([SELECT Id,Name,DSALES_SKUTangible__c,DSALES_SKU__c FROM DSALES_Certificado__c WHERE Id IN:mapCertifieds.values()]);
       Map<String,DSALES_VentaGEX.ServicioCorrespondiente> oportunidadLineMap= new Map<String,DSALES_VentaGEX.ServicioCorrespondiente>();
        List<OpportunityLineItem> listActualizarOp = new List<OpportunityLineItem>();
       
 
        List<Opportunity> oppor= new List<Opportunity>();
        List<OpportunityLineItem> opLine = new List<OpportunityLineItem>();
        oppor = [SELECT Id, StageName,SyncedQuoteId FROM opportunity WHERE Id=:cotizacion.OpportunityId WITH SECURITY_ENFORCED];
        If(oppor.size()>0){
            System.debug(oppor);
            for(Opportunity opp:oppor){
                opp.StageName='Cerrada ganada';
                opp.SyncedQuoteId=cotizacion.Id;
            } 
            opLine=[SELECT Id,Name,Product2.StockKeepingUnit,Product2.Name,DSALES_FolioCertificado__c FROM OpportunityLineItem WHERE OpportunityId=:oppor[0].id WITH SECURITY_ENFORCED];
            if(opLine.size()>0)
            {
               system.debug('Size del opLine '+opLine.size());
                List<DSALES_VentaGEX.OpporLineItem> listaDeOportunidades = new List<DSALES_VentaGEX.OpporLineItem>();
                for(OpportunityLineItem op:opLine)
                    {
                       if(mapAssets.containsKey(op.Product2.StockKeepingUnit))
                       {
                           system.debug('Cúantas veces pasó??? ');
                           DSALES_VentaGEX.ServicioCorrespondiente servicioGex= new DSALES_VentaGEX.ServicioCorrespondiente();
                            DSALES_VentaGEX.OpporLineItem opportunityLine = new DSALES_VentaGEX.OpporLineItem();
                           servicioGex.idPartidaDeOportunidad=op.Id;
                           OportunidadLineMap.put(op.Product2.StockKeepingUnit,servicioGex);
                         opportunityLine.idPartidaDeOportunidad=op.Id;
                         opportunityLine.nombreProducto=op.Product2.Name;
                       	opportunityLine.sku=op.Product2.StockKeepingUnit;
                       	opportunityLine.tipoProducto='Producto';
                        opportunityLine.idProductoAdquirido=mapAssets.get(op.Product2.StockKeepingUnit); 
                         
                           for(String b :mapaNombreCertificado.keySet())
                        {
                        
                            if(mapaNombreCertificado.get(b).DSALES_SKUTangible__c==op.Product2.StockKeepingUnit )
                            {
                                List<DSALES_VentaGEX.ServicioCorrespondiente> servicioCoList = new List <DSALES_VentaGEX.ServicioCorrespondiente>();
                                system.debug('Debugeando B : '+b);
                                  DSALES_VentaGex.ServicioCorrespondiente servicioCo = new  DSALES_VentaGex.ServicioCorrespondiente();
                                system.debug('Cúantas veces pasó??? hijo ');
                                 
                             
                                servicioCo.folioCertificado=mapaNombreCertificado.get(b).Name;
                                servicioCo.idPartidaDeOportunidad=op.Id;
                                servicioGex.idPartidaDeOportunidad=op.id;
                                servicioGex.folioCertificado=servicioCo.folioCertificado;
                                servicioCo.sku=mapaNombreCertificado.get(b).DSALES_SKU__c;
                                OportunidadLineMap.put(servicioCo.sku,servicioGex);
                                servicioCo.tipoProducto='Servicio';
                               
                                 if(OportunidadLineMap.containsKey(servicioCo.sku))
                                {
                                    servicioCo.idPartidaDeOportunidad=OportunidadLineMap.get(servicioCo.sku).idPartidaDeOportunidad;
                                   
                                }
                                    for(QuoteLineItem p:partida)
                        {
                            if(p.DSALES_SKU__c==servicioCo.sku)
                            {
                                servicioCo.nombreProducto=p.DSALES_NombreProductoServicio__c;
                                
                                
                            }
                            
                        }
                                 
                                 servicioCoList.add(servicioCo);
                                opportunityLine.entregaServicioCorrespondiente=servicioCoList;
                            }

                           
                        }
                            listaDeOportunidades.add(opportunityLine);
                       }
                        else
                        {
                            DSALES_VentaGEX.ServicioCorrespondiente servicioGex= new DSALES_VentaGEX.ServicioCorrespondiente();
                            servicioGex.idPartidaDeOportunidad=op.Id;
                            if(!OportunidadLineMap.isEmpty())
                           servicioGex.folioCertificado=OportunidadLineMap.get(op.Product2.StockKeepingUnit).folioCertificado;
                             OportunidadLineMap.put(op.Product2.StockKeepingUnit,servicioGex);
                        }
                        
                         
                      
                    }
                for(DSALES_VentaGEX.OpporLineItem lista:listaDeOportunidades)
                {
                    if(lista.entregaServicioCorrespondiente!=null)
                    {
                    for(DSALES_VentaGEX.ServicioCorrespondiente listaServicio:lista.entregaServicioCorrespondiente)
                    {
                        if(OportunidadLineMap.containsKey(listaServicio.sku))
                        {
                            listaServicio.idPartidaDeOportunidad=OportunidadLineMap.get(listaServicio.sku).idPartidaDeOportunidad;
                         opportunityLineItem opporLine = new opportunityLineItem();
                            opporLine.id= listaServicio.idPartidaDeOportunidad;

                            opporLine.DSALES_FolioCertificado__c=OportunidadLineMap.get(listaServicio.sku).folioCertificado;
                            system.debug('Ids Certificados: '+OportunidadLineMap.keySet());
      						listActualizarOp.add(opporLine);
                        }
                    }
                }
                     }
                ventaGEX.ListaPartidasOportunidad=listaDeOportunidades;
                
            }
            try{
                

                if(Schema.sObjectType.opportunityLineItem.isUpdateable()) {
                    Update oppor;
                    Update listActualizarOp;
                    }else{
                    
                    System.debug('Permisos insuficientes para actualizar');
                    }
                
                
            }catch(DmlException e){
                System.debug('Error occured: ' + e);  
            }
        }
    }
    
       
    
    
}