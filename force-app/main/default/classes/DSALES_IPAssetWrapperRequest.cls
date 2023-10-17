@RestResource(urlMapping='/insertIPAsset/*')
global with sharing class DSALES_IPAssetWrapperRequest {
    @HttpPost
    global static DSALES_IPAssetWrapper.IPAssetResponse createIPAsset()
    {
        Boolean exito=false;
        String message='';
        Integer code;
        DSALES_IPAssetWrapper.IPAssetResponse policyAssetRes= new DSALES_IPAssetWrapper.IPAssetResponse();
        DSALES_IPAssetWrapper.IPAssetResponse response = new DSALES_IPAssetWrapper.IPAssetResponse();
        DSALES_IPAssetWrapper.Seguro seguro = new DSALES_IPAssetWrapper.Seguro();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    DSALES_IPAssetWrapper.IPAssetRequest policyAsset = (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize(body, DSALES_IPAssetWrapper.IPAssetRequest.class);
                    creacionActivos(policyAsset);
                    exito=true;     
                }catch(Exception.JSONException e){
                        policyAssetRes.exito = false;
                        policyAssetRes.mensajeError = DSALES_Utility.BAD_REQUEST_MSJ;
                        policyAssetRes.codigoError=DSALES_Utility.BAD_REQUEST_CODE;
                        
                }catch(Exception e){
                    System.debug('error: '+e.getLineNumber()+':'+e.getMessage());
                    policyAssetRes.exito = false;
                    policyAssetRes.mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    policyAssetRes.codigoError=DSALES_Utility.INTERNAL_ERROR_CODE;   
                }
            }
        }
        return policyAssetRes;
       
    }	 
    
    global static InsurancePolicyAsset creacionActivos(DSALES_IPAssetWrapper.IPAssetRequest policyAsset){
        InsurancePolicyAsset ipAssetRecord  = new InsurancePolicyAsset();
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Poliza__c,DSALES_IDUniversal__c,DSALES_Nombre_del_Vendedor__c,DSALES_Motoentregada__c, DSALES_Motoexterna__c,DSALES_Seguro__c,DSALES_Cliente__c FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c=:policyAsset.idUniversal WITH SECURITY_ENFORCED LIMIT 1];
        if(policyAsset!=null){
            if(!String.isEmpty(policyAsset.numeroSerie) && policyAsset.imei==null ){
                ipAssetRecord=insertIPAsset(policyAsset,pago);  
            } 
            if( policyAsset.imei!=null){
                ipAssetRecord=crearActivoCelulares(policyAsset,pago); 
            }
            ipAssetRecord.DSALES_InformacionPago__c=pago.Id;
            iPAssetRecord.dsalesCliente__c=pago.DSALES_Cliente__c;
            ipAssetRecord.DSALES_Colaborador__c=pago.DSALES_Nombre_del_Vendedor__c;
            ipAssetRecord.InsurancePolicyId=pago.DSALES_Poliza__c;
            ipAssetRecord.dsalesEstatus__c='Activo';
            ipAssetRecord.AssetName=policyAsset.nombreActivo;
            ipAssetRecord.DSALES_Valorfactura__c=policyAsset.valorFactura;
            ipAssetRecord.DSALES_Tienda__c=policyAsset.claveTienda;
            ipAssetRecord.DSALES_Modelo__c=policyAsset.modelo;
            ipAssetRecord.DSALES_Marca__c=policyAsset.marca;
            if(Schema.sObjectType.InsurancePolicyAsset.isCreateable()) {
                insert ipAssetRecord;
            }else{
                System.debug('Permisos insuficientes para insertar');
            }
        }
        return ipAssetRecord;
    }
    
    global static InsurancePolicyAsset insertIPAsset(DSALES_IPAssetWrapper.IPAssetRequest policyAsset,DSALES_InformacionDePago__c pago){
        InsurancePolicyAsset ipAssetRecord  = new InsurancePolicyAsset();
            pago.DSALES_Motoexterna__c=policyAsset.bajoDemanda; 
            if(pago.DSALES_Seguro__c ==true) {
                String recordType='';
                recordType= Schema.SObjectType.InsurancePolicyAsset.getRecordTypeInfosByName().get('Activo de Póliza SM').getRecordTypeId();
                ipAssetRecord.RecordTypeId=recordType;
                ipAssetRecord.DSALES_Motoexterna__c=policyAsset.bajoDemanda; 
                ipAssetRecord.DSALES_Clavevehicular__c=policyAsset.claveVehicular;
                ipAssetRecord.DSALES_Descripcion__c=policyAsset.descripcion;
                
                ipAssetRecord.DSALES_Numeromotor__c=policyAsset.numeroMotor;
                ipAssetRecord.DSALES_Numeroserie__c=policyAsset.numeroSerie;
                ipAssetRecord.DSALES_Placas__c=policyAsset.placas;
                ipAssetRecord.DSALES_Servicio__c=policyAsset.servicio;
                ipAssetRecord.DSALES_Uso__c  =policyAsset.uso;
                ipAssetRecord.DSALES_emitir_poliza__c=policyAsset.emitirPoliza;
            }
            
            if(DSALES_InformacionDePago__c.SObjectType.getDescribe().isUpdateable()) {
                update pago;   
            }
            else{
                System.debug('Permisos insuficientes para actualizar');   
            } 
        return ipAssetRecord;
    }

    global static InsurancePolicyAsset crearActivoCelulares(DSALES_IPAssetWrapper.IPAssetRequest policyAsset,DSALES_InformacionDePago__c pago){
        String recordType='';
        InsurancePolicyAsset ipAssetRecord  = new InsurancePolicyAsset();
        recordType= Schema.SObjectType.InsurancePolicyAsset.getRecordTypeInfosByName().get('Activo de poliza SC').getRecordTypeId();
        ipAssetRecord.RecordTypeId=recordType;
        ipAssetRecord.dsalesAlmacenamiento__c=policyAsset.almacenamiento;
        ipAssetRecord.dsalesCPU__c=policyAsset.cpu;
        ipAssetRecord.dsalesTamanoPantalla__c=policyAsset.tamanoPantalla;
        ipAssetRecord.dsalesPrecio__c=policyAsset.precio;
        ipAssetRecord.dsalesIMEI__c=policyAsset.imei;
        ipAssetRecord.dsalesRAM__c=policyAsset.ram;
        ipAssetRecord.dsalesOperadorTelefonico__c=policyAsset.operadorTelefonico;
        ipAssetRecord.dsalesAnio__c=policyAsset.annio;
        ipAssetRecord.dsalesColor__c=policyAsset.color;  
        ipAssetRecord.DSALES_emitir_poliza__c=policyAsset.emitirPoliza;
        ipAssetRecord.DSALES_Numeroserie__c=policyAsset.numeroSerie;
        return ipAssetRecord;             
    }
    public class WrapperReturn{
        DSALES_IPAssetWrapper.ListaPartidasOportunidad listaPartidasOportunidad{get;set;}
        DSALES_IPAssetWrapper.Seguro seguro {get;set;}
    }
}