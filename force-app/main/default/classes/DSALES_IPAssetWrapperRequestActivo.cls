@RestResource(urlMapping='/insertIPAssetDelivered/*')
global with sharing class DSALES_IPAssetWrapperRequestActivo {
    @HttpPost
    global static DSALES_IPAssetWrapper.IPAssetResponse createIPAsset(){
        Boolean success=false;
        String message='';
        Integer code;
        Boolean emitirPoliza=true;
        final String ProdutoName='Producto';
        IPAssetAux1Wrapper data=new IPAssetAux1Wrapper();
        DSALES_IPAssetWrapper.IPAssetResponse policyAssetRes= new DSALES_IPAssetWrapper.IPAssetResponse();
        DSALES_IPAssetWrapper.IPAssetResponse response = new DSALES_IPAssetWrapper.IPAssetResponse();
        List<DSALES_IPAssetWrapper.ListaPartidasOportunidad> listaPartidas = new List<DSALES_IPAssetWrapper.ListaPartidasOportunidad>();
        DSALES_IPAssetWrapper.Seguro seguro = new DSALES_IPAssetWrapper.Seguro();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            switch on body {
                when '',null  {
                    System.debug('Error: Viene vacío');
                }
                when else {
                    try{
                        DSALES_IPAssetWrapper.IPAssetRequest policyAsset = (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize(body, DSALES_IPAssetWrapper.IPAssetRequest.class);
                        DSALES_InformacionDePago__c pago= new DSALES_InformacionDePago__c();
                        data=createIPAssetAux2(pago, policyAsset, emitirPoliza); 
                        listaPartidas=data.listaPartidas;
                        pago=data.pago;
                        success=true;
                        if(DSALES_InformacionDePago__c.SObjectType.getDescribe().isUpdateable()) {
                            update pago;  
                        } 
                    }
                    catch(Exception.JSONException e)
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
         
        }
        policyAssetRes.success=success;
        policyAssetRes.idActivo=data.idActivo;
        policyAssetRes.ListaPartidasOportunidad=listaPartidas;
        policyAssetRes.Seguro=data.seguro;
        return policyAssetRes;
    }	 
    
    private static IPAssetAux1Wrapper createIPAssetAux1(DSALES_InformacionDePago__c pago, DSALES_IPAssetWrapper.IPAssetRequest policyAsset, Boolean emitirPoliza){
        String idActivo='';
        Boolean success=false;
        IPAssetAux1Wrapper data = new IPAssetAux1Wrapper();
        InsurancePolicyAsset activo= insertIPAsset(policyAsset);
        DSALES_IPAssetWrapper.Seguro seguro = new DSALES_IPAssetWrapper.Seguro();
        switch on String.valueOf(pago.DSALES_Poliza__c) {
        when null,'' {
            if(Schema.sObjectType.InsurancePolicyAsset.isCreateable())
            {
                insert activo;
            }
            InsurancePolicy universalPoliza = [SELECT Id, Name  FROM InsurancePolicy where  Name=:DSALES_Utility.SEGURO_PREDETERMINADO WITH SECURITY_ENFORCED];
            pago.DSALES_Poliza__c=universalPoliza.Id;
        }
        when else {
            if(policyAsset.emitirPoliza==true && emitirPoliza==true){
                if(pago.DSALES_Poliza__r.PolicyName!= DSALES_Utility.SEGURO_PREDETERMINADO){
                    switch on String.valueOf(activo) {
                        when null {
                            system.debug('Es nulo');
                        }
                        when else {
                            Insurancepolicy poliza = DSales_NuevaPoliza.invokeService(activo);
                            success = true;
                            seguro.poliza = poliza.Name;
                            seguro.urlPdfPoliza = poliza.DSALES_PDF_poliza__c;
                            System.debug('SEGURO:' + seguro);
                            System.debug('POLIZA DESPUES DE EMITIR:' + poliza);
                            idActivo = poliza.dsalesActivoPolizaSeguro__c;
                        }
                    }
                }
            }
            else{
                createIPAssetAuxAux(activo,idActivo, pago);
            }
        }
       }
        
                
        
       
        data.seguro=seguro;
        data.idActivo=idActivo;
        return data;
    }

    private static IPAssetAux1Wrapper createIPAssetAux2(DSALES_InformacionDePago__c pago, DSALES_IPAssetWrapper.IPAssetRequest policyAsset, Boolean emitirPoliza){
        List<DSALES_IPAssetWrapper.ListaPartidasOportunidad> listaPartidas = new List<DSALES_IPAssetWrapper.ListaPartidasOportunidad>();
        IPAssetAux1Wrapper data = new IPAssetAux1Wrapper();
        if (Schema.sObjectType.DSALES_InformacionDePago__c.isQueryable()) {
            pago=[SELECT Id,DSALES_IDUniversal__c,	DSALES_Oportunidad__c,DSALES_Motoentregada__c,DSALES_Poliza__c,DSALES_Poliza__r.PolicyName FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c=:policyAsset.idUniversal];
            pago.DSALES_Motoentregada__c=true;	
        }
        if (Schema.sObjectType.OpportunityLineItem.isQueryable()) {
            for(OpportunityLineItem partidasSeguro: [SELECT Id,Name, Product2Id, Product2.DSales_Tipo_de_Producto__c, DSALES_Estatus__c
                FROM OpportunityLineItem WHERE OpportunityId=:pago.DSALES_Oportunidad__c AND Product2.DSales_Tipo_de_Producto__c=:'Seguro']){
                    switch on partidasSeguro.DSALES_Estatus__c {
                        when 'Devuelto' {
                                emitirPoliza=false;
                        }
                    }
                    switch on partidasSeguro.DSALES_Estatus__c {
                        when 'Cancelado' {
                                emitirPoliza=false;
                        }
                    }                                            
            }
        }
        
        if(policyAsset.numeroSerie!=''){
            //llamar metodo
            data=createIPAssetAux1(pago, policyAsset, emitirPoliza);
            String idOportunidad=pago.DSALES_Oportunidad__c;
            List<DSALES_VentaSMRest.WrapperDatosProductos> productosSincronisados=DSALES_VentaSMRest.obtenerProductosEnPartidasOportunidad(idOportunidad);
            for(DSALES_VentaSMRest.WrapperDatosProductos listSin:productosSincronisados){
                DSALES_IPAssetWrapper.ListaPartidasOportunidad listp= new  DSALES_IPAssetWrapper.ListaPartidasOportunidad ();
                listp.idPartidaDeOportunidad=listSin.oliId;
                listp.nombreProducto=listSin.nombreProducto;
                listp.sku=listSin.sku;
                listaPartidas.add(listp);
            }
        } 
        data.pago=pago;
        data.listaPartidas=listaPartidas;
        return data; 
    }

    private static void createIPAssetAuxAux(InsurancePolicyAsset activo, String idActivo, DSALES_InformacionDePago__c pago ){
        if(Schema.sObjectType.InsurancePolicyAsset.isCreateable() && Schema.sObjectType.InsurancePolicy.isQueryable()&& InsurancePolicy.SObjectType.getDescribe().isUpdateable()) {
            insert activo;
            idActivo=activo.Id;
            InsurancePolicy polizaActivo=new InsurancePolicy();
                polizaActivo = [SELECT Id FROM InsurancePolicy WHERE Id=:pago.DSALES_Poliza__c];
                polizaActivo.dsalesActivoPolizaSeguro__c=activo.Id;
                polizaActivo.DSALES_Clavevehicular__c=activo.DSALES_Clavevehicular__c;
                polizaActivo.DSALES_Modelo__c=activo.DSALES_Modelo__c;
                polizaActivo.DSALES_Numeroserie__c=activo.DSALES_Numeroserie__c;
                polizaActivo.dsalesNumeroDeMotor__c=activo.DSALES_Numeromotor__c;
                polizaActivo.DSALES_Descripcion__c=activo.DSALES_Descripcion__c;
                polizaActivo.DSALES_Servicio__c=activo.DSALES_Servicio__c;
                polizaActivo.DSALES_Placas__c=activo.DSALES_Placas__c;
                polizaActivo.DSALES_Marca__c=activo.DSALES_Marca__c;
                polizaActivo.DSALES_Uso__c=activo.DSALES_Uso__c;
                update polizaActivo;  
            }
    }

    global class IPAssetAux1Wrapper{
        global String idActivo {get;set;}
        global DSALES_IPAssetWrapper.Seguro seguro {get;set;}
        global List<DSALES_IPAssetWrapper.ListaPartidasOportunidad> listaPartidas {get;set;}
        global DSALES_InformacionDePago__c pago {get;set;}  
    }

    global static InsurancePolicyAsset insertIPAsset(DSALES_IPAssetWrapper.IPAssetRequest policyAsset){
        Boolean success=false;
        String message='';
        Integer code;

        InsurancePolicyAsset ipAssetRecord  = new InsurancePolicyAsset();
        try {
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Poliza__c,DSALES_Nombre_del_Vendedor__c,DSALES_Motoentregada__c, DSALES_Motoexterna__c,dsales_Seguro__c,DSALES_Cliente__c FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c=:policyAsset.idUniversal LIMIT 1];
            if(pago.dsales_Seguro__c ==true ) {
                ipAssetRecord.DSALES_InformacionPago__c=pago.Id;
                ipAssetRecord.dsalesCliente__c=pago.DSALES_Cliente__c;
                ipAssetRecord.DSALES_Tienda__c=policyAsset.idTienda;
                ipAssetRecord.DSALES_Colaborador__c=pago.DSALES_Nombre_del_Vendedor__c;
                ipAssetRecord.DSALES_Motoexterna__c=policyAsset.bajoDemanda; 
                ipAssetRecord.DSALES_Valorfactura__c=policyAsset.valorFactura;
                ipAssetRecord.InsurancePolicyId=pago.DSALES_Poliza__c;
                ipAssetRecord.dsalesEstatus__c='Activo';
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
                success = true; 
              
            }
            if(pago.dsales_Seguro__c ==false ) {
                InsurancePolicy poliza = [SELECT Id, Name  FROM InsurancePolicy where  Name=:DSALES_Utility.SEGURO_PREDETERMINADO];
                System.debug('poliza domi'+poliza);
                ipAssetRecord.DSALES_InformacionPago__c=pago.Id;
                ipAssetRecord.dsalesCliente__c=pago.DSALES_Cliente__c;
                ipAssetRecord.DSALES_Tienda__c=policyAsset.idTienda;
                ipAssetRecord.DSALES_Colaborador__c=pago.DSALES_Nombre_del_Vendedor__c;
                ipAssetRecord.DSALES_Motoexterna__c=policyAsset.bajoDemanda; 
                ipAssetRecord.DSALES_Valorfactura__c=policyAsset.valorFactura;
                ipAssetRecord.InsurancePolicyId= poliza.Id;
                ipAssetRecord.dsalesEstatus__c='Activo';
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
                success = true; 
              
            }
        } catch (Exception e) {
            success = false;
            message = DSALES_Utility.INTERNAL_ERROR_MSJ;
            code=DSALES_Utility.INTERNAL_ERROR_CODE;
            System.debug('ERROR ACTIVO:'+e.getLineNumber()+e.getMessage());
        }


        return ipAssetRecord;
    }
    
}