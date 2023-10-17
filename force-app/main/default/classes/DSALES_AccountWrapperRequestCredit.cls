@RestResource(urlMapping='/insertAccountCredit/*')
global with sharing class DSALES_AccountWrapperRequestCredit {
    
    @HttpPost
    global static DSALES_AccountWrapper.AccountResponse createAccount(){ 
        Boolean success = false;
        String message = '';
        Account accountRecord = new Account();
        
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            
            if(String.isNotBlank(body)){
                try{
                    DSALES_AccountWrapper.AccountRequest clienteCredito = (DSALES_AccountWrapper.AccountRequest)JSON.deserialize(body, DSALES_AccountWrapper.AccountRequest.class);
                    accountRecord.AccountNumber = clienteCredito.numeroCliente;
                    accountRecord.CP_WalletCustomerNumber__c = Decimal.valueOf(clienteCredito.numeroCliente);
                    accountRecord.FirstName = clienteCredito.nombre;
                    //accountRecord.MiddleName = clienteCredito.middle_name;
                    accountRecord.LastName = clienteCredito.apellidoPaterno;
                    accountRecord.Suffix = clienteCredito.apellidoMaterno;
                    accountRecord.PersonMobilePhone = clienteCredito.telefono;
                    accountRecord.PersonEmail = clienteCredito.correoElectronico;
                    //accountRecord.DSALES_Metodocontacto__pc = clienteCredito.contact_method;
                    accountRecord.CP_Gender__pc = clienteCredito.genero;
                    accountRecord.PersonBirthdate = clienteCredito.fechaNacimiento;
                    accountRecord.BillingState = clienteCredito.codigoEstado;
                    accountRecord.BillingCity = clienteCredito.nombreCiudad;
                    accountRecord.BillingCountry = clienteCredito.colonia;
                    accountRecord.BillingStreet = clienteCredito.calle;
                    accountRecord.BillingPostalCode = clienteCredito.codigoPostal;
                    //accountRecord.DSALES_DeseaserContactado__c = clienteCredito.contact_now;
                    
                    //Database.query('SELECT Id FROM Account WHERE CP_WalletCustomerNumber__c =\'' +clienteCredito.client_number+ '\'')
                    list<Account> result = [Select Id from Account WHERE CP_WalletCustomerNumber__c =:Decimal.valueOf(clienteCredito.numeroCliente)];
                    if(result.size()!= 0){
                        success = false;
                        message = 'An account already exists';
                    }else{
                        insert accountRecord;
                        success = true;
                        message = 'Account successfully saved';
                    }
                }catch(Exception e){
                    success = false;
                    message = 'Error: ' + e.getMessage();
                }
            }
        }
        DSALES_AccountWrapper.AccountResponse responsePayload = new DSALES_AccountWrapper.AccountResponse();
        responsePayload.success = success;
        responsePayload.mensajeError = message;
        responsePayload.idCuenta = accountRecord.id;
        return responsePayload;
        
    }	     
}