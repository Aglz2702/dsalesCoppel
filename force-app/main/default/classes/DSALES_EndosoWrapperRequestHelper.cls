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
@ Method Name :  upsertEndosoSm
@ Author : Namrata Katore
@ Purpose : method to insert or update Endoso record in salesforce
@ Date : 5/3/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :9/6/2023
**********************************************************************************************************************************************************************/    
    
    public static DSALES_EndorsementWrapper.EndorsementResponse upsertEndosoSm(DSALES_EndorsementWrapper.EndorsementRequest endosos){
        Integer uidExist = [SELECT COUNT() FROM DSALES_Endoso__c WHERE DSALES_uid__c =:endosos.uid WITH SECURITY_ENFORCED ];
        if(uidExist>0 && endosos.uid!=''){
            //DSALES_EndorsementWrapper.EndorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.insertEndoso(endosos);
            DSALES_EndorsementWrapper.EndorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.updateEndosoSm(endosos);
            return responsePayload;
        }
        else{
            
            //DSALES_EndorsementWrapper.EndorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.updateEndoso(endosos);
            DSALES_EndorsementWrapper.EndorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.insertEndosoSm(endosos);
            return responsePayload;
        }
        
    }
    
    /*********************************************************************************************************************************************************************
@ Method Name :  insertEndosoSm
@ Author : Namrata Katore
@ Purpose : method to insert endoso record of Seguro de Motos in salesforce ( if in request salesforce id is null)
@ Date : 5/3/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/        
    
    public static DSALES_EndorsementWrapper.EndorsementResponse insertEndosoSm(DSALES_EndorsementWrapper.EndorsementRequest endosos){
        Boolean success = false;
        String message = '';
        String code = '';
        String mensaje = '';
        String recordTypeId = Schema.SObjectType.DSALES_Endoso__c.getRecordTypeInfosByName().get('Registro de endoso SM').getRecordTypeId();
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
            endosoRecord.dsalesFechaAutorizacion__c = endosos.fechaAplicacion;
            endosoRecord.RecordTypeId = recordTypeId; 
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
@ Method Name :  updateEndosoSm
@ Author : Namrata Katore
@ Purpose : method to update update record in salesforce ( if in request salesforce id & uid are not null)
@ Date : 5/3/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/
    
    public static DSALES_EndorsementWrapper.EndorsementResponse updateEndosoSm(DSALES_EndorsementWrapper.EndorsementRequest endosos){
        Boolean success = false;
        String message = '';
        String code = '';
        String mensaje = '';
        DSALES_Endoso__c endosoRecord = new DSALES_Endoso__c();
        InsurancePolicy poliza = new InsurancePolicy();        
        try{
            endosoRecord = [SELECT Id, DSALES_Poliza__c, DSALES_Poliza__r.Name, DSALES_uid__c FROM DSALES_Endoso__c WHERE DSALES_uid__c=: endosos.uid AND RecordType.Name ='Registro de endoso SM' WITH SECURITY_ENFORCED LIMIT 1];
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
                    updatePolicySm(endosos);                    
                    
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
@ Method Name :  updatePolicySm
@ Author : Namrata Katore
@ Purpose : method to update Insurance Policy record in salesforce ( if in request endosos status is 'Autorizado')
@ Date : 8/3/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/
    
    
    public static void updatePolicySm(DSALES_EndorsementWrapper.EndorsementRequest endosos){
        try{
            DSALES_Endoso__c endosoRecord = [SELECT Id, DSALES_Poliza__c, DSALES_Poliza__r.Name, DSALES_uid__c FROM DSALES_Endoso__c WHERE DSALES_uid__c=: endosos.uid LIMIT 1];
            System.debug('Datos de endoso:____ '+endosoRecord);
            InsurancePolicy poliza = [SELECT Id, DSALES_TelefonoContacto__c, DSALES_CorreoElectronico__c,DSALES_NombredelAsegurado__c, DSALES_Placas__c, DSALES_Numeroserie__c,
                                      dsalesNumeroDeMotor__c, ChangeSubtype FROM InsurancePolicy WHERE Id=: endosoRecord.DSALES_Poliza__c WITH SECURITY_ENFORCED LIMIT 1];
            System.debug('Datos de poliza:____ '+poliza);
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
    
 /*********************************************************************************************************************************************************************
@ Method Name :  upsertEndosoSc
@ Author : Namrata Katore
@ Purpose : method to insert or update Endoso record in salesforce
@ Date : 12/10/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/    
    
    public static DSALES_EndorsementWrapper.EndorsementResponse upsertEndosoSc(DSALES_EndorsementWrapper.EndorsementRequest endosos){
        Integer uidExist = [SELECT COUNT() FROM DSALES_Endoso__c WHERE DSALES_uid__c =:endosos.uid WITH SECURITY_ENFORCED ];
        if(uidExist>0 && endosos.uid!=''){
            //DSALES_EndorsementWrapper.EndorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.insertEndoso(endosos);
            DSALES_EndorsementWrapper.EndorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.updateEndosoSc(endosos);
            return responsePayload;
        }
        else{
            
            //DSALES_EndorsementWrapper.EndorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.updateEndoso(endosos);
            DSALES_EndorsementWrapper.EndorsementResponse responsePayload = DSALES_EndosoWrapperRequestHelper.insertEndosoSc(endosos);
            return responsePayload;
        }
        
    }   
 /*********************************************************************************************************************************************************************
@ Method Name :  insertEndosoSc
@ Author : Namrata Katore
@ Purpose : method to insert endoso record of Seguro Celulares in salesforce ( if in request salesforce id is null)
@ Date : 12/10/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/        
    
    public static DSALES_EndorsementWrapper.EndorsementResponse insertEndosoSc(DSALES_EndorsementWrapper.EndorsementRequest endosos){
        Boolean success = false;
        String message = '';
        String code = '';
        String mensaje = '';
        String recordTypeId = Schema.SObjectType.DSALES_Endoso__c.getRecordTypeInfosByName().get('Registro de Endoso SC').getRecordTypeId();
        DSALES_Endoso__c endosoRecord = new DSALES_Endoso__c();
        InsurancePolicy poliza = new InsurancePolicy();
        try{
            poliza = [SELECT Id FROM InsurancePolicy WHERE Name =: endosos.numeroPoliza AND recordType.Name = 'Seguro de Celulares' WITH SECURITY_ENFORCED LIMIT 1 ];
            endosoRecord.DSALES_Poliza__c = poliza.Id;
            endosoRecord.DSALES_uid__c = endosos.uid;
            endosoRecord.DSALES_Tipodeendoso__c = endosos.tipoEndoso;
            endosoRecord.DSALES_Tipodedocumento__c = endosos.tipoDocumento;
            endosoRecord.DSALES_Tipodedato__c = endosos.datos.tipoDato;
            endosoRecord.DSALES_Valor__c = endosos.datos.valor;
            endosoRecord.DSALES_Estatus__c = 'Nuevo';
            endosoRecord.dsalesFechaCreacion__c = endosos.fechaEndoso;
            endosoRecord.dsalesFechaAutorizacion__c = endosos.fechaAplicacion;
            endosoRecord.RecordTypeId = recordTypeId; 
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
        responsePayload.idEndoso = endosoRecord.id;
        
        return responsePayload;
        
    }
    
    /*********************************************************************************************************************************************************************
@ Method Name :  updateEndosoSc
@ Author : Namrata Katore
@ Purpose : method to update record in salesforce ( if in request salesforce id & uid are not null)
@ Date : 12/10/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/
    
    public static DSALES_EndorsementWrapper.EndorsementResponse updateEndosoSc(DSALES_EndorsementWrapper.EndorsementRequest endosos){
        Boolean success = false;
        String message = '';
        String code = '';
        String mensaje = '';
        DSALES_Endoso__c endosoRecord = new DSALES_Endoso__c();
        InsurancePolicy poliza = new InsurancePolicy();        
        try{
            endosoRecord = [SELECT Id, DSALES_Poliza__c, DSALES_Poliza__r.Name, DSALES_uid__c FROM DSALES_Endoso__c WHERE DSALES_uid__c=: endosos.uid AND RecordType.Name ='Registro de Endoso SC' WITH SECURITY_ENFORCED LIMIT 1];
            switch on endosos.estatus{
                when 'En tramite'{
                    endosoRecord.DSALES_Estatus__c = 'En tramite';
                    if (DSALES_Endoso__c.SObjectType.getDescribe().isUpdateable()) {
                        upsert endosoRecord;
                    } 
                    else {
                        System.debug('Permisos insuficientes para actualizar');
                    }
                }
                when 'Requerimiento de Información'{
                    endosoRecord.DSALES_Estatus__c = 'Requerimiento de Información';
                    endosoRecord.DSALES_SolucionDevolucion__c = endosos.solucion;
                    upsert endosoRecord;
                    
                }
                when 'Rechazado'{
                    endosoRecord.DSALES_Estatus__c = 'Rechazado';
                    endosoRecord.DSALES_MotivoRechazo__c = endosos.estatusComentario;
                    upsert endosoRecord;
                }
                when 'Autorizado'{
                    endosoRecord.DSALES_Estatus__c = 'Autorizado';
                    //endosoRecord.DSALES_MontoaDevolver__c = endosos.montoDevolucion;
                    updatePolicySc(endosos);   
                    upsert endosoRecord;
                                     
                    
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
@ Method Name :  updatePolicySc
@ Author : Namrata Katore
@ Purpose : method to update Insurance Policy record in salesforce ( if in request endosos status is 'Autorizado')
@ Date : 12/10/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/
    
    
    public static void updatePolicySc(DSALES_EndorsementWrapper.EndorsementRequest endosos){
        try{
            DSALES_Endoso__c endosoRecord = [SELECT Id, DSALES_Poliza__c, DSALES_Poliza__r.Name, DSALES_uid__c FROM DSALES_Endoso__c WHERE DSALES_uid__c=: endosos.uid LIMIT 1];
            System.debug('Datos de endoso:____ '+endosoRecord);
            InsurancePolicy poliza = [SELECT Id, DSALES_TelefonoContacto__c, DSALES_CorreoElectronico__c,DSALES_NombredelAsegurado__c, DSALES_Placas__c, DSALES_Numeroserie__c,
                                      dsalesNumeroDeMotor__c, ChangeSubtype FROM InsurancePolicy WHERE Id=: endosoRecord.DSALES_Poliza__c AND recordType.Name = 'Seguro de Celulares' LIMIT 1];
            System.debug('Datos de poliza:____ '+poliza);
            switch on endosos.tipoEndoso{
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
                when 'Cancelación de póliza'{
                    poliza.dsalesEstatusPoliza__c = 'Cancelada';
                    poliza.ChangeSubtype = 'Endosada';
                    update poliza; 
                }                
            }
        }catch(DmlException e) {
            System.debug('Ocurrió un error: ' + e.getLineNumber()+''+e.getMessage());
        }
    }
}