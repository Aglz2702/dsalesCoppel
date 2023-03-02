@RestResource(urlMapping='/insertReembolso/*')
global class DSALES_ReembolsoWrapperRequest {
    @HttpPost
    global static  DSALES_ReembolsoWrapper.ReembolsoResponse createReembolso()
    {
        String id_reembolso='';
        Boolean exito=false;
        String codigo_error='';
        String mensaje_error='';
        
        
        DSALES_ReembolsoWrapper.ReembolsoResponse responsePayload= new DSALES_ReembolsoWrapper.ReembolsoResponse();
        if(RestContext.request != null){
            String Body = System.RestContext.request.requestBody.toString();
            
            if(String.isNotBlank(Body)){
                try{
                    DSALES_ReembolsoWrapper.ReembolsoRequest reembolso = (DSALES_ReembolsoWrapper.ReembolsoRequest)JSON.deserialize(body, DSALES_ReembolsoWrapper.ReembolsoRequest.class);
                    //responsePayload = insertReembolso(reembolso);
                    DSALES_Reembolso__c reembolsoRecord = new DSALES_Reembolso__c();
                    List<DSALES_InformacionDePago__c> buscarPago=[SELECT Id FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal__c=:reembolso.pago_universal];
                    if(buscarPago.size()>0)
                    {
                        reembolsoRecord.DSALES_InformaciondePago__c=buscarPago[0].id;
                    }
                    reembolsoRecord.DSALES_Comentarios__c=reembolso.comentarios;
                    reembolsoRecord.DSALES_Fecha__c=reembolso.fecha;
                    reembolsoRecord.Cantidad__c=reembolso.cantidad;
                    reembolsoRecord.DSALES_MetododePpago__c=reembolso.metodo_pago;
                    reembolsoRecord.DSALES_NumerodeReferencia__c=reembolso.numero_referencia;
                    
                    insert reembolsoRecord;
                    
                     id_reembolso=reembolsoRecord.Id;
                     exito=true;
                     codigo_error='';
                     mensaje_error='Reembolso creado';
                }
                
                catch(Exception.JSONException e)
                {
                    exito = false;
                    mensaje_error =e.GetMessage();
                    codigo_error=String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    
                }
                catch(Exception e){
                   exito = false;
                  mensaje_error = e.GetMessage();
                    codigo_error=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    
                    
                }
            }
        }
        responsePayload.id_reembolso=id_reembolso;
        responsePayload.exito=exito;
         responsePayload.mensaje_error=mensaje_error;
         responsePayload.codigo_error=codigo_error;
        return responsePayload;
        
    }
    
    
}