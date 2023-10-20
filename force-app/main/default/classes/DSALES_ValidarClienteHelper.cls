public without sharing class  DSALES_ValidarClienteHelper {
    
    public static void deleteUnpurchasedItem(List<DSALES_AssetWrapper.AssetRequest> listAssets, List<DSALES_CertificadoWrapper.CertificadoRequest> certificado, String quoteId) {
        Quote originalQuote = [SELECT Id, Name,OpportunityId,DSales_ID_Tienda__c, DSALES_EmailNew__c, Pricebook2Id, RecordTypeId, Status, DSALES_Enviarcotizacion__c, DSales_Tienda__c, DSales_Vendedor__c,
                               DSALES_Fechadecreacionpresupuesto__c, ExpirationDate, DSALES_esClon__c FROM Quote WHERE Id = :quoteId WITH SECURITY_ENFORCED]; 
        
        
        List<String>idPartidasAsset= new List<String>();
        List<Decimal>idSecuencias= new List<Decimal>();
        for(DSALES_AssetWrapper.AssetRequest a:listAssets){
            idPartidasAsset.add(a.idPartidaPresupuesto);
        }
        List<String> quoteLineItemId = new List<String>();
        List<String> lstSku = new List<String>();
        List<String> lstwotId = new List<String>();
        
        for(DSALES_CertificadoWrapper.CertificadoRequest cer:certificado){
            quoteLineItemId.add(cer.idPartidaPresupuesto);
            lstSku.add(cer.sku);
            idSecuencias.add(cer.idSecuencia);
        }
        List<QuoteLineItem>qtLineOriginalCertificado=[SELECT  Id,Quantity,dsalesIdSecuencia__c,dsalesSkuTangible__c ,DSALES_NombreProductoServicio__c,PricebookEntryId,UnitPrice,Product2Id,DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Servicio'AND Id  IN:quoteLineItemId WITH SECURITY_ENFORCED LIMIT:quoteLineItemId.size() ];
        List<QuoteLineItem>qtLineOriginal=[SELECT  Id,Quantity,dsalesIdSecuencia__c,PricebookEntryId,DSALES_NombreProductoServicio__c,UnitPrice,Product2Id,DSALES_ListaArticulo__c,dsalesSkuTangible__c,DSALES_SKU__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Producto'AND Id  IN:idPartidasAsset WITH SECURITY_ENFORCED LIMIT:idPartidasAsset.size() ];
        
        system.debug('qtLineOriginal: '+qtLineOriginal);
        system.debug('idPartidasAsset + limit: '+idPartidasAsset+' '+idPartidasAsset.size());
        system.debug('IdSecuenciassss: '+idSecuencias);
        List<String>qtOriginalIds= new List<String>();
        List<String>qtSecuencias=new List<String>();
        List<String>qtOriginalIdsCertificados = new List<String>();
        List<Id>totalIds = new List<String>();
        
        for(QuoteLineItem qt:qtLineOriginal)
        {
            qtOriginalIds.add(qt.id);
            totalIds.add(qt.Id);
        }
        for(QuoteLineItem qtC:qtLineOriginalCertificado)
        {
            qtSecuencias.add(qtC.dsalesSkuTangible__c+String.valueOf(qtC.dsalesIdSecuencia__c));
            
            qtOriginalIdsCertificados.add(qtc.id);
            totalIds.add(qtC.Id);
        }
        
        system.debug('TotalIds: '+totalIds);
        
        List<QuoteLineitem>qtBorrarTotal =[SELECT  Id,DSALES_SKU__c,Quantity,dsalesIdSecuencia__c,DSALES_NombreProductoServicio__c,dsalesSkuTangible__c,PricebookEntryId,UnitPrice,Product2.DSales_Tipo_de_Producto__c,Product2Id,DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and  Id NOT IN:totalIds  WITH SECURITY_ENFORCED];
        system.debug('SECUENCIAS: '+qtSecuencias);  
        system.debug('qTBorrarTotal Size: '+qtBorrarTotal.size());   
        
        
        
        If(qtBorrarTotal.size()>0){
            Quote unpurchasedQuote = originalQuote.clone(false, true);
            //unpurchasedQuote.RecordTypeId=originalQuote.RecordTypeId;
            unpurchasedQuote.Name = originalQuote.Name + ' -';
            unpurchasedQuote.OpportunityId=originalQuote.OpportunityId;  
            unpurchasedQuote.DSales_ID_Tienda__c = originalQuote.DSales_ID_Tienda__c;
            
            unpurchasedQuote.DSALES_Enviarcotizacion__c = false;
            try{   
                if(Schema.sObjectType.Quote.isCreateable()) {
                    
                    insert unpurchasedQuote;
                }else{
                    
                    System.debug('Permisos insuficientes para crear');
                }
                
                List<QuoteLineItem> item= new List<QuoteLineItem>();
               
                for (QuoteLineItem items : qtBorrarTotal) {  
                    system.debug('items.dsalesIdSecuencia__c '+items.dsalesIdSecuencia__c);
                    system.debug('Producto o Servicio: '+items.Product2.DSales_Tipo_de_Producto__c);
                    if(qtSecuencias.contains(items.dsalesSkuTangible__c+String.valueOf(items.dsalesIdSecuencia__c))&& items.Product2.DSales_Tipo_de_Producto__c=='Servicio')
                    {system.debug('Pasó');
                     
                    }
                    else
                    { system.debug('No Pasó: Else');
                     actualizaCotizacion(items, qtLineOriginal, unpurchasedQuote, item);
                     QuoteLineItem newItem = new QuoteLineItem();
                     newItem.QuoteId = unpurchasedQuote.Id;
                     newItem.Quantity= items.Quantity;
                     newItem.dsalesSkuTangible__c=items.dsalesSkuTangible__c;
                     newItem.PricebookEntryId= items.PricebookEntryId;
                     newItem.UnitPrice= items.UnitPrice;
                     newItem.Product2Id= items.Product2Id;
                     newItem.DSALES_NombreProductoServicio__c=items.DSALES_NombreProductoServicio__c;
                     newItem.DSALES_ListaArticulo__c= items.DSALES_ListaArticulo__c;
                     newItem.Vigencia_meses__c= items.Vigencia_meses__c;
                     item.add(newItem);
                      unpurchasedQuote.Status = 'Enviada';
                    unpurchasedQuote.DSALES_Enviarcotizacion__c=true;
                    unpurchasedQuote.DSALES_esClon__c=true;
                   
                    }
                } 
                 system.debug('Id del quote a borrar: '+unpurchasedQuote.Id);
                    
                    if(Schema.sObjectType.Quote.isUpdateable()) {
                        update unpurchasedQuote;
                        
                    }else{
                        System.debug('Permisos insuficientes para Actualizar datos');
                    }
                
              
                if(Schema.sObjectType.QuoteLineItem.isCreateable()) {
                    Insert item;
                   
                }else{
                    System.debug('Permisos insuficientes para crear');
                }
                try{
                    DELETE qtBorrarTotal;
                    
                    
                   
                } 
                catch(Exception e)
                {
                    System.debug('ERRORRRR: '+e.getMessage() +e.getLineNumber());
                }
                //actualizarCotizacion(quoteId);
                //DELETE unpurchasedQuote;
            }  catch (DmlException e) {
                System.debug('Error occured: ' + e.getMessage() + e.getLineNumber());
            }
            
        }  
        
        
    }
    public static void actualizaCotizacion(QuoteLineItem items, List<QuoteLineItem> qtLineOriginal, Quote unpurchasedQuote,List<QuoteLineItem> item)
    { 
        system.debug('ACTUALIZA COTIZACIÖN');
        String idSkuItem= items.dsalesSkuTangible__c+ String.valueOf(items.dsalesIdSecuencia__c);
        for(QuoteLineItem qt:qtLineOriginal)
            
        {
            if(idSkuItem==qt.DSALES_SKU__c+String.valueOf(qt.dsalesIdSecuencia__c))
            {
                 system.debug('Entró al IF');
                QuoteLineItem newItem = new QuoteLineItem();
                newItem.QuoteId = unpurchasedQuote.Id;
                newItem.Quantity= qt.Quantity;
                newItem.dsalesIdSecuencia__c=qt.dsalesIdSecuencia__c;
                newItem.dsalesSkuTangible__c=qt.dsalesSkuTangible__c;
                newItem.PricebookEntryId= qt.PricebookEntryId;
                newItem.DSALES_NombreProductoServicio__c=qt.DSALES_NombreProductoServicio__c;
                newItem.UnitPrice= 0;
                newItem.Product2Id= qt.Product2Id;
                newItem.DSALES_ListaArticulo__c= qt.DSALES_ListaArticulo__c;
                newItem.Vigencia_meses__c= qt.Vigencia_meses__c;
                if(!item.contains(newItem))
                {
                     system.debug('Entró al Segundo If');
                    item.add(newItem);
                    break;
                }
                else
                {
                    break;
                }
                   
                
            }
        }
    }
    
    //@future(callout=true)
    public static void actualizarCotizacion(String quoteId,DSALES_VentaGEX.VentaGexResponse ventaGEX,Map<String,String> mapAssets,Map<String,String>mapCertifieds){
        system.debug('MapAssetSize: '+mapAssets.size());
        list<String> idSecuencias=New list<String>();
        List<String> skuConcatenadosNuevos = new List<String>();
        List<Asset> productos=[SELECT dsalesIdSecuencia__c, DSALES_SKU__c FROM ASSET WHERE id IN:mapAssets.values() WITH SECURITY_ENFORCED ];
        List<DSALES_Certificado__c> certificados=[SELECT dsalesIdSecuencia__c,DSALES_SKU__c,DSALES_SKUTangible__c FROM DSALES_Certificado__c WHERE id IN:mapCertifieds.values() WITH SECURITY_ENFORCED];
        for(Asset p:productos)
        {
            for(DSALES_Certificado__c c:certificados)
            {
                if(p.DSALES_SKU__c+p.dsalesIdSecuencia__c==c.DSALES_SKUTangible__c+c.dsalesIdSecuencia__c)
                {
                    String agrega=p.DSALES_SKU__c+p.dsalesIdSecuencia__c;
                    skuConcatenadosNuevos.add(agrega);
                    idSecuencias.add(String.valueOf(p.dsalesIdSecuencia__c));
                }
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
                    
                    
                    
                    for(OpportunityLineItem op:opLine)
                    {
                        Integer numeroOppor=0;
                        
                        String skuNuevoActualizado='';
                        do{ 
                            
                            system.debug('NumeroOppor: '+numeroOppor);
                            system.debug('idSecuencias: '+idSecuencias);
                            system.debug('skuConcatenadosNuevos: '+skuConcatenadosNuevos);
                            
                            if(numeroOppor<idSecuencias.size())
                            {
                                system.debug('CONCATENACIÓN: '+op.Product2.StockKeepingUnit+idSecuencias[numeroOppor]);
                                system.debug('VERSUS: '+skuConcatenadosNuevos[numeroOppor]);
                                if(op.Product2.StockKeepingUnit+idSecuencias[numeroOppor]==skuConcatenadosNuevos[numeroOppor])
                                {
                                    skuNuevoActualizado=skuConcatenadosNuevos[numeroOppor];
                                    skuConcatenadosNuevos.remove(numeroOppor);
                                    idSecuencias.remove(numeroOppor);
                                    system.debug('skuConcatenadosNuevos: '+skuConcatenadosNuevos);
                                    numeroOppor=idSecuencias.size()+1;
                                    system.debug('Entró skuNuevoActualizado: '+skuNuevoActualizado);
                                    
                                }
                                else
                                {
                                    numeroOppor++;
                                }
                            }
                            else
                            {
                                numeroOppor=idSecuencias.size()+1;
                            }
                            
                        }
                        while(numeroOppor<idSecuencias.size());
                        
                        Boolean checkGex=False;
                        
                        system.debug('mapAssets: '+mapAssets);
                        system.debug('MapAssets.Size()2'+MapAssets.size());
                        
                        
                        system.debug('PRIMER Id del OP: '+op.Id);
                        
                        
                        if( ( mapAssets.containsKey(skuNuevoActualizado))  || mapAssets.containsKey(op.Product2.StockKeepingUnit))
                        {
                            
                            if(mapAssets.containsKey(op.Product2.StockKeepingUnit))
                            {
                                skuTemporal=op.Product2.StockKeepingUnit;
                            }
                            else
                            {
                                skuTemporal=skuNuevoActualizado;
                            }
                            
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
                            
                            
                            
                            for(String b :mapaNombreCertificado.keySet())
                            {
                                system.debug('CHECK GEX: '+checkGex);
                                system.debug('SKU Temporal parte 5: '+ skutemporal);
                                if(checkGex)
                                {
                                    checkGex=false;
                                    break;
                                }
                                
                                try{
                                    system.debug('IMPRIMETE opID '+op.id);
                                    system.debug('REVISAR Comparación: '+mapaNombreCertificado.get(b).DSALES_SKUTangible__c+mapaNombreCertificado.get(b).dsalesIdSecuencia__c);
                                    system.debug('VS: '+skuNuevoActualizado);
                                    if( mapaNombreCertificado.get(b).DSALES_SKUTangible__c+mapaNombreCertificado.get(b).dsalesIdSecuencia__c==skuNuevoActualizado
                                      )
                                    {
                                        
                                        List<DSALES_VentaGEX.ServicioCorrespondiente> servicioCoList = new List <DSALES_VentaGEX.ServicioCorrespondiente>();
                                        system.debug('Debugeando B : '+b);
                                        
                                        DSALES_VentaGex.ServicioCorrespondiente servicioCo = new  DSALES_VentaGex.ServicioCorrespondiente();
                                        system.debug('Cúantas veces pasó??? hijo ');
                                        
                                        
                                        servicioCo.folioCertificado=mapaNombreCertificado.get(b).Name;
                                        
                                        servicioCo.idPartidaDeOportunidad=op.Id;
                                        servicioGex.idPartidaDeOportunidad=op.id;
                                        servicioGex.folioCertificado=servicioCo.folioCertificado;
                                        system.debug('OPID: '+op.Id);
                                        servicioCo.sku=mapaNombreCertificado.get(b).DSALES_SKU__c;
                                        
                                        system.debug('SERVICIo CO: '+servicioCo.sku);
                                        
                                        skuTemporal=servicioCo.sku+mapaNombreCertificado.get(b).DSALES_SKUTangible__c+mapaNombreCertificado.get(b).dsalesIdSecuencia__c;
                                        system.debug('skuTemporalGex: '+skuTemporal);
                                        OportunidadLineMap.put(skuTemporal,servicioGex);
                                        system.debug('OportunidadLineMap Linea 191 ' +OportunidadLineMap);
                                        OportunidadLineMap1.put(skuTemporal,servicioGex.folioCertificado);
                                       // system.debug('OportunidadLineMap1'+OportunidadLineMap1);
                                       // dadsa
                                        concatenarSkus.add(skuTemporal);
                                        skuTemporal='';
                                        //OportunidadLineMap1.put(servicioCo.folioCertificado,servicioGex);
                                        servicioCo.tipoProducto='Servicio';
                                        
                                        checkGex=True;
                                        
                                        
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
                                        system.debug('MapaNombre borrado ANTES: '+mapaNombreCertificado);
                                        mapaNombreCertificado.Remove(b);
                                        system.debug('MapaNombre borrado: '+mapaNombreCertificado);
                                        
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
                            
                            system.debug('CONCATENA LIST: '+concatenarSkus);
                            system.debug('OP MAP Concatena: '+oportunidadLineMap);
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