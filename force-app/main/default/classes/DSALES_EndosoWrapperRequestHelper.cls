/*********************************************************************************************************************************************************************
@ Class Name :  DSALES_EndosoWrapperRequestHelper
@ Author : Namrata Katore
@ Purpose : Helper class for webhook to insert or update Endoso record in salesforce
@ Date : 5/3/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/

public without sharing class DSALES_EndosoWrapperRequestHelper{

/*********************************************************************************************************************************************************************
@ Method Name :  upsertEndoso
@ Author : Namrata Katore
@ Purpose : method to insert or update Endoso record in salesforce
@ Date : 5/3/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/    

public static DSALES_EndorsementWrapper.EndorsementResponse upsertEndoso(DSALES_EndorsementWrapper.EndorsementRequest endosos){
    Integer uidExist = [SELECT COUNT() FROM DSALES_Endoso__c WHERE DSALES_uid__c =:endosos.uid WITH SECURITY_ENFORCED ];
    if(uidExist>0 && endosos.uid!=''){
        //DSALES_EndorsementWrapper.EndorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.insertEndoso(endosos);
        DSALES_EndorsementWrapper.EndorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.updateEndoso(endosos);
        return responsePayload;
    }
    else{
       
        //DSALES_EndorsementWrapper.EndorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.updateEndoso(endosos);
         DSALES_EndorsementWrapper.EndorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.insertEndoso(endosos);
        return responsePayload;
    }
        
}

/*********************************************************************************************************************************************************************
@ Method Name :  insertEndoso
@ Author : Namrata Katore
@ Purpose : method to insert endoso record in salesforce ( if in request salesforce id is null)
@ Date : 5/3/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/        

public static DSALES_EndorsementWrapper.EndorsementResponse insertEndoso(DSALES_EndorsementWrapper.EndorsementRequest endosos){
    Boolean success = false;
    String message = '';
    String code = '';
    String mensaje = '';
    DSALES_Endoso__c endosoRecord = new DSALES_Endoso__c();
    InsurancePolicy poliza = new InsurancePolicy();
    try{
        poliza = [SELECT Id FROM InsurancePolicy WHERE Name =: endosos.numeroPoliza WITH SECURITY_ENFORCED LIMIT 1 ];
        endosoRecord.DSALES_Poliza__c = poliza.Id;
        endosoRecord.DSALES_uid__c = endosos.uid;
        endosoRecord.DSALES_Tipodeendoso__c = endosos.tipoEndoso;
        endosoRecord.DSALES_Tipodedocumento__c = endosos.tipoDocumento;
        endosoRecord.DSALES_Tipodedato__c = endosos.datos.tipoDato;
        endosoRecord.DSALES_Valor__c = endosos.datos.valor;
        endosoRecord.DSALES_Estatus__c = 'Nuevo';
        endosoRecord.dsalesFechaCreacion__c = endosos.fechaEndoso;
        endosoRecord.DSALES_MotivoDevolucion__c = endosos.estatusComentario;
        endosoRecord.DSALES_SolucionDevolucion__c = endosos.solucion;
        endosoRecord.DSALES_MotivoRechazo__c = endosos.estatusComentario;
        endosoRecord.DSALES_MontoaDevolver__c = endosos.montoDevolucion;
        if(Schema.sObjectType.DSALES_Endoso__c.isCreateable()){
            insert endosoRecord;           
            }
            else{            
            System.debug('Permisos insuficientes para insertar');           
            }
        success = true;
        message = '';
        code = '';
        mensaje = 'Endoso creado';
        
    }catch(Exception e){
        success = false;
        message = DSALES_Utility.INTERNAL_ERROR_MSJ+' '+ e.getLineNumber()+' '+e.getCause()+' '+e.getMessage();
        code = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
    }
    
    DSALES_EndorsementWrapper.EndorsementResponse responsePayload = new DSALES_EndorsementWrapper.EndorsementResponse();
    responsePayload.mensaje = mensaje;
    responsePayload.success = success;
    responsePayload.mensajeError = message;
    responsePayload.codigoError = code;
    responsePayload.idEndoso = endosoRecord.Id;
    
    return responsePayload;
}

/*********************************************************************************************************************************************************************
@ Method Name :  updateEndoso
@ Author : Namrata Katore
@ Purpose : method to update update record in salesforce ( if in request salesforce id & uid are not null)
@ Date : 5/3/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/

public static DSALES_EndorsementWrapper.EndorsementResponse updateEndoso(DSALES_EndorsementWrapper.EndorsementRequest endosos){
    Boolean success = false;
    String message = '';
    String code = '';
    String mensaje = '';
    DSALES_Endoso__c endosoRecord = new DSALES_Endoso__c();
    InsurancePolicy poliza = new InsurancePolicy();        
    try{
        endosoRecord = [SELECT Id, DSALES_Poliza__c, DSALES_Poliza__r.Name, DSALES_uid__c FROM DSALES_Endoso__c WHERE DSALES_uid__c=: endosos.uid WITH SECURITY_ENFORCED LIMIT 1];
        switch on endosos.estatus{
            when 'En proceso'{
                endosoRecord.DSALES_Estatus__c = 'En tramite';
                if (DSALES_Endoso__c.SObjectType.getDescribe().isUpdateable()) {
                    upsert endosoRecord;
                    } 
                else {
                    System.debug('Permisos insuficientes para actualizar');
                    }
            }
            when 'Pendiente de información'{
                endosoRecord.DSALES_Estatus__c = 'Requerimiento de Información';
                endosoRecord.DSALES_MotivoDevolucion__c = endosos.estatusComentario;
                endosoRecord.DSALES_SolucionDevolucion__c = endosos.solucion;
                upsert endosoRecord;
            }
            when 'Rechazo'{
                endosoRecord.DSALES_Estatus__c = 'Rechazado';
                endosoRecord.DSALES_MotivoRechazo__c = endosos.estatusComentario;
                upsert endosoRecord;
            }
            when 'Finalizado'{
                endosoRecord.DSALES_Estatus__c = 'Autorizado';
                endosoRecord.DSALES_MontoaDevolver__c = endosos.montoDevolucion;
                upsert endosoRecord;
                updatePolicy(endosos);                    
                
            }
        }
        success = true;
        message = '';
        code = '';
        mensaje = 'Endoso actualizado';
    }catch(Exception e){
        success = false;
        message = DSALES_Utility.INTERNAL_ERROR_MSJ+' '+ e.getLineNumber()+' '+e.getCause()+' '+e.getMessage();
        code = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
    }
    
    DSALES_EndorsementWrapper.EndorsementResponse responsePayload = new DSALES_EndorsementWrapper.EndorsementResponse();
    responsePayload.mensaje = mensaje;
    responsePayload.success = success;
    responsePayload.mensajeError = message;
    responsePayload.codigoError = code;
    responsePayload.idEndoso = endosoRecord.id;
    
    return responsePayload;
}

/*********************************************************************************************************************************************************************
@ Method Name :  updatePolicy
@ Author : Namrata Katore
@ Purpose : method to update Insurance Policy record in salesforce ( if in request endosos status is 'Autorizado')
@ Date : 8/3/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/


public static void updatePolicy(DSALES_EndorsementWrapper.EndorsementRequest endosos){
    try{
        DSALES_Endoso__c endosoRecord = [SELECT Id, DSALES_Poliza__c, DSALES_Poliza__r.Name, DSALES_uid__c FROM DSALES_Endoso__c WHERE DSALES_uid__c=: endosos.uid WITH SECURITY_ENFORCED LIMIT 1];
        InsurancePolicy poliza = [SELECT Id, DSALES_TelefonoContacto__c, DSALES_CorreoElectronico__c,DSALES_NombredelAsegurado__c, DSALES_Placas__c, DSALES_Numeroserie__c,
                                    dsalesNumeroDeMotor__c, ChangeSubtype FROM InsurancePolicy WHERE Id=: endosoRecord.DSALES_Poliza__c WITH SECURITY_ENFORCED LIMIT 1];
        switch on endosos.tipoEndoso{
            when 'Actualización de correo electrónico'{
                poliza.DSALES_CorreoElectronico__c = endosos.datos.valor;
                poliza.ChangeSubtype = 'Endosada';
            if (InsurancePolicy.SObjectType.getDescribe().isUpdateable()) {
                update poliza;
                } 
            else {
                System.debug('Permisos insuficientes para actualizar');
                }
            //update poliza; 
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
                poliza.dsalesNumeroDeMotor__c = endosos.datos.valor;
                poliza.ChangeSubtype = 'Endosada';
                update poliza; 
            }
        }
    }catch(DmlException e) {
        System.debug('Ocurrió un error: ' + e.getLineNumber()+''+e.getMessage());
    }
}
}