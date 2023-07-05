@RestResource(urlMapping='/insertAccount/*')
global with sharing class DSALES_AccountWrapperRequest {
    
    @HttpPost
    global static DSALES_AccountWrapper.AccountResponse createAccount(){ 
        Boolean success = false;
        String message = '';
        Account accountRecord = new Account();
        DSALES_AccountWrapper.AccountResponse responsePayload = new DSALES_AccountWrapper.AccountResponse();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            
            if(String.isNotBlank(body)){
                try{
                    DSALES_AccountWrapper.AccountRequest cliente = (DSALES_AccountWrapper.AccountRequest)JSON.deserialize(body, DSALES_AccountWrapper.AccountRequest.class);
                    responsePayload = upsertAccount(cliente);
                }catch(JSONException e){
                    responsePayload.success = false;
                    responsePayload.codigoError = String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    responsePayload.mensajeError = DSALES_Utility.BAD_REQUEST_MSJ + e.getLineNumber()+e.getCause()+e.getMessage();
                }catch(Exception e){
                    responsePayload.success = false;
                    responsePayload.codigoError = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    responsePayload.mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ;
                }
            }
        }
        return responsePayload;
        
    }
    
    
    public static  DSALES_AccountWrapper.AccountResponse upsertAccount (DSALES_AccountWrapper.AccountRequest cliente){
        Boolean success = false;
        String message = '';
        String code = '';
        Account accountRecord = new Account();
        System.debug('datos de cliente antes de buscar:'+cliente);
        try{
            if(cliente.numeroCliente == null || String.isEmpty(cliente.numeroCliente)){
                for(Account item : [Select id from Account Where FirstName=:cliente.nombre and LastName=:cliente.apellidoPaterno and PersonEmail= :cliente.correoElectronico WITH SECURITY_ENFORCED]){
                    accountRecord.Id = item.Id;
                }
            }else{
                for(Account item : [Select id from Account Where CP_WalletCustomerNumber__c =: Decimal.valueOf(cliente.numeroCliente) WITH SECURITY_ENFORCED]){
                    accountRecord.Id = item.Id;
                    accountRecord.CP_WalletCustomerNumber__c = Decimal.valueOf(cliente.numeroCliente);
                }
            }
            accountRecord.dsalesRfc__c=cliente.rfc;
            accountRecord.FirstName = cliente.nombre;
            accountRecord.LastName = cliente.apellidoPaterno;
            accountRecord.Suffix = cliente.apellidoMaterno;
            accountRecord.PersonMobilePhone = cliente.telefono;
            accountRecord.PersonEmail = cliente.correoElectronico;
            System.debug('Genero antes de asignar:'+cliente.genero);
            accountRecord.CP_Gender__pc=asignarGenero(cliente.genero);
            System.debug('Genero despues de asignar:'+accountRecord.CP_Gender__pc);
            //accountRecord.CP_Gender__pc = cliente.genero;
            accountRecord.PersonBirthdate = cliente.fechaNacimiento;
            accountRecord.BillingStreet = cliente.calle;
            accountRecord.BillingCity =  cliente.nombreCiudad;
            accountRecord.BillingState = cliente.nombreEstado;
            accountRecord.BillingPostalCode = cliente.codigoPostal;
            if(!String.isEmpty(cliente.numeroInterior))
            {
                accountRecord.dsalesNumeroInterior__c=Decimal.valueOf(cliente.numeroInterior);
            }
            
            accountRecord.dsalesNumeroExterior__c=Decimal.valueOf(cliente.numeroExterior);
            accountRecord.CP_BillingStateCode__c=cliente.codigoEstado; //clave de estado en SM
            if(!String.isEmpty(cliente.codigoColonia)){
                accountRecord.dsalesCodigoColonia__c=Decimal.valueOf(cliente.codigoColonia); //clave colonia SM
            }
            if(!String.isEmpty(cliente.colonia)){ // gex
                accountRecord.BillingStreet=cliente.calle + ', ' + cliente.colonia;
            }
            
            System.debug('Datos del cliente: '+accountRecord);
            System.debug('Datos del cliente: '+accountRecord.Id + ' ' + accountRecord.FirstName + ' ' + accountRecord.LastName);
            if(Schema.sObjectType.Account.isCreateable() && Schema.sObjectType.Account.isUpdateable()){
                upsert accountRecord;
                System.debug('cuenta actualizada'+accountRecord);
            } else {
                System.debug('Permisos insuficientes para actualizar');
            }
            
            success = true;
            message = '';
            code = '';
            
        }catch(Exception e){
            success = false;
            message = DSALES_Utility.INTERNAL_ERROR_MSJ + e.getMessage() + e.getLineNumber();
            code = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
        }
        
        
        DSALES_AccountWrapper.AccountResponse responsePayload = new DSALES_AccountWrapper.AccountResponse();
        responsePayload.success = success;
        responsePayload.mensajeError = message;
        responsePayload.codigoError = code;
        responsePayload.idCuenta = accountRecord.id;
        
        return responsePayload;
    }

    public static String asignarGenero(String genero){
        String generoAsignado='';
        if(genero=='Femenino'){
            generoAsignado= 'F';
        }
        else if(genero=='Masculino'){
            generoAsignado= 'M';
        }
        if(genero=='M' || genero=='F'){
            generoAsignado =genero;
        }
        return generoAsignado;
    }
}