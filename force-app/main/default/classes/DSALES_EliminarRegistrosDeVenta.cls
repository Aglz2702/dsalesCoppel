public with sharing class DSALES_EliminarRegistrosDeVenta {
    public static Boolean eliminarRegistros(Opportunity oportunidad,IdsBorrar datos){
        Boolean borrar=false;
        List<OpportunityLineItem> oliLista =DSALES_VentaSCRest.obtenerPartidasSincronizadas(oportunidad);
        DSALES_InformacionDePago__c pagoAEliminar= DSALES_VentaSCRest.consultaPago('',oportunidad.Id);
        if(pagoAEliminar.DSALES_Poliza__c!=null && pagoAEliminar.DSALES_Poliza__r.Name!=DSALES_Utility.SEGURO_PREDETERMINADO){
            Insurancepolicy poliza =consultarPoliza(oportunidad.Id,datos.idCotSincro);
            if(poliza.dsalesActivoPolizaSeguro__c!=null){
                List<InsurancePolicyAsset> activo = consultarActivo(poliza.Id);
                eliminarActivo(activo);
            }
            if(poliza!=null){
                if(Insurancepolicy.SObjectType.getDescribe().isDeletable()) {
                    delete poliza;  
                }else{
                    System.debug('Permisos insuficientes para eliminar');   
                }
                
            }
        }
        List<Quote> cotizaciones=DSALES_VentaSCRest.consultarCotizacionAEliminar( oportunidad.Id,datos.idCotPrincipal);
        if(oliLista!=null){
            if(OpportunityLineItem.SObjectType.getDescribe().isDeletable()) {
                delete oliLista;  
            }else{
                System.debug('Permisos insuficientes para eliminar');   
            }
          borrar=true;
        }
        borrar=eliminarPago(pagoAEliminar,cotizaciones);
        
        return borrar;
    }
    private static void eliminarActivo(List<InsurancePolicyAsset> activo){
        if(activo!=null){
            if(InsurancePolicyAsset.SObjectType.getDescribe().isDeletable()) {
                delete activo;  
            }else{
                System.debug('Permisos insuficientes para eliminar');   
            }
            
        }
    }
    private static  Boolean eliminarPago(DSALES_InformacionDePago__c pagoAEliminar, List<Quote> cotizaciones){
        Boolean borrar=false;
        if(pagoAEliminar!=null){
            if(DSALES_InformacionDePago__c.SObjectType.getDescribe().isDeletable()) {
                delete pagoAEliminar;
            }else{
                System.debug('Permisos insuficientes para eliminar');   
            }
            
        }
        if(cotizaciones!=null){
            if(Quote.SObjectType.getDescribe().isDeletable()) {
                delete cotizaciones;
            }else{
                System.debug('Permisos insuficientes para eliminar');   
            }
          borrar=true;
        }
        return borrar;
    }

    public static Insurancepolicy consultarPoliza(String idOportunidad, String idCot){

        Insurancepolicy poliza =[SELECT Id, Name,SourceQuoteId,dsalesActivoPolizaSeguro__c FROM Insurancepolicy WHERE SourceOpportunityId=:idOportunidad AND SourceQuoteId=:idCot  WITH SECURITY_ENFORCED LIMIT 1];
        if(poliza.Name!=DSALES_Utility.SEGURO_PREDETERMINADO){
               return poliza;
        }
        else{
            return null;
        }
    }
    public static List<InsurancePolicyAsset> consultarActivo(String idPoliza){
        List<InsurancePolicyAsset> activo =[SELECT Id, Name FROM InsurancePolicyAsset WHERE InsurancePolicyId=:idPoliza  WITH SECURITY_ENFORCED];
        if(activo!=null){
            return activo;
        }
        else{
            return null;
        }
    }
    public class IdsBorrar{
        public String idCotPrincipal{get;set;}
        public String idCotSincro{get;set;}
    }
}