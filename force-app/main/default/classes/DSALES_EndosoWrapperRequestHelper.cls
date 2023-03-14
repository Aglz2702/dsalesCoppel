/*********************************************************************************************************************************************************************
@ Class Name :  DSALES_EndosoWrapperRequestHelper
@ Author : Namrata Katore
@ Purpose : Helper class for webhook to insert or update Endoso record in salesforce
@ Date : 5/4/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/

public class DSALES_EndosoWrapperRequestHelper {
    
    /*********************************************************************************************************************************************************************
@ Method Name :  upsertEndoso
@ Author : Namrata Katore
@ Purpose : method to insert or update Endoso record in salesforce
@ Date : 5/4/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/    
    
    public static DSALES_EndorsementWrapper.endorsementResponse upsertEndoso(DSALES_EndorsementWrapper.endorsementRequest endosos){
        if(endosos.Estatus=='Nuevo'){
            DSALES_EndorsementWrapper.endorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.insertEndoso(endosos);
            return responsePayload;
        }
        else {
            DSALES_EndorsementWrapper.endorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.updateEndoso(endosos);
            return responsePayload;
        }
    }
    
    /*********************************************************************************************************************************************************************
@ Method Name :  insertEndoso
@ Author : Namrata Katore
@ Purpose : method to insert endoso record in salesforce ( if in request salesforce id is null)
@ Date : 5/4/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/        
    
    public static DSALES_EndorsementWrapper.endorsementResponse insertEndoso(DSALES_EndorsementWrapper.endorsementRequest endosos){
        Boolean success = false;
        String message = '';
        String code = '';
        DSALES_Endoso__c endosoRecord = new DSALES_Endoso__c();
        InsurancePolicy poliza = new InsurancePolicy();
        try{
            poliza = [SELECT Id FROM InsurancePolicy WHERE Name =: endosos.numero_poliza LIMIT 1 ];
            endosoRecord.DSALES_Poliza__c = poliza.Id;
            endosoRecord.DSALES_uid__c = endosos.uid;
            endosoRecord.DSALES_Tipodeendoso__c = endosos.tipo_endoso;
            endosoRecord.DSALES_Tipodedocumento__c = endosos.tipo_documento;
            endosoRecord.DSALES_Tipodedato__c = endosos.datos.tipo_dato;
            endosoRecord.DSALES_Valor__c = endosos.datos.valor;
            endosoRecord.DSALES_Estatus__c = endosos.estatus;
            endosoRecord.DSALES_MotivoDevolucion__c = endosos.motivo_devolucion;
            endosoRecord.DSALES_SolucionDevolucion__c = endosos.solucion_devolucion;
            endosoRecord.DSALES_MotivoRechazo__c = endosos.motivo_rechazo;
            endosoRecord.DSALES_MontoaDevolver__c = endosos.monto_a_devolver;
            
            insert endosoRecord;
            success = true;
            message = '';
            code = '';
            
        }catch(Exception e){
            success = false;
            message = DSALES_Utility.INTERNAL_ERROR_MSJ+' '+ e.getLineNumber()+' '+e.getCause()+' '+e.getMessage();
            code = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
        }
        
        DSALES_EndorsementWrapper.endorsementResponse responsePayload = new DSALES_EndorsementWrapper.endorsementResponse();
        responsePayload.success = success;
        responsePayload.mensaje_error = message;
        responsePayload.codigo_error = code;
        responsePayload.id_endoso = endosoRecord.id;
        
        return responsePayload;
    }
    
    /*********************************************************************************************************************************************************************
@ Method Name :  updateEndoso
@ Author : Namrata Katore
@ Purpose : method to update update record in salesforce ( if in request salesforce id & uid are not null)
@ Date : 5/4/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/
    
    public static DSALES_EndorsementWrapper.endorsementResponse updateEndoso(DSALES_EndorsementWrapper.endorsementRequest endosos){
        Boolean success = false;
        String message = '';
        String code = '';
        DSALES_Endoso__c endosoRecord = new DSALES_Endoso__c();
        InsurancePolicy poliza = new InsurancePolicy();        
        try{
            endosoRecord = [SELECT id,DSALES_Poliza__c,DSALES_Poliza__r.Name, DSALES_uid__c FROM DSALES_Endoso__c WHERE DSALES_uid__c=:endosos.uid LIMIT 1];
            switch on endosos.estatus{
                when'En tramite'{
                    endosoRecord.DSALES_Estatus__c = endosos.estatus;
                    upsert endosoRecord;
                }
                when'Requerimiento de Información'{
                    endosoRecord.DSALES_Estatus__c = endosos.estatus;
                    endosoRecord.DSALES_MotivoDevolucion__c = endosos.motivo_devolucion;
                    endosoRecord.DSALES_SolucionDevolucion__c = endosos.solucion_devolucion;
                    upsert endosoRecord;
                }
                when'Rechazado'{
                    endosoRecord.DSALES_Estatus__c = endosos.estatus;
                    endosoRecord.DSALES_MotivoRechazo__c = endosos.motivo_rechazo;
                    upsert endosoRecord;
                }
                when 'Autorizado'{
                    endosoRecord.DSALES_Estatus__c = endosos.estatus;
                    endosoRecord.DSALES_MontoaDevolver__c = endosos.monto_a_devolver;
                    upsert endosoRecord;
                    updatePolicy(endosos);
                    
                    
                }
            }
            success = true;
            message = '';
            code = '';
        }catch(Exception e){
            success = false;
            message = DSALES_Utility.INTERNAL_ERROR_MSJ+' '+ e.getLineNumber()+' '+e.getCause()+' '+e.getMessage();
            code = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
        }
        
        DSALES_EndorsementWrapper.endorsementResponse responsePayload = new DSALES_EndorsementWrapper.endorsementResponse();
        responsePayload.success = success;
        responsePayload.mensaje_error = message;
        responsePayload.codigo_error = code;
        responsePayload.id_endoso = endosoRecord.id;
        
        return responsePayload;
    }
    
    /*********************************************************************************************************************************************************************
@ Method Name :  updatePolicy
@ Author : Namrata Katore
@ Purpose : method to update Insurance Policy record in salesforce ( if in request endosos status is 'Autorizado')
@ Date : 8/4/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/
    
    
    public static void updatePolicy(DSALES_EndorsementWrapper.endorsementRequest endosos){
        try{
            DSALES_Endoso__c endosoRecord = [SELECT id,DSALES_Poliza__c,DSALES_Poliza__r.Name, DSALES_uid__c FROM DSALES_Endoso__c WHERE DSALES_uid__c=:endosos.uid  LIMIT 1];
            InsurancePolicy poliza = [SELECT id, DSALES_TelefonoContacto__c, DSALES_CorreoElectronico__c,DSALES_NombredelAsegurado__c, DSALES_Placas__c, DSALES_Numeroserie__c,
                                      DSALES_Nmerodemotor__c, ChangeSubtype FROM InsurancePolicy WHERE id=:endosoRecord.DSALES_Poliza__c];
            switch on endosos.tipo_endoso{
                when 'Actualización de correo electrónico'{
                    poliza.DSALES_CorreoElectronico__c = endosos.datos.valor;
                    poliza.ChangeSubtype = 'Endosada';
                    update poliza; 
                }
                when'Actualización de teléfono'{
                    poliza.DSALES_TelefonoContacto__c = endosos.datos.valor;
                    poliza.ChangeSubtype = 'Endosada';
                    update poliza;
                }
                when 'Corrección de nombre'{
                    poliza.DSALES_NombredelAsegurado__c = endosos.datos.valor;
                    poliza.ChangeSubtype = 'Endosada';
                    update poliza; 
                }
                when 'Cambio de placas'{
                    poliza.DSALES_Placas__c = endosos.datos.valor;
                    poliza.ChangeSubtype = 'Endosada';
                    update poliza; 
                }
                when 'Cambio de número de serie'{
                    poliza.DSALES_Numeroserie__c = endosos.datos.valor;
                    poliza.ChangeSubtype = 'Endosada';
                    update poliza; 
                }
                when 'Cambio de número de motor'{
                    poliza.DSALES_Nmerodemotor__c = endosos.datos.valor;
                    poliza.ChangeSubtype = 'Endosada';
                    update poliza; 
                }
            }
        }catch(DmlException e) {
            System.debug('Ocurrió un error: ' + e);
        }
    }
}