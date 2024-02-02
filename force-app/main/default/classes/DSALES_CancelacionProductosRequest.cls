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
        String idCancelacion='';
        if(String.isNotBlank(body)){
            try{
                DSALES_CancelacionProductosWrapper.Request datos = (DSALES_CancelacionProductosWrapper.Request)JSON.deserialize(body,DSALES_CancelacionProductosWrapper.Request.class);
                List<DSALES_CancelacionProductosWrapper.listaProducto> listaProductos = datos.ListaProductos;
                DSALES_InformacionDePago__c pago =[SELECT Id, RecordTypeId FROM DSALES_InformacionDePago__c WHERE 	DSALES_IDUniversal1__c=:datos.idUniversal WITH SECURITY_ENFORCED LIMIT 1];
                idCancelacion=escenariosCancelacion(pago, datos, listaProductos);
                if(idCancelacion!=''){
                    response.mensaje='Transacción Exitosa!';
                    response.idCancelacion=idCancelacion;
                    response.exito=true;
                }
                else{
                    response.mensaje='No se pudo realizar la cancelación verifique los datos!';
                    response.exito=false;
                    response.codigoError=401;
                }
                
            }catch(Exception.JSONException e){
                System.debug('ERROR JSON'+e.getLineNumber()+e.getMessage());
                response.exito = false;
                response.mensaje = DSALES_Utility.BAD_REQUEST_MSJ;
                response.codigoError = Integer.valueOf(DSALES_Utility.BAD_REQUEST_CODE); 
            }
            catch(Exception e){
                System.debug('ERROR INTERNO'+ e.getLineNumber()+e.getMessage());
                response.exito = false;
                response.mensaje =e.getMessage() + e.getLineNumber();
                response.codigoError = Integer.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
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
    private static String escenariosCancelacion(DSALES_InformacionDePago__c pago,DSALES_CancelacionProductosWrapper.Request datos,List<DSALES_CancelacionProductosWrapper.listaProducto> listaProductos){
        String idCancelacion='';
        if(pago!=null ){
           idCancelacion= cancelacionGex(pago, datos, listaProductos);
           /* idCancelacion =crearCancelacion(datos);
            if(String.isNotEmpty(idCancelacion)){
                cancelacionGex(pago, datos, listaProductos);
            }
            System.debug('idCancelación: '+idCancelacion);*/
        }
        return idCancelacion;
    }
    private static String cancelacionGex(DSALES_InformacionDePago__c pago,DSALES_CancelacionProductosWrapper.Request datos,List<DSALES_CancelacionProductosWrapper.listaProducto> listaProductos){
        String recordTypeIdMoto = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_PagosdeVentaenNPVSM_c').getRecordTypeId();
        String recordTypeIdGex = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_Pagos_en_NPV').getRecordTypeId();
        String idCancelacion='';
        List<DSALES_CancelacionProductosWrapper.listaProducto> listaCancelar = new List<DSALES_CancelacionProductosWrapper.listaProducto>();
        if(pago.RecordTypeId==recordTypeIdGex){
            System.debug('cancelación gex');
            DSALES_CertificadoWrapperRequest.putCertificado(datos.idUniversal,listaProductos,datos.estatus,datos.motivoCancelacion,datos.causa);
            idCancelacion =crearCancelacion(datos);
        }else if(pago!=null && pago.RecordTypeId==recordTypeIdMoto){
            System.debug('cancelación motos');
            if(listaProductos.size()>0){
                actualizarOportunidades(listaProductos);
                idCancelacion =crearCancelacion(datos);
            }
            else{
                System.debug('Lista de productos vacia');
                listaCancelar=cancelacionCompleta(datos.idUniversal, datos.estatus,datos.motivoCancelacion);
                if(listaCancelar.size()>0){
                    actualizarOportunidades(listaCancelar);
                    idCancelacion =crearCancelacion(datos);
                }
               
            }
           
        }
        return idCancelacion;
    }
    private static  List<DSALES_CancelacionProductosWrapper.listaProducto> cancelacionCompleta(String idUniversal,String estatus, String motivo){
        DSALES_InformacionDePago__c pago =[SELECT Id, DSALES_Oportunidad__c FROM DSALES_InformacionDePago__c WHERE 	DSALES_IDUniversal1__c=:idUniversal WITH SECURITY_ENFORCED LIMIT 1];
        List<OpportunityLineItem> olis = [SELECT Id,Name, OpportunityId, Product2Id, Product2.DSales_Tipo_de_Producto__c, DSALES_Estatus__c
                                          FROM OpportunityLineItem
                                          WHERE OpportunityId = :pago.DSALES_Oportunidad__c 
                                          WITH SECURITY_ENFORCED]; 
        List<DSALES_CancelacionProductosWrapper.listaProducto> productosSincro = new List<DSALES_CancelacionProductosWrapper.listaProducto>();
        if(olis!=null && olis.size()>0){
            for(OpportunityLineItem ol:olis){
                DSALES_CancelacionProductosWrapper.listaProducto producto = new DSALES_CancelacionProductosWrapper.listaProducto();
                producto.estatus=estatus;
                producto.motivoCancelacion=motivo;
                producto.idPartidaOportunidad=ol.Id;
                productosSincro.add(producto);
            }
        }
        System.debug('lista de productos sincronizados a cancelar: '+productosSincro);
        return productosSincro;
    }
   
    
    public static String crearCancelacion(DSALES_CancelacionProductosWrapper.Request datos){
        DSALES_InformacionDePago__c pago = [SELECT Id FROM 	DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c =:datos.idUniversal WITH SECURITY_ENFORCED LIMIT 1];
        Tienda__c tienda =[SELECT Id FROM Tienda__c WHERE DSales_TiendaID__c=:datos.idTienda WITH SECURITY_ENFORCED];
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
        if(poliza.dsalesEstatusPoliza__c ==ESTATUS_POLIZA ){
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
    
    @HttpPut
    global static DSALES_CancelacionProductosWrapper.Response cancelarCelular(Id oportunidadId, DSALES_CancelacionProductosWrapper.Request cancelacion)
    {
        DSALES_Cancelacion__c cancelaObj=new DSALES_Cancelacion__c();
        DSALES_CancelacionProductosWrapper.Response responsePayload = new DSALES_CancelacionProductosWrapper.Response();
       //caso 1 recibo idOportunidad
       if(oportunidadId!=null || !String.isEmpty(oportunidadId))
           {
               try{
                   OpportunityLineItem oportunidad = [SELECT Id,DSALES_Estatus__c, OpportunityId FROM 
                                                     OpportunityLineItem WHERE ID=:oportunidadId];
                   if(oportunidad.DSALES_Estatus__c=='Cancelado')
                       {
                           responsePayload.codigoError=DSALES_Utility.INTERNAL_ERROR_CODE;
                   			responsePayload.mensaje='Este producto ya está cancelado ';
                   			responsePayload.exito=false;
                           
                       }
                   else{
                       DSALES_InformacionDePago__c pago= [select Id FROM DSALES_InformaciondePago__c 
                                                      WHERE DSALES_Oportunidad__c=:oportunidad.OpportunityId];
                   InsurancePolicyAsset activo = [SELECT Id,dsalesEstatus__c FROM InsurancePolicyAsset WHERE
                                                 DSALES_InformacionPago__c=:pago.Id];
                   oportunidad.DSALES_Estatus__c='Cancelado';
                  activo.dsalesEstatus__c='Cancelado';
                cancelaObj.DSALES_FolioCancelacion__c=cancelacion.folioCancelacion;
                  cancelaObj.RecordTypeId=Schema.SObjectType.DSALES_Cancelacion__c.getRecordTypeInfosByDeveloperName().get('dsalesRegistroCancelacionSC').getRecordTypeId();
                cancelaObj.DSALES_FechaCancelacion__c=cancelacion.fechaCancelacion;
                 if(!String.isempty(cancelacion.idTienda))
                     {
                         Tienda__c tienda= [SELECT Id, DSales_TiendaID__c FROM Tienda__c WHERE DSales_TiendaID__c=:cancelacion.idTienda];
                         cancelaObj.DSALES_Tienda__c=tienda.id;
                     }
                   
                 cancelaObj.DSALES_NombreVendedor__c=cancelacion.nombreVendedor;
                 cancelaObj.DSALES_NumeroVendedor__c=cancelacion.numeroVendedor;
                   cancelaObj.DSALES_Canal__c='PSF';
                 cancelaObj.DSALES_MotivoCancelacion__c=cancelacion.motivoCancelacion;
                   cancelaObj.DSALES_Estatus__c='Cancelado';
                   cancelaObj.DSALES_Informaciondepago__c=pago.id;
                   system.debug('Id Insurance: '+activo);
                   If( OpportunityLineItem.SobjectType.GetDescribe().isUpdateable() && InsurancePolicy.sObjectType.GetDescribe().isUpdateable())
                   {
                       responsePayload.exito=true;
                       responsePayload.mensaje='Seguro de Celular Cancelado';
                       
                       Update oportunidad;
                       update activo;
                       system.debug('Seguro de Celular Cancelado');
                   }
                   if(DSALES_Cancelacion__c.SobjectType.GetDescribe().isCreateable())
                   {
                       insert cancelaObj;
                       responsePayload.idCancelacion=cancelaObj.Id;
                       responsePayload.mensaje+= ' Y registro Creado';
                       
                   }
                   }
                   
               }
               catch(Exception e){
                   responsePayload.codigoError=DSALES_Utility.INTERNAL_ERROR_CODE;
                   responsePayload.mensaje='ERROR: '+e.getMessage() + e.getLineNumber();
                   responsePayload.exito=false;
               }
           }
        else
        {
            responsePayload.codigoError=DSALES_Utility.INTERNAL_ERROR_CODE;
                   responsePayload.mensaje='El campo OpportunityId viene vacío o nulo';
                   responsePayload.exito=false;        
        }
       
        return responsePayload;
    }
    
}