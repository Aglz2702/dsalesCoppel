//buscar moto por sku y seguro por id de partida, modificar cuando ya se tenga el servicio de la venta 
public with sharing class DSALES_QuotePagoSM {
    public static void cotizacionesNuevas(String idPago,List<String> partidasSeleccionadas,String skuMoto){
        try {
            System.debug('Entra en función 2');
            String idCotizacion='';
            List<String> listIdCotiza = new List<String>();
            List<QuoteLineItem> listPartidasCreadas = new List<QuoteLineItem>();
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Seguro__c,DSALES_Oportunidad__c,DSALES_Nombre_del_Vendedor__c,DSales_Tienda__c,DSALES_SKU__c  
                                            FROM DSALES_InformacionDePago__c 
                                            WHERE Id=:idPago];
            
            Quote beforeCot = [SELECT Id,OpportunityId,AccountId FROM Quote WHERE OpportunityId =:pago.DSALES_Oportunidad__c];
            Opportunity opty=[SELECT Id,StageName,SyncedQuoteId FROM Opportunity WHERE Id=:beforeCot.OpportunityId LIMIT 1];
            //Account cliente=[SELECT Id,Name, Tipo_de_Cliente__c,CP_WalletCustomerNumber__c,AccountNumber FROM Account WHERE Id=:beforeCot.AccountId LIMIT 1 ];
            //cliente.AccountNumber==null;
            if(pago.DSALES_Plazodecomprademoto__c==0){
                pago.DSALES_Plazodecomprademoto__c=12;
            }
            update pago;
            //if debe comprar si el campo de partidas trae un valor, es decir seguro
            if(pago.DSALES_Seguro__c==false ){ //solo compró moto   
                //crear dos cotizaciones 
                System.debug('se crea DOS');
                for(Integer i=0;i<2;i++){
                    idCotizacion=crearCotizacion(beforeCot.Id,pago.Id);
                    listIdCotiza.add(idCotizacion);
                }  
                String idCotSin=crear2CotPartidas(beforeCot.Id,listIdCotiza,Integer.valueOf(pago.DSALES_Plazodecomprademoto__c), partidasSeleccionadas,skuMoto);
                if(idCotSin!=null|| idCotSin!=''){
                    sincronizarOportunidad(idCotSin);
                }
                
            }
            else{//compro moto y seguro
                if(skuMoto!=null){
                    QuoteLineItem producto =[SELECT Id,DSALES_NombreProducto__c, DSALES_Segurogratis__c FROM QuoteLineItem  WHERE DSALES_SKU__c=:skuMoto  AND quoteId=:beforeCot.Id LIMIT 1];
                    System.debug('Nombre: '+producto.DSALES_NombreProducto__c);
                    System.debug('trae seguro gratis?: '+producto.DSALES_Segurogratis__c);
                    System.debug('////////////PARTIDAS////////: '+partidasSeleccionadas.size());
                    if(producto.DSALES_Segurogratis__c==true && partidasSeleccionadas!=null && partidasSeleccionadas.size()==1){
                        System.debug('DOS COTIZACIONES// SEGURO GRATIS');
                        for(Integer i=0;i<2;i++){
                            idCotizacion=crearCotizacion(beforeCot.Id,pago.Id);
                            listIdCotiza.add(idCotizacion);
                        } 
                        String idCotSin=crear2CotPartidas(beforeCot.Id,listIdCotiza,Integer.valueOf(pago.DSALES_Plazodecomprademoto__c), partidasSeleccionadas,skuMoto);
                        if(idCotSin!=null|| idCotSin!=''){
                            sincronizarOportunidad(idCotSin);
                        }
                    }
                    else if(producto.DSALES_Segurogratis__c==true && partidasSeleccionadas!=null && partidasSeleccionadas.size()==2){
                        //solo crear una cotizacion
                        System.debug('se crea UNA COTIZACION1');
                        idCotizacion=crearCotizacion(beforeCot.Id,pago.Id);
                        System.debug('cotizaciones creadas: '+ idCotizacion);
                        crearPartidas(beforeCot.Id,idCotizacion,partidasSeleccionadas,skuMoto);
                        if(idCotizacion!=null || idCotizacion!=''){
                            sincronizarOportunidad(idCotizacion);
                        } 
                    }
                    else if(producto.DSALES_Segurogratis__c==false){
                        //solo crear una cotizacion
                        System.debug('se crea UNA COTIZACION');
                        idCotizacion=crearCotizacion(beforeCot.Id,pago.Id);
                        System.debug('cotizaciones creadas: '+ idCotizacion);
                        crearPartidas(beforeCot.Id,idCotizacion,partidasSeleccionadas,skuMoto);
                        if(idCotizacion!=null || idCotizacion!=''){
                            sincronizarOportunidad(idCotizacion);
                        } 
                    }
                }
                
            } 
            
        } catch (Exception e) {
            System.debug('Error en método principal de cotización');
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
        }
        
    }
    
    public static String crearCotizacion(String IdCotizacion,String idPago){
        try{
            Quote beforeCot = [SELECT Id,OpportunityId,Name,DSALES_Fechadenacimiento__c,Email,DSALES_Cobertura__c,DSALES_Opcindepago__c,DSALES_Gnero__c,Phone,DSALES_Cdigopostal__c,DSALES_Fechadecomienzodepliza__c,
                            Lista_negra__c,Motivo_de_lista_negra__c,DSALES_TrakingID__c,DSALES_NombreCliente__c,DSALES_Enviarcotizacion__c,GrandTotal,Tax,DSales_Vendedor__c,ExpirationDate,DSALES_IDdelvehculo__c,
                            DSales_Tienda__c,DSALES_Plazoacotizar__c,DSALES_PlazoacotizarRC__c,DSALES_Tipodeuso__c,DSALES_RFC__c,DSALES_TipoUso__c,DSALES_Tipodeveihculo__c
                            FROM Quote WHERE Id=:IdCotizacion];
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Oportunidad__c,DSALES_Nombre_del_Vendedor__c,DSales_Tienda__c,DSALES_SKU__c  
                                            FROM DSALES_InformacionDePago__c WHERE Id=:idPago];
            Quote cotizacion = new Quote();
            cotizacion.OpportunityId=beforeCot.OpportunityId;
            cotizacion.Name=beforeCot.Name;
            cotizacion.DSALES_Fechadenacimiento__c=beforeCot.DSALES_Fechadenacimiento__c;
            cotizacion.Email=beforeCot.Email;
            cotizacion.DSALES_Cobertura__c=beforeCot.DSALES_Cobertura__c;
            cotizacion.DSALES_Opcindepago__c=beforeCot.DSALES_Opcindepago__c;
            cotizacion.DSALES_Gnero__c=beforeCot.DSALES_Gnero__c;
            cotizacion.Phone=beforeCot.Phone;
            cotizacion.DSALES_Cdigopostal__c=beforeCot.DSALES_Cdigopostal__c;
            cotizacion.DSALES_Fechadecomienzodepliza__c=beforeCot.DSALES_Fechadecomienzodepliza__c;
            cotizacion.Lista_negra__c=beforeCot.Lista_negra__c;
            cotizacion.Motivo_de_lista_negra__c=beforeCot.Motivo_de_lista_negra__c;
            cotizacion.DSALES_TrakingID__c=beforeCot.DSALES_TrakingID__c;
            if(pago.DSALES_Nombre_del_Vendedor__c!=null){
                cotizacion.DSales_Vendedor__c=pago.DSALES_Nombre_del_Vendedor__c;
            }
            cotizacion.DSales_Vendedor__c=beforeCot.DSales_Vendedor__c;
            if(pago.DSales_Tienda__c!=null){
                cotizacion.DSales_Tienda__c=pago.DSales_Tienda__c;
            }
            cotizacion.DSales_Tienda__c=beforeCot.DSales_Tienda__c;
            //cotizacion.ExpirationDate=Date.parse(cotizacion.createdDate);
            cotizacion.Tax=beforeCot.Tax;
            cotizacion.DSALES_IDdelvehculo__c=beforeCot.DSALES_IDdelvehculo__c;
            cotizacion.DSALES_Plazoacotizar__c=pago.DSALES_Plazodecomprademoto__c;
            cotizacion.DSALES_PlazoacotizarRC__c=beforeCot.DSALES_PlazoacotizarRC__c;
            cotizacion.DSALES_Tipodeuso__c=beforeCot.DSALES_Tipodeuso__c;
            cotizacion.DSALES_RFC__c=beforeCot.DSALES_RFC__c;
            cotizacion.DSALES_TipoUso__c=beforeCot.DSALES_TipoUso__c;
            cotizacion.DSALES_Tipodeveihculo__c=beforeCot.DSALES_Tipodeveihculo__c;
            cotizacion.ExpirationDate=beforeCot.ExpirationDate;
            insert cotizacion;  
            return cotizacion.Id;
        }catch(Exception e){
            System.debug('Error al crear cotización');
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            return null;
        }
    }
    
    public static void crearPartidas(String idCot,String idCotizacion,List<String> partidasSeleccionadas,String skuMoto){
        try{
            List<String> listIdProd = new List<String>();
            List<QuoteLineItem> listPartidas = new List<QuoteLineItem>();
            List<QuoteLineItem> partidas = new List<QuoteLineItem>();
            QuoteLineItem part;
            //trae la moto
            System.debug('sku:'+skuMoto);
            System.debug('partidas: '+partidasSeleccionadas);
            System.debug('cotización: '+idCot);
            
                //amp y rc al plazo indicado
                for(List<QuoteLineItem> partida: [SELECT Id,DSALES_Descripcion__c,DSALES_TrackingID__c,DSALES_Pagomensual__c,DSALES_SKU__c,DSALES_Recargos__c,QuoteId,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                                        DSALES_Gastosdeoperacindelrecibo__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                        FROM QuoteLineItem WHERE Id IN:partidasSeleccionadas
                                        ])
                {
                    partidas=partida;
                }
                if(skuMoto!=null ){
                    QuoteLineItem producto =[SELECT Id,QuoteId,DSALES_Segurogratis__c,DSALES_Descripcion__c,DSALES_Pagomensual__c,DSALES_TrackingID__c,DSALES_Comision__c,DSALES_NombreProducto__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                                DSALES_Gastosdeoperacindelrecibo__c,DSALES_Impuestos__c,DSALES_Recargos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                FROM QuoteLineItem  WHERE QuoteId=:idCot  AND DSALES_SKU__c=:skuMoto LIMIT 1]; 
                    System.debug('moto:'+producto);
                    partidas.add(producto);
                    
                }
                List<String> idsPartidasGratis= new List<String>();
                if(partidas!=null){
                    System.debug('partidas:'+partidas);
                    System.debug(' Partidas size:'+partidas.size());
                    for(QuoteLineItem q:partidas){
                        listIdProd.add(q.Product2Id);
                    }
                }
                
                List<Product2> productos = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Id IN:listIdProd ] ;
                System.debug('productos: '+productos);
                List<PricebookEntry> precios = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN:listIdProd]; 
                List<Plazo__c> plazos =[SELECT Id, Dsales_Plazo__c,DSALES_Seguro__c FROM Plazo__c WHERE  DSALES_Seguro__c=:listIdProd];
                System.debug('precios:'+precios);
                System.debug('xxxx:'+plazos);
                //moto + 2 seguros
                for(QuoteLineItem q:partidas){
                    System.debug('partida: '+ q.DSALES_NombreProducto__c);
                    System.debug('partida: '+ q.DSALES_NombreProducto__c);
                    QuoteLineItem partida = new QuoteLineItem();
                    //moto + 2 seguros
                    for(PricebookEntry pr:precios){
                        for(Plazo__c p:plazos){
                            if(pr.Name==q.DSALES_NombreProducto__c){
                                partida.QuoteId = idCotizacion; 
                                partida.PricebookEntryId = pr.Id;
                                if(partida.DSALES_Segurogratis__c!=null){
                                    partida.DSALES_Segurogratis__c=q.DSALES_Segurogratis__c;
                                }
                                partida.Product2Id = pr.Product2Id;
                                partida.Quantity = 1;
                                //partida.UnitPrice = pr.UnitPrice;
                                partida.DSALES_Fechadeinicio__c = q.DSALES_Fechadeinicio__c;
                                partida.DSALES_Fechadetermino__c = q.DSALES_Fechadetermino__c;
                                partida.DSALES_Primaneta__c = q.DSALES_Primaneta__c;
                                partida.UnitPrice = q.UnitPrice;
                                System.debug('precio del seguro: '+ partida.UnitPrice);
                                partida.DSALES_Derechosdepliza__c = q.DSALES_Derechosdepliza__c;
                                partida.DSALES_Gastosdeoperacindelrecibo__c = q.DSALES_Gastosdeoperacindelrecibo__c;
                                partida.DSALES_Impuestos__c = q.DSALES_Impuestos__c;
                                partida.DSALES_Comision__c=q.DSALES_Comision__c;
                                partida.DSALES_TrackingID__c=q.DSALES_TrackingID__c;
                                //partida.DSALES_SKU__c=q.DSALES_SKU__c;
                                partida.DSALES_Recargos__c=q.DSALES_Recargos__c;
                                partida.DSALES_Pagomensual__c=q.DSALES_Pagomensual__c;
                                partida.DSALES_Descripcion__c=q.DSALES_Descripcion__c;
                                if(p.Id==q.DSALES_Plazo__c){
                                    partida.DSALES_Plazo__c=p.Id;
                                }
                                
                                
                            } 
                        }
                        
                    }
                    listPartidas.add(partida);
                }
                System.debug('size:'+listPartidas.size());
                System.debug('partidasCreadas:'+listPartidas);
                insert listPartidas;
            List<QuoteLineItem> idNuevos = new List<QuoteLineItem>();
            List<QuoteLineItem> partidasNuevas =[SELECT Id, UnitPrice,DSALES_Tipodeproducto__c,ListPrice,DSALES_Pagomensual__c,TotalPrice,DSALES_Impuestos__c,DSALES_Recargos__c,DSALES_Derechosdepliza__c,DSALES_Primaneta__c,DSALES_Gastosdeoperacindelrecibo__c,DSALES_Plazo__c,DSALES_Segurogratis__c,DSALES_NombreProducto__c FROM QuoteLineItem WHERE Id IN:listPartidas];
            for(QuoteLineItem ql:partidasNuevas){
                for(QuoteLineItem q:partidas){
                    if(ql.DSALES_NombreProducto__c == q.DSALES_NombreProducto__c){
                        if( ql.DSALES_Plazo__c == q.DSALES_Plazo__c){
                            if(ql.DSALES_Segurogratis__c==true && ql.DSALES_Tipodeproducto__c=='Seguro'){
                                ql.UnitPrice=0;
                                ql.DSALES_Gastosdeoperacindelrecibo__c=0;
                                ql.DSALES_Primaneta__c=0;
                                ql.DSALES_Derechosdepliza__c=0;
                                ql.DSALES_Comision__c=0;
                                ql.DSALES_Recargos__c=0;
                                //ql.ListPrice=0;
                                ql.DSALES_Impuestos__c=0;
                                //ql.TotalPrice=0;
                                ql.DSALES_Pagomensual__c=0;
                            }
                            else{
                                ql.UnitPrice=q.UnitPrice;
                            }
                            idNuevos.add(ql);
                        }
                    }
                    
                    
                }
            
            }
            update idNuevos;
        }catch(Exception e){
            System.debug('Error al crear una partida de presupuesto');
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
        }

    } 
    public static String crear2CotPartidas(String idCot,List<String> listCotNew,Integer plazo,List<String> partidasSeleccionadas,String skuMoto){
        try{
            System.debug('lista de new cotiza: '+ listCotNew.size());
            List<String> listIdProd = new List<String>();
            List<QuoteLineItem> listPartidas = new List<QuoteLineItem>();
            List<QuoteLineItem> listSeguros = new List<QuoteLineItem>();
            List<QuoteLineItem> listPartInsert = new List<QuoteLineItem>();
            List<QuoteLineItem> listPartInsertSeg = new List<QuoteLineItem>();
            List<QuoteLineItem> listMotoRc = new List<QuoteLineItem>();
            List<QuoteLineItem> listaMotoSeguro = new List<QuoteLineItem>();
            //QuoteLineItem partidas ;
            QuoteLineItem seguro = new QuoteLineItem();
            QuoteLineItem seguroGratis = new QuoteLineItem();
            String idCotSincronizar='';
            
            //trae la moto
            QuoteLineItem producto =[SELECT Id,QuoteId,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Pagomensual__c,DSALES_Segurogratis__c,DSALES_Comision__c,DSALES_NombreProducto__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                                    DSALES_Gastosdeoperacindelrecibo__c,DSALES_Recargos__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                    FROM QuoteLineItem  WHERE QuoteId=:idCot  AND DSALES_SKU__c=:skuMoto LIMIT 1]; 
            System.debug('moto:'+producto);
            if(producto!=null){
                if(producto.DSALES_Segurogratis__c==true){
                    for(QuoteLineItem partida: [SELECT Id,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Pagomensual__c,DSALES_SKU__c,QuoteId,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                                        DSALES_Gastosdeoperacindelrecibo__c,DSALES_Recargos__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                        FROM QuoteLineItem WHERE Id IN:partidasSeleccionadas LIMIT 1
                                        ])
                    {
                        seguroGratis=partida; //SOLO ID DE RC

                        //listMotoRc.add(partida);
                    }
                    seguro=[SELECT Id,QuoteId,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Pagomensual__c,DSALES_Recargos__c,DSALES_SKU__c,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                                DSALES_Gastosdeoperacindelrecibo__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                FROM QuoteLineItem WHERE QuoteId=:idCot AND DSALES_Segurogratis__c!=true AND DSALES_Plazo__r.Dsales_Plazo__c =:String.valueOf(plazo) AND Id!=:seguroGratis.Id LIMIT 1
                                ];
                    System.debug('seguro amp:'+seguro);
                    System.debug('seguro RC gratis:'+seguroGratis);
                    listPartidas.add(producto);
                    listMotoRc.add(producto);
                    listaMotoSeguro.add(producto);
                    if(seguroGratis!=null){
                        listPartidas.add(seguroGratis);
                        listMotoRc.add(seguroGratis);
                    }
                    if(seguro!=null){
                        listPartidas.add(seguro);
                        listaMotoSeguro.add(seguro);    
                    }
                   
                    System.debug('listMotoRc:'+listMotoRc.size());
                    System.debug('Lista completa:'+listPartidas.size());
                    for(QuoteLineItem q:listPartidas){
                        //listIdPartidas.add(q.Id);
                        listIdProd.add(q.Product2Id);
                    }
                    List<Product2> productos = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Id IN:listIdProd ] ;
                    System.debug('productos: '+productos);
                    List<PricebookEntry> precios = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN:listIdProd]; 
                    List<Plazo__c> plazos =[SELECT Id, Dsales_Plazo__c,DSALES_Seguro__c FROM Plazo__c WHERE  DSALES_Seguro__c=:listIdProd];
                    System.debug('precios:'+precios);
                    System.debug('xxxx:'+plazos);
                    List<QuoteLineItem> listaMotoSeguroToInsert = new List<QuoteLineItem>();
                    for(QuoteLineItem ql:listaMotoSeguro){
                        QuoteLineItem partida = new QuoteLineItem();
                        partida.QuoteId = listCotNew[0]; 
                        for(PricebookEntry pr:precios){
                            if(pr.Name==ql.DSALES_NombreProducto__c){
                                partida.PricebookEntryId = pr.Id;
                                partida.Product2Id = pr.Product2Id;
                                partida.UnitPrice = pr.UnitPrice;
                                //partida.TotalPrice=pr.TotalPrice;
                            }
                        }
                        if(ql.DSALES_Segurogratis__c!=null){
                            partida.DSALES_Segurogratis__c=ql.DSALES_Segurogratis__c;
                        }
                        partida.Quantity = 1;
                        partida.DSALES_Fechadeinicio__c = ql.DSALES_Fechadeinicio__c;
                        partida.DSALES_Fechadetermino__c = ql.DSALES_Fechadetermino__c;
                        partida.DSALES_Primaneta__c = ql.DSALES_Primaneta__c;
                        partida.UnitPrice = ql.UnitPrice;
                        partida.DSALES_Derechosdepliza__c = ql.DSALES_Derechosdepliza__c;
                        partida.DSALES_Gastosdeoperacindelrecibo__c = ql.DSALES_Gastosdeoperacindelrecibo__c;
                        partida.DSALES_Impuestos__c = ql.DSALES_Impuestos__c;
                        partida.DSALES_Comision__c=ql.DSALES_Comision__c;
                        partida.DSALES_TrackingID__c=ql.DSALES_TrackingID__c;
                        //partida.DSALES_SKU__c=seguro.DSALES_SKU__c;
                        partida.DSALES_Recargos__c=ql.DSALES_Recargos__c;
                        partida.DSALES_Pagomensual__c=ql.DSALES_Pagomensual__c;
                        partida.DSALES_Descripcion__c=ql.DSALES_Descripcion__c;
                        for(Plazo__c p:plazos){
                            if(ql.DSALES_Plazo__c!=null && p.Id== ql.DSALES_Plazo__c){
                                partida.DSALES_Plazo__c=ql.Dsales_Plazo__c;
                            }
                        }
                        listaMotoSeguroToInsert.add(partida);
                        System.debug('partida to email:'+partida);
                    }
                    //System.debug('partida: '+partida);
                    System.debug('Lista de listaMotoSeguroToInsert: '+listaMotoSeguroToInsert.size());
                    System.debug('Lista de listaMotoSeguroToInsert: '+listaMotoSeguroToInsert);
                    Quote cotizacionEnviar=[SELECT Id,DSALES_Enviarcotizacion__c FROM Quote WHERE Id=:listaMotoSeguroToInsert[0].QuoteId LIMIT 1];
                    cotizacionEnviar.DSALES_Enviarcotizacion__c=true;
                    update cotizacionEnviar;
                    for(QuoteLineItem q:listMotoRc){
                        //if( q.DSALES_Tipodeproducto__c=='Seguro'){
                            QuoteLineItem part = new QuoteLineItem();
                            for(PricebookEntry pr:precios){
                                if(pr.Name==q.DSALES_NombreProducto__c){
                                    part.QuoteId = listCotNew[1]; 
                                    part.PricebookEntryId = pr.Id;
                                    part.UnitPrice=pr.UnitPrice;
                                    if(part.DSALES_Segurogratis__c!=null){
                                        part.DSALES_Segurogratis__c=q.DSALES_Segurogratis__c;
                                    }
                                    part.Quantity = 1;
                                    part.DSALES_Fechadeinicio__c = q.DSALES_Fechadeinicio__c;
                                    part.DSALES_Fechadetermino__c = q.DSALES_Fechadetermino__c;
                                    part.DSALES_Primaneta__c = q.DSALES_Primaneta__c;
                                    //partida.UnitPrice = q.UnitPrice;
                                    part.DSALES_Derechosdepliza__c = q.DSALES_Derechosdepliza__c;
                                    part.DSALES_Gastosdeoperacindelrecibo__c = q.DSALES_Gastosdeoperacindelrecibo__c;
                                    part.DSALES_Impuestos__c = q.DSALES_Impuestos__c;
                                    part.DSALES_TrackingID__c=q.DSALES_TrackingID__c;
                                    part.DSALES_Comision__c=q.DSALES_Comision__c;
                                    //part.DSALES_SKU__c=q.DSALES_SKU__c;
                                    part.DSALES_Recargos__c=q.DSALES_Recargos__c;
                                    part.DSALES_Descripcion__c=q.DSALES_Descripcion__c;
                                    part.DSALES_Pagomensual__c=q.DSALES_Pagomensual__c;
                                    for(Plazo__c p:plazos){
                                        if(q.DSALES_Plazo__c!=null && p.Id== q.DSALES_Plazo__c){
                                            part.DSALES_Plazo__c=q.Dsales_Plazo__c;
                                        }
                                    
                                    }
                                }   
                            }
                            listPartInsert.add(part); 
                        //}     
                    }
                    System.debug('listPartInsert:'+listPartInsert.size());
                    System.debug('listPartInsert:'+listPartInsert);
                    try{
                        insert listaMotoSeguroToInsert;
                        insert listPartInsert;

                        Quote cotizacion =[SELECT Id,DSALES_Enviarcotizacion__c FROM Quote WHERE Id=:listCotNew[0] LIMIT 1];
                        if(cotizacion!=null){
                            cotizacion.DSALES_Enviarcotizacion__c=true;
                        }
                    }catch(Exception e){
                        System.debug('Error al insertar:\n'+e.getMessage());
                    }
                    
                    List<QuoteLineItem> idNuevos = new List<QuoteLineItem>();
                    List<QuoteLineItem> partidasNuevas =[SELECT Id,DSALES_Tipodeproducto__c,DSALES_Impuestos__c,DSALES_Pagomensual__c,DSALES_Recargos__c,DSALES_Comision__c,
                            DSALES_Derechosdepliza__c, UnitPrice,DSALES_Gastosdeoperacindelrecibo__c,DSALES_Primaneta__c,DSALES_Plazo__c,DSALES_NombreProducto__c,DSALES_Segurogratis__c 
                            FROM QuoteLineItem WHERE Id IN:listPartInsert];
                    System.debug('nuevas:'+partidasNuevas.size());
                    for(QuoteLineItem ql:partidasNuevas){
                        for(QuoteLineItem q:listMotoRc){
                            if( ql.DSALES_Plazo__c == q.DSALES_Plazo__c){
                                if(ql.DSALES_Segurogratis__c==true && ql.DSALES_Tipodeproducto__c=='Seguro'){
                                    ql.UnitPrice=0;
                                    ql.DSALES_Gastosdeoperacindelrecibo__c=0;
                                    ql.DSALES_Primaneta__c=0;
                                    ql.DSALES_Derechosdepliza__c=0;
                                    ql.DSALES_Comision__c=0;
                                    ql.DSALES_Recargos__c=0;
                                    //ql.ListPrice=0;
                                    ql.DSALES_Impuestos__c=0;
                                    //ql.TotalPrice=0;
                                    ql.DSALES_Pagomensual__c=0;
                                
                                }else{
                                    ql.UnitPrice=q.UnitPrice;
                                }  
                            }
                        }
                        idNuevos.add(ql);
                            System.debug('ID X:'+ql.DSALES_NombreProducto__c);
                    }
                    System.debug('rc gratis:'+idNuevos);
                    update idNuevos;
                    System.debug('idCotizacion actu:'+listPartInsert[0].QuoteId);
                    idCotSincronizar= listPartInsert[0].QuoteId;
                }
                else{ // no aplica seguro gratis
                    listSeguros=[SELECT Id,QuoteId,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Recargos__c,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,Dsales_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                                DSALES_Gastosdeoperacindelrecibo__c,DSALES_Pagomensual__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                FROM QuoteLineItem WHERE  QuoteId=:idCot AND DSALES_Tipodeproducto__c='Seguro' AND DSALES_Plazo__r.Dsales_Plazo__c =:String.valueOf(plazo) ];
                    System.debug('Seguro con plazo correcto:'+listSeguros);
                    System.debug('Seguro size:'+listSeguros.size());
                    if(listSeguros!=null && listSeguros.size()==1){
                        seguro=[SELECT Id,QuoteId,DSALES_Plazo__r.Dsales_Plazo__c,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Recargos__c,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,Dsales_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                                DSALES_Gastosdeoperacindelrecibo__c,DSALES_Pagomensual__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                FROM QuoteLineItem WHERE  QuoteId=:idCot AND DSALES_Tipodeproducto__c='Seguro' AND DSALES_NombreProducto__c=:'RC Seguro de Moto' ORDER BY DSALES_Plazo__r.Dsales_Plazo__c DESC LIMIT 1]; 
                        listSeguros.add(seguro);
                        System.debug('Seguros:'+listSeguros);
                        System.debug('Dos seguros:'+ listSeguros.size());
                    }
                    listPartidas=listSeguros;
                    listPartidas.add(producto);
                    System.debug('listPartidas fin:'+listPartidas);
                    System.debug('size listPartidas: '+listPartidas.size());
                    for(QuoteLineItem q:listPartidas){
                        //listIdPartidas.add(q.Id);
                        listIdProd.add(q.Product2Id);
                    }
                    List<Product2> productos = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Id IN:listIdProd ] ;
                    System.debug('productos: '+productos);
                    List<PricebookEntry> precios = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN:listIdProd]; 
                    List<Plazo__c> plazos =[SELECT Id, Dsales_Plazo__c,DSALES_Seguro__c FROM Plazo__c WHERE  DSALES_Seguro__c=:listIdProd];
                    System.debug('precios:'+precios);
                    System.debug('xxxx:'+plazos);
                    QuoteLineItem partida = new QuoteLineItem();
                    partida.QuoteId = listCotNew[0]; 
                    for(PricebookEntry pr:precios){
                        if(pr.Name==producto.DSALES_NombreProducto__c){
                            partida.PricebookEntryId = pr.Id;
                            partida.Product2Id = pr.Product2Id;
                            partida.UnitPrice = pr.UnitPrice;
                            //partida.TotalPrice=pr.TotalPrice;
                        }
                    }
                    if(producto.DSALES_Segurogratis__c!=null){
                        partida.DSALES_Segurogratis__c=producto.DSALES_Segurogratis__c;
                    }
                    partida.Quantity = 1;
                    partida.DSALES_Fechadeinicio__c = producto.DSALES_Fechadeinicio__c;
                    partida.DSALES_Fechadetermino__c = producto.DSALES_Fechadetermino__c;
                    partida.DSALES_Primaneta__c = producto.DSALES_Primaneta__c;
                    partida.UnitPrice = producto.UnitPrice;
                    partida.DSALES_Derechosdepliza__c = producto.DSALES_Derechosdepliza__c;
                    partida.DSALES_Gastosdeoperacindelrecibo__c = producto.DSALES_Gastosdeoperacindelrecibo__c;
                    partida.DSALES_Impuestos__c = producto.DSALES_Impuestos__c;
                    partida.DSALES_Comision__c=producto.DSALES_Comision__c;
                    partida.DSALES_TrackingID__c=producto.DSALES_TrackingID__c;
                    partida.DSALES_Recargos__c=producto.DSALES_Recargos__c;
                    partida.DSALES_Pagomensual__c=producto.DSALES_Pagomensual__c;
                    partida.DSALES_Descripcion__c=producto.DSALES_Descripcion__c;
                    if( producto.DSALES_Plazo__c!=null && producto.Id==producto.DSALES_Plazo__c){
                        partida.DSALES_Plazo__c=producto.Dsales_Plazo__c;
                    }
                    System.debug('partida: '+partida);
                    insert partida;
                    //crear cotización 2 seguros y enviarla
                    for(QuoteLineItem q:listPartidas){
                        //if( q.DSALES_Tipodeproducto__c=='Seguro'){
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
                                        partida.UnitPrice = q.UnitPrice;
                                        System.debug('precio de seguro:'+partida.UnitPrice);
                                        part.DSALES_Derechosdepliza__c = q.DSALES_Derechosdepliza__c;
                                        part.DSALES_Gastosdeoperacindelrecibo__c = q.DSALES_Gastosdeoperacindelrecibo__c;
                                        part.DSALES_Impuestos__c = q.DSALES_Impuestos__c;
                                        part.DSALES_TrackingID__c=q.DSALES_TrackingID__c;
                                        part.DSALES_Recargos__c=q.DSALES_Recargos__c;
                                        part.DSALES_Pagomensual__c=q.DSALES_Pagomensual__c;
                                        part.DSALES_Descripcion__c=q.DSALES_Descripcion__c;
                                        if(q.DSALES_Plazo__c!=null && p.Id== q.DSALES_Plazo__c){
                                            part.DSALES_Plazo__c=q.Dsales_Plazo__c;
                                        }
                                    }
                                }   
                            }
                            listPartInsert.add(part); 
                    // }     
                    }
                    System.debug('partidas seg+ rc3:'+listPartInsert.size());

                    insert listPartInsert;
                    Quote cotizacionEnviar=[SELECT Id,DSALES_Enviarcotizacion__c FROM Quote WHERE Id=:listPartInsert[0].QuoteId LIMIT 1];
                    cotizacionEnviar.DSALES_Enviarcotizacion__c=true;
                    update cotizacionEnviar;
                    List<QuoteLineItem> idNuevos = new List<QuoteLineItem>();
                    List<QuoteLineItem> partidasNuevas =[SELECT Id, UnitPrice,DSALES_Plazo__c,DSALES_NombreProducto__c FROM QuoteLineItem WHERE Id IN:listPartInsert];
                    for(QuoteLineItem ql:partidasNuevas){
                        for(QuoteLineItem q:listPartidas){
                            if(ql.DSALES_NombreProducto__c == q.DSALES_NombreProducto__c){
                                if( ql.DSALES_Plazo__c == q.DSALES_Plazo__c){
                                    ql.UnitPrice=q.UnitPrice;
                                }
                            }  
                        }
                        idNuevos.add(ql);
                    }
                    update idNuevos;
                    idCotSincronizar= partida.QuoteId;
                }
                //return idCotSincronizar;
            }
            return idCotSincronizar;
        }catch(Exception e ){
            System.debug('Error al crear dos partidas de presupuesto');
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            return null;
        }
    }

    /*public static void enviarCotizacion(){
        String queryOpp = 'SELECT Id FROM Opportunity WHERE RecordType.DeveloperName =\'' + 'Seguro_de_Moto' + '\'';
        List<Opportunity>consultaOpp=DataBase.query(queryOpp);
        System.debug('Oportunidades tam: '+ consultaOpp.size());
        List<String> listOpp = new List<String>();
        List<String> idsOpp = new List<String>();
        Map<Id,List<DSALES_InformacionDePago__c> > mapaPagos = new Map<Id,List<DSALES_InformacionDePago__c> >();
        for(DSALES_InformacionDePago__c item:[SELECT Id,DSALES_Oportunidad__c,DSALES_Motosinseguro__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c  =: consultaOpp ]){
            List<DSALES_InformacionDePago__c> pagos= new List<DSALES_InformacionDePago__c>();
            if(mapaPagos.containsKey(item.DSALES_Oportunidad__c)){
                pagos=mapaPagos.get(item.DSALES_Oportunidad__c);     
            }
            pagos.add(item);
            mapaPagos.put(item.DSALES_Oportunidad__c,pagos);
        }
        System.debug('datos en el mapa: '+mapaPagos);
        ///
        
        System.debug('oppty recibidos: '+consultaOpp);
        System.debug('mapa pagos recibidos: '+ mapaPagos);
        for(Opportunity op: consultaOpp){
            System.debug('Opportunity: '+ op.Id);
            List<DSALES_InformacionDePago__c> pagos=mapaPagos.get(op.Id);
            System.debug('listPagosM:'+pagos);
            if( pagos!=null &&  pagos.size()>0 ){
                System.debug('Pagos x Opp');
                for(DSALES_InformacionDePago__c p:pagos){
                    if(p.DSALES_Motosinseguro__c==true){
                        System.debug('for p:'+pagos);
                        listOpp.add(op.Id);
                    }
                    
                }
                
                
            }
            else{
                System.debug('Solo hay un pago');
            }
        }
        System.debug('Opp sin pago de seguro:'+ listOpp);
        ///
        String query = 'SELECT Id,QuoteNumber,DSALES_Enviarcotizacion__c FROM Quote WHERE OpportunityId =:  listOpp ';
        List<Quote> consulta = DataBase.query(query);
        System.debug('Cotizaciones query: '+ consulta.size());
        List<Quote> listActualizarCot = new List<Quote>();
        System.debug('Cotizaciones:'+consulta);
        String idCotSeguro='';
        Map<Id,List<QuoteLineItem> > mapaQuoteLine = new Map<Id,List<QuoteLineItem> >();
        for(QuoteLineItem item:
            [SELECT Id,QuoteId,DSALES_NombreProducto__c,DSALES_Plazo__r.Dsales_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
            DSALES_Gastosdeoperacindelrecibo__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
            FROM QuoteLineItem WHERE  QuoteId =:consulta  AND DSALES_Tipodeproducto__c='Seguro']){
                List<QuoteLineItem> partidas= new List<QuoteLineItem>();
                if(mapaQuoteLine.containsKey(item.QuoteId)){
                     partidas=mapaQuoteLine.get(item.QuoteId);  
                }
                partidas.add(item);
                mapaQuoteLine.put(item.QuoteId,partidas);
        }
        for(Quote q: consulta){
            List<QuoteLineItem> partidas=mapaQuoteLine.get(q.Id);
            if(q.DSALES_Enviarcotizacion__c==false && partidas!=null &&  partidas.size()==2 ){
                System.debug('Cotización: '+ q.QuoteNumber);
                System.debug('Cotización: '+ q.Id);
                q.DSALES_Enviarcotizacion__c=true;
                idCotSeguro=q.Id;
                listActualizarCot.add(q);
            }
            else{
                System.debug('No es la cotización de seguros');
            }
        }
        System.debug('Cotizaciones para actualizar:'+listActualizarCot);
        if(listActualizarCot!=null){
            update listActualizarCot;
        }

        
    }*/
    
    public static void sincronizarOportunidad(String quoteId){
        try{
            System.debug('sincronza la cotización con oportunidad');
            Quote cotizacion = [SELECT Id,OpportunityId,DSALES_Enviarcotizacion__c FROM Quote WHERE Id= :quoteId LIMIT 1];
            System.debug('cotización sin:'+cotizacion);
            Opportunity opp = [SELECT Id, StageName,SyncedQuoteId FROM opportunity WHERE Id=:cotizacion.OpportunityId LIMIT 1];
            System.debug('oportunidad sin:'+opp);
            opp.StageName='Cerrada ganada';
            opp.SyncedQuoteId=cotizacion.Id;
            System.debug('Cotización a sincronizar: '+ cotizacion.Id);
            //cotizacion.DSALES_Enviarcotizacion__c=true;
            update opp;
            //update cotizacion; 
        }catch(Exception e){
            System.debug('Error al sincronizar la cotización');
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
        }
    }
}