@RestResource(urlMapping='/insertAsset/*')
global with sharing class DSALES_AssetWrapperRequest {
    @HttpPost
    global static DSALES_AssetWrapper.AssetResponse createAsset()
    {
        DSALES_AssetWrapper.AssetResponse responsePayload = new DSALES_AssetWrapper.AssetResponse();
        if(RestContext.request != null){
            String Body = System.RestContext.request.requestBody.toString();
            
            if(String.isNotBlank(Body)){
                try{
                    DSALES_AssetWrapper.AssetRequest producto = (DSALES_AssetWrapper.AssetRequest)JSON.deserialize(body, DSALES_AssetWrapper.AssetRequest.class);
                    responsePayload = insertAssets(producto);
                }
                catch(Exception.JSONException e)
                {
                    responsePayload.exito = false;
                    responsePayload.mensaje_error = DSALES_Utility.BAD_REQUEST_MSJ;
                    responsePayload.codigo_error=String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    
                }
                catch(Exception e){
                    responsePayload.exito = false;
                   
                    responsePayload.mensaje_error = DSALES_Utility.INTERNAL_ERROR_MSJ + ' '+e.GetMessage() ;
                    responsePayload.codigo_error=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    
                    
                }
            }
            
        }
        return responsePayload;
    }
    
    global static DSALES_AssetWrapper.AssetResponse insertAssets(DSALES_AssetWrapper.AssetRequest product){
        String recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Garantia Extendida').getRecordTypeId();
        String recordProductTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Garantía Extendida').getRecordTypeId();
        Boolean success=false;
        String message='';
        String code='';
        Asset assetRecord = new Asset();
        DSALES_Categoria__c categoria= new DSALES_Categoria__c(); 
        DSALES_Clase__c clase=new  DSALES_Clase__c();
        DSALES_familia__c familia = new DSALES_familia__c();
        
        try{
            system.debug('Product: '+product);   
            
            if(product.categoria!=null)
            {
                categoria=[SELECT id FROM DSALES_categoria__c WHERE name=:product.categoria LIMIT 1];    
            }
            else if (product.clase!=null)
            {
                clase=[SELECT id FROM DSALES_clase__c WHERE name=:product.clase];    
            }
            else if (product.familia!=null)
            {
                familia=[SELECT id FROM DSALES_familia__c WHERE name=:product.familia];
            }
            
            if(!String.isEmpty(product.id_producto))
            {
                Product2 producto=[SELECT Id,RecordTypeId FROM Product2 WHERE Id=:product.id_producto LIMIT 1];
               
                    assetRecord.Product2Id=producto.id;
                
            }
            assetRecord.RecordTypeId=recordTypeId;
            assetRecord.AccountId=product.id_cuenta;                    
            assetRecord.Name=product.articulo;                   
            assetRecord.ContactId=product.id_contacto;
            assetRecord.DSALES_TipoProducto__c=product.tipo_producto;
            assetRecord.DSALES_TipoSeguro__c=product.tipo_seguro;
            assetRecord.DSALES_TipoServicio__c=product.tipo_servicio;
            assetRecord.DSALES_CategoriaBuscar__c=categoria.id;
            assetRecord.DSALES_ClaseBuscar__c=clase.id;
            assetRecord.DSALES_FamiliaBuscar__c=familia.id;
            assetRecord.Status=product.estado;
            assetRecord.DSALES_VigenciaMeses__c=product.meses;
            assetRecord.DSALES_SKU__c=product.sku_de_tangible;
            //assetRecord.DSALES_DuracionGEX__c=product.warranty_duration;
            assetRecord.SerialNumber=product.numero_serie;
            assetRecord.PurchaseDate=product.fecha_compra;
            assetRecord.Quantity=product.cantidad;
            assetRecord.DSales_Marca__c=product.marca;
            assetRecord.DSales_Modelo__c=product.modelo;
            assetRecord.Description=product.descripcion; 
            assetRecord.DSales_Informacion_pago__c=product.id_pago;
            system.debug('JSON: '+json.serialize(assetRecord));
            insert assetRecord;
            
            success = true;
            message = '';  
        }catch(Exception e){
            
            success = false;
            message = DSALES_Utility.INTERNAL_ERROR_MSJ + e.GetMessage() + e.GetLineNumber();
            code=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
            
        }
        
        
        DSALES_AssetWrapper.AssetResponse responsePayload = new DSALES_AssetWrapper.AssetResponse();
        responsePayload.exito = success;
        responsePayload.mensaje_error = message;
        responsePayload.codigo_error=code;
        responsePayload.id_ASSET = AssetRecord.id;
        
        return responsePayload;
        
    }
}