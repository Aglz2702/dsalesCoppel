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
                    responsePayload.success = false;
                    responsePayload.error_message = DSALES_Utility.BAD_REQUEST_MSJ;
                    responsePayload.error_code=String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    
                }
                catch(Exception e){
                    responsePayload.success = false;
                    responsePayload.error_message = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    responsePayload.error_code=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    
                    
                }
            }
            
        }
        return responsePayload;
    }
    
    global static DSALES_AssetWrapper.AssetResponse insertAssets(DSALES_AssetWrapper.AssetRequest product){
        Boolean success=false;
        String message='';
         String code='';
        Asset assetRecord = new Asset();
       DSALES_Categoria__c categoria= new DSALES_Categoria__c(); 
         DSALES_Clase__c clase=new  DSALES_Clase__c();
        DSALES_familia__c familia = new DSALES_familia__c();
          
                try{
                 system.debug('Product: '+product);   
                  
                    if(product.category!=null)
                    {
                    	 categoria=[SELECT id FROM DSALES_categoria__c WHERE name=:product.category LIMIT 1];    
                    }
                    else if (product.class_type!=null)
                    {
                    clase=[SELECT id FROM DSALES_clase__c WHERE name=:product.class_type];    
                    }
                    else if (product.family!=null)
                        {
                             familia=[SELECT id FROM DSALES_familia__c WHERE name=:product.family];
                        }
                    
                    
                    
                    //cuando se crea un cliente, será de crédito/contado.
                    // if(product.client_number!=null || product.client_number!='')
                    //{
                    //Account cliente =[SELECT Id FROM ACCOUNT WHERE CP_WalletCustomerNumber__c=:Double.valueOf(product.client_number) LIMIT 1];  
                    //assetRecord.AccountId=cliente.id;
                    //}
                    
                    
                    
                    assetRecord.AccountId=product.account_id;                    
                    assetRecord.Name=product.name;                   
                    assetRecord.ContactId=product.contact_id;
                    assetRecord.DSALES_TipoProducto__c=product.product_type;
                    assetRecord.DSALES_TipoSeguro__c=product.insurance_type;
                    assetRecord.DSALES_TipoServicio__c=product.service_type;
                    assetRecord.DSALES_CategoriaBuscar__c=categoria.id;
                    assetRecord.DSALES_ClaseBuscar__c=clase.id;
                    assetRecord.DSALES_FamiliaBuscar__c=familia.id;
                    assetRecord.Status=product.status;
                    assetRecord.DSALES_VigenciaMeses__c=product.months;
                    assetRecord.DSALES_SKU__c=product.sku;
                    //assetRecord.DSALES_DuracionGEX__c=product.warranty_duration;
                    assetRecord.SerialNumber=product.serial_number;
                    assetRecord.PurchaseDate=product.purchase_date;
                    assetRecord.Quantity=product.quantity;
                    assetRecord.DSales_Marca__c=product.brand;
                    assetRecord.DSales_Modelo__c=product.model;
                    assetRecord.Description=product.description; 
                    system.debug('JSON: '+json.serialize(assetRecord));
                    insert assetRecord;
                    
                  //  if(assetRecord.DSALES_SKU__c=='658019' &&  assetRecord.Status=='Adquirido'){
                  //   createQuote(assetRecord,product.sku);
                        
                  //  }
                    success = true;
                    message = '';
                    system.debug('Product Creado ');
                   
                    
                    
                    
                }catch(Exception e){
                    
                    success = false;
                    message = DSALES_Utility.INTERNAL_ERROR_MSJ;
                  code=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    
                }
            
        
        DSALES_AssetWrapper.AssetResponse responsePayload = new DSALES_AssetWrapper.AssetResponse();
        responsePayload.success = success;
        responsePayload.error_message = message;
        responsePayload.error_code=code;
        responsePayload.Asset_id = AssetRecord.id;
        
        return responsePayload;
        
    }
    /*
    public static void createQuote(Asset updateAsset, String sku){
        if( sku=='658019' && updateAsset.Status== 'Adquirido'){
            updateAsset.DSALES_TipoServicio__c='Garantía Extendida';
            updateAsset.DSALES_VigenciaMeses__c = '12';
            updateAsset.DSALES_DuracionGEX__c = '12';
            update updateAsset;
            
            String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Garantía Extendida').getRecordTypeId();            
            String recordTypeQuoteId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Venta de Garantía Extendida').getRecordTypeId();             
            Account cliente =[SELECT Id,FirstName, LastName FROM ACCOUNT where Id=: updateAsset.AccountId LIMIT 1];  
            
            opportunity opp = new opportunity();
            opp.AccountId = updateAsset.AccountId;
            opp.Name = cliente .FirstName+' '+cliente.LastName;
            opp.CloseDate = date.today()+30;
            opp.StageName = 'Nuevo';
            opp.RecordTypeId = recordTypeId;
            insert opp;
            
            Quote coti= new Quote();
            coti.OpportunityId = opp.Id;
            coti.RecordTypeId =recordTypeQuoteId;
            coti.Name= cliente .FirstName+' '+cliente.LastName;
            insert coti;
            
            List<QuoteLineItem> quoteItem = new List<QuoteLineItem>();
            List<Product2> pro =[ Select Id, Name,StockKeepingUnit from Product2 where StockKeepingUnit=: updateAsset.DSALES_SKU__c]; 
            if(pro!= null && pro.size()>0){                
                QuoteLineItem cotiItem = new QuoteLineItem();
                cotiItem.QuoteId = coti.Id;
                cotiItem.Product2Id = pro[0].Id;            
                cotiItem.DSales_Tipo_de_Producto__c= 'Producto';
                cotiItem.DSales_SKU_Producto__c =sku;
                cotiItem.Vigencia_meses__c='12';
                cotiItem.Quantity = updateAsset.Quantity;
                quoteItem.add(cotiItem) ;
                
                QuoteLineItem item = new QuoteLineItem();  
                item.quoteId = coti.Id;
                item.Product2Id = pro[1].Id;       // need to check
                item.Quantity = 1;
                item.DSales_Tipo_de_Producto__c= 'Servicio';
                item.DSales_SKU_Producto__c ='658019.';
                item.Vigencia_meses__c='12';                             
                quoteItem.add(item);
                
            }
            insert quoteItem; 
            
            System.debug('List of QuoteLineItem is------->'+quoteItem);         
            
        }
        
        
    }
*/
}