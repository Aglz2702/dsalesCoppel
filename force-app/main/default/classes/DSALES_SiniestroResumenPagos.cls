@RestResource(urlMapping='/insertClaimPaymentSummary/*')
global with sharing class DSALES_SiniestroResumenPagos {
    @HttpPost
    global static DSALES_SiniestroRPWrapper.SiniestroRPResponse createSiniestroRP()
    {
        Boolean success=false;
        String message='';
        Integer code;
        Claim siniestro =  new Claim();
        if(RestContext.request != null){
            String Body = System.RestContext.request.requestBody.toString();
            
            if(String.isNotBlank(Body)){
                List<ClaimPaymentSummary> listaPagos = new List<ClaimPaymentSummary>();
                try{
                    DSALES_SiniestroRPWrapper.SiniestroRPRequest SiniestroRP = (DSALES_SiniestroRPWrapper.SiniestroRPRequest)JSON.deserialize(body, DSALES_SiniestroRPWrapper.SiniestroRPRequest.class);
                    siniestro=[SELECT Id FROM Claim WHERE id=:SiniestroRP.claimpayment_info LIMIT 1];
                        
                    for (DSALES_SiniestroRPWrapper.listaSiniestros aux : SiniestroRP.listSiniestro) {
                        ClaimPaymentSummary SiniestroRPRecord = new ClaimPaymentSummary();
                            SiniestroRPRecord.ClaimId=siniestro.Id;
                            SiniestroRPRecord.PaymentAmount= aux.payment_amount;
                            SiniestroRPRecord.Name = aux.claimpayment_name;
                            SiniestroRPRecord.DSALES_Tipopago__c= aux.payment_type;
                            SiniestroRPRecord.PaymentDate= aux.payment_date;
                            listaPagos.add(SiniestroRPRecord);
                    }
                            
							insert listaPagos;
                            
                             
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
        responsePayload.success = success;
        responsePayload.error_message = message;
        responsePayload.error_code = code;
        responsePayload.claimpayment_id = siniestro.Id;
        
         
        return responsePayload;
        
    }	     
}