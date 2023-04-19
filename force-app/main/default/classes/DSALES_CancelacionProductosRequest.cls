@RestResource(urlMapping='/cancelacionProductos/*')
global with sharing class DSALES_CancelacionProductosRequest {
    static final String estatusPoliza='Cancelada';
    @HttpPost
    global static DSALES_CancelacionProductosWrapper.response cancelar(){
        DSALES_CancelacionProductosWrapper.response response = new DSALES_CancelacionProductosWrapper.response();
        List<OpportunityLineItem> listaActualizar = new List<OpportunityLineItem>();
        Boolean success = false;
        String errorMessage = '';
        Integer code;
        String idCancelacion='';
        String recordTypeIdMoto = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_PagosdeVentaenNPVSM_c').getRecordTypeId();
        String recordTypeIdGex = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_Pagos_en_NPV').getRecordTypeId();
        
        if(RestContext.request != null){
            String Body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(Body)){
                try{
                    DSALES_CancelacionProductosWrapper.request datos = (DSALES_CancelacionProductosWrapper.request)JSON.deserialize(body,DSALES_CancelacionProductosWrapper.request.class);
                    List<DSALES_CancelacionProductosWrapper.ListaProducto> listaProductos = datos.ListaProductos;
                    DSALES_InformacionDePago__c pago =[SELECT Id, RecordTypeId FROM DSALES_InformacionDePago__c WHERE 	DSALES_IDUniversal1__c=:datos.idUniversal];
                    if(pago!=null ){
                        idCancelacion =crearCancelacion(datos);
                        if(idCancelacion!=''){
                            if(pago.RecordTypeId==recordTypeIdGex){
                                //llamar método de Dani para cancelar Gex
                                DSALES_CertificadoWrapperRequest.putCertificado(datos.idUniversal,listaProductos,datos.estatus,datos.motivoCancelacion);
                            }else if(pago!=null && pago.RecordTypeId==recordTypeIdMoto){
                                actualizarOportunidades(listaProductos);
                            }
                            success=true;
                        }
                        
                    }
                }catch(Exception.JSONException e){
                    System.debug('ERROR JSON'+e.getLineNumber()+e.getMessage());
                    success = false;
                    errorMessage = DSALES_Utility.BAD_REQUEST_MSJ;
                    code = DSALES_Utility.BAD_REQUEST_CODE; 
                }
                catch(Exception e){
                    System.debug('ERROR INTERNO'+ e.getLineNumber()+e.getMessage());
                    success = false;
                    errorMessage =e.getMessage() + e.getLineNumber();
                    code = DSALES_Utility.INTERNAL_ERROR_CODE;
                }
            }
        }
        
        
        response.codigoError=code;
        response.mensajeError=errorMessage;
        response.success=success;
        return response;
    }
    public static void actualizarOportunidades(List<DSALES_CancelacionProductosWrapper.ListaProducto> productosSincro) {
        Map<Id, String> mapaProductos = new Map<Id, String>();
        Map<Id, String> mapaProduct2 = new Map<Id, String>();
        List<Product2> prodRelacionados  = new List<Product2>();
        InsurancePolicyAsset activo  = new InsurancePolicyAsset();
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c();
        String idPaOp='';
        for (DSALES_CancelacionProductosWrapper.ListaProducto producto : productosSincro) {
            mapaProductos.put(producto.idPartidaOportunidad, producto.estatus);
        }
        List<OpportunityLineItem> olis = [SELECT Id,Name, OpportunityId, Product2Id, Product2.DSales_Tipo_de_Producto__c, DSALES_Estatus__c
                                          FROM OpportunityLineItem
                                          WHERE Id IN :mapaProductos.keySet()]; 
        if(olis.size()==1 && olis[0].Product2.DSales_Tipo_de_Producto__c=='Producto'){
            pago = [SELECT Id,DSALES_Motoentregada__c,DSALES_Motoexterna__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c =:olis[0].OpportunityId];
            if(pago.DSALES_Motoentregada__c==true){
                activo = [SELECT Id,Estatus__c FROM InsurancePolicyAsset WHERE DSALES_InformacionPago__c=:pago.Id];
                if (activo!=null){
                    pago = [SELECT Id,DSALES_Poliza__c,DSALES_Poliza__r.DSALES_Estatusdepliza__c,DSALES_Poliza__r.PolicyName,DSALES_Poliza__r.DSALES_Activodeplizadeseguro__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c =:olis[0].OpportunityId];
                }
            }
            
        }
        else if(olis.size()>1){
            pago = [SELECT Id,DSALES_Poliza__r.DSALES_Estatusdepliza__c,DSALES_Poliza__r.PolicyName,DSALES_Poliza__r.DSALES_Activodeplizadeseguro__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c =:olis[0].OpportunityId];
            if(pago.DSALES_Poliza__c!=null && pago.DSALES_Poliza__r.DSALES_Activodeplizadeseguro__c!=null && pago.DSALES_Poliza__r.DSALES_Estatusdepliza__c!='Prepoliza' ){
                activo = [SELECT Id,Estatus__c FROM InsurancePolicyAsset WHERE DSALES_InformacionPago__c=:pago.Id];
            }
        }
        for (OpportunityLineItem  prod: olis) {
            mapaProduct2.put(prod.Product2Id,prod.Id);
        }
        prodRelacionados = [SELECT Id,DSales_Tipo_de_Producto__c,Name FROM Product2 WHERE Id IN:mapaProduct2.keySet() AND DSales_Tipo_de_Producto__c=:'Producto' ];
        if(prodRelacionados!=null){
            for(Product2 pd:prodRelacionados){
                idPaOp =mapaProduct2.get(pd.Id);
            }
        }
        if(olis!=null){
            for (OpportunityLineItem oli : olis) {
                String estatus = mapaProductos.get(oli.Id);
                oli.DSALES_Estatus__c = estatus;
                if(activo!=null && idPaOp!=''){
                    activo.Estatus__c=estatus;
                    if(oli.Id==idPaOp){
                        activo.Estatus__c=estatus;
                    }  
                }
                
                
            }
        }
        update olis;
        if(activo.Id!=null){
            update activo;
        }
        
    }
    
    public static String crearCancelacion(DSALES_CancelacionProductosWrapper.request datos){
        DSALES_InformacionDePago__c pago = [SELECT Id FROM 	DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c =:datos.idUniversal];
        Tienda__c tienda =[SELECT Id FROM Tienda__c WHERE DSales_TiendaID__c=:datos.idTienda];
        DSALES_Cancelacion__c cancelacion = new DSALES_Cancelacion__c(
            DSALES_Canal__c= datos.canal,
            DSALES_FechaCancelacion__c =datos.fechaCancelacion,
            DSALES_FolioCancelacion__c =datos.folioCancelacion,    
            DSALES_NumeroVendedor__c=datos.numeroVendedor,
            DSALES_NombreVendedor__c = datos.nombreVendedor,
            DSALES_Tienda__c=tienda.Id
        ) ;
        if(datos.ListaProductos.size()>0){
            cancelacion.DSALES_Estatus__c=datos.ListaProductos[0].estatus;
            cancelacion.DSALES_MotivoCancelacion__c=datos.ListaProductos[0].motivoCancelacion;
        }
        else{
            cancelacion.DSALES_Estatus__c=datos.estatus;
            cancelacion.DSALES_MotivoCancelacion__c=datos.motivoCancelacion;
        }
            
        if(pago!=null){
            cancelacion.DSALES_Informaciondepago__c=pago.Id;
        }
        insert cancelacion;
        if(datos.ListaReembolso!=null){
            for(DSALES_ReembolsoWrapper.ReembolsoRequest rmb:datos.ListaReembolso){
                rmb.numeroCancelacion=cancelacion.Id;
            }
            DSALES_ReembolsoWrapperRequest.insertReembolso(datos.ListaReembolso);
        }
        return cancelacion.Id;
    }
    
    
    public static void cancelarPartidaDeSeguro(InsurancePolicy poliza){
        InsurancePolicyAsset activo = new InsurancePolicyAsset();
        if(poliza.DSALES_Estatusdepliza__c ==estatusPoliza ){
            List<OpportunityLineItem> partidasActualizadas = new List<OpportunityLineItem>();
            for(OpportunityLineItem oli: [SELECT Id,Name, Product2Id, Product2.DSales_Tipo_de_Producto__c, DSALES_Estatus__c
                                          FROM OpportunityLineItem
                                          WHERE OpportunityId=:poliza.SourceOpportunityId ]){
                                              if(oli.Product2.DSales_Tipo_de_Producto__c=='Seguro'){
                                                  oli.DSALES_Estatus__c='Cancelado';
                                              }
                                              if(poliza.DSALES_Activodeplizadeseguro__c!=null){
                                                  activo = [SELECT Id,Estatus__c,	DSALES_Motoexterna__c FROM InsurancePolicyAsset WHERE Id=:poliza.DSALES_Activodeplizadeseguro__c];
                                                  if (activo.DSALES_Motoexterna__c==true) {
                                                      activo.Estatus__c='Cancelado';
                                                  }
                                              }
                                              partidasActualizadas.add(oli);
                                              
                                              
                                          }
            update partidasActualizadas;
            if(activo!=null){
                update activo;
            }
        }
    }
}