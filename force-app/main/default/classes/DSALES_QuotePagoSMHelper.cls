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
public with sharing class DSALES_QuotePagoSMHelper {

  private static final  String RC_GRATIS='RC';

    public static void crearCotizacionesNuevas(String idPago, List<String> partidasSeleccionadas, String skuMoto){
        if(skuMoto!=null){
            crearCotNueva2(idPago, partidasSeleccionadas, skuMoto);
        }
        else{
            creacionDePartida(idPago, partidasSeleccionadas, skuMoto);
        }
    }

    public static void crearCotNueva2(String idPago, List<String> partidasSeleccionadas, String skuMoto){
        List<String> listIdCotiza = new List<String>();
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Seguro__c,DSALES_Oportunidad__c,DSALES_Nombre_del_Vendedor__c,DSales_Tienda__c,DSALES_SKU__c  
                                        FROM DSALES_InformacionDePago__c 
                                        WHERE Id=:idPago WITH SECURITY_ENFORCED];
        Quote beforeCot = [SELECT Id,OpportunityId,AccountId FROM Quote WHERE OpportunityId =:pago.DSALES_Oportunidad__c WITH SECURITY_ENFORCED];
        QuoteLineItem producto =[SELECT Id,DSALES_NombreProducto__c, DSALES_Segurogratis__c FROM QuoteLineItem  WHERE DSALES_SKU__c=:skuMoto  AND quoteId=:beforeCot.Id WITH SECURITY_ENFORCED LIMIT 1];
        if(producto.DSALES_Segurogratis__c==true && partidasSeleccionadas!=null && partidasSeleccionadas.size()==1){
            for(Integer i=0;i<2;i++){
                //String idCotizacion=DSALES_QuotePagoSM.crearCotizacion(beforeCot.Id,pago.Id);
                //listIdCotiza.add(idCotizacion);
            } 
            Map<String, Object> stringData=new Map<String, String>();
                stringData.put('beCot',beforeCot.Id);
                stringData.put('skuMoto',skuMoto);
                stringData.put('plazo',Integer.valueOf(pago.DSALES_Plazodecomprademoto__c));
            /*String idCotSin=DSALES_QuotePagoSM.crear2CotPartidas(stringData, listIdCotiza, partidasSeleccionadas);
            if(idCotSin!=null|| idCotSin!=''){
                DSALES_QuotePagoSM.sincronizarOportunidad(idCotSin);
            }*/
        }
        else if(producto.DSALES_Segurogratis__c==true && partidasSeleccionadas!=null && partidasSeleccionadas.size()==2){
            //solo crear una cotizacion
            creacionDePartida(idPago, partidasSeleccionadas, skuMoto);
        }
        else if(producto.DSALES_Segurogratis__c==false){
            //solo crear una cotizacion
            creacionDePartida(idPago, partidasSeleccionadas, skuMoto);
        }
    }

    public static void creacionDePartida(String idPago, List<String> partidasSeleccionadas, String skuMoto){
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Seguro__c,DSALES_Oportunidad__c,DSALES_Nombre_del_Vendedor__c,DSales_Tienda__c,DSALES_SKU__c  
                                        FROM DSALES_InformacionDePago__c 
                                        WHERE Id=:idPago WITH SECURITY_ENFORCED];
        Quote beforeCot = [SELECT Id,OpportunityId,AccountId FROM Quote WHERE OpportunityId =:pago.DSALES_Oportunidad__c WITH SECURITY_ENFORCED];
        //String idCotizacion=DSALES_QuotePagoSM.crearCotizacion(beforeCot.Id,pago.Id);
        Map<String, String> ambasCotizaciones=new Map<String, String>();
        ambasCotizaciones.put('beCot',beforeCot.Id);
        //ambasCotizaciones.put('cot',idCotizacion);
        //DSALES_QuotePagoSM.crearPartidas(ambasCotizaciones, partidasSeleccionadas, skuMoto);
        /*if(idCotizacion!=null || idCotizacion!=''){
            DSALES_QuotePagoSM.sincronizarOportunidad(idCotizacion);
        } */
    }

    public static QuoteLineItem llenarPartida(QuoteLineItem ql, QuoteLineItem q){
        QuoteLineItem newpartida=new QuoteLineItem();
        if(ql.DSALES_NombreProducto__c == q.DSALES_NombreProducto__c){
            if( ql.DSALES_Plazo__c == q.DSALES_Plazo__c){
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
                newpartida=ql;
            }
        }  
        return newpartida;
    }

    public static QuoteLineItem productoIf(List<PricebookEntry> precios, QuoteLineItem q, /*List<String> listCotNew, List<Plazo__c> plazos*/Map<String, List<Object>> mapData){
        
        List<String> listCotNew=(List<String>)mapData.get('listCotNew');
        List<Plazo__c> plazos=(List<Plazo__c>)mapData.get('plazos');
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
                part.dsalesDerechosDePoliza__c = q.dsalesDerechosDePoliza__c;
                part.dsalesGastosDeOperacionDelRecibo__c = q.dsalesGastosDeOperacionDelRecibo__c;
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

    public static QuoteLineItem quoteIf(QuoteLineItem ql, QuoteLineItem q){
        if(ql.DSALES_Segurogratis__c==true && ql.DSALES_Tipodeproducto__c=='Seguro'){
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
        return ql;
    }
}