public with sharing class DSALES_QuotePagoSM {
    private static String rcGratis='RCEXC';
    public static void cotizacionesNuevas(String idPago,List<String> partidasSeleccionadas,String skuMoto){
        try {
            String idCotizacion='';
            List<String> listIdCotiza = new List<String>();
            List<QuoteLineItem> listPartidasCreadas = new List<QuoteLineItem>();
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Seguro__c,DSALES_Oportunidad__c,DSALES_Nombre_del_Vendedor__c,DSales_Tienda__c,DSALES_SKU__c  
                                              FROM DSALES_InformacionDePago__c WHERE Id=:idPago WITH SECURITY_ENFORCED];
            
            Quote beforeCot = [SELECT Id,OpportunityId,AccountId, DSALES_Plazoacotizar__c FROM Quote WHERE OpportunityId =:pago.DSALES_Oportunidad__c WITH SECURITY_ENFORCED LIMIT 1];
            Opportunity opty=[SELECT Id,StageName,SyncedQuoteId FROM Opportunity WHERE Id=:beforeCot.OpportunityId WITH SECURITY_ENFORCED LIMIT 1];
            pago = updatePago(idPago);
            
            if(pago.DSALES_Seguro__c==false ){  
                System.debug('--------->se crea DOS');
                for(Integer i=0;i<2;i++){
                    idCotizacion=crearCotizacion(beforeCot.Id,pago.Id);
                    listIdCotiza.add(idCotizacion);
                }  
                String idCotSin=crear2CotPartidas(beforeCot.Id,listIdCotiza,Integer.valueOf(pago.DSALES_Plazodecomprademoto__c), partidasSeleccionadas,skuMoto);
                createCot(idCotSin );
                
            }
            else{
                if(skuMoto!=null){
                    QuoteLineItem producto =[SELECT Id,DSALES_NombreProducto__c, DSALES_Segurogratis__c FROM QuoteLineItem  WHERE DSALES_SKU__c=:skuMoto  AND quoteId=:beforeCot.Id WITH SECURITY_ENFORCED LIMIT 1];
                    if(producto.DSALES_Segurogratis__c==true && partidasSeleccionadas!=null && partidasSeleccionadas.size()==1){
                        System.debug('DOS COTIZACIONES// SEGURO GRATIS //Nombre:------> '+producto.DSALES_NombreProducto__c);
                        for(Integer i=0;i<2;i++){
                            idCotizacion=crearCotizacion(beforeCot.Id,pago.Id);
                            listIdCotiza.add(idCotizacion);
                        } 
                        String idCotSin=crear2CotPartidas(beforeCot.Id,listIdCotiza,Integer.valueOf(pago.DSALES_Plazodecomprademoto__c), partidasSeleccionadas,skuMoto);
                        createCot( idCotSin );
                    }
                    else if(producto.DSALES_Segurogratis__c==true && partidasSeleccionadas!=null && partidasSeleccionadas.size()==2){
                        idCotizacion=crearCotizacion(beforeCot.Id,pago.Id);
                        System.debug('se UNA cotizaciones creadas--------> '+ idCotizacion);
                        crearPartidas(beforeCot.Id,idCotizacion,partidasSeleccionadas,skuMoto);
                        createQuote(idCotizacion );
                    }
                    else if(producto.DSALES_Segurogratis__c==false){
                        idCotizacion=crearCotizacion(beforeCot.Id,pago.Id);
                        System.debug('se UNA cotizaciones creadas-------> '+ idCotizacion);
                        crearPartidas(beforeCot.Id,idCotizacion,partidasSeleccionadas,skuMoto);
                        createQuote(idCotizacion );
                    }
                }
                else{
                    System.debug('se crea UNA COTIZACION SOLO SEGUROS SIN SKU');
                    idCotizacion=crearCotizacion(beforeCot.Id,pago.Id);
                    System.debug('cotizaciones creadas-------> '+ idCotizacion);
                    crearPartidas(beforeCot.Id,idCotizacion,partidasSeleccionadas,skuMoto);
                    createQuote(idCotizacion );
                    
                } 
            }
            
        } catch (Exception e) {
            System.debug('Error en método principal de cotización----->'+e.getLineNumber()+''+e.getMessage());
        }
        
    }
    
    /***********************************    1      ****************************/
    public static DSALES_InformacionDePago__c updatePago(String idPago){
        
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Seguro__c,DSALES_Oportunidad__c,DSALES_Nombre_del_Vendedor__c,DSales_Tienda__c,DSALES_SKU__c  
                                          FROM DSALES_InformacionDePago__c 
                                          WHERE Id=:idPago WITH SECURITY_ENFORCED];
        try{
            if(pago.DSALES_Plazodecomprademoto__c==0 || pago.DSALES_Plazodecomprademoto__c== null ){
                pago.DSALES_Plazodecomprademoto__c=12;
            }
            
            if(DSALES_InformacionDePago__c.SObjectType.getDescribe().isUpdateable()) {
                update pago; 
                
            }else{
                System.debug('Permisos insuficientes para actualizar'); 
                
            }
            
        }catch (Exception e) {
            System.debug('Error en método principal de cotización---------->'+e.getLineNumber()+''+e.getMessage());
        }
        return pago;
    }
    
    /******************************************   2   ***************************************/
    public static void createCot(String idCotSin ){ 
        if(idCotSin!=null|| idCotSin!=''){
            sincronizarOportunidad(idCotSin);
        }
        
    }
    /***********************************   3   ***************************************/
    public static void createQuote(String idCotizacion ){
        if(idCotizacion!=null || idCotizacion!=''){
            sincronizarOportunidad(idCotizacion);
        } 
    }
    /****************************************************************************** */
    
    
    public static String crearCotizacion(String idCotizacion,String idPago){
        try{
            Quote beforeCot = [SELECT Id,OpportunityId,Name,DSALES_Fechadenacimiento__c,Email,DSALES_Cobertura__c,dsalesOpcionDePago__c,dsalesGenero__c,Phone,dsalesCodigoPostal__c,dsalesFechaDeComienzoDePoliza__c,
                               dsalesListaNegra__c,dsalesMotivoDeListaNegra__c,DSALES_TrakingID__c,DSALES_NombreCliente__c,DSALES_Enviarcotizacion__c,GrandTotal,Tax,DSales_Vendedor__c,ExpirationDate,dsalesIdDeVehiculo__c,
                               DSales_Tienda__c,DSALES_Plazoacotizar__c,DSALES_PlazoacotizarRC__c,DSALES_Tipodeuso__c,DSALES_RFC__c,DSALES_TipoUso__c,dsalesTipoDeVehiculo__c, RecordTypeId
                               FROM Quote WHERE Id=:idCotizacion WITH SECURITY_ENFORCED];
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Oportunidad__c,DSALES_Nombre_del_Vendedor__c,DSales_Tienda__c,DSALES_SKU__c  
                                              FROM DSALES_InformacionDePago__c WHERE Id=:idPago WITH SECURITY_ENFORCED];
            Quote cotizacion = new Quote();
            cotizacion.RecordTypeId=beforeCot.RecordTypeId;
            cotizacion.OpportunityId=beforeCot.OpportunityId;
            cotizacion.Name=beforeCot.Name;
            cotizacion.DSALES_Fechadenacimiento__c=beforeCot.DSALES_Fechadenacimiento__c;
            cotizacion.Email=beforeCot.Email;
            cotizacion.DSALES_Cobertura__c=beforeCot.DSALES_Cobertura__c;
            cotizacion.dsalesOpcionDePago__c=beforeCot.dsalesOpcionDePago__c;
            cotizacion.dsalesGenero__c=beforeCot.dsalesGenero__c;
            cotizacion.Phone=beforeCot.Phone;
            cotizacion.dsalesCodigoPostal__c=beforeCot.dsalesCodigoPostal__c;
            cotizacion.dsalesFechaDeComienzoDePoliza__c=beforeCot.dsalesFechaDeComienzoDePoliza__c;
            cotizacion.dsalesListaNegra__c=beforeCot.dsalesListaNegra__c;
            cotizacion.dsalesMotivoDeListaNegra__c=beforeCot.dsalesMotivoDeListaNegra__c;
            cotizacion.DSALES_TrakingID__c=beforeCot.DSALES_TrakingID__c;
            if(pago.DSALES_Nombre_del_Vendedor__c!=null){
                cotizacion.DSales_Vendedor__c=pago.DSALES_Nombre_del_Vendedor__c;
            }
            cotizacion.DSales_Vendedor__c=beforeCot.DSales_Vendedor__c;
            if(pago.DSales_Tienda__c!=null){
                cotizacion.DSales_Tienda__c=pago.DSales_Tienda__c;
            }
            cotizacion.DSales_Tienda__c=beforeCot.DSales_Tienda__c;
            cotizacion.Tax=beforeCot.Tax;
            cotizacion.dsalesIdDeVehiculo__c=beforeCot.dsalesIdDeVehiculo__c;
            cotizacion.DSALES_Plazoacotizar__c=pago.DSALES_Plazodecomprademoto__c;
            cotizacion.DSALES_PlazoacotizarRC__c=beforeCot.DSALES_PlazoacotizarRC__c;
            cotizacion.DSALES_Tipodeuso__c=beforeCot.DSALES_Tipodeuso__c;
            cotizacion.DSALES_RFC__c=beforeCot.DSALES_RFC__c;
            cotizacion.DSALES_TipoUso__c=beforeCot.DSALES_TipoUso__c;
            cotizacion.dsalesTipoDeVehiculo__c=beforeCot.dsalesTipoDeVehiculo__c;
            cotizacion.ExpirationDate=beforeCot.ExpirationDate;
            if(Schema.sObjectType.Quote.isCreateable()) {
                insert cotizacion; 
            }else{
                System.debug('Permisos insuficientes para insertar');
            }
            
            return cotizacion.Id;
        }catch(Exception e){
            System.debug('Error al crear cotización--------->'+e.getLineNumber() + e.getMessage());
            return null;
        }
    }
    
    public static void crearPartidas(String idCot,String idCotizacion,List<String> partidasSeleccionadas,String skuMoto){
        try{
            List<String> listIdProd = new List<String>();
            List<QuoteLineItem> listPartidas = new List<QuoteLineItem>();
            List<QuoteLineItem> partidas = new List<QuoteLineItem>();
            QuoteLineItem part;
            
            for(List<QuoteLineItem> partida: [SELECT Id,DSALES_Descripcion__c,DSALES_TrackingID__c,DSALES_Pagomensual__c,DSALES_SKU__c,DSALES_Recargos__c,QuoteId,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,dsalesDerechosDePoliza__c,
                                              dsalesGastosDeOperacionDelRecibo__c,DSALES_Impuestos__c,dsalesQuoteId__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c,dsalesOpcionPago__c
                                              FROM QuoteLineItem WHERE Id IN:partidasSeleccionadas
                                              WITH SECURITY_ENFORCED]){
                                                  
                                                  partidas=partida;
                                                  
                                              }
            if(skuMoto!=null ){
                QuoteLineItem producto =[SELECT Id,QuoteId,DSALES_Segurogratis__c,DSALES_Descripcion__c,DSALES_Pagomensual__c,DSALES_TrackingID__c,DSALES_Comision__c,DSALES_NombreProducto__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,dsalesDerechosDePoliza__c,
                                         dsalesGastosDeOperacionDelRecibo__c,DSALES_Impuestos__c,DSALES_Recargos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c,dsalesQuoteId__c,dsalesOpcionPago__c
                                         FROM QuoteLineItem  WHERE QuoteId=:idCot  AND DSALES_SKU__c=:skuMoto WITH SECURITY_ENFORCED LIMIT 1]; 
                System.debug('moto:'+producto);
                partidas.add(producto);
                
            }
            if(partidas!=null){
                System.debug('partidas----->'+partidas.size()+'------' +partidas);
                listPartidas=createNewQuoteLineItems(idCotizacion,partidas);
            }
            
            System.debug('partidasCreadas-------->'+listPartidas);
            if(Schema.sObjectType.QuoteLineItem.isCreateable()) {
                insert listPartidas;
            }else{
                System.debug('Permisos insuficientes para insertar');
            }
            
            List<QuoteLineItem> idNuevos = new List<QuoteLineItem>();
            idNuevos=updateQuLnItm(partidas, listPartidas);
            if(QuoteLineItem.SObjectType.getDescribe().isUpdateable()) {
                update idNuevos;   
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            } 
        }catch(Exception e){
            System.debug('Error al crear una partida de presupuesto--------->'+e.getLineNumber() + e.getMessage());
        }
        
    } 
    /*******************************     1     *****************************************************************/   
    public static List<QuoteLineItem> createNewQuoteLineItems(String idCotizacion, List<QuoteLineItem> partidas) {
        List<QuoteLineItem> listPartidas = new List<QuoteLineItem>();
        List<String> listIdProd = new List<String>();
        for(QuoteLineItem q:partidas){
            listIdProd.add(q.Product2Id);
        }
        List<Product2> productos = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Id IN:listIdProd WITH SECURITY_ENFORCED] ;
        System.debug('productos---------> '+productos);
        List<PricebookEntry> precios = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN:listIdProd WITH SECURITY_ENFORCED]; 
        List<Plazo__c> plazos =[SELECT Id, Dsales_Plazo__c,dsalesSeguro__c FROM Plazo__c WHERE  dsalesSeguro__c=:listIdProd WITH SECURITY_ENFORCED];
        System.debug('precios:'+precios);
        System.debug('xxxx:'+plazos);
        for(QuoteLineItem q:partidas){
            System.debug('partida: '+ q.DSALES_NombreProducto__c);
            QuoteLineItem partida = new QuoteLineItem();
            partida.QuoteId = idCotizacion;
            for(PricebookEntry pr:precios){
                for(Plazo__c p:plazos){
                    if(pr.Name==q.DSALES_NombreProducto__c){
                        partida.PricebookEntryId = pr.Id;
                        // if(partida.DSALES_Segurogratis__c!=null){
                        partida.DSALES_Segurogratis__c=q.DSALES_Segurogratis__c;
                        // }
                        partida.Product2Id = pr.Product2Id;
                        partida.Quantity = 1;
                        partida.DSALES_Fechadeinicio__c = q.DSALES_Fechadeinicio__c;
                        partida.DSALES_Fechadetermino__c = q.DSALES_Fechadetermino__c;
                        partida.DSALES_Primaneta__c = q.DSALES_Primaneta__c;
                        partida.UnitPrice = q.UnitPrice;
                        partida.dsalesDerechosDePoliza__c = q.dsalesDerechosDePoliza__c;
                        partida.dsalesGastosDeOperacionDelRecibo__c = q.dsalesGastosDeOperacionDelRecibo__c;
                        partida.DSALES_Impuestos__c = q.DSALES_Impuestos__c;
                        partida.DSALES_Comision__c=q.DSALES_Comision__c;
                        partida.DSALES_TrackingID__c=q.DSALES_TrackingID__c;
                        partida.DSALES_Recargos__c=q.DSALES_Recargos__c;
                        partida.DSALES_Pagomensual__c=q.DSALES_Pagomensual__c;
                        partida.DSALES_Descripcion__c=q.DSALES_Descripcion__c;
                        partida.dsalesQuoteId__c=q.dsalesQuoteId__c;
                        partida.dsalesOpcionPago__c=q.dsalesOpcionPago__c;
                        if(p.Id==q.DSALES_Plazo__c){
                            partida.DSALES_Plazo__c=p.Id;
                        }
                        
                        
                    } 
                }
                
            }
            listPartidas.add(partida);
        }
        
        return listPartidas;
    }
    /*********************************************       2      *************************************************************/
    
    public static list<QuoteLineItem> updateQuLnItm(List<QuoteLineItem> partidas, List<QuoteLineItem>listPartidas){
        List<QuoteLineItem> idNuevos = new List<QuoteLineItem>();
        List<QuoteLineItem> partidasNuevas =[SELECT Id, UnitPrice,DSALES_Tipodeproducto__c,ListPrice,DSALES_Pagomensual__c,TotalPrice,DSALES_Impuestos__c,DSALES_Recargos__c,dsalesDerechosDePoliza__c,DSALES_Primaneta__c,dsalesGastosDeOperacionDelRecibo__c,DSALES_Plazo__c,DSALES_Segurogratis__c,DSALES_NombreProducto__c FROM QuoteLineItem WHERE Id IN:listPartidas WITH SECURITY_ENFORCED];
        for(QuoteLineItem ql:partidasNuevas){
            for(QuoteLineItem q:partidas){
                if(ql.DSALES_NombreProducto__c == q.DSALES_NombreProducto__c && ql.DSALES_Plazo__c == q.DSALES_Plazo__c){
                    if(ql.DSALES_Segurogratis__c==true && ql.DSALES_Tipodeproducto__c=='Seguro'){
                        ql.UnitPrice=0;
                        ql.dsalesGastosDeOperacionDelRecibo__c=0;
                        ql.DSALES_Primaneta__c=0;
                        ql.dsalesDerechosDePoliza__c=0;
                        ql.DSALES_Comision__c=0;
                        ql.DSALES_Recargos__c=0;
                        ql.DSALES_Impuestos__c=0;
                        ql.DSALES_Pagomensual__c=0;
                    }
                    else{
                        ql.UnitPrice=q.UnitPrice;
                    }
                    idNuevos.add(ql);
                }
                
                
            }
            
        }
        return idNuevos;
    }
    /*********************************************************************************************************************/  
    
    public static String crear2CotPartidas(String idCot,List<String> listCotNew,Integer plazo,List<String> partidasSeleccionadas, String skuMoto){
        
        List<String> listIdProd = new List<String>();
        List<QuoteLineItem> listPartidas = new List<QuoteLineItem>();
        List<QuoteLineItem> listSeguros = new List<QuoteLineItem>();
        List<QuoteLineItem> listMotoRc = new List<QuoteLineItem>();
        List<QuoteLineItem> listaMotoSeguro = new List<QuoteLineItem>();
        List<QuoteLineItem> listPartInsert = new List<QuoteLineItem>();
        QuoteLineItem seguro = new QuoteLineItem();
        QuoteLineItem seguroGratis = new QuoteLineItem();
        String idCotSincronizar='';
        try{
            QuoteLineItem producto =lstQlItm(idCot, skuMoto);
            if(producto!=null && producto.DSALES_Segurogratis__c==true){
                seguroGratis= lstQlItms(partidasSeleccionadas);
                seguro=[SELECT Id,dsalesOpcionPago__c,QuoteId,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Pagomensual__c,DSALES_Recargos__c,DSALES_SKU__c,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,dsalesDerechosDePoliza__c,
                        dsalesGastosDeOperacionDelRecibo__c,DSALES_Impuestos__c,dsalesQuoteId__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c FROM QuoteLineItem WHERE 
                        QuoteId=:idCot AND DSALES_Segurogratis__c!=true AND DSALES_Plazo__r.Dsales_Plazo__c =:String.valueOf(plazo) AND Id!=:seguroGratis.Id WITH SECURITY_ENFORCED LIMIT 1];
                
                listPartidas.add(producto);
                listPartidas.add(seguro); 
                listPartidas.add(seguroGratis);
                
                listMotoRc.add(producto);
                listMotoRc.add(seguroGratis);
                
                listaMotoSeguro.add(seguro);
                listaMotoSeguro.add(producto);						
                
                List<QuoteLineItem> listaMotoSeguroToInsert = new List<QuoteLineItem>();
                listaMotoSeguroToInsert= createQlItm (listCotNew, listPartidas, listaMotoSeguro);
                
                Quote cotizacionEnviar= updateEnviarCot(listaMotoSeguroToInsert);
                listPartInsert= createQlItms(listCotNew,listPartidas,listMotoRc);
                
                try{
                    if(Schema.sObjectType.QuoteLineItem.isCreateable()) {
                        insert listaMotoSeguroToInsert;
                        insert listPartInsert;
                    }else{
                        System.debug('Permisos insuficientes para insertar');
                    }
                    
                    Quote cotizacion =updateCot(listCotNew);
                }catch(Exception e){
                    System.debug('Error al insertar:\n'+e.getMessage());
                }
                
                List<QuoteLineItem> idNuevos = new List<QuoteLineItem>();
                idNuevos= createCotItm(listMotoRc, listPartInsert);
                update idNuevos;
                System.debug('idCotizacion actu:'+listPartInsert[0].QuoteId);
                idCotSincronizar= listPartInsert[0].QuoteId;
            }
            else if(producto!= null){ 
                listSeguros=[SELECT Id,dsalesOpcionPago__c,QuoteId,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Recargos__c,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,Dsales_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,dsalesDerechosDePoliza__c,
                             dsalesGastosDeOperacionDelRecibo__c,dsalesQuoteId__c,DSALES_Pagomensual__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                             FROM QuoteLineItem WHERE  QuoteId=:idCot AND DSALES_Tipodeproducto__c='Seguro' AND DSALES_NombreProducto__c!=:rcGratis AND DSALES_Plazo__r.Dsales_Plazo__c =:String.valueOf(plazo) WITH SECURITY_ENFORCED ORDER BY DSALES_Plazo__r.Dsales_Plazo__c ASC LIMIT 10];
                
                listPartidas=listSeguros;
                listPartidas.add(producto);
                
                System.debug('listPartidas fin-------->'+listPartidas);
                System.debug('size listPartidas---------> '+listPartidas.size());
                List<Product2> productos = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Id IN:listIdProd WITH SECURITY_ENFORCED] ;
                List<PricebookEntry> precios = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN:listIdProd WITH SECURITY_ENFORCED]; 
                List<Plazo__c> plazos =[SELECT Id, Dsales_Plazo__c,dsalesSeguro__c FROM Plazo__c WHERE  dsalesSeguro__c=:listIdProd WITH SECURITY_ENFORCED];
                
                QuoteLineItem partida= new QuoteLineItem();
                partida =createCotlItem(listCotNew, listPartidas, producto);
                listPartInsert= createCotlItems(listCotNew, listPartidas);
                if(Schema.sObjectType.QuoteLineItem.isCreateable()) {
                    insert partida;
                    insert listPartInsert;
                    
                }else{
                    System.debug('Permisos insuficientes para insertar');
                }
                System.debug('partida---------> '+partida);
                System.debug('partidas seg+ rc3-------->'+listPartInsert.size());
                
                Quote cotizacionEnviar=updateQot(listPartInsert);
                List<QuoteLineItem> idNuevos = new List<QuoteLineItem>();
                idNuevos= createNuevos(listPartidas, listPartInsert);
                update idNuevos; 
                idCotSincronizar= partida.QuoteId;
            }
            return idCotSincronizar;
        }catch(Exception e ){
            System.debug('Error al crear dos partidas de presupuesto--------->'+e.getLineNumber() + e.getMessage());
            return null;
        }
    }
    /****************************************************************************** */
    public static QuoteLineItem lstQlItm(String idCot, String skuMoto){
        QuoteLineItem producto =[SELECT Id,QuoteId,dsalesOpcionPago__c,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Pagomensual__c,DSALES_Segurogratis__c,DSALES_Comision__c,DSALES_NombreProducto__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,dsalesDerechosDePoliza__c,
                                 dsalesGastosDeOperacionDelRecibo__c,DSALES_Recargos__c,dsalesQuoteId__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                 FROM QuoteLineItem  WHERE QuoteId=:idCot  AND DSALES_SKU__c=:skuMoto WITH SECURITY_ENFORCED LIMIT 1]; 
        System.debug('moto---------->'+producto);
        return producto;
    } 
    /************************************************************************************* */
    
    public static QuoteLineItem lstQlItms(List<String> partidasSeleccionadas){
        QuoteLineItem seguroGratis = new QuoteLineItem();
        for(QuoteLineItem partida: [SELECT Id,dsalesOpcionPago__c,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Pagomensual__c,DSALES_SKU__c,QuoteId,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,dsalesDerechosDePoliza__c,
                                    dsalesGastosDeOperacionDelRecibo__c,dsalesQuoteId__c,DSALES_Recargos__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                    FROM QuoteLineItem WHERE Id IN:partidasSeleccionadas WITH SECURITY_ENFORCED LIMIT 10]){
                                        
                                        seguroGratis=partida;       
                                    }
        return seguroGratis;
    }
    /******************************************************************************************************/
    public static Quote updateQot(List<QuoteLineItem>listPartInsert){
        Quote cotizacionEnviar=[SELECT Id,DSALES_Enviarcotizacion__c FROM Quote WHERE Id=:listPartInsert[0].QuoteId WITH SECURITY_ENFORCED LIMIT 1];
        cotizacionEnviar.DSALES_Enviarcotizacion__c=true;
        if(Quote.SObjectType.getDescribe().isUpdateable()) {
            update cotizacionEnviar;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        } 
        return cotizacionEnviar;
    }
    /**********************************************************************************************************/
    public static Quote updateCot(List<String>listCotNew){
        Quote cotizacion =[SELECT Id,DSALES_Enviarcotizacion__c FROM Quote WHERE Id=:listCotNew[0] WITH SECURITY_ENFORCED LIMIT 1];
        if(cotizacion!=null){
            cotizacion.DSALES_Enviarcotizacion__c=true;
        }
        return cotizacion;
    }
    
    /**************************************************************** */
    public static Quote updateEnviarCot(List<QuoteLineItem>listaMotoSeguroToInsert){
        Quote cotizacionEnviar=[SELECT Id,DSALES_Enviarcotizacion__c FROM Quote WHERE Id=:listaMotoSeguroToInsert[0].QuoteId WITH SECURITY_ENFORCED LIMIT 1];
        cotizacionEnviar.DSALES_Enviarcotizacion__c=true;
        if(Quote.SObjectType.getDescribe().isUpdateable()) {
            update cotizacionEnviar;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        } 
        return cotizacionEnviar;
    }
    
    
    /*************************  1   ********************************************************/
    
    
    public static List<QuoteLineItem> createQlItm (List<String> listCotNew, List<QuoteLineItem> listPartidas, List<QuoteLineItem> listaMotoSeguro){
        List<QuoteLineItem> listaMotoSeguroToInsert = new List<QuoteLineItem>();
        List<String> listIdProd = new List<String>();
        for(QuoteLineItem q:listPartidas){
            listIdProd.add(q.Product2Id);
        }
        
        Map<String, Product2> productsMap = new Map<String, Product2>([SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Id IN :listIdProd WITH SECURITY_ENFORCED]);
        Map<String, PricebookEntry> pricesMap = new Map<String, PricebookEntry>([SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN :listIdProd WITH SECURITY_ENFORCED]);
        Map<String, Plazo__c> plazosMap = new Map<String, Plazo__c>([SELECT Id, Dsales_Plazo__c, dsalesSeguro__c FROM Plazo__c WHERE dsalesSeguro__c IN :listIdProd WITH SECURITY_ENFORCED]);
        for(QuoteLineItem ql:listaMotoSeguro){
            QuoteLineItem partida = new QuoteLineItem();
            partida.QuoteId = listCotNew[0]; 
            if (pricesMap.containsKey(ql.DSALES_NombreProducto__c) && plazosMap.containsKey(ql.DSALES_Plazo__c)) {
                PricebookEntry pr = pricesMap.get(ql.DSALES_NombreProducto__c);
                Plazo__c p = plazosMap.get(ql.DSALES_Plazo__c);
                partida.PricebookEntryId = pr.Id;
                partida.Product2Id = pr.Product2Id;
                partida.UnitPrice = pr.UnitPrice;
                
                if(ql.DSALES_Segurogratis__c!=null){
                    partida.DSALES_Segurogratis__c=ql.DSALES_Segurogratis__c;
                }
                partida.Quantity = 1;
                partida.DSALES_Fechadeinicio__c = ql.DSALES_Fechadeinicio__c;
                partida.DSALES_Fechadetermino__c = ql.DSALES_Fechadetermino__c;
                partida.DSALES_Primaneta__c = ql.DSALES_Primaneta__c;
                partida.UnitPrice = ql.UnitPrice;
                partida.dsalesDerechosDePoliza__c = ql.dsalesDerechosDePoliza__c;
                partida.dsalesGastosDeOperacionDelRecibo__c = ql.dsalesGastosDeOperacionDelRecibo__c;
                partida.DSALES_Impuestos__c = ql.DSALES_Impuestos__c;
                partida.DSALES_Comision__c=ql.DSALES_Comision__c;
                partida.DSALES_TrackingID__c=ql.DSALES_TrackingID__c;
                partida.DSALES_Recargos__c=ql.DSALES_Recargos__c;
                partida.DSALES_Pagomensual__c=ql.DSALES_Pagomensual__c;
                partida.DSALES_Descripcion__c=ql.DSALES_Descripcion__c;
                partida.dsalesQuoteId__c=ql.dsalesQuoteId__c;
                partida.dsalesOpcionPago__c=ql.dsalesOpcionPago__c;
                //for(Plazo__c p:plazos){
                if(ql.DSALES_Plazo__c!=null && p.Id== ql.DSALES_Plazo__c){
                    partida.DSALES_Plazo__c=ql.Dsales_Plazo__c;
                }
                //}
                listaMotoSeguroToInsert.add(partida);
                
            }
        }
        return listaMotoSeguroToInsert;
        
    }
    /*************************  2   ********************************************************/
    
    public static List<QuoteLineItem> createQlItms(List<String> listCotNew, List<QuoteLineItem> listPartidas, List<QuoteLineItem>listMotoRc){
        List<QuoteLineItem> listPartInsert = new List<QuoteLineItem>();
        List<String> listIdProd = new List<String>();
        for(QuoteLineItem q:listPartidas){
            listIdProd.add(q.Product2Id);
        }
        List<Product2> productos = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Id IN:listIdProd WITH SECURITY_ENFORCED] ;
        Map<String, PricebookEntry> pricesMap = new Map<String, PricebookEntry>([SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN :listIdProd WITH SECURITY_ENFORCED]);
        Map<String, Plazo__c> plazosMap = new Map<String, Plazo__c>([SELECT Id, Dsales_Plazo__c, dsalesSeguro__c FROM Plazo__c WHERE dsalesSeguro__c IN :listIdProd WITH SECURITY_ENFORCED]);
        
        for(QuoteLineItem q:listMotoRc){
            QuoteLineItem part = new QuoteLineItem();
            part.QuoteId = listCotNew[0]; 
            if (pricesMap.containsKey(q.DSALES_NombreProducto__c) && plazosMap.containsKey(q.DSALES_Plazo__c)) {
                PricebookEntry pr = pricesMap.get(q.DSALES_NombreProducto__c);
                
                part.PricebookEntryId = pr.Id;
                part.UnitPrice=pr.UnitPrice;
                part.DSALES_Segurogratis__c=q?.DSALES_Segurogratis__c;
                part.Quantity = 1;
                part.DSALES_Fechadeinicio__c = q.DSALES_Fechadeinicio__c;
                part.DSALES_Fechadetermino__c = q.DSALES_Fechadetermino__c;
                part.DSALES_Primaneta__c = q.DSALES_Primaneta__c;
                part.dsalesDerechosDePoliza__c = q.dsalesDerechosDePoliza__c;
                part.dsalesGastosDeOperacionDelRecibo__c = q.dsalesGastosDeOperacionDelRecibo__c;
                part.DSALES_Impuestos__c = q.DSALES_Impuestos__c;
                part.DSALES_TrackingID__c=q.DSALES_TrackingID__c;
                part.DSALES_Comision__c=q.DSALES_Comision__c;
                part.DSALES_Recargos__c=q.DSALES_Recargos__c;
                part.DSALES_Descripcion__c=q.DSALES_Descripcion__c;
                part.DSALES_Pagomensual__c=q.DSALES_Pagomensual__c;
                part.dsalesQuoteId__c=q.dsalesQuoteId__c;
                part.dsalesOpcionPago__c=q.dsalesOpcionPago__c;
                //for(Plazo__c p:plazos){
                part.DSALES_Plazo__c=q.Dsales_Plazo__c;
            }
            listPartInsert.add(part); 
        }
        System.debug('listPartInsert:'+listPartInsert.size());
        return listPartInsert;
    }
    /*************************  3   ********************************************************/
    
    public static list<QuoteLineItem> createCotItm(List<QuoteLineItem>listMotoRc, List<QuoteLineItem>listPartInsert){
        List<QuoteLineItem> idNuevos = new List<QuoteLineItem>();
        List<QuoteLineItem> partidasNuevas =[SELECT Id,DSALES_Tipodeproducto__c,DSALES_Impuestos__c,DSALES_Pagomensual__c,DSALES_Recargos__c,DSALES_Comision__c,
                                             dsalesDerechosDePoliza__c, UnitPrice,dsalesGastosDeOperacionDelRecibo__c,DSALES_Primaneta__c,DSALES_Plazo__c,DSALES_NombreProducto__c,DSALES_Segurogratis__c 
                                             FROM QuoteLineItem WHERE Id IN:listPartInsert WITH SECURITY_ENFORCED];
        System.debug('nuevas:'+partidasNuevas.size());
        for(QuoteLineItem ql:partidasNuevas){
            for(QuoteLineItem q:listMotoRc){
                if( ql.DSALES_Plazo__c == q.DSALES_Plazo__c && ql.DSALES_Segurogratis__c==true && ql.DSALES_Tipodeproducto__c=='Seguro'){
                    ql.UnitPrice=0;
                    ql.dsalesGastosDeOperacionDelRecibo__c=0;
                    ql.DSALES_Primaneta__c=0;
                    ql.dsalesDerechosDePoliza__c=0;
                    ql.DSALES_Comision__c=0;
                    ql.DSALES_Recargos__c=0;
                    ql.DSALES_Impuestos__c=0;
                    ql.DSALES_Pagomensual__c=0;
                }else{
                    ql.UnitPrice=q.UnitPrice;
                }
            }
            idNuevos.add(ql);
            System.debug('ID X:'+ql.DSALES_NombreProducto__c);
        }
        return idNuevos;
    }
    
    /*************************  4   ********************************************************/
    
    public static QuoteLineItem createCotlItem(List<String> listCotNew, List<QuoteLineItem>listPartidas, QuoteLineItem producto ){
        List<String> listIdProd = new List<String>();
        for(QuoteLineItem q:listPartidas){
            listIdProd.add(q.Product2Id);
        }
        List<Product2> productos = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Id IN:listIdProd WITH SECURITY_ENFORCED] ;
        List<PricebookEntry> precios = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN:listIdProd WITH SECURITY_ENFORCED]; 
        List<Plazo__c> plazos =[SELECT Id, Dsales_Plazo__c,dsalesSeguro__c FROM Plazo__c WHERE  dsalesSeguro__c=:listIdProd WITH SECURITY_ENFORCED];
        QuoteLineItem partida = new QuoteLineItem();
        for(PricebookEntry pr:precios){
            partida.QuoteId = listCotNew[0];
            if(pr.Name==producto.DSALES_NombreProducto__c){
                partida.PricebookEntryId = pr.Id;
                partida.Product2Id = pr.Product2Id;
                partida.UnitPrice = pr.UnitPrice;
            }
            if(producto.DSALES_Segurogratis__c!=null){
                partida.DSALES_Segurogratis__c=producto.DSALES_Segurogratis__c;
            }
            partida.Quantity = 1;
            partida.DSALES_Fechadeinicio__c = producto.DSALES_Fechadeinicio__c;
            partida.DSALES_Fechadetermino__c = producto.DSALES_Fechadetermino__c;
            partida.DSALES_Primaneta__c = producto.DSALES_Primaneta__c;
            partida.UnitPrice = producto.UnitPrice;
            partida.dsalesDerechosDePoliza__c = producto.dsalesDerechosDePoliza__c;
            partida.dsalesGastosDeOperacionDelRecibo__c = producto.dsalesGastosDeOperacionDelRecibo__c;
            partida.DSALES_Impuestos__c = producto.DSALES_Impuestos__c;
            partida.DSALES_Comision__c=producto.DSALES_Comision__c;
            partida.DSALES_TrackingID__c=producto.DSALES_TrackingID__c;
            partida.DSALES_Recargos__c=producto.DSALES_Recargos__c;
            partida.DSALES_Pagomensual__c=producto.DSALES_Pagomensual__c;
            partida.DSALES_Descripcion__c=producto.DSALES_Descripcion__c;
            partida.dsalesOpcionPago__c=producto.dsalesOpcionPago__c;
            partida.dsalesQuoteId__c=producto.dsalesQuoteId__c;
            for(Plazo__c p:plazos){
                if(producto.DSALES_Plazo__c!=null && p.Id== producto.DSALES_Plazo__c){
                    partida.DSALES_Plazo__c=producto.Dsales_Plazo__c;
                }
            }
        }
        return partida;
    }
    /*************************  5   ********************************************************/
    public static List<QuoteLineItem> createCotlItems(List<String> listCotNew, List<QuoteLineItem>listPartidas){
        List<QuoteLineItem> listPartInsert = new List<QuoteLineItem>();
        List<String> listIdProd = new List<String>();
        for(QuoteLineItem q:listPartidas){
            listIdProd.add(q.Product2Id);
        }
        List<Product2> productos = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Id IN:listIdProd WITH SECURITY_ENFORCED] ;
        List<PricebookEntry> precios = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN:listIdProd WITH SECURITY_ENFORCED]; 
        List<Plazo__c> plazos =[SELECT Id, Dsales_Plazo__c,dsalesSeguro__c FROM Plazo__c WHERE  dsalesSeguro__c=:listIdProd WITH SECURITY_ENFORCED];
        
        for(QuoteLineItem q:listPartidas){
            QuoteLineItem part = new QuoteLineItem();
            for(PricebookEntry pr:precios){
                for(Plazo__c p:plazos){
                    if(pr.Name==q.DSALES_NombreProducto__c){
                        part.QuoteId = listCotNew[1]; 
                        part.PricebookEntryId = pr.Id;
                        part.UnitPrice=pr.UnitPrice;
                        if(part.DSALES_Segurogratis__c!=null){
                            part.DSALES_Segurogratis__c=q.DSALES_Segurogratis__c;
                        }
                        part.Quantity = 1;
                        
                        part.DSALES_Comision__c=q.DSALES_Comision__c;
                        part.DSALES_Fechadeinicio__c = q.DSALES_Fechadeinicio__c;
                        part.DSALES_Fechadetermino__c = q.DSALES_Fechadetermino__c;
                        part.DSALES_Primaneta__c = q.DSALES_Primaneta__c;
                        //partida.UnitPrice = q.UnitPrice;
                        part.dsalesDerechosDePoliza__c = q.dsalesDerechosDePoliza__c;
                        part.dsalesGastosDeOperacionDelRecibo__c = q.dsalesGastosDeOperacionDelRecibo__c;
                        part.DSALES_Impuestos__c = q.DSALES_Impuestos__c;
                        part.DSALES_TrackingID__c=q.DSALES_TrackingID__c;
                        part.DSALES_Recargos__c=q.DSALES_Recargos__c;
                        part.DSALES_Pagomensual__c=q.DSALES_Pagomensual__c;
                        part.DSALES_Descripcion__c=q.DSALES_Descripcion__c;
                        part.dsalesQuoteId__c=q.dsalesQuoteId__c;
                        part.dsalesOpcionPago__c=q.dsalesOpcionPago__c;
                        part.DSALES_Plazo__c=q.Dsales_Plazo__c;
                    }
                }
            }
            
            
            listPartInsert.add(part); 
        }
        System.debug('partidas seg+ rc3-------->'+listPartInsert.size());
        return listPartInsert;
    }
    
    /*****************************   6   ***************************************************/
    public static List<QuoteLineItem> createNuevos(List<QuoteLineItem>listPartidas, List<QuoteLineItem>listPartInsert){
        List<QuoteLineItem> idNuevos = new List<QuoteLineItem>();
        List<QuoteLineItem> partidasNuevas =[SELECT Id, UnitPrice,DSALES_Plazo__c,DSALES_NombreProducto__c FROM QuoteLineItem WHERE Id IN:listPartInsert WITH SECURITY_ENFORCED];
        for(QuoteLineItem ql:partidasNuevas){
            for(QuoteLineItem q:listPartidas){
                if(ql.DSALES_NombreProducto__c == q.DSALES_NombreProducto__c && ql.DSALES_Plazo__c == q.DSALES_Plazo__c){
                    ql.UnitPrice=q.UnitPrice;
                }  
            }
            idNuevos.add(ql);
        }
        return idNuevos;
    }
    
    
    public static void sincronizarOportunidad(String quoteId){
        try{
            System.debug('sincronza la cotización con oportunidad');
            Quote cotizacion = [SELECT Id,OpportunityId,DSALES_Enviarcotizacion__c FROM Quote WHERE Id= :quoteId WITH SECURITY_ENFORCED LIMIT 1];
            System.debug('cotización sin:'+cotizacion);
            Opportunity opp = [SELECT Id, StageName,SyncedQuoteId FROM opportunity WHERE Id=:cotizacion.OpportunityId WITH SECURITY_ENFORCED LIMIT 1];
            System.debug('oportunidad sin:'+opp);
            opp.StageName='Cerrada ganada';
            opp.SyncedQuoteId=cotizacion.Id;
            System.debug('Cotización a sincronizar: '+ cotizacion.Id);
            if(Opportunity.SObjectType.getDescribe().isUpdateable()) {
                update opp;   
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            } 
            
        }catch(Exception e){
            System.debug('Error al sincronizar la cotización--------->'+e.getLineNumber()+''+e.getMessage());
            
        }
    }
}