public without sharing class DSALES_CreateInsurancePolicy {
    private static  String seguroAMP='AMP';
    private static  String seguroRC='RC';

    public static InsurancePolicy createPoliza(String idPago) {
		InsurancePolicy poliza = new InsurancePolicy();
        try{
            //System.debug('creaePoliza función');
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Oportunidad__c,DSALES_Motoexterna__c,DSALES_Poliza__c FROM DSALES_InformacionDePago__c WHERE Id=:idPago];
            Opportunity op =[SELECT Id,AccountId,SyncedQuoteId FROM Opportunity WHERE Id=:pago.DSALES_Oportunidad__c];
            System.debug('opp:'+ op.Id);
            Account cliente =[SELECT Id,RecordTypeId, Name,FirstName,MiddleName,LastName,Suffix,PersonEmail,Fecha_de_Nacimiento__c,CP_Gender__pc FROM Account WHERE Id=:op.AccountId];
            System.debug('opp:'+ cliente.Id);
            Quote cotizacion=[SELECT Id,DSALES_RFC__c FROM Quote WHERE Id=:op.SyncedQuoteId LIMIT 1]; 
            System.debug('quote:'+ cotizacion.Id);
            List<QuoteLineItem> partidas =[SELECT Id,DSALES_Tipodeproducto__c,DSALES_NombreProducto__c FROM QuoteLineItem WHERE QuoteId=:cotizacion.Id AND DSALES_Tipodeproducto__c='Seguro'];
            System.debug('xxxxxxx PARTIDASxxxxxxxx: '+partidas.size());
            System.debug('xxxxxxx PARTIDAS NOMBRExxxxxxxx: '+partidas[0].DSALES_NombreProducto__c);
            
            poliza.DSALES_RFC__c=cotizacion.DSALES_RFC__c;
            poliza.PolicyName='0001';
            poliza.Name='0001';
            poliza.NameInsuredId=cliente.Id;
            poliza.DSALES_Estatusdepliza__c='Prepoliza';
            poliza.DSALES_CorreoElectronico__c=cliente.PersonEmail;
           String recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
            if(cliente.RecordTypeId==recordTypeId){
                poliza.DSALES_Tipodepersona__c='Física';
            }else {
                poliza.DSALES_Tipodepersona__c='Moral';
            }
            poliza.SourceOpportunityId=op.Id;
            poliza.SourceQuoteId=cotizacion.Id;
            poliza.Fecha_de_emisi_n__c=Date.today();
            if(partidas.size()==1){
                if(partidas[0].DSALES_NombreProducto__c==seguroAMP){
                    System.debug('Es PLUS');
                    poliza.DSALES_Cobertura__c='PLUS';
                }
                else if(partidas[0].DSALES_NombreProducto__c==seguroRC){
                    System.debug('Es RC');
                    poliza.DSALES_Cobertura__c='RC';
                }
                
            }
            else if( partidas.size()==2){
                System.debug('Es AMBOS');
                poliza.DSALES_Cobertura__c='PLUS';
                
            }
            System.debug('cobertura: '+poliza.DSALES_Cobertura__c);
            insert poliza;
        }catch(Exception e){
            System.debug(e.getLineNumber() +':'+ e.getMessage() );
        }
        return poliza;
    }

    public static void updateInfoPago(InsurancePolicy pol){
        try{
            //System.debug('updateInfoPago función');
            InsurancePolicy poliza =[SELECT Id,SourceOpportunityId FROM InsurancePolicy WHERE Id=:pol.Id];
            List<DSALES_InformacionDePago__c>  pagos =[SELECT Id,DSALES_Oportunidad__c,DSALES_Poliza__c,DSALES_Seguro__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c=:poliza.SourceOpportunityId  ];
            List<DSALES_InformacionDePago__c> listToUpdate = new List<DSALES_InformacionDePago__c>();
            for(DSALES_InformacionDePago__c pago:pagos){
                if(pago.DSALES_Poliza__c==null && pago.DSALES_Seguro__c==true){
                    pago.DSALES_Poliza__c=poliza.Id;
                    //update pago;
                    listToUpdate.add(pago);
                }
            }
            update listToUpdate;
        }catch(Exception e){
            System.debug(e.getLineNumber()+':'+e.getMessage());
        }
       
    }

    public static InsurancePolicy agregarDatosDeActivo(InsurancePolicyAsset activo,String idPoliza){
        //try{
            System.debug('activo :'+activo);
            System.debug('datos de pago'+activo.DSALES_InformacionPago__c);
            InsurancePolicy poliza = new InsurancePolicy();
            if(activo!=null){
            //DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Poliza__c FROM DSALES_InformacionDePago__c WHERE Id=:activo.DSALES_InformacionPago__c];
            poliza= [SELECT Id,DSALES_Activodeplizadeseguro__c,DSALES_Clavevehicular__c,DSALES_Modelo__c,DSALES_Numeroserie__c,DSALES_Nmerodemotor__c,DSALES_Descripcion__c,
                                    DSALES_Servicio__c,DSALES_Placas__c,DSALES_Marca__c,DSALES_Uso__c,DSALES_ClaveAMIS__c
                                    FROM InsurancePolicy WHERE Id=:idPoliza];
                
                poliza.DSALES_Activodeplizadeseguro__c=activo.Id;
                poliza.DSALES_Clavevehicular__c=activo.DSALES_Clavevehicular__c;
                poliza.DSALES_Modelo__c=activo.DSALES_Modelo__c;
                poliza.DSALES_Numeroserie__c=activo.DSALES_Numeroserie__c;
                poliza.DSALES_Nmerodemotor__c=activo.DSALES_Numeromotor__c;
                poliza.DSALES_Descripcion__c=activo.DSALES_Descripcion__c;
                poliza.DSALES_Servicio__c=activo.DSALES_Servicio__c;
                poliza.DSALES_Placas__c=activo.DSALES_Placas__c;
                poliza.DSALES_Marca__c=activo.DSALES_Marca__c;
                poliza.DSALES_Uso__c=activo.DSALES_Uso__c;
               // poliza.DSALES_ClaveAMIS__c=activo.DSALES_ClaveAMIS__c;
                //p.DSALES_Estatusdepliza__c='En trámite';
                System.debug('*****poliza con datos de activo actualizada**********'+ poliza);
                update poliza;
                
            }
            return poliza;
    }

    public static void cambiarEstatus(String idPoliza){
        InsurancePolicy p=[SELECT Id,DSALES_VigenciacumplidaSM__c,DSALES_Estatusdepliza__c,EffectiveDate FROM InsurancePolicy WHERE Id=:idPoliza];
        if(p.DSALES_VigenciacumplidaSM__c==true){
            p.DSALES_Estatusdepliza__c='Vencida';
            update p;
        }
    }
}