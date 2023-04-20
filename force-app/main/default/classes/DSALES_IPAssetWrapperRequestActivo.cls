@RestResource(urlMapping='/insertIPAssetDelivered/*')
global with sharing class DSALES_IPAssetWrapperRequestActivo {
    @HttpPost
    global static DSALES_IPAssetWrapper.IPAssetResponse createIPAsset(){
        Boolean success=false;
        String message='';
        Integer code;
        Boolean emitirPoliza=true;
        String idActivo='';
        final String ProdutoName='Producto';
        DSALES_IPAssetWrapper.IPAssetResponse policyAssetRes= new DSALES_IPAssetWrapper.IPAssetResponse();
        DSALES_IPAssetWrapper.IPAssetResponse response = new DSALES_IPAssetWrapper.IPAssetResponse();
        List<DSALES_IPAssetWrapper.ListaPartidasOportunidad> listaPartidas = new List<DSALES_IPAssetWrapper.ListaPartidasOportunidad>();
        DSALES_IPAssetWrapper.Seguro seguro = new DSALES_IPAssetWrapper.Seguro();
        if(RestContext.request != null){
            String Body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(Body)){
                try{
                    DSALES_IPAssetWrapper.IPAssetRequest policyAsset = (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize(body, DSALES_IPAssetWrapper.IPAssetRequest.class);
                  	DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_IDUniversal__c,	DSALES_Oportunidad__c,DSALES_Motoentregada__c,DSALES_Poliza__c,DSALES_Poliza__r.PolicyName FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c=:policyAsset.idUniversal];
					pago.DSALES_Motoentregada__c=true;	
                    for(OpportunityLineItem partidasSeguro: [SELECT Id,Name, Product2Id, Product2.DSales_Tipo_de_Producto__c, DSALES_Estatus__c
                                          FROM OpportunityLineItem WHERE OpportunityId=:pago.DSALES_Oportunidad__c AND Product2.DSales_Tipo_de_Producto__c=:'Seguro']){
                       if(partidasSeguro.DSALES_Estatus__c=='Devuelto' || partidasSeguro.DSALES_Estatus__c=='Cancelado' ){
                        	      emitirPoliza=false;                    
                       }                                             
                    }
                    
                    if(policyAsset.numeroSerie!=''){
                        InsurancePolicyAsset activo= insertIPAsset(policyAsset);
                        if(pago.DSALES_Poliza__c!=null){
                            if(policyAsset.emitirPoliza==true && emitirPoliza==true){
                                if(pago.DSALES_Poliza__r.PolicyName!= DSALES_Utility.SEGURO_PREDETERMINADO){
                                    if( activo!=null){
                                        Insurancepolicy poliza=DSALES_NuevaPoliza.invokeService(activo);  
                                        success=true;
                                        seguro.poliza=poliza.Name;
                                        seguro.urlPdfPoliza= poliza.DSALES_PDF_poliza__c;
                                        System.debug('SEGURO:'+seguro);  
                                        System.debug('POLIZA DESPUES DE EMITIR:'+poliza); 
                                        idActivo=poliza.DSALES_Activodeplizadeseguro__c;
                                        
                                    }
                                }
                                
                            }
                            else{
                                insert activo;
                                idActivo=activo.Id;
                                //if(pago.DSALES_Poliza__c!=null){
                                    InsurancePolicy polizaActivo = [SELECT Id FROM InsurancePolicy WHERE Id=:pago.DSALES_Poliza__c];//agregar datos de activo en póliza
                                    polizaActivo.DSALES_Activodeplizadeseguro__c=activo.Id;
                                    polizaActivo.DSALES_Clavevehicular__c=activo.DSALES_Clavevehicular__c;
                                    polizaActivo.DSALES_Modelo__c=activo.DSALES_Modelo__c;
                                    polizaActivo.DSALES_Numeroserie__c=activo.DSALES_Numeroserie__c;
                                    polizaActivo.DSALES_Nmerodemotor__c=activo.DSALES_Numeromotor__c;
                                    polizaActivo.DSALES_Descripcion__c=activo.DSALES_Descripcion__c;
                                    polizaActivo.DSALES_Servicio__c=activo.DSALES_Servicio__c;
                                    polizaActivo.DSALES_Placas__c=activo.DSALES_Placas__c;
                                    polizaActivo.DSALES_Marca__c=activo.DSALES_Marca__c;
                                    polizaActivo.DSALES_Uso__c=activo.DSALES_Uso__c;
                                    update polizaActivo;
                                    
                               // }
                            }
                            
                        }
                        else{
                            insert activo;
                            InsurancePolicy universalPoliza = [SELECT Id, Name  FROM InsurancePolicy where  Name=:DSALES_Utility.SEGURO_PREDETERMINADO];
                            pago.DSALES_Poliza__c=universalPoliza.Id;
                        }
						
                        
                        String idOportunidad=pago.DSALES_Oportunidad__c;
                        List<DSALES_VentaSMRest.WrapperDatosProductos> productosSincronisados=DSALES_VentaSMRest.obtenerProductosEnPartidasOportunidad(idOportunidad);
                        for(DSALES_VentaSMRest.WrapperDatosProductos listSin:productosSincronisados){
                            DSALES_IPAssetWrapper.ListaPartidasOportunidad listp= new  DSALES_IPAssetWrapper.ListaPartidasOportunidad ();
                            listp.idPartidaDeOportunidad=listSin.oliId;
                            listp.nombreProducto=listSin.nombreProducto;
                            listp.sku=listSin.sku;
                            listaPartidas.add(listp);
                        }
                        success=true;
                        update pago;
                    }    ///num-se
                }catch(Exception.JSONException e)
                {
                    policyAssetRes.success = false;
                    policyAssetRes.mensajeError = DSALES_Utility.BAD_REQUEST_MSJ;
                    policyAssetRes.codigoError=DSALES_Utility.BAD_REQUEST_CODE;
                    
                }
                catch(Exception e){
                    System.debug('**ERROR**'+e.getLineNumber()+ ': '+e.getMessage());
                    policyAssetRes.success = false;
                    policyAssetRes.mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    policyAssetRes.codigoError=DSALES_Utility.INTERNAL_ERROR_CODE;
                    
                    
                }
            }
        }

        policyAssetRes.success=success;
        policyAssetRes.idActivo=idActivo;
        policyAssetRes.ListaPartidasOportunidad=listaPartidas;
        policyAssetRes.Seguro=seguro;
        
        return policyAssetRes;
       
    }	 
    
    
    global static InsurancePolicyAsset insertIPAsset(DSALES_IPAssetWrapper.IPAssetRequest policyAsset){
        Boolean success=false;
        String message='';
        Integer code;

        InsurancePolicyAsset IPassetRecord  = new InsurancePolicyAsset();
        try {
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Poliza__c,DSALES_Nombre_del_Vendedor__c,DSALES_Motoentregada__c, DSALES_Motoexterna__c,DSALES_Seguro__c,DSALES_Cliente__c FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c=:policyAsset.idUniversal LIMIT 1];
            if(pago.DSALES_Seguro__c ==true ) {
                IPassetRecord.DSALES_InformacionPago__c=pago.Id;
                IPassetRecord.DSALES_Account__c=pago.DSALES_Cliente__c;
                IPassetRecord.DSALES_Tienda__c=policyAsset.idTienda;
                IPassetRecord.DSALES_Colaborador__c=pago.DSALES_Nombre_del_Vendedor__c;
                IPassetRecord.DSALES_Motoexterna__c=policyAsset.bajoDemanda; 
                IPassetRecord.DSALES_Valorfactura__c=policyAsset.valorFactura;
                IPassetRecord.InsurancePolicyId=pago.DSALES_Poliza__c;
                IPassetRecord.Estatus__c='Activo';
                IPassetRecord.DSALES_Clavevehicular__c=policyAsset.claveVehicular;
                IPassetRecord.DSALES_Descripcion__c=policyAsset.descripcion;
                IPassetRecord.DSALES_Modelo__c=policyAsset.modelo;
                IPassetRecord.DSALES_Marca__c=policyAsset.marca;
                IPassetRecord.DSALES_Numeromotor__c=policyAsset.numeroMotor;
                IPassetRecord.DSALES_Numeroserie__c=policyAsset.numeroSerie;
                IPassetRecord.DSALES_Placas__c=policyAsset.placas;
                IPassetRecord.DSALES_Servicio__c=policyAsset.servicio;
                IPassetRecord.DSALES_Uso__c  =policyAsset.uso;
                IPassetRecord.AssetName=policyAsset.nombreActivo;
                IPassetRecord.DSALES_emitir_poliza__c=policyAsset.emitirPoliza;            
                success = true; 
              
            }
            if(pago.DSALES_Seguro__c ==false ) {
                InsurancePolicy poliza = [SELECT Id, Name  FROM InsurancePolicy where  Name=:DSALES_Utility.SEGURO_PREDETERMINADO];
                System.debug('poliza domi'+poliza);
                IPassetRecord.DSALES_InformacionPago__c=pago.Id;
                IPassetRecord.DSALES_Account__c=pago.DSALES_Cliente__c;
                IPassetRecord.DSALES_Tienda__c=policyAsset.idTienda;
                IPassetRecord.DSALES_Colaborador__c=pago.DSALES_Nombre_del_Vendedor__c;
                IPassetRecord.DSALES_Motoexterna__c=policyAsset.bajoDemanda; 
                IPassetRecord.DSALES_Valorfactura__c=policyAsset.valorFactura;
                IPassetRecord.InsurancePolicyId= poliza.Id;
                IPassetRecord.Estatus__c='Activo';
                IPassetRecord.DSALES_Clavevehicular__c=policyAsset.claveVehicular;
                IPassetRecord.DSALES_Descripcion__c=policyAsset.descripcion;
                IPassetRecord.DSALES_Modelo__c=policyAsset.modelo;
                IPassetRecord.DSALES_Marca__c=policyAsset.marca;
                IPassetRecord.DSALES_Numeromotor__c=policyAsset.numeroMotor;
                IPassetRecord.DSALES_Numeroserie__c=policyAsset.numeroSerie;
                IPassetRecord.DSALES_Placas__c=policyAsset.placas;
                IPassetRecord.DSALES_Servicio__c=policyAsset.servicio;
                IPassetRecord.DSALES_Uso__c  =policyAsset.uso;
                IPassetRecord.AssetName=policyAsset.nombreActivo;
                IPassetRecord.DSALES_emitir_poliza__c=policyAsset.emitirPoliza;            
                success = true; 
              
            }
        } catch (Exception e) {
            success = false;
            message = DSALES_Utility.INTERNAL_ERROR_MSJ;
            code=DSALES_Utility.INTERNAL_ERROR_CODE;
            System.debug('ERROR ACTIVO:'+e.getLineNumber()+e.getMessage());
        }


        return IPassetRecord;
    }
    
}