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

    /////////////////////////////-----NEW------/////////////////////////////

    public static void crearCotizacionesNuevas(String idPago, List<String> partidasSeleccionadas, String skuMoto){
        if(skuMoto!=null){
            crearCotNueva2(idPago, partidasSeleccionadas, skuMoto);
        }
        else{
            creacionDePartida(idPago, partidasSeleccionadas, skuMoto);
        }
    }


    public static void crearCotNueva2(String idPago, List<String> partidasSeleccionadas, String skuMoto){
        ////////////////////////
        List<String> listIdCotiza = new List<String>();
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Seguro__c,DSALES_Oportunidad__c,DSALES_Nombre_del_Vendedor__c,DSales_Tienda__c,DSALES_SKU__c  
                                        FROM DSALES_InformacionDePago__c 
                                        WHERE Id=:idPago WITH SECURITY_ENFORCED];
        Quote beforeCot = [SELECT Id,OpportunityId,AccountId FROM Quote WHERE OpportunityId =:pago.DSALES_Oportunidad__c WITH SECURITY_ENFORCED];
        QuoteLineItem producto =[SELECT Id,DSALES_NombreProducto__c, DSALES_Segurogratis__c FROM QuoteLineItem  WHERE DSALES_SKU__c=:skuMoto  AND quoteId=:beforeCot.Id WITH SECURITY_ENFORCED LIMIT 1];
        ////////////////////////
        if(producto.DSALES_Segurogratis__c==true && partidasSeleccionadas!=null && partidasSeleccionadas.size()==1){
            for(Integer i=0;i<2;i++){
                String idCotizacion=DSALES_QuotePagoSM.crearCotizacion(beforeCot.Id,pago.Id);
                listIdCotiza.add(idCotizacion);
            } 
            String idCotSin=DSALES_QuotePagoSM.crear2CotPartidas(beforeCot.Id,listIdCotiza,Integer.valueOf(pago.DSALES_Plazodecomprademoto__c), partidasSeleccionadas,skuMoto);
            if(idCotSin!=null|| idCotSin!=''){
                DSALES_QuotePagoSM.sincronizarOportunidad(idCotSin);
            }
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
        ///////////////
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Seguro__c,DSALES_Oportunidad__c,DSALES_Nombre_del_Vendedor__c,DSales_Tienda__c,DSALES_SKU__c  
                                        FROM DSALES_InformacionDePago__c 
                                        WHERE Id=:idPago WITH SECURITY_ENFORCED];
        Quote beforeCot = [SELECT Id,OpportunityId,AccountId FROM Quote WHERE OpportunityId =:pago.DSALES_Oportunidad__c WITH SECURITY_ENFORCED];
        ///////////////
        String idCotizacion=DSALES_QuotePagoSM.crearCotizacion(beforeCot.Id,pago.Id);
        Map<String, String> ambasCotizaciones=new Map<String, String>();
        ambasCotizaciones.put('beCot',beforeCot.Id);
        ambasCotizaciones.put('cot',idCotizacion);
        DSALES_QuotePagoSM.crearPartidas(ambasCotizaciones, partidasSeleccionadas, skuMoto);
        if(idCotizacion!=null || idCotizacion!=''){
            DSALES_QuotePagoSM.sincronizarOportunidad(idCotizacion);
        } 
    }

    public static QuoteLineItem llenarPartida(QuoteLineItem ql, QuoteLineItem q){
        QuoteLineItem newpartida=new QuoteLineItem();
        if(ql.DSALES_NombreProducto__c == q.DSALES_NombreProducto__c){
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
                newpartida=ql;
            }
        }  
        return newpartida;
    }

}