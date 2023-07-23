@RestResource(urlMapping='/insertAsset/*')
global with sharing class DSALES_AssetWrapperRequest {
    
    @HttpPost
    global static DSALES_AssetWrapper.AssetResponse crearAsset()
    {
        DSALES_AssetWrapper.AssetResponse responsePayload = new DSALES_AssetWrapper.AssetResponse();
        if(RestContext.request != null){
            String cuerpo = System.RestContext.request.requestBody.toString();
            
            if(String.isNotBlank(cuerpo)){
                try{
                    DSALES_AssetWrapper.AssetRequest producto = (DSALES_AssetWrapper.AssetRequest)JSON.deserialize(cuerpo, DSALES_AssetWrapper.AssetRequest.class);
                    responsePayload = insertaAssets(producto);
                }
                catch(Exception.JSONException e)
                {
                    responsePayload.exito = false;
                    responsePayload.mensajeError = DSALES_Utility.BAD_REQUEST_MSJ;
                    responsePayload.codigoError=String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    
                }
                catch(Exception e){
                    responsePayload.exito = false;
                   
                    responsePayload.mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ + ' '+e.GetMessage() ;
                    responsePayload.codigoError=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    
                    
                }
            }
            
        }
        return responsePayload;
    }
    
    global static DSALES_AssetWrapper.AssetResponse insertaAssets(DSALES_AssetWrapper.AssetRequest product){
        String recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Garantia Extendida').getRecordTypeId();
        String recordProductTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Garantía Extendida').getRecordTypeId();
        Boolean exito=false;
        String mensaje='';
        String codigo='';
        Asset assetRegistro = new Asset();
        DSALES_Categoria__c categoria= new DSALES_Categoria__c(); 
        DSALES_Clase__c clase=new  DSALES_Clase__c();
        DSALES_Familia__c familia = new 	DSALES_Familia__c();
        
        try{
            system.debug('Product: '+product);   
            
            if(product.categoria!=null)
            {
                categoria=[SELECT id FROM DSALES_categoria__c WHERE name=:product.categoria WITH SECURITY_ENFORCED LIMIT 1 ];    
            }
            else if (product.clase!=null)
            {
                clase=[SELECT id FROM DSALES_clase__c WHERE name=:product.clase WITH SECURITY_ENFORCED];    
            }
            else if (product.familia!=null)
            {
                familia=[SELECT id FROM DSALES_familia__c WHERE name=:product.familia WITH SECURITY_ENFORCED];
            }
            
            if(!String.isEmpty(product.idProducto))
            {
                
                Product2 producto=[SELECT Id,RecordTypeId FROM Product2 WHERE Id=:product.idProducto WITH SECURITY_ENFORCED LIMIT 1 ];
               
                    assetRegistro.Product2Id=producto.id;
                
                
            }
            assetRegistro.RecordTypeId=recordTypeId;
            assetRegistro.AccountId=product.idCuenta;                    
            assetRegistro.Name=product.articulo;                   
            assetRegistro.ContactId=product.idContacto;
            assetRegistro.DSALES_TipoProducto__c=product.tipoProducto;
            assetRegistro.DSALES_TipoSeguro__c=product.tipoSeguro;
            assetRegistro.DSALES_TipoServicio__c=product.tipoServicio;
            assetRegistro.DSALES_CategoriaBuscar__c=categoria.id;
            assetRegistro.DSALES_ClaseBuscar__c=clase.id;
            assetRegistro.DSALES_FamiliaBuscar__c=familia.id;
            assetRegistro.Status=product.estado;
            assetRegistro.DSALES_VigenciaMeses__c=product.meses;
            assetRegistro.DSALES_SKU__c=product.skuDeTangible;
            assetRegistro.dsalesIdSecuencia__c=product.idSecuencia;
            //assetRegistro.DSALES_DuracionGEX__c=product.warranty_duration;
            assetRegistro.SerialNumber=product.numeroSerie;
            assetRegistro.PurchaseDate=product.fechaCompra;
            assetRegistro.Quantity=product.cantidad;
            assetRegistro.DSales_Marca__c=product.marca;
            assetRegistro.DSales_Modelo__c=product.modelo;
            assetRegistro.Description=product.descripcion; 
            assetRegistro.DSales_Informacion_pago__c=product.idPago;
            system.debug('JSON: '+json.serialize(assetRegistro));
            
        if (Asset.SObjectType.getDescribe().isCreateable()) 
            {
            insert assetRegistro;
            }
            
            
            
            exito = true;
            mensaje = '';  
        }catch(Exception e){
            
            exito = false;
            mensaje =  e.GetMessage() + e.GetLineNumber();
            codigo=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
            
        }
        
        
        DSALES_AssetWrapper.AssetResponse responsePayload = new DSALES_AssetWrapper.AssetResponse();
        responsePayload.exito = exito;
        responsePayload.mensajeError = mensaje;
        responsePayload.codigoError=codigo;
        responsePayload.idAsset = assetRegistro.id;
        
        return responsePayload;
        
    }
   
}