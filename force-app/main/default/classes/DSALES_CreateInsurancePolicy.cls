public without sharing class DSALES_CreateInsurancePolicy {
    static final String SEGURO_AMP='AMP';
    static final  String SEGURO_RC='RC';

    public static InsurancePolicy crearPoliza(String idPago) {
		InsurancePolicy poliza = new InsurancePolicy();
        try{
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Oportunidad__c,DSALES_Motoexterna__c,DSALES_Poliza__c FROM DSALES_InformacionDePago__c WHERE Id=:idPago WITH SECURITY_ENFORCED];
            Opportunity oportunidad =[SELECT Id,AccountId,SyncedQuoteId FROM Opportunity WHERE Id=:pago.DSALES_Oportunidad__c WITH SECURITY_ENFORCED];
            Account cliente =[SELECT Id,RecordTypeId, Name,FirstName,MiddleName,LastName,Suffix,PersonEmail,Fecha_de_Nacimiento__c,CP_Gender__pc FROM Account WHERE Id=:oportunidad.AccountId WITH SECURITY_ENFORCED];
            Quote cotizacion=[SELECT Id,dsalesRfc FROM Quote WHERE Id=:oportunidad.SyncedQuoteId WITH SECURITY_ENFORCED LIMIT 1 ]; 
            List<QuoteLineItem> partidas =[SELECT Id,DSALES_Tipodeproducto__c,DSALES_NombreProducto__c FROM QuoteLineItem WHERE QuoteId=:cotizacion.Id AND DSALES_Tipodeproducto__c='Seguro' WITH SECURITY_ENFORCED];
            poliza.dsalesRfc=cotizacion.dsalesRfc;
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
            poliza.SourceOpportunityId=oportunidad.Id;
            poliza.SourceQuoteId=cotizacion.Id;
            poliza.Fecha_de_emisi_n__c=Date.today();
            if(partidas.size()==1){
                if(partidas[0].DSALES_NombreProducto__c==SEGURO_AMP){
                    poliza.DSALES_Cobertura__c='PLUS';
                }
                else if(partidas[0].DSALES_NombreProducto__c==SEGURO_RC){
                    poliza.DSALES_Cobertura__c='RC';
                }
                
            }
            else if( partidas.size()==2){
                poliza.DSALES_Cobertura__c='PLUS';
                
            }
            if(Schema.sObjectType.InsurancePolicy.isCreateable()) {
                insert poliza;
            }else{
                System.debug('Permisos insuficientes para insertar');   
            }
           
        }catch(Exception e){
            System.debug(e.getLineNumber() +':'+ e.getMessage() );
        }
        return poliza;
    }

    public static void relacionarPolizaAPago(InsurancePolicy poliza){
        try{
            InsurancePolicy polizaActual =[SELECT Id,SourceOpportunityId FROM InsurancePolicy WHERE Id=:poliza.Id WITH SECURITY_ENFORCED];
            List<DSALES_InformacionDePago__c>  pagos =[SELECT Id,DSALES_Oportunidad__c,DSALES_Poliza__c,dsalesSeguro__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c=:polizaActual.SourceOpportunityId WITH SECURITY_ENFORCED ];
            List<DSALES_InformacionDePago__c> listaParaActualizar = new List<DSALES_InformacionDePago__c>();
            for(DSALES_InformacionDePago__c pago:pagos){
                if(pago.DSALES_Poliza__c==null && pago.dsalesSeguro__c==true){
                    pago.DSALES_Poliza__c=poliza.Id;
                    listaParaActualizar.add(pago);
                }
            }
            if(DSALES_InformacionDePago__c.SObjectType.getDescribe().isUpdateable()) {
                update listaParaActualizar;
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            }
        }catch(Exception e){
            System.debug(e.getLineNumber()+':'+e.getMessage());
        }
       
    }

    public static InsurancePolicy agregarDatosDeActivo(InsurancePolicyAsset activo,String idPoliza){
        InsurancePolicy poliza = new InsurancePolicy();
        if(activo!=null){
        poliza= [SELECT Id,DSALES_Activodeplizadeseguro__c,DSALES_Clavevehicular__c,DSALES_Modelo__c,DSALES_Numeroserie__c,DSALES_Nmerodemotor__c,DSALES_Descripcion__c,
                                DSALES_Servicio__c,DSALES_Placas__c,DSALES_Marca__c,DSALES_Uso__c,DSALES_ClaveAMIS__c
                                FROM InsurancePolicy WHERE Id=:idPoliza WITH SECURITY_ENFORCED];
            
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
            if(InsurancePolicy.SObjectType.getDescribe().isUpdateable()) {
                update poliza;
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            }
            
            
        }
        return poliza;
    }

    public static void cambiarEstatusPoliza(String idPoliza){
        InsurancePolicy poliza=[SELECT Id,DSALES_VigenciacumplidaSM__c,DSALES_Estatusdepliza__c,EffectiveDate FROM InsurancePolicy WHERE Id=:idPoliza WITH SECURITY_ENFORCED];
        if(poliza.DSALES_VigenciacumplidaSM__c==true){
            poliza.DSALES_Estatusdepliza__c='Vencida';
            if(InsurancePolicy.SObjectType.getDescribe().isUpdateable()) {
                update poliza;
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            }
        }
    }
}