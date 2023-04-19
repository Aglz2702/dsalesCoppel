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
        try{
            if(cliente.numeroCliente == null || cliente.numeroCliente ==''){
                for(Account item : [Select id from Account Where FirstName=:cliente.nombre and LastName=:cliente.apellidoPaterno and PersonEmail= :cliente.correoElectronico WITH SECURITY_ENFORCED]){
                    accountRecord.Id = item.Id;
                }
            }else{
                for(Account item : [Select id from Account Where CP_WalletCustomerNumber__c =: Decimal.valueOf(cliente.numeroCliente) WITH SECURITY_ENFORCED]){
                    accountRecord.Id = item.Id;
                    accountRecord.CP_WalletCustomerNumber__c = Decimal.valueOf(cliente.numeroCliente);
                }
            }
            accountRecord.FirstName = cliente.nombre;
            accountRecord.LastName = cliente.apellidoPaterno;
            accountRecord.Suffix = cliente.apellidoMaterno;
            accountRecord.PersonMobilePhone = cliente.telefono;
            accountRecord.PersonEmail = cliente.correoElectronico;
            accountRecord.CP_Gender__pc = cliente.genero;
            accountRecord.PersonBirthdate = cliente.fechaNacimiento;
            accountRecord.BillingStreet = cliente.domicilio;
            accountRecord.BillingCity =  cliente.nombreCiudad;
            accountRecord.BillingState = cliente.nombreEstado;
            accountRecord.BillingPostalCode = cliente.codigoPostal;
            
            if(Schema.sObjectType.Account.isCreateable() && Schema.sObjectType.Account.isUpdateable()){
                upsert accountRecord;
            } else {
                System.debug('Permisos insuficientes para actualizar');
            }
            
            success = true;
            message = '';
            code = '';
            
        }catch(Exception e){
            success = false;
            message = DSALES_Utility.INTERNAL_ERROR_MSJ;
            code = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
        }
        
        
        DSALES_AccountWrapper.AccountResponse responsePayload = new DSALES_AccountWrapper.AccountResponse();
        responsePayload.success = success;
        responsePayload.mensajeError = message;
        responsePayload.codigoError = code;
        responsePayload.idCuenta = accountRecord.id;
        
        return responsePayload;
    }
}