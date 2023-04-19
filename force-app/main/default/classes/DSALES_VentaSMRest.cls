@RestResource(urlMapping='/ventaSM/*')
global class DSALES_VentaSMRest {
    public static final String NOMBRE_SERVICIO = 'DSALES_createPoliza';
    @HttpPost
    global static DSALES_VentaSM.VentaSMResponse createVenta() {
        String id_cliente='';
        String id_pago= '';
        String id_activo = '';
        Boolean success=false;
        String mensaje_error='';
        Integer codigo_error;
        String partidas ='';
        String id_universal='';
        String urlPdf='';
        Boolean dmlExitoso=true;
        InsurancePolicyAsset activo = new InsurancePolicyAsset();
        Insurancepolicy poliza= new Insurancepolicy();
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c();
        DSALES_VentaSM.VentaSMResponse ventaSM= new DSALES_VentaSM.VentaSMResponse();
        List<DSALES_VentaSM.ListaPartidasOportunidad> listaPartidas = new List<DSALES_VentaSM.ListaPartidasOportunidad>();
        if(RestContext.request != null){
            String Body = System.RestContext.request.requestBody.toString();
                if(String.isNotBlank(Body)){
                    try{
                        DSALES_VentaSM.VentaSMRequest venta = (DSALES_VentaSM.VentaSMRequest)JSON.deserialize(body, DSALES_VentaSM.VentaSMRequest.class);
                        DSALES_AccountWrapper.AccountResponse cliente = DSALES_AccountWrapperRequest.upsertAccount(venta.cliente);
                        validarCliente(venta.id_cotizacion, cliente.id_cuenta);
                        id_cliente=cliente.id_cuenta;
                        id_universal=venta.pagos.id_universal;
                        System.debug('cliente:'+cliente);
                        Quote cotizacion=[SELECT  Id,OpportunityId FROM Quote WHERE Id=:venta.id_cotizacion];
                        System.debug('cotizacion: '+cotizacion);
                        Opportunity oppor=[SELECT Id,StageName,SyncedQuoteId FROM Opportunity WHERE Id=:cotizacion.OpportunityId ];
                        System.debug('oportunidad: '+oppor);
                        venta.pagos.id_oportunidad=oppor.Id;
                        List<String> partidasSeleccionadas= venta.id_partida_de_presupuesto;
                        DSALES_PaymentInfoWrapper.PaymentResponse resp= DSALES_PaymentInfoWrapperRequest.insertarPago(venta.pagos);
                        System.debug('pago:'+resp);
                        pago=[SELECT Id,DSALES_Factura__c,DSALES_Plazodecomprademoto__c,DSALES_Poliza__c,DSALES_Poliza__r.PolicyName,DSALES_Seguro__c,DSALES_SKU__c  
                                                FROM DSALES_InformacionDePago__c 
                                                WHERE Id=:resp.pago_id];
                        id_pago=pago.Id;
                        if(pago!=null){
                            DSALES_QuotePagoSM.cotizacionesNuevas(pago.Id,partidasSeleccionadas,pago.DSALES_SKU__c);
                            List<OpportunityLineItemProduct> productosSincronisados= getOpportunityLineItemProducts(oppor.Id);
                            System.debug('productos sincro:'+productosSincronisados);
                            for(OpportunityLineItemProduct listSin:productosSincronisados){
                                DSALES_VentaSM.ListaPartidasOportunidad listp= new DSALES_VentaSM.ListaPartidasOportunidad();
                                listp.id_partida_de_oportunidad=listSin.oliId;
                                listp.nombre_producto=listSin.productName;
                                listp.sku=listSin.productSku;
                                listaPartidas.add(listp);
                            }
                            if(pago.DSALES_Seguro__c==true && pago.DSALES_Poliza__c==null){
                                //pago.DSALES_Factura__c!=null   && (
                                if(pago.DSALES_SKU__c==null || pago.DSALES_SKU__c!=null ){
                                    System.debug('||||||||SE CREA PREPOLIZA||||||||||');
                                    poliza=DSALES_CreateInsurancePolicy.createPoliza(pago.Id);
                                    pago.DSALES_Poliza__c=poliza.Id;
                                    update pago;
                                    
                                }else{
                                System.debug('no es pago de SM');
                                }
                            }
                            if(venta.activo.numero_serie!=''){
                                System.debug('Se crea activo en la venta'+venta.activo);
                                activo= DSALES_IPAssetWrapperRequest.insertIPAsset(venta.activo,pago.Id);
                                id_activo=activo.Id;
                                poliza.DSALES_Activodeplizadeseguro__c=activo.Id;
                                poliza=DSALES_CreateInsurancePolicy.agregarDatosDeActivo(activo,poliza.Id);
                                System.debug('activo creado en venta-nuevo:'+activo.Id);
                                system.debug('poliza to pago:'+pago.DSALES_Poliza__c);
                                if(pago.DSALES_Poliza__c!=null && pago.DSALES_Poliza__r.PolicyName!= DSALES_Utility.SEGURO_PREDETERMINADO){
                                    System.debug('poliza en pago venta');
                                    System.debug('activo!=null: '+activo);
                                    if( activo!=null && venta.activo.emitir_poliza==true){
                                        System.debug('a emitir');
                                        emitirPoliza(activo.Id);
                                        
                                    }
                                    
                                }
                                System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                                System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                                System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                            }
                            success=true;
                        }
                    }catch(Exception.JSONException e){
                       success = false;
                        mensaje_error= DSALES_Utility.BAD_REQUEST_MSJ;
                        codigo_error=DSALES_Utility.BAD_REQUEST_CODE;
                        
                    }
                    catch(Exception e){
                        System.debug('**ERROR**'+e.getLineNumber()+ ': '+e.getMessage());
                        success = false;
                        mensaje_error = DSALES_Utility.INTERNAL_ERROR_MSJ;
                        codigo_error=DSALES_Utility.INTERNAL_ERROR_CODE;
                    }
                }
            }
        ventaSM.idUniversal =id_universal;
        ventaSM.id_cliente=id_cliente;
        ventaSM.id_pago=id_pago;
        ventaSM.id_activo=id_activo;
        ventaSM.ListaPartidasOportunidad=listaPartidas;
        ventaSM.success=success;
        ventaSM.codigo_error=codigo_error;
        ventaSM.mensaje_error=mensaje_error;
        return ventaSM;
    }

    @future(callout=true)
    public static void emitirPoliza(String idActivo){
        System.debug('hola');
        InsurancePolicyAsset activo =[SELECT Id,InsurancePolicyId,DSALES_Clavevehicular__c,DSALES_Modelo__c,DSALES_Numeroserie__c,DSALES_Numeromotor__c,DSALES_Descripcion__c,DSALES_Servicio__c,DSALES_Placas__c,DSALES_Marca__c,DSALES_Uso__c FROM InsurancePolicyAsset WHERE Id=:idActivo];
        DSALES_NuevaPoliza.invokeService(activo);
    }

    public static Boolean validarCliente(String quoteId, String accountId){ 
        Quote cotizacion = [SELECT Id,AccountId,OpportunityId,Opportunity.AccountId FROM Quote WHERE Id= :quoteId]; 
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = accountId;
        oportunidad.Id = cotizacion.OpportunityId;
        update oportunidad;
        return true; 
    }

    public static List<OpportunityLineItemProduct> getOpportunityLineItemProducts(Id opportunityId) {
        List<OpportunityLineItemProduct> oliProductList = new List<OpportunityLineItemProduct>();
        List<OpportunityLineItem> oliList = [SELECT Id, Product2Id FROM OpportunityLineItem WHERE OpportunityId = :opportunityId];
        List<Id> productIds = new List<Id>();
        for(OpportunityLineItem oli : oliList) {
            productIds.add(oli.Product2Id);
        }
        Map<Id, String> productNameMap = new Map<Id, String>();
        Map<Id, String> productSkuMap = new Map<Id, String>();
        if(productIds.size() > 0) {
            List<Product2> productList = [SELECT Id, Name,StockKeepingUnit FROM Product2 WHERE Id IN :productIds];
            for(Product2 product : productList) {
                productNameMap.put(product.Id, product.Name);
                productSkuMap.put(product.Id,product.StockKeepingUnit);
            }
        }
        for(OpportunityLineItem oli : oliList) {
            OpportunityLineItemProduct oliProduct = new OpportunityLineItemProduct();
            oliProduct.oliId = oli.Id;
            oliProduct.productName = productNameMap.get(oli.Product2Id);
            oliProduct.productSku=productSkuMap.get(oli.Product2Id);
            oliProductList.add(oliProduct);
        }
        
        return oliProductList;
    }
    
    public class OpportunityLineItemProduct {
        public Id oliId { get; set; }
        public String productName { get; set; }
        public String productSku {get;set;}
    }
}