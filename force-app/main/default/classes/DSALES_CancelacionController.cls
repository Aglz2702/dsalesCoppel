public with sharing class DSALES_CancelacionController {
    public static void escenarioPolizaActRegistros(List<OpportunityLineItem> partidasActualizadas,Insurancepolicy poliza){
        InsurancePolicyAsset activo = new InsurancePolicyAsset();
        if(OpportunityLineItem.SObjectType.getDescribe().isUpdateable()) {
            update partidasActualizadas;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        }                                    
        if(poliza.DSALES_Activodeplizadeseguro__c!=null){
            activo = [SELECT Id,Estatus__c,	DSALES_Motoexterna__c FROM InsurancePolicyAsset WHERE Id=:poliza.DSALES_Activodeplizadeseguro__c WITH SECURITY_ENFORCED];
            if (activo.DSALES_Motoexterna__c==true) {
                activo.Estatus__c='Cancelado';
                if(InsurancePolicyAsset.SObjectType.getDescribe().isUpdateable()) {
                    update activo;   
                }else{
                    System.debug('Permisos insuficientes para actualizar');   
                } 
            }
        }
    }
    public static InsurancePolicyAsset obtenerActivo(List<OpportunityLineItem> olis){
        InsurancePolicyAsset activo  = new InsurancePolicyAsset();
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c();
        if(olis.size()==1 && olis[0].Product2.DSales_Tipo_de_Producto__c=='Producto'){
            pago = [SELECT Id,DSALES_Motoentregada__c,DSALES_Motoexterna__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c =:olis[0].OpportunityId WITH SECURITY_ENFORCED];
            if(pago.DSALES_Motoentregada__c==true){
                activo = [SELECT Id,Estatus__c FROM InsurancePolicyAsset WHERE DSALES_InformacionPago__c=:pago.Id WITH SECURITY_ENFORCED];
                if (activo!=null){
                    pago = [SELECT Id,DSALES_Poliza__c,DSALES_Poliza__r.DSALES_Estatusdepliza__c,DSALES_Poliza__r.PolicyName,DSALES_Poliza__r.DSALES_Activodeplizadeseguro__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c =:olis[0].OpportunityId WITH SECURITY_ENFORCED];
                }
            }
            
        }
        else if(olis.size()>1){
            pago = [SELECT Id,DSALES_Poliza__r.DSALES_Estatusdepliza__c,DSALES_Poliza__r.PolicyName,DSALES_Poliza__r.DSALES_Activodeplizadeseguro__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c =:olis[0].OpportunityId WITH SECURITY_ENFORCED];
            if(pago.DSALES_Poliza__c!=null && pago.DSALES_Poliza__r.DSALES_Activodeplizadeseguro__c!=null && pago.DSALES_Poliza__r.DSALES_Estatusdepliza__c!='Prepoliza' ){
                activo = [SELECT Id,Estatus__c FROM InsurancePolicyAsset WHERE DSALES_InformacionPago__c=:pago.Id WITH SECURITY_ENFORCED];
            }
        }
        return activo;
    }
    public static String obtenerIdPago(List<OpportunityLineItem> olis){
        Map<Id, String> mapaProduct2 = new Map<Id, String>();
        List<Product2> prodRelacionados  = new List<Product2>();
        String idPaOp='';
        for (OpportunityLineItem  prod: olis) {
            mapaProduct2.put(prod.Product2Id,prod.Id);
        }
        prodRelacionados = [SELECT Id,DSales_Tipo_de_Producto__c,Name FROM Product2 WHERE Id IN:mapaProduct2.keySet() AND DSales_Tipo_de_Producto__c=:'Producto' WITH SECURITY_ENFORCED];
        if(prodRelacionados!=null){
            for(Product2 pd:prodRelacionados){
                idPaOp =mapaProduct2.get(pd.Id);
            }
        }
        return idPaOp;
    }
}