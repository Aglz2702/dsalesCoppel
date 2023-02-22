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
    /*public static void crearCotizacion(List<DSALES_InformacionDePago__c> records){
        System.debug('entra en la función 1');
        List<DSALES_InformacionDePago__c> listPagos=[SELECT Id, DSALES_Plazodecomprademoto__c,DSALES_Oportunidad__c,DSALES_Seguro__c FROM DSALES_InformacionDePago__c WHERE Id IN:records ];
        List<String> listIdOpp= new List<String>();
        System.debug('listPago1: '+listPagos.size());
        for(DSALES_InformacionDePago__c pago: listPagos){
            listIdOpp.add(pago.DSALES_Oportunidad__c);
        }
        List<DSALES_InformacionDePago__c> pagosEnOportunidad =[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Oportunidad__c,DSALES_Seguro__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c IN:listIdOpp];
        if(pagosEnOportunidad.size() ==1 ){
            for(DSALES_InformacionDePago__c pago: pagosEnOportunidad){
                if(pago.DSALES_Plazodecomprademoto__c !=null){
                    System.debug('xxxxxxxxxxx');
                    DSALES_QuotePagoSM.cotizacionesNuevas(pago.Id);
                }
                else{
                    System.debug('No se especifica un plazo');
                }
            }

        }
    }*/
    /*public static void envioProgramado(List<DSALES_InformacionDePago__c> records){
        List<DSALES_InformacionDePago__c> listPagos = [SELECT Id,RecordTypeId,RecordType.Name,RecordType.DeveloperName,DSALES_Motosinseguro__c FROM DSALES_InformacionDePago__c WHERE Id IN:records];
        for(DSALES_InformacionDePago__c pago:listPagos){
            if(pago.RecordType.DeveloperName=='DSALES_PagosdeVentaenNPVSM_c' && pago.DSALES_Seguro__c==true){
                DSALES_EnviarCotizacionProgramado.enviarCotizacion();
            }
        }
    } */    
    

    public static void createPolizaMExt(List<DSALES_InformacionDePago__c> records){
        List<DSALES_InformacionDePago__c> listPagos = [SELECT Id,DSALES_Factura__c,DSALES_Poliza__c,DSALES_SKU__c,DSALES_Motoexterna__c,DSALES_Motoentregada__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName,DSALES_Seguro__c FROM DSALES_InformacionDePago__c WHERE Id IN:records];
        System.debug('recordTypeid: '+listPagos[0].RecordTypeId);
        System.debug('DeveloperName: '+listPagos[0].RecordType.DeveloperName);
        for(DSALES_InformacionDePago__c pago:listPagos){
            if(pago.RecordType.DeveloperName=='DSALES_PagosdeVentaenNPVSM_c'){
                if(pago.DSALES_Seguro__c==true && pago.DSALES_Poliza__c==null){
                    if(pago.DSALES_Factura__c!=null   && (pago.DSALES_SKU__c==null || pago.DSALES_SKU__c!=null )){
                		DSALES_CreateInsurancePolicy.createPoliza(pago.Id);
                 
                	}else{
                    System.debug('no es pago de SM');
                	}
           		}
          	}    
            
            
        }
        
    } 
    public static void enviarIntegracion(Map<Id, SObject> existingRecords,List<DSALES_InformacionDePago__c> records){
        List<DSALES_InformacionDePago__c> listRecord = (List<DSALES_InformacionDePago__c>)records;
        List<DSALES_InformacionDePago__c> listPagos=[SELECT Id,DSALES_Factura__c,DSALES_Seguro__c,DSALES_Poliza__c,DSALES_SKU__c,DSALES_Motoexterna__c,DSALES_Motoentregada__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName FROM DSALES_InformacionDePago__c WHERE Id IN:listRecord];
        System.debug('type name: '+listPagos[0].recordType.Name);
         for(DSALES_InformacionDePago__c pago :listPagos){
            if(pago.RecordType.DeveloperName=='DSALES_PagosdeVentaenNPVSM_c'){
                DSALES_InformacionDePago__c pagoOld = (DSALES_InformacionDePago__c)existingRecords.get(pago.Id);
                if(pagoOld.DSALES_Motoentregada__c!=pago.DSALES_Motoentregada__c  && pago.DSALES_Motoentregada__c==true  && pago.DSALES_Motoexterna__c==false){
                    DSALES_CreateInsurancePolicy.estatusTramite(pago.DSALES_Poliza__c);
                    DSALES_NuevaPoliza.invokeService(pago.DSALES_Poliza__c);
                    
                    
                }
                if(pagoOld.DSALES_Motoexterna__c!=pago.DSALES_Motoexterna__c  && pago.DSALES_Motoexterna__c==true  && pago.DSALES_Motoentregada__c==false && pago.DSALES_SKU__c==null){
                    DSALES_CreateInsurancePolicy.estatusTramite(pago.DSALES_Poliza__c);
                    DSALES_NuevaPoliza.invokeService(pago.DSALES_Poliza__c);
                }
            }
        } 

    }
    
}