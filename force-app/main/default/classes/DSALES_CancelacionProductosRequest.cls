@RestResource(urlMapping='/cancelacionProductos/*')
global with sharing class DSALES_CancelacionProductosRequest {
    static final String ESTATUS_POLIZA='Cancelada';
    @HttpPost
    global static DSALES_CancelacionProductosWrapper.Response servicioCancelar(){
        DSALES_CancelacionProductosWrapper.Response response = new DSALES_CancelacionProductosWrapper.Response();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
           response= cancelar(body);
        }
        
        return response;
    }

    private static DSALES_CancelacionProductosWrapper.Response cancelar(String body){
        DSALES_CancelacionProductosWrapper.Response response = new DSALES_CancelacionProductosWrapper.Response();
        if(String.isNotBlank(body)){
            try{
                DSALES_CancelacionProductosWrapper.Request datos = (DSALES_CancelacionProductosWrapper.Request)JSON.deserialize(body,DSALES_CancelacionProductosWrapper.Request.class);
                List<DSALES_CancelacionProductosWrapper.listaProducto> listaProductos = datos.ListaProductos;
                DSALES_InformacionDePago__c pago =[SELECT Id, RecordTypeId FROM DSALES_InformacionDePago__c WHERE 	DSALES_IDUniversal1__c=:datos.idUniversal WITH SECURITY_ENFORCED];
                escenariosCancelacion(pago, datos, listaProductos);
                response.success=true;
            }catch(Exception.JSONException e){
                System.debug('ERROR JSON'+e.getLineNumber()+e.getMessage());
                response.success = false;
                response.mensajeError = DSALES_Utility.BAD_REQUEST_MSJ;
                response.codigoError = DSALES_Utility.BAD_REQUEST_CODE; 
            }
            catch(Exception e){
                System.debug('ERROR INTERNO'+ e.getLineNumber()+e.getMessage());
                response.success = false;
                response.mensajeError =e.getMessage() + e.getLineNumber();
                response.codigoError = DSALES_Utility.INTERNAL_ERROR_CODE;
            }
        }
        return response;
    }
    public static void actualizarOportunidades(List<DSALES_CancelacionProductosWrapper.listaProducto> productosSincro) {
        Map<Id, String> mapaProductos = new Map<Id, String>();
        InsurancePolicyAsset activo  = new InsurancePolicyAsset();
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c();
        String idPaOp='';
        for (DSALES_CancelacionProductosWrapper.listaProducto producto : productosSincro) {
            mapaProductos.put(producto.idPartidaOportunidad, producto.estatus);
        }
        List<OpportunityLineItem> olis = [SELECT Id,Name, OpportunityId, Product2Id, Product2.DSales_Tipo_de_Producto__c, DSALES_Estatus__c
                                          FROM OpportunityLineItem
                                          WHERE Id IN :mapaProductos.keySet() WITH SECURITY_ENFORCED]; 
        activo =DSALES_CancelacionController.obtenerActivo(olis);
        idPaOp=DSALES_CancelacionController.obtenerIdPago(olis);
        if(olis!=null){
            for (OpportunityLineItem oli : olis) {
                String estatus = mapaProductos.get(oli.Id);
                oli.DSALES_Estatus__c = estatus;
                if(activo!=null && idPaOp!=''){
                    activo.dsalesEstatus__c=estatus;
                    if(oli.Id==idPaOp){
                        activo.dsalesEstatus__c=estatus;
                    }  
                }
            }
        }
        actualizarRegistros(olis,activo);
    }

    private static void actualizarRegistros(List<OpportunityLineItem> olis,InsurancePolicyAsset activo){
        if(OpportunityLineItem.SObjectType.getDescribe().isUpdateable()) {
            update olis;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        } 
        if(activo.Id!=null){
            if(InsurancePolicyAsset.SObjectType.getDescribe().isUpdateable()) {
                update activo;   
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            } 
        }
    }
    private static void escenariosCancelacion(DSALES_InformacionDePago__c pago,DSALES_CancelacionProductosWrapper.Request datos,List<DSALES_CancelacionProductosWrapper.listaProducto> listaProductos){
        String idCancelacion='';
        if(pago!=null ){
            idCancelacion =crearCancelacion(datos);
            if(String.isNotEmpty(idCancelacion)){
                cancelacionGex(pago, datos, listaProductos);
            }
            
        }
    }
    private static void cancelacionGex(DSALES_InformacionDePago__c pago,DSALES_CancelacionProductosWrapper.Request datos,List<DSALES_CancelacionProductosWrapper.listaProducto> listaProductos){
        String recordTypeIdMoto = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_PagosdeVentaenNPVSM_c').getRecordTypeId();
        String recordTypeIdGex = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_Pagos_en_NPV').getRecordTypeId();
        if(pago.RecordTypeId==recordTypeIdGex){
            DSALES_CertificadoWrapperRequest.putCertificado(datos.idUniversal,listaProductos,datos.estatus,datos.motivoCancelacion);
        }else if(pago!=null && pago.RecordTypeId==recordTypeIdMoto){
            actualizarOportunidades(listaProductos);
        }
    }

   
    
    public static String crearCancelacion(DSALES_CancelacionProductosWrapper.Request datos){
        DSALES_InformacionDePago__c pago = [SELECT Id FROM 	DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c =:datos.idUniversal WITH SECURITY_ENFORCED];
        Tienda__c tienda =[SELECT Id FROM Tienda__c WHERE dsalesTiendaID__c=:datos.idTienda WITH SECURITY_ENFORCED];
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
        if(Schema.sObjectType.DSALES_Cancelacion__c.isCreateable()) {
            insert cancelacion;
        }else{
            System.debug('Permisos insuficientes para insertar');
        }
        if(datos.listaReembolso!=null){
            for(DSALES_ReembolsoWrapper.ReembolsoRequest rmb:datos.listaReembolso){
                rmb.numeroCancelacion=cancelacion.Id;
            }
            DSALES_ReembolsoWrapperRequest.insertReembolso(datos.listaReembolso);
        }
        return cancelacion.Id;
    }
    
    public static void cancelarPartidaDeSeguro(InsurancePolicy poliza){
        InsurancePolicyAsset activo = new InsurancePolicyAsset();
        if(poliza.DSALES_Estatusdepliza__c ==ESTATUS_POLIZA ){
            List<OpportunityLineItem> partidasActualizadas = new List<OpportunityLineItem>();
            Set<Id> oliIds = new Set<Id>(); 
            
            for(OpportunityLineItem oli: [SELECT Id,Name, Product2Id, Product2.DSales_Tipo_de_Producto__c, DSALES_Estatus__c
                                          FROM OpportunityLineItem
                                          WHERE OpportunityId=:poliza.SourceOpportunityId  WITH SECURITY_ENFORCED]){
                if(oli.Product2.DSales_Tipo_de_Producto__c=='Seguro'){
                    oli.DSALES_Estatus__c='Cancelado';
                    oliIds.add(oli.Id);
                }
                partidasActualizadas.add(oli);
            }
            DSALES_CancelacionController.escenarioPolizaActRegistros(partidasActualizadas,poliza);
        }
    }
    
}