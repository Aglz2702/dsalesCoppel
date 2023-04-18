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

}