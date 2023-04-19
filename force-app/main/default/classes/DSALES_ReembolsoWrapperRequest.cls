@RestResource(urlMapping='/insertReembolso/*')

global class DSALES_ReembolsoWrapperRequest {
    
    @HttpPost
    global static  DSALES_ReembolsoWrapper.ReembolsoResponse createReembolso()
    {
        List< String> listaIdsReembolso = new  List<String>();
        Boolean exito=false;
        String codigoError='';
        String mensajeError='';
        DSALES_ReembolsoWrapper.ReembolsoResponse responsePayload= new DSALES_ReembolsoWrapper.ReembolsoResponse();
        if(RestContext.request != null){
            String Body = System.RestContext.request.requestBody.toString();
            
            if(String.isNotBlank(Body)){
                try{
                  
                    List<DSALES_ReembolsoWrapper.ReembolsoRequest>  reembolsosList = (List<DSALES_ReembolsoWrapper.ReembolsoRequest> )JSON.deserialize(body, List<DSALES_ReembolsoWrapper.ReembolsoRequest>.class );
                   responsePayload =insertReembolso(reembolsosList);
                
                   

                }
                
                catch(Exception.JSONException e)
                {
                    exito = false;
                    mensajeError =DSALES_Utility.BAD_REQUEST_MSJ;
                    codigoError =String.valueof(DSALES_Utility.BAD_REQUEST_CODE);
                    
                }
                catch(Exception e){
                    exito = false;
                    mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    codigoError=String.valueof(DSALES_Utility.INTERNAL_ERROR_CODE);
                    
                    
                }
            }
        }
        responsePayload.codigoError=codigoError;

        
        return responsePayload;
        
    }
    global static DSALES_ReembolsoWrapper.ReembolsoResponse insertReembolso(List<DSALES_ReembolsoWrapper.ReembolsoRequest> reembolso){
        System.debug('Reembolso en reembolso:'+reembolso);
        DSALES_ReembolsoWrapper.ReembolsoResponse responsePayload= new DSALES_ReembolsoWrapper.ReembolsoResponse();
        List< DSALES_Reembolso__c> listaReembolso = new  List<DSALES_Reembolso__c>();
        List< String> listaIdsReembolso = new  List<String>();
        try{
            for(DSALES_ReembolsoWrapper.ReembolsoRequest rem:reembolso){
                DSALES_Reembolso__c reembolsoRecord = new DSALES_Reembolso__c();
                reembolsoRecord.DSALES_Comentarios__c=rem.comentarios;
                reembolsoRecord.DSALES_FechaReembolso__c=rem.fechaReembolso;
                reembolsoRecord.DSALES_CantidadReembolsada__c=rem.cantidadReembolsada;
                reembolsoRecord.DSALES_MetododePpago__c=rem.metodoPago;
                reembolsoRecord.DSALES_NumerodeReferencia__c=rem.numeroReferencia;
                reembolsoRecord.NombredelProducto__c=rem.nombreProducto;
                reembolsoRecord.DSALES_NumeroCancelacion__c=rem.numeroCancelacion;
                listaReembolso.add(reembolsoRecord);
            }
            List<String> reembolsoIds= new List<String>();
            System.debug('Insertar reembolso'+listaReembolso);
            insert listaReembolso;
            responsePayload.exito=true;
            responsePayload.codigoError='';
            responsePayload.mensajeError='Reembolsos creados';
            for(DSALES_Reembolso__c rb: listaReembolso){
                reembolsoIds.add(rb.Id);
            }  
            responsePayload.idReembolsos=reembolsoIds;
        }
        catch(Exception e)
        {
          responsePayload.exito = false;
         responsePayload.mensajeError=e.GetMessage() + ' '+ e.GetLineNumber();
         responsePayload.codigoError=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
        }
       
        return responsePayload;
    }
    
    
    
}