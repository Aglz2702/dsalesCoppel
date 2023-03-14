/*********************************************************************************************************************************************************************
 @ Class Name :  DSALES_EndosoWrapperRequest
 @ Author : Namrata Katore
 @ Purpose : exposing service for webhook to insert or update Endoso record in salesforce
 @ Date : 5/4/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
 @ Change History :
**********************************************************************************************************************************************************************/


@RestResource(urlMapping='/insertEndoso/*')
global with sharing class DSALES_EndosoWrapperRequest {
  
/*********************************************************************************************************************************************************************
 @ Method Name :  createEndoso (HttpPost Method)
 @ Author : Namrata Katore
 @ Purpose : exposing method for webhook to insert or update Endoso record in salesforce
 @ Date : 5/4/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
 @ Change History :
**********************************************************************************************************************************************************************/
    @HttpPost
    global static DSALES_EndorsementWrapper.endorsementResponse createEndoso(){
        DSALES_EndorsementWrapper.endorsementResponse responsePayload = new DSALES_EndorsementWrapper.endorsementResponse();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    DSALES_EndorsementWrapper.endorsementRequest endoso = (DSALES_EndorsementWrapper.endorsementRequest)JSON.deserialize(body, DSALES_EndorsementWrapper.endorsementRequest.class);
                    responsePayload = DSALES_EndosoWrapperRequestHelper.upsertEndoso(endoso);
                 }catch(JSONException e){
                    responsePayload.success = false;
                    responsePayload.codigo_error = String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    responsePayload.mensaje_error = DSALES_Utility.BAD_REQUEST_MSJ+' '+ e.getLineNumber()+' '+e.getCause()+' '+e.getMessage();
                }catch(Exception e){
                    responsePayload.success = false;
                    responsePayload.codigo_error = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    responsePayload.mensaje_error = DSALES_Utility.INTERNAL_ERROR_MSJ+' '+ e.getLineNumber()+' '+e.getCause()+' '+e.getMessage();
                }
            }
        }
        return responsePayload;  
    }
}