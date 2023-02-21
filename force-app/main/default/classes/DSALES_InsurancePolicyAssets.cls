public with sharing class DSALES_InsurancePolicyAssets {
    public static void agregarDatosDeActivo(List<InsurancePolicyAsset> activos){
        for(InsurancePolicyAsset i:activos){
            System.debug('Se agregan datos del activo');
            DSALES_CreateInsurancePolicy.agregarDatosDeActivo(i.Id);
        }
    }
    public static void cancelarPoliza(Map<Id,SObject> existingRecords, List<SObject> records){
        List<InsurancePolicyAsset> listRecord = (List<InsurancePolicyAsset>)records;
        for(InsurancePolicyAsset a:listRecord){
            InsurancePolicyAsset assetOld = (InsurancePolicyAsset)existingRecords.get(a.Id);
            if(assetOld.Estatus__c!=a.Estatus__c){
                if(a.Estatus__c=='Devuelto' ||a.Estatus__c=='Cancelado'){
                    DSALES_CreateInsurancePolicy.cancelarPoliza(a.Id);
                }
                
            }
            
        }
     }
    
    
    public static void emisionDePoliza(List<InsurancePolicyAsset> records){
        System.debug('Se solicita la emisión de póliza');
        List<InsurancePolicyAsset> listRecord = (List<InsurancePolicyAsset>)records;
        List<InsurancePolicyAsset> listaActivos =[SELECT Id,DSALES_Numeroserie__c,DSALES_emitir_poliza__c,DSALES_Motoexterna__c,DSALES_InformacionPago__c FROM InsurancePolicyAsset WHERE Id IN:listRecord];
        System.debug('activo size:'+listaActivos.size());
        List<String> idsPago = new List<String>();
        for(InsurancePolicyAsset a:listaActivos){
           idsPago.add(a.DSALES_InformacionPago__c);
        }
        System.debug('pagos ids size:'+idsPago.size());
       	List<DSALES_InformacionDePago__c> listPagos=[SELECT Id,DSALES_Poliza__c,DSALES_Motoentregada__c FROM DSALES_InformacionDePago__c WHERE Id IN:idsPago AND DSALES_Motoentregada__c=true  AND DSALES_Seguro__c=true ];
		for(InsurancePolicyAsset a:listaActivos){
            System.debug('serie:'+a.DSALES_Numeroserie__c);
            System.debug('emitir?:'+a.DSALES_emitir_poliza__c);
            System.debug('externa?:'+a.DSALES_Motoexterna__c);
            if( a.DSALES_Numeroserie__c!='' && a.DSALES_emitir_poliza__c==true && a.DSALES_Motoexterna__c==false){
                for(DSALES_InformacionDePago__c pago:[SELECT Id,DSALES_Poliza__c,DSALES_Motoentregada__c FROM DSALES_InformacionDePago__c WHERE Id IN:idsPago AND DSALES_Motoentregada__c=true  AND DSALES_Seguro__c=true ]){
                   System.debug('Se emite');
                    DSALES_CreateInsurancePolicy.estatusTramite(pago.DSALES_Poliza__c);
                    DSALES_NuevaPoliza.invokeService(pago.DSALES_Poliza__c);
                }
            }
        }
    }
}