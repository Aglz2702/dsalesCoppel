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
                    responsePayload.codigo_error = String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    responsePayload.mensaje_error = DSALES_Utility.BAD_REQUEST_MSJ + e.getLineNumber()+e.getCause()+e.getMessage();
                }catch(Exception e){
                    responsePayload.success = false;
                    responsePayload.codigo_error = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    responsePayload.mensaje_error = DSALES_Utility.INTERNAL_ERROR_MSJ;
                }
            }
        }
        return responsePayload;
        
    }
    
    
    global static  DSALES_AccountWrapper.AccountResponse upsertAccount (DSALES_AccountWrapper.AccountRequest cliente){
        Boolean success = false;
        String message = '';
        String code = '';
        Account accountRecord = new Account();
        try{
            if(cliente.numero_de_cliente == null || cliente.numero_de_cliente ==''){
                for(Account item : [Select id from Account Where FirstName=:cliente.nombre and LastName=:cliente.apellido_paterno and PersonEmail= :cliente.correo_electronico]){
                    accountRecord.Id = item.Id;
                }
            }else{
                for(Account item : [Select id from Account Where CP_WalletCustomerNumber__c =: Decimal.valueOf(cliente.numero_de_cliente)]){
                    accountRecord.Id = item.Id;
                    accountRecord.CP_WalletCustomerNumber__c = Decimal.valueOf(cliente.numero_de_cliente);
                }
            }
            accountRecord.FirstName = cliente.nombre;
            accountRecord.LastName = cliente.apellido_paterno;
            accountRecord.Suffix = cliente.apellido_materno;
            accountRecord.PersonMobilePhone = cliente.telefono;
            accountRecord.PersonEmail = cliente.correo_electronico;
            accountRecord.CP_Gender__pc = cliente.genero;
            accountRecord.PersonBirthdate = cliente.fecha_nacimiento;
            accountRecord.BillingStreet = cliente.domicilio;
            accountRecord.BillingCity =  cliente.nombre_ciudad;
            accountRecord.BillingState = cliente.nombre_estado;
            accountRecord.BillingPostalCode = cliente.codigo_postal;
            upsert accountRecord;
            
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
        responsePayload.mensaje_error = message;
        responsePayload.codigo_error = code;
        responsePayload.id_cuenta = accountRecord.id;
        
        return responsePayload;
    }
}