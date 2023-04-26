/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 04-24-2023
 * @last modified by  : Juan Antonio Flores
 * Modifications Log 
 * Ver   Date          Author             Modification
 * 1.0   04-24-2023                       Initial Version
**/

public with sharing class DSALES_QuotePagoSM { 

    private static final  String RC_GRATIS='RC';

    /////////////****------ 1 -----------****///////////////
    public static void cotizacionesNuevas(String idPago, List<String> partidasSeleccionadas, String skuMoto){
        try {
            String idCotizacion='';
            List<String> listIdCotiza = new List<String>();
            List<QuoteLineItem> listPartidasCreadas = new List<QuoteLineItem>();
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Seguro__c,DSALES_Oportunidad__c,DSALES_Nombre_del_Vendedor__c,DSales_Tienda__c,DSALES_SKU__c  
                                            FROM DSALES_InformacionDePago__c 
                                            WHERE Id=:idPago WITH SECURITY_ENFORCED];
            
            Quote beforeCot = [SELECT Id,OpportunityId,AccountId FROM Quote WHERE OpportunityId =:pago.DSALES_Oportunidad__c WITH SECURITY_ENFORCED];
            Opportunity opty=[SELECT Id,StageName,SyncedQuoteId FROM Opportunity WHERE Id=:beforeCot.OpportunityId WITH SECURITY_ENFORCED LIMIT 1];
            if(pago.DSALES_Plazodecomprademoto__c==0){
                pago.DSALES_Plazodecomprademoto__c=12;
            }
            else if(DSALES_InformacionDePago__c.SObjectType.getDescribe().isUpdateable()) {
                update pago;
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            } 
            if(pago.DSALES_Seguro__c==false ){ //solo compró moto   
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
                DSALES_QuotePagoSMHelper.crearCotizacionesNuevas(idPago, partidasSeleccionadas, skuMoto);
                /*if(skuMoto!=null){
                    QuoteLineItem producto =[SELECT Id,DSALES_NombreProducto__c, DSALES_Segurogratis__c FROM QuoteLineItem  WHERE DSALES_SKU__c=:skuMoto  AND quoteId=:beforeCot.Id WITH SECURITY_ENFORCED LIMIT 1];
                    if(producto.DSALES_Segurogratis__c==true && partidasSeleccionadas!=null && partidasSeleccionadas.size()==1){
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
                        idCotizacion=crearCotizacion(beforeCot.Id,pago.Id);
                        crearPartidas(beforeCot.Id,idCotizacion,partidasSeleccionadas,skuMoto);
                        if(idCotizacion!=null || idCotizacion!=''){
                            sincronizarOportunidad(idCotizacion);
                        } 
                    }
                    else if(producto.DSALES_Segurogratis__c==false){
                        //solo crear una cotizacion
                        idCotizacion=crearCotizacion(beforeCot.Id,pago.Id);
                        crearPartidas(beforeCot.Id,idCotizacion,partidasSeleccionadas,skuMoto);
                        if(idCotizacion!=null || idCotizacion!=''){
                            sincronizarOportunidad(idCotizacion);
                        } 
                    }
                }
                else{
                        idCotizacion=crearCotizacion(beforeCot.Id,pago.Id);
                        crearPartidas(beforeCot.Id,idCotizacion,partidasSeleccionadas,skuMoto);
                        if(idCotizacion!=null || idCotizacion!=''){
                            sincronizarOportunidad(idCotizacion);
                        } 
            }*/
        }   
        } catch (Exception e) {
            System.debug('Error en método principal de cotización');
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
        }   
    }
    

    /////////////****------ 2 -----------****///////////////
    public static String crearCotizacion(String idCotizacion,String idPago){
        try{
            Quote beforeCot = [SELECT Id,OpportunityId,Name,DSALES_Fechadenacimiento__c,Email,DSALES_Cobertura__c,DSALES_Opcindepago__c,DSALES_Gnero__c,Phone,DSALES_Cdigopostal__c,DSALES_Fechadecomienzodepliza__c,
                            Lista_negra__c,Motivo_de_lista_negra__c,DSALES_TrakingID__c,DSALES_NombreCliente__c,DSALES_Enviarcotizacion__c,GrandTotal,Tax,DSales_Vendedor__c,ExpirationDate,DSALES_IDdelvehculo__c,
                            DSales_Tienda__c,DSALES_Plazoacotizar__c,DSALES_PlazoacotizarRC__c,DSALES_Tipodeuso__c,DSALES_RFC__c,DSALES_TipoUso__c,DSALES_Tipodeveihculo__c
                            FROM Quote WHERE Id=:idCotizacion WITH SECURITY_ENFORCED];
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Oportunidad__c,DSALES_Nombre_del_Vendedor__c,DSales_Tienda__c,DSALES_SKU__c  
                                            FROM DSALES_InformacionDePago__c WHERE Id=:idPago WITH SECURITY_ENFORCED];
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
            cotizacion.Tax=beforeCot.Tax;
            cotizacion.DSALES_IDdelvehculo__c=beforeCot.DSALES_IDdelvehculo__c;
            cotizacion.DSALES_Plazoacotizar__c=pago.DSALES_Plazodecomprademoto__c;
            cotizacion.DSALES_PlazoacotizarRC__c=beforeCot.DSALES_PlazoacotizarRC__c;
            cotizacion.DSALES_Tipodeuso__c=beforeCot.DSALES_Tipodeuso__c;
            cotizacion.DSALES_RFC__c=beforeCot.DSALES_RFC__c;
            cotizacion.DSALES_TipoUso__c=beforeCot.DSALES_TipoUso__c;
            cotizacion.DSALES_Tipodeveihculo__c=beforeCot.DSALES_Tipodeveihculo__c;
            cotizacion.ExpirationDate=beforeCot.ExpirationDate;
            if(Schema.sObjectType.Quote.isCreateable()) {
                insert cotizacion;  
            }else{
                System.debug('Permisos insuficientes para insertar');
            }
            return cotizacion.Id;
        }catch(Exception e){
            System.debug('Error al crear cotización');
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            return null;
        }
    }

    /////////////****------ 3 ----------****///////////////
    public static void crearPartidas(Map<String, String> cotizaciones,List<String> partidasSeleccionadas, String skuMoto){
        try{
            String idCot=(String)cotizaciones.get('beCot');
            String idCotizacion=(String)cotizaciones.get('cot');
            List<String> listIdProd = new List<String>();
            List<QuoteLineItem> listPartidas = new List<QuoteLineItem>();
            List<QuoteLineItem> partidas = new List<QuoteLineItem>();
            QuoteLineItem part;
            //trae la moto
            //amp y rc al plazo indicado
            for(List<QuoteLineItem> partida: [SELECT Id,DSALES_Descripcion__c,DSALES_TrackingID__c,DSALES_Pagomensual__c,DSALES_SKU__c,DSALES_Recargos__c,QuoteId,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                                    DSALES_Gastosdeoperacindelrecibo__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                    FROM QuoteLineItem WHERE Id IN:partidasSeleccionadas
                                    WITH SECURITY_ENFORCED])
            {
                partidas=partida;
            }
            if(skuMoto!=null ){
                QuoteLineItem producto =[SELECT Id,QuoteId,DSALES_Segurogratis__c,DSALES_Descripcion__c,DSALES_Pagomensual__c,DSALES_TrackingID__c,DSALES_Comision__c,DSALES_NombreProducto__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                            DSALES_Gastosdeoperacindelrecibo__c,DSALES_Impuestos__c,DSALES_Recargos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                            FROM QuoteLineItem  WHERE QuoteId=:idCot  AND DSALES_SKU__c=:skuMoto WITH SECURITY_ENFORCED LIMIT 1]; 
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
            List<Product2> productos = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Id IN:listIdProd  WITH SECURITY_ENFORCED] ;
            List<PricebookEntry> precios = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN:listIdProd WITH SECURITY_ENFORCED]; 
            List<Plazo__c> plazos =[SELECT Id, Dsales_Plazo__c,DSALES_Seguro__c FROM Plazo__c WHERE  DSALES_Seguro__c=:listIdProd WITH SECURITY_ENFORCED];
            //moto + 2 seguros
            WrapperListaPartidas listaPrueba = new WrapperListaPartidas();
            listaPrueba.partidas=partidas;
            listaPrueba.plazos=plazos;
            listaPrueba.precios=precios;
            //listPartidas=mapeoPartidas(listaPrueba,idCotizacion);
            if(Schema.sObjectType.QuoteLineItem.isCreateable()) {
                insert listPartidas;
            }else{
                System.debug('Permisos insuficientes para insertar');
            }
            List<QuoteLineItem> idNuevos = new List<QuoteLineItem>();
            List<QuoteLineItem> partidasNuevas =[SELECT Id, UnitPrice,DSALES_Tipodeproducto__c,ListPrice,DSALES_Pagomensual__c,TotalPrice,DSALES_Impuestos__c,DSALES_Recargos__c,DSALES_Derechosdepliza__c,DSALES_Primaneta__c,DSALES_Gastosdeoperacindelrecibo__c,DSALES_Plazo__c,DSALES_Segurogratis__c,DSALES_NombreProducto__c FROM QuoteLineItem WHERE Id IN:listPartidas WITH SECURITY_ENFORCED];
            for(QuoteLineItem ql:partidasNuevas){
                for(QuoteLineItem q:partidas){
                    /*if(ql.DSALES_NombreProducto__c == q.DSALES_NombreProducto__c){
                        if( ql.DSALES_Plazo__c == q.DSALES_Plazo__c){
                            if(ql.DSALES_Segurogratis__c==true && ql.DSALES_Tipodeproducto__c=='Seguro'){
                                ql.UnitPrice=0;
                                ql.DSALES_Gastosdeoperacindelrecibo__c=0;
                                ql.DSALES_Primaneta__c=0;
                                ql.DSALES_Derechosdepliza__c=0;
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
                    } */
                    idNuevos.add(DSALES_QuotePagoSMHelper.llenarPartida(ql,q));
                }
            }
            if(QuoteLineItem.SObjectType.getDescribe().isUpdateable()) {
                update idNuevos;   
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            }
        }catch(Exception e){
            System.debug('Error al crear una partida de presupuesto');
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
        }

    } 
 
     
    /////////////****------ 4 -----------****///////////////
    /*private static List<QuoteLineItem> mapeoPartidas(WrapperListaPartidas listaPrueba,String idCotizacion){
        List<QuoteLineItem> listPartidas = new List<QuoteLineItem>();
        for(QuoteLineItem q:listaPrueba.partidas){
            QuoteLineItem partida = new QuoteLineItem();
            WrapperPartidas prueba = new WrapperPartidas();
            //moto + 2 seguros
            for(PricebookEntry pr:listaPrueba.precios){
                for(Plazo__c p:listaPrueba.plazos){
                    if(pr.Name==q.DSALES_NombreProducto__c){
                        partida.QuoteId = idCotizacion; 
                        partida.PricebookEntryId = pr.Id;
                        prueba.nuevaPartida=partida;
                        prueba.q=q;
                        prueba pr=pr;
                        prueba.p=p;
                        QuoteLineItem resultado =asignacionCampos(prueba);
                        
                    } 
                }
            }
            listPartidas.add(resultado);
        }
        return listPartidas;
    } */

    /*private static QuoteLineItem asignacionCampos(WrapperPartidas prueba){
        //QuoteLineItem partida = new QuoteLineItem();
    // if(prueba.partida.DSALES_Segurogratis__c!=null){
            ///prueba.partida.DSALES_Segurogratis__c=prueba.q.DSALES_Segurogratis__c;
        //}
        nuevaPartida.Product2Id =prueba.pr.Product2Id;
        nuevaPartida.Quantity = 1;
        nuevaPartida.DSALES_Fechadeinicio__c = prueba.q.DSALES_Fechadeinicio__c;
        nuevaPartida.DSALES_Fechadetermino__c = prueba.q.DSALES_Fechadetermino__c;
        nuevaPartida.DSALES_Primaneta__c = prueba.q.DSALES_Primaneta__c;
        nuevaPartida.UnitPrice = prueba.q.UnitPrice;
        nuevaPartida.DSALES_Derechosdepliza__c = prueba.q.DSALES_Derechosdepliza__c;
        nuevaPartida.DSALES_Gastosdeoperacindelrecibo__c = prueba.q.DSALES_Gastosdeoperacindelrecibo__c;
        nuevaPartida.DSALES_Impuestos__c = prueba.q.DSALES_Impuestos__c;
        nuevaPartida.DSALES_Comision__c=prueba.q.DSALES_Comision__c;
        nuevaPartida.DSALES_TrackingID__c=prueba.q.DSALES_TrackingID__c;
        nuevaPartida.DSALES_Recargos__c=prueba.q.DSALES_Recargos__c;
        nuevaPartida.DSALES_Pagomensual__c=prueba.q.DSALES_Pagomensual__c;
        nuevaPartida.DSALES_Descripcion__c=prueba.q.DSALES_Descripcion__c;
        if(prueba.p.Id==prueba.q.DSALES_Plazo__c){
            nuevaPartida.DSALES_Plazo__c=prueba.p.Id;
        }
        return nuevaPartida;
    }*/

    /////////////****------ 5 -----------****///////////////
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
                                    FROM QuoteLineItem  WHERE QuoteId=:idCot  AND DSALES_SKU__c=:skuMoto WITH SECURITY_ENFORCED LIMIT 1]; 
            System.debug('moto:'+producto);
            if(producto!=null){
                if(producto.DSALES_Segurogratis__c==true){
                    for(QuoteLineItem partida: [SELECT Id,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Pagomensual__c,DSALES_SKU__c,QuoteId,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                                        DSALES_Gastosdeoperacindelrecibo__c,DSALES_Recargos__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                        FROM QuoteLineItem WHERE Id IN:partidasSeleccionadas WITH SECURITY_ENFORCED LIMIT 1
                                        ])
                    {
                        seguroGratis=partida; //SOLO ID DE RC    
                    }
                    seguro=[SELECT Id,QuoteId,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Pagomensual__c,DSALES_Recargos__c,DSALES_SKU__c,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,DSALES_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                                DSALES_Gastosdeoperacindelrecibo__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                FROM QuoteLineItem WHERE QuoteId=:idCot AND DSALES_Segurogratis__c!=true AND DSALES_Plazo__r.Dsales_Plazo__c =:String.valueOf(plazo) AND Id!=:seguroGratis.Id WITH SECURITY_ENFORCED LIMIT 1
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
                        listIdProd.add(q.Product2Id);
                    }
                    List<Product2> productos = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Id IN:listIdProd WITH SECURITY_ENFORCED] ;
                    List<PricebookEntry> precios = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN:listIdProd WITH SECURITY_ENFORCED]; 
                    List<Plazo__c> plazos =[SELECT Id, Dsales_Plazo__c,DSALES_Seguro__c FROM Plazo__c WHERE  DSALES_Seguro__c=:listIdProd WITH SECURITY_ENFORCED];
                    System.debug('productos: '+productos);
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
                    System.debug('Lista de listaMotoSeguroToInsert: '+listaMotoSeguroToInsert.size());
                    System.debug('Lista de listaMotoSeguroToInsert: '+listaMotoSeguroToInsert);

                    ///////////////////////////////////////

                    Quote cotizacionEnviar=[SELECT Id,DSALES_Enviarcotizacion__c FROM Quote WHERE Id=:listaMotoSeguroToInsert[0].QuoteId WITH SECURITY_ENFORCED LIMIT 1];
                    cotizacionEnviar.DSALES_Enviarcotizacion__c=true;
                    if(Quote.SObjectType.getDescribe().isUpdateable()) {
                        update cotizacionEnviar;  
                    }else{
                        System.debug('Permisos insuficientes para actualizar');   
                    }   
                    for(QuoteLineItem q:listMotoRc){
                        QuoteLineItem part = new QuoteLineItem();
                        //for(PricebookEntry pr:precios){
                              /*if(pr.Name==q.DSALES_NombreProducto__c){
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
                                part.DSALES_Derechosdepliza__c = q.DSALES_Derechosdepliza__c;
                                part.DSALES_Gastosdeoperacindelrecibo__c = q.DSALES_Gastosdeoperacindelrecibo__c;
                                part.DSALES_Impuestos__c = q.DSALES_Impuestos__c;
                                part.DSALES_TrackingID__c=q.DSALES_TrackingID__c;
                                part.DSALES_Comision__c=q.DSALES_Comision__c;
                                part.DSALES_Recargos__c=q.DSALES_Recargos__c;
                                part.DSALES_Descripcion__c=q.DSALES_Descripcion__c;
                                part.DSALES_Pagomensual__c=q.DSALES_Pagomensual__c;
                                for(Plazo__c p:plazos){
                                    if(q.DSALES_Plazo__c!=null && p.Id==q.DSALES_Plazo__c){
                                        part.DSALES_Plazo__c=q.Dsales_Plazo__c;
                                    }
                                }
                            }*/
                            //part=part;   
                        //}
                        //listPartInsert.add(part);
                        listPartInsert.add(productoIf(precios, q, listCotNew, plazos)); 
                    }
                    System.debug('listPartInsert:'+listPartInsert.size());
                    System.debug('listPartInsert:'+listPartInsert);
                    try{
                        if(Schema.sObjectType.QuoteLineItem.isCreateable()) {
                            insert listaMotoSeguroToInsert;
                            insert listPartInsert;
                        }else{
                            System.debug('Permisos insuficientes para insertar');
                        }
                        Quote cotizacion =[SELECT Id,DSALES_Enviarcotizacion__c FROM Quote WHERE Id=:listCotNew[0] WITH SECURITY_ENFORCED LIMIT 1];
                        if(cotizacion!=null){
                            cotizacion.DSALES_Enviarcotizacion__c=true;
                        }
                    }catch(Exception e){
                        System.debug('Error al insertar:\n'+e.getMessage());
                    }
                    
                    List<QuoteLineItem> idNuevos = new List<QuoteLineItem>();
                    List<QuoteLineItem> partidasNuevas =[SELECT Id,DSALES_Tipodeproducto__c,DSALES_Impuestos__c,DSALES_Pagomensual__c,DSALES_Recargos__c,DSALES_Comision__c,
                            DSALES_Derechosdepliza__c, UnitPrice,DSALES_Gastosdeoperacindelrecibo__c,DSALES_Primaneta__c,DSALES_Plazo__c,DSALES_NombreProducto__c,DSALES_Segurogratis__c 
                            FROM QuoteLineItem WHERE Id IN:listPartInsert WITH SECURITY_ENFORCED];
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
                                    ql.DSALES_Impuestos__c=0;
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
                    if(QuoteLineItem.SObjectType.getDescribe().isUpdateable()) {
                        update idNuevos;   
                    }else{
                        System.debug('Permisos insuficientes para actualizar');   
                    } 
                    
                    System.debug('idCotizacion actu:'+listPartInsert[0].QuoteId);
                    idCotSincronizar= listPartInsert[0].QuoteId;
                }
                else{ // no aplica seguro gratis
                    listSeguros=[SELECT Id,QuoteId,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Recargos__c,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,Dsales_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                                DSALES_Gastosdeoperacindelrecibo__c,DSALES_Pagomensual__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                FROM QuoteLineItem WHERE  QuoteId=:idCot AND DSALES_Tipodeproducto__c='Seguro' AND DSALES_Plazo__r.Dsales_Plazo__c =:String.valueOf(plazo) WITH SECURITY_ENFORCED];
                    System.debug('Seguro con plazo correcto:'+listSeguros);
                    System.debug('Seguro size:'+listSeguros.size());
                    if(listSeguros!=null && listSeguros.size()==1){
                        seguro=[SELECT Id,QuoteId,DSALES_Plazo__r.Dsales_Plazo__c,DSALES_TrackingID__c,DSALES_Descripcion__c,DSALES_Recargos__c,DSALES_NombreProducto__c,DSALES_Comision__c,DSALES_Segurogratis__c,Dsales_Plazo__c,PricebookEntryId,Product2Id,Quantity,UnitPrice,DSALES_Fechadeinicio__c,DSALES_Fechadetermino__c,DSALES_Primaneta__c,DSALES_Derechosdepliza__c,
                                DSALES_Gastosdeoperacindelrecibo__c,DSALES_Pagomensual__c,DSALES_Impuestos__c,TotalPrice,ListPrice,DSales_SKU_Producto__c,DSALES_Tipodeproducto__c
                                FROM QuoteLineItem WHERE  QuoteId=:idCot AND DSALES_Tipodeproducto__c='Seguro' AND DSALES_NombreProducto__c=:RC_GRATIS WITH SECURITY_ENFORCED ORDER BY DSALES_Plazo__r.Dsales_Plazo__c DESC LIMIT 1]; 
                        listSeguros.add(seguro);
                        System.debug('Seguros:'+listSeguros);
                        System.debug('Dos seguros:'+ listSeguros.size());
                    }
                    listPartidas=listSeguros;
                    listPartidas.add(producto);
                    System.debug('listPartidas fin:'+listPartidas);
                    System.debug('size listPartidas: '+listPartidas.size());
                    for(QuoteLineItem q:listPartidas){
                        listIdProd.add(q.Product2Id);
                    }
                    List<Product2> productos = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Id IN:listIdProd WITH SECURITY_ENFORCED ] ;
                    System.debug('productos: '+productos);
                    List<PricebookEntry> precios = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN:listIdProd WITH SECURITY_ENFORCED]; 
                    List<Plazo__c> plazos =[SELECT Id, Dsales_Plazo__c,DSALES_Seguro__c FROM Plazo__c WHERE  DSALES_Seguro__c=:listIdProd WITH SECURITY_ENFORCED];
                    System.debug('precios:'+precios);
                    System.debug('xxxx:'+plazos);
                    QuoteLineItem partida = new QuoteLineItem();
                    partida.QuoteId = listCotNew[0]; 
                    for(PricebookEntry pr:precios){
                        if(pr.Name==producto.DSALES_NombreProducto__c){
                            partida.PricebookEntryId = pr.Id;
                            partida.Product2Id = pr.Product2Id;
                            partida.UnitPrice = pr.UnitPrice;
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
                    if(Schema.sObjectType.QuoteLineItem.isCreateable()) {
                        insert partida;
                    }else{
                        System.debug('Permisos insuficientes para insertar');
                    }
                    //crear cotización 2 seguros y enviarla
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
                    }
                    System.debug('partidas seg+ rc3:'+listPartInsert.size());

                    insert listPartInsert;
                    Quote cotizacionEnviar=[SELECT Id,DSALES_Enviarcotizacion__c FROM Quote WHERE Id=:listPartInsert[0].QuoteId WITH SECURITY_ENFORCED LIMIT 1];
                    cotizacionEnviar.DSALES_Enviarcotizacion__c=true;
                    update cotizacionEnviar;
                    List<QuoteLineItem> idNuevos = new List<QuoteLineItem>();
                    List<QuoteLineItem> partidasNuevas =[SELECT Id, UnitPrice,DSALES_Plazo__c,DSALES_NombreProducto__c FROM QuoteLineItem WHERE Id IN:listPartInsert WITH SECURITY_ENFORCED];
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
            }
            return idCotSincronizar;
        }catch(Exception e ){
            System.debug('Error al crear dos partidas de presupuesto');
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            return null;
        }
    }

    ///////////////////--------- NEW -------------/////////////////////////

    public static QuoteLineItem productoIf(List<PricebookEntry> precios, QuoteLineItem q, List<String> listCotNew, List<Plazo__c> plazos){
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
                part.DSALES_Derechosdepliza__c = q.DSALES_Derechosdepliza__c;
                part.DSALES_Gastosdeoperacindelrecibo__c = q.DSALES_Gastosdeoperacindelrecibo__c;
                part.DSALES_Impuestos__c = q.DSALES_Impuestos__c;
                part.DSALES_TrackingID__c=q.DSALES_TrackingID__c;
                part.DSALES_Comision__c=q.DSALES_Comision__c;
                part.DSALES_Recargos__c=q.DSALES_Recargos__c;
                part.DSALES_Descripcion__c=q.DSALES_Descripcion__c;
                part.DSALES_Pagomensual__c=q.DSALES_Pagomensual__c;
                for(Plazo__c p:plazos){
                    if(q.DSALES_Plazo__c!=null && p.Id==q.DSALES_Plazo__c){
                        part.DSALES_Plazo__c=q.Dsales_Plazo__c;
                    }
                }
            }
        }
        //listPartInsert.add(part);
        return part;
    }

    /////////////****------ 6 -----------****///////////////
    public static void sincronizarOportunidad(String quoteId){
        try{
            Quote cotizacion = [SELECT Id,OpportunityId,DSALES_Enviarcotizacion__c FROM Quote WHERE Id= :quoteId WITH SECURITY_ENFORCED LIMIT 1];
            Opportunity opp = [SELECT Id, StageName,SyncedQuoteId FROM opportunity WHERE Id=:cotizacion.OpportunityId WITH SECURITY_ENFORCED LIMIT 1];
            opp.StageName='Cerrada ganada';
            opp.SyncedQuoteId=cotizacion.Id;
            if(Opportunity.SObjectType.getDescribe().isUpdateable()) {
                update opp;   
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            }
            
        }catch(Exception e){
            System.debug('Error al sincronizar la cotización');
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
        }
    }
        
    private class WrapperPartidas{
        QuoteLineItem nuevaPartida{get;set;}
        QuoteLineItem partida {get;set;}
        Plazo__c p {get;set;}
        PricebookEntry pr {get;set;}
    }

    private class WrapperListaPartidas{
        List<QuoteLineItem> partidas{get;set;}
        List<PricebookEntry> precios{get;set;}
        List<Plazo__c> plazos{get;set;}
    }

    private class WrapperPrimero{
        String idCot{get;set;}
        List<String> listCotNew{get;set;}
        Integer plazo{get;set;}
        List<String> partidasSeleccionadas{get;set;}
        String skuMoto{get;set;}
    }
}