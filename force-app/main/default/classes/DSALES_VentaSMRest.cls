@RestResource(urlMapping='/ventaSM/*')
global without sharing class DSALES_VentaSMRest {
    public static final String NOMBRE_SERVICIO = 'DSALES_createPoliza';
    /*
    @HttpPost
    global static DSALES_VentaSM.VentaSMResponse crearVenta() {
        String idCliente='';
        String idPago= '';
        String idActivo = '';
        Boolean exito=false;
        String mensajeError='';
        Integer codigoError;
        String partidas ='';
        String idUniversal='';
        String urlPdf='';
        Boolean dmlExitoso=true;
        //InsurancePolicyAsset activo = new InsurancePolicyAsset();
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c();
        DSALES_VentaSM.VentaSMResponse ventaSM= new DSALES_VentaSM.VentaSMResponse();
        DSALES_VentaSM.IdsARetornar idsLista = new DSALES_VentaSM.IdsARetornar();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
                if(String.isNotBlank(body)){
                    try{
                        DSALES_VentaSM.VentaSMRequest venta = (DSALES_VentaSM.VentaSMRequest)JSON.deserialize(body, DSALES_VentaSM.VentaSMRequest.class);
                        DSALES_AccountWrapper.AccountResponse cliente = DSALES_AccountWrapperRequest.upsertAccount(venta.cliente);
                        sincronizarOportunidad(venta.idCotizacion, cliente.idCuenta);
                        idCliente=cliente.idCuenta;
                        idUniversal=venta.pagos.idUniversal;
                        Quote cotizacion=[SELECT  Id,OpportunityId FROM Quote WHERE Id=:venta.idCotizacion WITH SECURITY_ENFORCED];
                        Opportunity oppor=[SELECT Id,StageName,SyncedQuoteId FROM Opportunity WHERE Id=:cotizacion.OpportunityId WITH SECURITY_ENFORCED ];
                        venta.pagos.idOportunidad=oppor.Id;
                        List<String> partidasSeleccionadas= venta.idPartidaPresupuesto;
                        DSALES_PaymentInfoWrapper.PaymentResponse resp= DSALES_PaymentInfoWrapperRequest.insertarPago(venta.pagos);
                        pago=[SELECT Id,DSALES_Factura__c,DSALES_Oportunidad__c,DSALES_Plazodecomprademoto__c,DSALES_Poliza__c,DSALES_Poliza__r.PolicyName,dsalesSeguro__c,DSALES_SKU__c  
                                                FROM DSALES_InformacionDePago__c 
                                                WHERE Id=:resp.pagoId WITH SECURITY_ENFORCED];
                        idPago=pago.Id;
                        idsLista=procesoVenta(pago,partidasSeleccionadas,venta.activo);
                        
                    }catch(Exception.JSONException e){
                       exito = false;
                        mensajeError= DSALES_Utility.BAD_REQUEST_MSJ;
                        codigoError=DSALES_Utility.BAD_REQUEST_CODE;
                        
                    }
                    catch(Exception e){
                        System.debug('**ERROR**'+e.getLineNumber()+ ': '+e.getMessage());
                        exito = false;
                        mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ;
                        codigoError=DSALES_Utility.INTERNAL_ERROR_CODE;
                    }
                }
            }
        ventaSM.idUniversal =idUniversal;
        ventaSM.idCliente=idCliente;
        ventaSM.idPago=idPago;
        ventaSM.idActivo=idsLista.idActivo;
        ventaSM.listaPartidasOportunidad=idsLista.listaPartidas;
        ventaSM.exito=exito;
        ventaSM.codigoError=codigoError;
        ventaSM.mensajeError=mensajeError;
        return ventaSM;
    }

    @future(callout=true)
    public static void emitirPoliza(String idActivo){
        InsurancePolicyAsset activo =[SELECT Id,InsurancePolicyId,DSALES_Clavevehicular__c,DSALES_Modelo__c,DSALES_Numeroserie__c,DSALES_Numeromotor__c,DSALES_Descripcion__c,DSALES_Servicio__c,DSALES_Placas__c,DSALES_Marca__c,DSALES_Uso__c FROM InsurancePolicyAsset WHERE Id=:idActivo WITH SECURITY_ENFORCED];
        DSALES_NuevaPoliza.invokeService(activo);
    }

    private static DSALES_VentaSM.IdsARetornar procesoVenta(DSALES_InformacionDePago__c pago,List<String> partidasSeleccionadas,DSALES_IPAssetWrapper.IPAssetRequest datosActivo){
        List<DSALES_VentaSM.ListaPartidasOportunidad> listaPartidas = new List<DSALES_VentaSM.ListaPartidasOportunidad>();
        Insurancepolicy poliza= new Insurancepolicy();
        DSALES_VentaSM.IdsARetornar listaIds = new DSALES_VentaSM.IdsARetornar();
        if(pago!=null){
            //DSALES_QuotePagoSM.cotizacionesNuevas(pago.Id,partidasSeleccionadas,pago.DSALES_SKU__c);
            List<WrapperDatosProductos> productosSincronisados= obtenerProductosEnPartidasOportunidad(pago.DSALES_Oportunidad__c);
            for(WrapperDatosProductos listSin:productosSincronisados){
                DSALES_VentaSM.ListaPartidasOportunidad listaPartidaOportunidad= new DSALES_VentaSM.ListaPartidasOportunidad();
                listaPartidaOportunidad.idPartidaOportunidad=listSin.oliId;
                listaPartidaOportunidad.nombreProducto=listSin.nombreProducto;
                listaPartidaOportunidad.sku=listSin.sku;
                listaPartidas.add(listaPartidaOportunidad);
            }
            crearPrePoliza(pago,poliza);
            listaIds.idActivo=crearActivo(pago,datosActivo,poliza);
            listaIds.listaPartidas=listaPartidas;
            
        }
        return listaIds;
    }
    private static String crearActivo(DSALES_InformacionDePago__c pago, DSALES_IPAssetWrapper.IPAssetRequest datosActivo, Insurancepolicy poliza){
        String idActivo ='';
        InsurancePolicyAsset activo = new InsurancePolicyAsset();
        if(String.isNotEmpty(datosActivo.numeroSerie)){
            activo= DSALES_IPAssetWrapperRequest.insertIPAsset(datosActivo,pago.Id);
            idActivo=activo.Id;
            poliza.dsalesActivoPolizaSeguro__c=activo.Id;
            poliza=DSALES_CreateInsurancePolicy.agregarDatosDeActivo(activo,poliza.Id);
            if(pago.DSALES_Poliza__c!=null && pago.DSALES_Poliza__r.PolicyName!= DSALES_Utility.SEGURO_PREDETERMINADO){
                condicionesParaEmitir(activo,datosActivo.emitirPoliza);
            }
            
        }
        return idActivo;
    }

    private static void  condicionesParaEmitir(InsurancePolicyAsset activo, Boolean emitir){
        if( activo!=null){
            if(emitir==true){
                emitirPoliza(activo.Id);
            }       
        }
    }
    private static void crearPrePoliza(DSALES_InformacionDePago__c pago, Insurancepolicy poliza){
        if(pago.dsalesSeguro__c==true && pago.DSALES_Poliza__c==null){
            poliza=DSALES_CreateInsurancePolicy.crearPoliza(pago.Id);
            pago.DSALES_Poliza__c=poliza.Id;       
        }
        if(DSALES_InformacionDePago__c.SObjectType.getDescribe().isUpdateable()) {
            update pago;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        }
    }
    private static Boolean sincronizarOportunidad(String quoteId, String accountId){ 
        Quote cotizacion = [SELECT Id,AccountId,OpportunityId,Opportunity.AccountId FROM Quote WHERE Id= :quoteId WITH SECURITY_ENFORCED]; 
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = accountId;
        oportunidad.Id = cotizacion.OpportunityId;
        if(Opportunity.SObjectType.getDescribe().isUpdateable()) {
            update oportunidad;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        }
        return true; 
    }

    public static List<WrapperDatosProductos> obtenerProductosEnPartidasOportunidad(Id opportunityId) {
        List<WrapperDatosProductos> listaWrapperProducto = new List<WrapperDatosProductos>();
        List<OpportunityLineItem> oliLista = [SELECT Id, Product2Id FROM OpportunityLineItem WHERE OpportunityId = :opportunityId WITH SECURITY_ENFORCED];
        List<Id> listaIdsProducto = new List<Id>();
        for(OpportunityLineItem oli : oliLista) {
            listaIdsProducto.add(oli.Product2Id);
        }
        Map<Id, String> mapaNombresProductos = new Map<Id, String>();
        Map<Id, String> mapaSkuProductos = new Map<Id, String>();
        if(listaIdsProducto.size() > 0) {
            List<Product2> listaProductos = [SELECT Id, Name,StockKeepingUnit FROM Product2 WHERE Id IN :listaIdsProducto WITH SECURITY_ENFORCED];
            for(Product2 producto : listaProductos) {
                mapaNombresProductos.put(producto.Id, producto.Name);
                mapaSkuProductos.put(producto.Id,producto.StockKeepingUnit);
            }
        }
        for(OpportunityLineItem oli : oliLista) {
            WrapperDatosProductos productoWrapper = new WrapperDatosProductos();
            productoWrapper.oliId = oli.Id;
            productoWrapper.nombreProducto = mapaNombresProductos.get(oli.Product2Id);
            productoWrapper.sku=mapaSkuProductos.get(oli.Product2Id);
            listaWrapperProducto.add(productoWrapper);
        }
        
        return listaWrapperProducto;
    }
    
    public class WrapperDatosProductos {
        public Id oliId { get; set; }
        public String nombreProducto { get; set; }
        public String sku {get;set;}
    }
*/
}