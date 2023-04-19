@RestResource(urlMapping='/insertClaimPaymentSummary/*')
global with sharing class DSALES_SiniestroResumenPagos {
    @HttpPost
    global static DSALES_SiniestroRPWrapper.SiniestroRPResponse crearSiniestro()
    {
        Boolean success=false;
        String message='';
        Integer code;
        Claim siniestro =  new Claim();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            
            if(String.isNotBlank(body)){
                List<ClaimPaymentSummary> listaPagos = new List<ClaimPaymentSummary>();
                try{
                    DSALES_SiniestroRPWrapper.SiniestroRPRequest siniestroRp = (DSALES_SiniestroRPWrapper.SiniestroRPRequest)JSON.deserialize(body, DSALES_SiniestroRPWrapper.SiniestroRPRequest.class);
                    siniestro=[SELECT Id FROM Claim WHERE id=:siniestroRp.infoResumenPago WITH SECURITY_ENFORCED LIMIT 1];
                    
                    for (DSALES_SiniestroRPWrapper.ListaSiniestros aux : siniestroRp.listSiniestro) {
                        ClaimPaymentSummary siniestroRpRecord = new ClaimPaymentSummary();
                            siniestroRpRecord.ClaimId=siniestro.Id;
                            siniestroRpRecord.PaymentAmount= aux.cantidadPago;
                            siniestroRpRecord.Name = aux.nombrePagoSiniestro;
                            siniestroRpRecord.DSALES_Tipopago__c= aux.tipoPago;
                            siniestroRpRecord.PaymentDate= aux.fechaPago;
                            listaPagos.add(siniestroRpRecord);
                    }

                    if(Schema.sObjectType.ClaimPaymentSummary.isCreateable()) {

                        insert listaPagos;
                        }else{
                        
                        System.debug('Permisos insuficientes para insertar');
                        }
                        
                            
                             
                        success = true;
                    
                }catch(Exception.JSONException ed){
                    success =false;
                    message= DSALES_Utility.BAD_REQUEST_MSJ;
                    code= DSALES_Utility.BAD_REQUEST_CODE;

                }catch(Exception e){
                    success =false;
                    message= DSALES_Utility.INTERNAL_ERROR_MSJ;
                    code= DSALES_Utility.INTERNAL_ERROR_CODE; 
                }
                
            }
        }
        DSALES_SiniestroRPWrapper.SiniestroRPResponse responsePayload = new DSALES_SiniestroRPWrapper.SiniestroRPResponse();
        responsePayload.exitoso = success;
        responsePayload.mensajeError = message;
        responsePayload.codigoError = code;
        responsePayload.idPagoSiniestro = siniestro.Id;
        
         
        return responsePayload;
        
    }	     
} 