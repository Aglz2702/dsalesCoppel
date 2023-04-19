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
            String Body = System.RestContext.request.requestBody.toString();

            
            if(String.isNotBlank(Body)){
                try{
                    DSALES_IPAssetWrapper.IPAssetRequest policyAsset = (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize(body, DSALES_IPAssetWrapper.IPAssetRequest.class);
                    if(policyAsset.numero_serie!=''){
                        InsurancePolicyAsset activo= insertIPAsset(policyAsset,'');
                        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_IDUniversal__c,	DSALES_Motoexterna__c,DSALES_Poliza__c,DSALES_Poliza__r.PolicyName FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal__c=:policyAsset.id_universal];
                        if(pago.DSALES_Poliza__c!=null && pago.DSALES_Poliza__r.PolicyName!= DSALES_Utility.SEGURO_PREDETERMINADO){
                            pago.DSALES_Motoexterna__c=true;
                            if( activo!=null && policyAsset.emitir_poliza==true){
                                Insurancepolicy poliza=DSALES_NuevaPoliza.invokeService(activo);
                                /*System.debug('OPORTUNITY DE POLIZA: '+poliza.SourceOpportunityId);
                                String idOportunidad=poliza.SourceOpportunityId;
                                List<OpportunityLineItem> partidasSincro =[SELECT Id,Name,Product2Id FROM OpportunityLineItem WHERE OpportunityId=:idOportunidad];
                                System.debug('PARTIDAS SINCRO: '+partidasSincro.size());
                                List<String> idsProducts= new list<String>();
                                List<String> idsPartidas= new list<String>();
                                System.debug('--------------------------------------------');
                                System.debug('PARTIDAS SINCRO: '+partidasSincro);
                                if(partidasSincro!=null){
                                    for(OpportunityLineItem opSincro:partidasSincro){
                                        System.debug('PRODUCTOS EN OPSINCRO'+opSincro);
                                        idsProducts.add(opSincro.Product2Id);
                                        idsPartidas.add(opSincro.Id);
                                    }
                                }
                                System.debug('Produtos ids:'+idsProducts);
                                System.debug('--------------------------------------------');
                                System.debug('--------------------------------------------');
                                Product2 productos= [SELECT Id, Name,StockKeepingUnit FROM Product2 WHERE Id IN:idsProducts AND DSales_Tipo_de_Producto__c='Producto' LIMIT 1]; 
                                System.debug('PRODUCTOS: '+productos);
                                System.debug('--------------------------------------------');
                                update pago;
                                System.debug('activo de partida en ws: '+ poliza.DSALES_Activodeplizadeseguro__c);
                                tangible.id_activo=poliza.DSALES_Activodeplizadeseguro__c;
                                tangible.id_universal=pago.DSALES_IDUniversal__c;
                                tangible.sku=productos.StockKeepingUnit;
                                tangible.partida_de_oportunidad=  idsPartidas;
                                System.debug('TANGIBLE: '+tangible);*/
                                seguro.poliza=poliza.Name;
                                seguro.url_pdf_poliza= poliza.DSALES_PDF_poliza__c;
                                System.debug('SEGURO:'+seguro);  
                                success=true;      
                            }
                        }
                    }
                }catch(Exception.JSONException e)
                {
                    policyAssetRes.success = false;
                    policyAssetRes.mensaje_error = DSALES_Utility.BAD_REQUEST_MSJ;
                    policyAssetRes.codigo_error=DSALES_Utility.BAD_REQUEST_CODE;
                    
                }
                catch(Exception e){
                    System.debug('ERROR SERIVICO ACTIVO EXTERNO');
                    System.debug('error: '+e.getLineNumber()+':'+e.getMessage());
                    policyAssetRes.success = false;
                    policyAssetRes.mensaje_error = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    policyAssetRes.codigo_error=DSALES_Utility.INTERNAL_ERROR_CODE;
                    
                    
                }
            }
        }

        return policyAssetRes;
       
    }	 
    
    
    global static InsurancePolicyAsset insertIPAsset(DSALES_IPAssetWrapper.IPAssetRequest policyAsset,String idPago){
        System.debug('creación de registro de activo');
        InsurancePolicyAsset IPassetRecord  = new InsurancePolicyAsset();
        try{
            
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Poliza__c,DSALES_IDUniversal__c,DSALES_Nombre_del_Vendedor__c,DSALES_Motoentregada__c, DSALES_Motoexterna__c,DSALES_Seguro__c,DSALES_Cliente__c FROM DSALES_InformacionDePago__c WHERE Id=:idPago LIMIT 1];
            System.debug('pago:'+pago);
            if(pago.DSALES_Seguro__c ==true) {
                IPassetRecord.DSALES_InformacionPago__c=pago.Id;
                IPassetRecord.DSALES_Account__c=pago.DSALES_Cliente__c;
                IPassetRecord.DSALES_Tienda__c=policyAsset.id_tienda;
                IPassetRecord.DSALES_Colaborador__c=pago.DSALES_Nombre_del_Vendedor__c;
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
                IPassetRecord.DSALES_emitir_poliza__c=policyAsset.emitir_poliza;            
                //System.debug('***pago actualizado:***'+pago.DSALES_Motoentregada__c);
                if(policyAsset.bajo_demanda==true){
                    pago.DSALES_Motoexterna__c=policyAsset.bajo_demanda;
                    update pago;
                }
                insert IPassetRecord;
                System.debug(IPassetRecord);
            }
        }catch(Exception e){
            System.debug('ERROR EN ACTIVO SERVICE:'+e.getLineNumber()+':'+e.getMessage());
        }
        System.debug('activo creado en venta x: '+IPassetRecord);
        return IPassetRecord;
    }
 
}