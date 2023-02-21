public class DSALES_InformacionPagoHandler {
    public static void CambiaClienteCautivo(List<DSALES_InformacionDePago__c> actualInfoPago){
        List<Account> clientes = new List<Account>();  
        List<DSALES_InformacionDePago__c> listCliente=[SELECT Id,DSALES_Estatus__c,DSALES_Cliente__c,RecordType.DeveloperName FROM DSALES_InformacionDePago__c WHERE Id IN:actualInfoPago];
        for(DSALES_InformacionDePago__c info: listCliente){
            if(info.RecordType.DeveloperName=='DSALES_PagosdeVentaenNPVSM_c'){
                if(info.DSALES_Estatus__c == 'Acreditado'){
                    Account aux  = [SELECT Id, FinServ__Status__c FROM Account WHERE Id=:info.DSALES_Cliente__c];
                    Aux.FinServ__Status__c = 'Cautivo';
                    clientes.add(aux); 
                    update clientes;
                }
               
            }
        }
               
    }


    public static void createPolizaMExt(String idPaago){
        DSALES_InformacionDePago__c pago = [SELECT Id,DSALES_Factura__c,DSALES_Poliza__c,DSALES_SKU__c,DSALES_Motoexterna__c,DSALES_Motoentregada__c,
                                            RecordTypeId,RecordType.Name,RecordType.DeveloperName,DSALES_Seguro__c 
                                            FROM DSALES_InformacionDePago__c WHERE Id =:idPaago];
        if(pago.RecordType.DeveloperName=='DSALES_PagosdeVentaenNPVSM_c'){
                if(pago.DSALES_Seguro__c==true && pago.DSALES_Poliza__c==null){
                    if(pago.DSALES_Factura__c!=null   && (pago.DSALES_SKU__c==null || pago.DSALES_SKU__c!=null )){
                        System.debug('||||||||SE CREA PREPOLIZA||||||||||');
                        DSALES_CreateInsurancePolicy.createPoliza(pago.Id);
                 
                	}else{
                    System.debug('no es pago de SM');
                	}
           		}
          	}    
        
    } 
    
}