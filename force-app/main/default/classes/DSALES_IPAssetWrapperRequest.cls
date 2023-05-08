@RestResource(urlMapping='/insertIPAsset/*')
global with sharing class DSALES_IPAssetWrapperRequest {
    @HttpPost
    global static DSALES_IPAssetWrapper.IPAssetResponse createIPAsset()
    {
        //DSALES_IPAssetWrapper.IPAssetResponse policyAssetRes= new DSALES_IPAssetWrapper.IPAssetResponse();
        Boolean success=false;
        String message='';
        Integer code;
        final String ProdutoName='Producto';
        DSALES_IPAssetWrapper.IPAssetResponse policyAssetRes= new DSALES_IPAssetWrapper.IPAssetResponse();
        DSALES_IPAssetWrapper.IPAssetResponse response = new DSALES_IPAssetWrapper.IPAssetResponse();
       // DSALES_IPAssetWrapper.Tangible tangible = new DSALES_IPAssetWrapper.Tangible();
        DSALES_IPAssetWrapper.Seguro seguro = new DSALES_IPAssetWrapper.Seguro();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();

            
            if(String.isNotBlank(body)){
                try{
                    DSALES_IPAssetWrapper.IPAssetRequest policyAsset = (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize(body, DSALES_IPAssetWrapper.IPAssetRequest.class);
                   switch on policyAsset.numeroSerie {
                    when '',null  {
                        System.debug('Error: Está nulo');
                    }
                    when else {
                        processPolicyAsset(policyAsset);
                        //varoables prueba= processPolicyAsset(policyAsset);
                    }
                   }
                               
            }catch(Exception.JSONException e){
                    policyAssetRes.success = false;
                    policyAssetRes.mensajeError = DSALES_Utility.BAD_REQUEST_MSJ;
                    policyAssetRes.codigoError=DSALES_Utility.BAD_REQUEST_CODE;
                    
                }catch(Exception e){
                    System.debug('ERROR SERIVICO ACTIVO EXTERNO');
                    System.debug('error: '+e.getLineNumber()+':'+e.getMessage());
                    policyAssetRes.success = false;
                    policyAssetRes.mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    policyAssetRes.codigoError=DSALES_Utility.INTERNAL_ERROR_CODE;
                    
                    
                }
            }
        }
        //policyAssetRes=prueba.seguro.poliza;
        return policyAssetRes;
       
    }	 
    
    
    global static InsurancePolicyAsset insertIPAsset(DSALES_IPAssetWrapper.IPAssetRequest policyAsset,String idPago){
        System.debug('creación de registro de activo');
        InsurancePolicyAsset ipAssetRecord  = new InsurancePolicyAsset();
        try{
            
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Poliza__c,DSALES_IDUniversal__c,DSALES_Nombre_del_Vendedor__c,DSALES_Motoentregada__c, DSALES_Motoexterna__c,DSALES_Seguro__c,DSALES_Cliente__c FROM DSALES_InformacionDePago__c WHERE Id=:idPago WITH SECURITY_ENFORCED LIMIT 1];
            System.debug('pago:'+pago);
            if(pago.DSALES_Seguro__c ==true) {
                ipAssetRecord.DSALES_InformacionPago__c=pago.Id;
                iPAssetRecord.DSALES_Account__c=pago.DSALES_Cliente__c;
                ipAssetRecord.DSALES_Tienda__c=policyAsset.idTienda;
                ipAssetRecord.DSALES_Colaborador__c=pago.DSALES_Nombre_del_Vendedor__c;
                ipAssetRecord.DSALES_Motoexterna__c=policyAsset.bajoDemanda; 
                ipAssetRecord.DSALES_Valorfactura__c=policyAsset.valorFactura;
                ipAssetRecord.InsurancePolicyId=pago.DSALES_Poliza__c;
                ipAssetRecord.Estatus__c='Activo';
                // ipAssetRecord.DSALES_ClaveAMIS__c=policyAsset.key_amis;
                ipAssetRecord.DSALES_Clavevehicular__c=policyAsset.claveVehicular;
                ipAssetRecord.DSALES_Descripcion__c=policyAsset.descripcion;
                ipAssetRecord.DSALES_Modelo__c=policyAsset.modelo;
                ipAssetRecord.DSALES_Marca__c=policyAsset.marca;
                ipAssetRecord.DSALES_Numeromotor__c=policyAsset.numeroMotor;
                ipAssetRecord.DSALES_Numeroserie__c=policyAsset.numeroSerie;
                ipAssetRecord.DSALES_Placas__c=policyAsset.placas;
                ipAssetRecord.DSALES_Servicio__c=policyAsset.servicio;
                ipAssetRecord.DSALES_Uso__c  =policyAsset.uso;
                ipAssetRecord.AssetName=policyAsset.nombreActivo;
                ipAssetRecord.DSALES_emitir_poliza__c=policyAsset.emitirPoliza;            
                //System.debug('***pago actualizado:***'+pago.DSALES_Motoentregada__c);
                if(policyAsset.bajoDemanda==true){
                    pago.DSALES_Motoexterna__c=policyAsset.bajoDemanda; 
                    actualizarPago(pago);
                }
                if(Schema.sObjectType.InsurancePolicyAsset.isCreateable()) {
                    insert ipAssetRecord;
                }else{
                    System.debug('Permisos insuficientes para insertar');
                }               
                System.debug('Registro ha insertado');
            }
        }catch(Exception e){
            System.debug('ERROR EN ACTIVO SERVICE:'+e.getLineNumber()+':'+e.getMessage());
        }
        //System.debug('activo creado en venta x: '+ipAssetRecord);
        return ipAssetRecord;
    }

    public static WrapperReturn processPolicyAsset(DSALES_IPAssetWrapper.IPAssetRequest policyAsset) {
        DSALES_IPAssetWrapper seguro = new DSALES_IPAssetWrapper();
        WrapperReturn prueba= new WrapperReturn();
        DSALES_InformacionDePago__c pago = [SELECT Id, DSALES_IDUniversal__c, DSALES_Motoexterna__c, DSALES_Poliza__c, DSALES_Poliza__r.PolicyName FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c = :policyAsset.idUniversal WITH SECURITY_ENFORCED];
        InsurancePolicyAsset activo = insertIPAsset(policyAsset, pago.Id);
        if (pago.DSALES_Poliza__c != null && pago.DSALES_Poliza__r.PolicyName != DSALES_Utility.SEGURO_PREDETERMINADO) {
            processInformacionDePago(pago, activo, policyAsset);
            
        }
        // call method DSALES_VentaSMRest.obtenerProductosEnPartidasOportunidad
        //and return this values with variable seguro
        //prueba.listaPartidasOportunidad.idPartidaDeOportunidad
        return prueba;
    }
    public static void actualizarPago(DSALES_InformacionDePago__c pago)
    {
        if(DSALES_InformacionDePago__c.SObjectType.getDescribe().isUpdateable()) {
            update pago;   
        }
        else{
            System.debug('Permisos insuficientes para actualizar');   
        } 
    }
    public static void processInformacionDePago(DSALES_InformacionDePago__c pago, InsurancePolicyAsset activo, DSALES_IPAssetWrapper.IPAssetRequest policyAsset) {
        Boolean success=false;
        DSALES_IPAssetWrapper.Seguro seguro = new DSALES_IPAssetWrapper.Seguro();
        pago.DSALES_Motoexterna__c = true;
        if (activo != null && policyAsset.emitirPoliza == true) {
            Insurancepolicy poliza = DSALES_NuevaPoliza.invokeService(activo);
            seguro.poliza = poliza.Name;
            seguro.urlPdfPoliza = poliza.DSALES_PDF_poliza__c;
            System.debug('SEGURO:' + seguro);
            success = true;
        }

        //return seguro;
    }
 
    public class WrapperReturn{
        DSALES_IPAssetWrapper.ListaPartidasOportunidad listaPartidasOportunidad{get;set;}
        DSALES_IPAssetWrapper.Seguro seguro {get;set;}
    }
}