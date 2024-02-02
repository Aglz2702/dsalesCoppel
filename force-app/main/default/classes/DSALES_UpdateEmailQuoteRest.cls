@RestResource(urlMapping='/actualizarCotizacion')
global with sharing class DSALES_UpdateEmailQuoteRest {
    @HttpPut
    global static DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteResponse actualizarQuote() {
        // Lógica para actualizar la Quote basada en condiciones
        // Aquí deberías implementar las condiciones específicas de tu lógica
        // Por ejemplo, puedes consultar la Quote con el ID proporcionado y actualizar el campo de correo electrónico.
        //DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteRequest quoteRequest= new  DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteRequest();
        DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteResponse quoteResponse= new DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteResponse();
        boolean exito=false;
        String mensajeError='';
        Integer codigoError=0;
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    system.debug('hello');
                    DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteRequest cotizacion =  (DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteRequest)JSON.deserialize(body,  DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteRequest.class);
                    if(!String.isEmpty(cotizacion.idCotizacion)){
                        exito=DSALES_UpdateEmailQuoteRest.auxActualizarQuote(cotizacion);
                        mensajeError='¡Correo enviado exitosamente!';

                    }
                    
                }
                catch(Exception.JSONException e){
                    exito = false;
                    mensajeError= DSALES_Utility.BAD_REQUEST_MSJ;
                    codigoError=DSALES_Utility.BAD_REQUEST_CODE;
                }
                catch(Exception e){
                    System.debug('**ERROR**'+e.getLineNumber()+ ': '+e.getMessage());
                    exito = false;
                    mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ +': '+e.getLineNumber()+ ': '+e.getMessage();
                    codigoError=DSALES_Utility.INTERNAL_ERROR_CODE;
                }
            }


        }
        quoteResponse.codigoError=codigoError;
        quoteResponse.exito=exito;
        quoteResponse.mensaje=mensajeError;

        return quoteResponse;
    }  
        global static Boolean auxActualizarQuote(DSALES_UpdateEmailQuote.DSALES_UpdateEmailQuoteRequest cotizacion){
            Quote cotizaSales = [SELECT Id, DSALES_Contado__c FROM Quote WHERE id=:cotizacion.idCotizacion  WITH SECURITY_ENFORCED limit 1 ];
            if(cotizaSales.DSALES_Contado__c){
                cotizaSales.DSALES_EmailNew__c=cotizacion.correo;
                cotizaSales.DSALES_Enviarcotizacion__c=true;
            }
            else{
                Opportunity oportunidad=  [SELECT Id, AccountId FROM Opportunity where id= :cotizacion.idOportunidad WITH SECURITY_ENFORCED];
                Account cliente=  [SELECT Id FROM Account where id= :oportunidad.AccountId WITH SECURITY_ENFORCED];
                cliente.PersonEmail=cotizacion.correo;
                cotizaSales.Email=cotizacion.correo;
                cotizaSales.DSALES_Enviarcotizacion__c=true;
                if(Account.SObjectType.getDescribe().isUpdateable()) {  
                    update cliente;
                }
            }
            if(Quote.SObjectType.getDescribe().isUpdateable()) {  
                update cotizaSales;
                
            }
            return true;

        }
    }