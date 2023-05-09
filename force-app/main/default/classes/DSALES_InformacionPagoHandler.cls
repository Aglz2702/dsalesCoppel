public without sharing class DSALES_InformacionPagoHandler {
    public static void cambiaClienteCautivo(List<DSALES_InformacionDePago__c> actualInfoPago){
        List<DSALES_InformacionDePago__c> listaCliente=[SELECT Id,DSALES_Estatus__c,DSALES_Cliente__c,RecordType.DeveloperName FROM DSALES_InformacionDePago__c WHERE Id IN:actualInfoPago WITH SECURITY_ENFORCED];
        List<Account> clientes = new List<Account>();  
        Set<Id> clienteIds = new Set<Id>();
        for(DSALES_InformacionDePago__c info: listaCliente){
            if(info.RecordType.DeveloperName == 'DSALES_PagosdeVentaenNPVSM_c' && info.DSALES_Estatus__c == 'Acreditado'){
                clienteIds.add(info.DSALES_Cliente__c);
            }
        }
        Map<Id, Account> clienteMap = new Map<Id, Account>([SELECT Id, dsalesFinServStatus FROM Account WHERE Id IN :clienteIds WITH SECURITY_ENFORCED]);
        for(DSALES_InformacionDePago__c info: listaCliente){
            if(info.RecordType.DeveloperName == 'DSALES_PagosdeVentaenNPVSM_c' && info.DSALES_Estatus__c == 'Acreditado'){
                Account aux = clienteMap.get(info.DSALES_Cliente__c);
                if(aux != null){
                    aux.dsalesFinServStatus = 'Cautivo';
                    clientes.add(aux); 
                }
            }
        }
        if(Account.SObjectType.getDescribe().isUpdateable()) {
            update clientes;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        }   
    }
}