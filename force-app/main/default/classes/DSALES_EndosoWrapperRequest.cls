/*********************************************************************************************************************************************************************
@ Class Name :  DSALES_EndosoWrapperRequest
@ Author : Namrata Katore
@ Purpose : exposing service for webhook to insert or update Endoso record in salesforce
@ Date : 5/3/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/


@RestResource(urlMapping='/insertEndoso/*')
global with sharing class DSALES_EndosoWrapperRequest {
    
    /*********************************************************************************************************************************************************************
@ Method Name :  createEndoso (HttpPost Method)
@ Author : Namrata Katore
@ Purpose : exposing method for webhook to insert or update Endoso record in salesforce
@ Date : 5/3/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/
    @HttpPost
    global static DSALES_EndorsementWrapper.EndorsementResponse createEndoso(){
        DSALES_EndorsementWrapper.EndorsementResponse responsePayload = new DSALES_EndorsementWrapper.EndorsementResponse();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    DSALES_EndorsementWrapper.EndorsementRequest endoso = (DSALES_EndorsementWrapper.EndorsementRequest)JSON.deserialize(body, DSALES_EndorsementWrapper.EndorsementRequest.class);
                    responsePayload = DSALES_EndosoWrapperRequestHelper.upsertEndoso(endoso);
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
        return responsePayload;  
    }
}