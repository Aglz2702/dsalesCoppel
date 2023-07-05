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
    
        list<String> idSecuencias=New list<String>();
        List<Asset> productos=[SELECT dsalesIdSecuencia__c FROM ASSET WHERE id IN:mapAssets.values() WITH SECURITY_ENFORCED LIMIT 10];
        for(Asset p:productos)
            {
                if(p.dsalesIdSecuencia__c!=-2 || p.dsalesIdSecuencia__c!=null)
                {
                    idSecuencias.add(String.valueOf(p.dsalesIdSecuencia__c));
                }
                
            }
        Quote cotizacion = [SELECT Id,AccountId,Name,OpportunityId,Opportunity.AccountId FROM Quote WHERE Id= :quoteId WITH SECURITY_ENFORCED];
        List<QuoteLineItem> partida = [SELECT Product2.Name, DSALES_NombreProductoServicio__c,DSALES_SKU__c,dsalesIdSecuencia__c,DSALES_ListaArticulo__c FROM QuoteLineItem WHERE QuoteId=:quoteId WITH SECURITY_ENFORCED];
        //Map<String,DSALES_Certificado__c> listaCertificados =[SELECT Id,Name FROM DSALES_Certificado__c WHERE DSALES_SKU__c IN:mapCertifieds.keySet() ];
        Map<String,DSALES_Certificado__c> mapaNombreCertificado = new Map<String,DSALES_Certificado__c>([SELECT Id,Name,DSALES_SKUTangible__c,DSALES_SKU__c,dsalesIdSecuencia__c FROM DSALES_Certificado__c WHERE Id IN:mapCertifieds.values() WITH SECURITY_ENFORCED]);
       Map<String,DSALES_VentaGEX.ServicioCorrespondiente> oportunidadLineMap= new Map<String,DSALES_VentaGEX.ServicioCorrespondiente>();
         Map<String,String> oportunidadLineMap1= new Map<String,String>();
        
        List<OpportunityLineItem> listActualizarOp = new List<OpportunityLineItem>();
        Set<OpportunityLineItem> setActualizarOp= new Set <OpportunityLineItem>();
       
 
        List<Opportunity> oppor= new List<Opportunity>();
        List<String> concatenarSkus= new List<String>();
        String skuTemporal='';
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
               
                Integer numeroPartida=0;
               
               system.debug('Size del opLine '+opLine.size());
                List<DSALES_VentaGEX.OpporLineItem> listaDeOportunidades = new List<DSALES_VentaGEX.OpporLineItem>();
                
               
                try{
                    system.debug('IdSecuencias : '+idSecuencias);
                 Integer numeroOppor=0;
                Integer numeroGex=0;
                   
                for(OpportunityLineItem op:opLine)
                    {
                        
                        system.debug('numeroOppor!!! '+numeroOppor);
                        //system.debug('mapAssets: '+mapAssets);
                       
                        if(idSecuencias.size()<=numeroOppor)
                        {
                            numeroOppor--;
                             system.debug('op[numeroOppor]: '+op.Product2.StockKeepingUnit+idSecuencias[numeroOppor]);
                        }
                        
                       if( (idSecuencias[numeroOppor]!=null && mapAssets.containsKey(op.Product2.StockKeepingUnit+idSecuencias[numeroOppor]))  || mapAssets.containsKey(op.Product2.StockKeepingUnit))
                       {
                           if(mapAssets.containsKey(op.Product2.StockKeepingUnit))
                           {
                                skuTemporal=op.Product2.StockKeepingUnit;
                           }
                           else
                           {
                                skuTemporal=op.Product2.StockKeepingUnit+idSecuencias[numeroOppor];
                           }
                          system.debug('NUMEROSSS: '+ numeroOppor);
                           system.debug('Cúantas veces pasó??? ');
                           DSALES_VentaGEX.ServicioCorrespondiente servicioGex= new DSALES_VentaGEX.ServicioCorrespondiente();
                            DSALES_VentaGEX.OpporLineItem opportunityLine = new DSALES_VentaGEX.OpporLineItem();
                           servicioGex.idPartidaDeOportunidad=op.Id;
                           OportunidadLineMap.put(op.Product2.StockKeepingUnit,servicioGex);
                         opportunityLine.idPartidaDeOportunidad=op.Id;
                           system.debug('REVISAR NOMBRE DE PRODUCTO ' +op.Product2.Name);
                         opportunityLine.nombreProducto=op.Product2.Name;
                       	opportunityLine.sku=op.Product2.StockKeepingUnit;
                       	opportunityLine.tipoProducto='Producto'; 
                        opportunityLine.idProductoAdquirido=mapAssets.get(skuTemporal); 
                       
                           system.debug('secuencia '+idSecuencias[numeroOppor]);
                           for(String b :mapaNombreCertificado.keySet())
                        {
                        	
                            try{
                              
                            if(numeroGex<idSecuencias.size() && mapaNombreCertificado.get(b).DSALES_SKUTangible__c+idSecuencias[numeroOppor]==op.Product2.StockKeepingUnit+idSecuencias[numeroOppor] )
                            {
                                numeroOppor++;
                                List<DSALES_VentaGEX.ServicioCorrespondiente> servicioCoList = new List <DSALES_VentaGEX.ServicioCorrespondiente>();
                                system.debug('Debugeando B : '+b);
                                system.debug('numeroGex '+numeroGex);
                                  DSALES_VentaGex.ServicioCorrespondiente servicioCo = new  DSALES_VentaGex.ServicioCorrespondiente();
                                system.debug('Cúantas veces pasó??? hijo ');
                                 
                             
                                servicioCo.folioCertificado=mapaNombreCertificado.get(b).Name;
                               
                                servicioCo.idPartidaDeOportunidad=op.Id;
                                servicioGex.idPartidaDeOportunidad=op.id;
                                servicioGex.folioCertificado=servicioCo.folioCertificado;
                                 system.debug('OPID: '+op.Id);
                                servicioCo.sku=mapaNombreCertificado.get(b).DSALES_SKU__c;
                                
                                system.debug('SERVICIo CO: '+servicioCo.sku);
                                
                                skuTemporal=servicioCo.sku+mapaNombreCertificado.get(b).DSALES_SKUTangible__c+idSecuencias[numeroGex];
                                system.debug('skuTemporalGex: '+skuTemporal);
                                OportunidadLineMap.put(skuTemporal,servicioGex);
                                system.debug('OportunidadLineMap Linea 191 ' +OportunidadLineMap);
                                OportunidadLineMap1.put(skuTemporal,servicioGex.folioCertificado);
                                system.debug('OportunidadLineMap1'+OportunidadLineMap1);
                                concatenarSkus.add(skuTemporal);
                                skuTemporal='';
                                //OportunidadLineMap1.put(servicioCo.folioCertificado,servicioGex);
                                servicioCo.tipoProducto='Servicio';
                               numeroGex++;
                                
                                    for(QuoteLineItem p:partida)
                        {
                            system.debug('DEBUGGUEANDO VALIDAR CLIENTE; NO PASÓ IF ');
                            system.debug('Intenando con esta concatenación: '+ servicioCo.sku+mapaNombreCertificado.get(b).DSALES_SKUTangible__c+
                               mapaNombreCertificado.get(b).dsalesIdSecuencia__c);
                            system.debug('Vs Esta concatenacion: '+mapaNombreCertificado.get(b).DSALES_SKU__c+p.DSALES_SKU__c+p.dsalesIdSecuencia__c);
                                system.debug('Es Producto?? '+p.DSALES_ListaArticulo__c);
                            system.debug('Partida Id '+p.Id);
                           
                            if( p.DSALES_SKU__c+mapaNombreCertificado.get(b).DSALES_SKUTangible__c+p.dsalesIdSecuencia__c== servicioCo.sku+mapaNombreCertificado.get(b).DSALES_SKUTangible__c+
                               mapaNombreCertificado.get(b).dsalesIdSecuencia__c && p.DSALES_NombreProductoServicio__c.contains(mapaNombreCertificado.get(b).DSALES_SKUTangible__c) )
                            {
                                system.debug('DEBUGGUEANDO VALIDAR CLIENTE; SI PASÓ IF ' +p.DSALES_NombreProductoServicio__c);
                                system.debug('Nombre Producto '+p.DSALES_NombreProductoServicio__c);
                                system.debug('Sku tan: '+mapaNombreCertificado.get(b).DSALES_SKUTangible__c);
                                
                                         servicioCo.nombreProducto=p.DSALES_NombreProductoServicio__c;
                                          Integer n=partida.indexOf(p);
                               		 partida.remove(n);
                                                                     
                                break;
                               
                               
                                
                                
                            }
                                                        
                        }
                                
                                
                                

                                 system.debug('servicioCooo' +servicioCo);
                                 servicioCoList.add(servicioCo);
                                system.debug('servicioCoListPrint: '+servicioCoList);
                                
                               
                                opportunityLine.entregaServicioCorrespondiente=servicioCoList;
                               
                               
                            }
                                
                               
                                }
                            catch (Exception e)
                                {
                                    system.debug('ERROR Concatena: '+e.getMessage()+e.getLineNumber());
                                }

                         
                        }
                           
                            listaDeOportunidades.add(opportunityLine);
                           system.debug('opportunityLineS: '+opportunityLine);
                           
                       }
                        
                        else
                        {
                            DSALES_VentaGEX.ServicioCorrespondiente servicioGex= new DSALES_VentaGEX.ServicioCorrespondiente();
                            servicioGex.idPartidaDeOportunidad=op.Id;
                            if(!OportunidadLineMap.isEmpty())
                            {
                                
                    system.debug('Concatenado'+ concatenarSkus);
                               Integer n=0;
                               
                                
                                for(String concatena:concatenarSkus)
                                {
                                    system.debug('OpLineMap1: '+OportunidadLineMap1);
                                     servicioGex.folioCertificado=OportunidadLineMap1.get(concatena);
                             OportunidadLineMap.put(op.Product2.StockKeepingUnit,servicioGex);
                                  
                                   
                                }
                               
                             }
                           
                            
                        }
                        
                         }
                       
                       
                   
                    }
                Catch(Exception e)
                    {
                        system.debug('ERRORR: '+e.getMessage()+' ' +e.getLineNumber());
                    }
                         
                      
                    
              Integer n=0;
               
                for(DSALES_VentaGEX.OpporLineItem lista:listaDeOportunidades)
                {
                    if(lista.entregaServicioCorrespondiente!=null)
                    {
                       system.debug('concatenarSkus.size'+concatenarSkus.size());
                        
                      if(n<concatenarSkus.size())
                      {
                          system.debug('N' +n);
                     
 					  if(OportunidadLineMap.containsKey(concatenarSkus[n]))
                        {
                            system.debug('CONCETENA SKUS: '+concatenarSKus[n]);
                                       //listaServicio.idPartidaDeOportunidad=OportunidadLineMap.get(listaServicio.sku).idPartidaDeOportunidad;
                         	opportunityLineItem opporLine = new opportunityLineItem();
                            system.debug('PRIMER ID DE LISTA: '+ lista.idPartidaDeOportunidad);
                            opporLine.id= lista.idPartidaDeOportunidad;

                            
                                opporLine.DSALES_FolioCertificado__c=OportunidadLineMap.get(concatenarSkus[n]).folioCertificado;
                            	listActualizarOp.add(opporLine);
                                
                            
                            n++;
                            }
      						
                            
                           
                            
                                
                         
                        }
                    
                       
                   
                }
                     }
                                
                ventaGEX.ListaPartidasOportunidad=listaDeOportunidades;
                
            }
            try{
                
                if(Opportunity.SObjectType.getDescribe().isUpdateable()) {
                    update oppor;   
                }else{
                    System.debug('Permisos insuficientes para actualizar');   
                } 
                if(opportunityLineItem.SObjectType.getDescribe().isUpdateable()) {
                    
                    system.debug('listActualizarOp: '+listActualizarOp);
                    update listActualizarOp;  
                }else{
                    System.debug('Permisos insuficientes para actualizar');   
                } 
                
                
            }catch(DmlException e){
                System.debug('Error occured: ' + e);  
            }
        }
    }
    
    
}