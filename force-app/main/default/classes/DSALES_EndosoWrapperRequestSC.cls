/*********************************************************************************************************************************************************************
@ Class Name :  DSALES_EndosoWrapperRequestSC
@ Author : Namrata Katore
@ Purpose : exposing service for CARDIF to insert or update Endoso Seguro Celularec record in salesforce
@ Date : 12/10/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/


@RestResource(urlMapping='/insertEndosoSc/*')
global with sharing class DSALES_EndosoWrapperRequestSC {
     
    /*********************************************************************************************************************************************************************
@ Method Name :  createEndosoSc (HttpPost Method)
@ Author : Namrata Katore
@ Purpose : exposing method for CARDIF to insert or update Endoso record in salesforce
@ Date : 12/10/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/
    @HttpPost
    global static DSALES_EndorsementWrapper.EndorsementResponse createEndosoSc(){
        DSALES_EndorsementWrapper.EndorsementResponse responsePayload = new DSALES_EndorsementWrapper.EndorsementResponse();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    System.debug('Datos Recibidos: '+body);
                    DSALES_EndorsementWrapper.EndorsementRequest endoso = (DSALES_EndorsementWrapper.EndorsementRequest)JSON.deserialize(body, DSALES_EndorsementWrapper.EndorsementRequest.class);
                    responsePayload = DSALES_EndosoWrapperRequestHelper.upsertEndosoSc(endoso);
                }catch(JSONException e){
                    responsePayload.success = false;
                    responsePayload.codigoError = String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    responsePayload.mensajeError = DSALES_Utility.BAD_REQUEST_MSJ+' '+ e.getLineNumber()+' '+e.getCause()+' '+e.getMessage();
                }catch(Exception e){
                    responsePayload.success = false;
                    responsePayload.codigoError = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    responsePayload.mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ+' '+ e.getLineNumber()+' '+e.getCause()+' '+e.getMessage();
                }
            }
        }
        
        DSALES_EndorsementWrapper.EndorsementResponse responsePayload1 = new DSALES_EndorsementWrapper.EndorsementResponse();
        responsePayload1.mensaje = responsePayload.mensaje;
        responsePayload1.success = responsePayload.success;
        responsePayload1.mensajeError = responsePayload.mensajeError;
        responsePayload1.codigoError = responsePayload.codigoError;
        responsePayload1.idEndoso = responsePayload.idEndoso;
        String jsonResponse = JSON.serialize(responsePayload1);
        System.debug('Respuesta: '+jsonResponse);
        return responsePayload1; 
    }
}