@RestResource(urlMapping='/insertIPAsset/*')
global with sharing class DSALES_IPAssetWrapperRequest {
    @HttpPost
    global static DSALES_IPAssetWrapper.IPAssetResponse createIPAsset()
    {
        DSALES_IPAssetWrapper.IPAssetResponse policyAssetRes= new DSALES_IPAssetWrapper.IPAssetResponse();
        if(RestContext.request != null){
            String Body = System.RestContext.request.requestBody.toString();

            
            if(String.isNotBlank(Body)){
                try{
                    DSALES_IPAssetWrapper.IPAssetRequest policyAsset = (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize(body, DSALES_IPAssetWrapper.IPAssetRequest.class);
                    policyAssetRes= insertIPAsset(policyAsset);

                    
                }catch(Exception.JSONException e)
                {
                    policyAssetRes.success = false;
                    policyAssetRes.mensaje_error = DSALES_Utility.BAD_REQUEST_MSJ;
                    policyAssetRes.codigo_error=DSALES_Utility.BAD_REQUEST_CODE;
                    
                }
                catch(Exception e){
                    policyAssetRes.success = false;
                    policyAssetRes.mensaje_error = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    policyAssetRes.codigo_error=DSALES_Utility.INTERNAL_ERROR_CODE;
                    
                    
                }
            }
        }

        return policyAssetRes;
       
    }	 
    
    
    global static DSALES_IPAssetWrapper.IPAssetResponse insertIPAsset(DSALES_IPAssetWrapper.IPAssetRequest policyAsset)
    {
        Boolean success=false;
        String message='';
        Integer code;

        InsurancePolicyAsset IPassetRecord  = new InsurancePolicyAsset();



        try {
            //Account cliente =[SELECT Id,Name FROM ACCOUNT WHERE Id=:policyAsset.client_id LIMIT 1];
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Poliza__c, DSALES_Motoexterna__c,DSALES_Seguro__c,DSALES_Cliente__c FROM DSALES_InformacionDePago__c WHERE id=:policyAsset.id_pago];
            if(pago.DSALES_Seguro__c ==true) {
                IPassetRecord.DSALES_InformacionPago__c=pago.Id;
                IPassetRecord.DSALES_Account__c=pago.DSALES_Cliente__c;
                IPassetRecord.DSALES_Tienda__c=policyAsset.id_tienda;
                //IPassetRecord.DSALES_Colaborador__c=policyAsset.partner;
                IPassetRecord.DSALES_Motoexterna__c=policyAsset.bajo_demanda; 
                IPassetRecord.DSALES_Valorfactura__c=policyAsset.valor_factura;
                IPassetRecord.InsurancePolicyId=pago.DSALES_Poliza__c;
                IPassetRecord.Estatus__c='Activo';
               // IPassetRecord.DSALES_ClaveAMIS__c=policyAsset.key_amis;
                IPassetRecord.DSALES_Clavevehicular__c=policyAsset.clave_vehicular;
                IPassetRecord.DSALES_Descripcion__c=policyAsset.descripcion;
                IPassetRecord.DSALES_Modelo__c=policyAsset.modelo;
                IPassetRecord.DSALES_Marca__c=policyAsset.marca;
                IPassetRecord.DSALES_Numeromotor__c=policyAsset.numero_motor;
                IPassetRecord.DSALES_Numeroserie__c=policyAsset.numero_serie;
                IPassetRecord.DSALES_Placas__c=policyAsset.placas;
                IPassetRecord.DSALES_Servicio__c=policyAsset.servicio;
                IPassetRecord.DSALES_Uso__c  =policyAsset.uso;
                IPassetRecord.AssetName=policyAsset.nombre_activo;
                if(policyAsset.bajo_demanda==true){
                    pago.DSALES_Motoexterna__c=true;
                }             
                
                insert IPassetRecord;
                update pago;
                
                success = true;  
            }
            
        } catch (Exception e) {
            success = false;
            message = DSALES_Utility.INTERNAL_ERROR_MSJ;
            code=DSALES_Utility.INTERNAL_ERROR_CODE;
        }

        DSALES_IPAssetWrapper.IPAssetResponse responsePayload = new DSALES_IPAssetWrapper.IPAssetResponse();
        responsePayload.success = success;
        responsePayload.codigo_error=code;
        responsePayload.mensaje_error = message;
        responsePayload.id_activo = IPAssetRecord.id;
        
        return responsePayload;

        

    }
    

}