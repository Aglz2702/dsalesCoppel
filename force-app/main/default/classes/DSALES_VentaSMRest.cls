@RestResource(urlMapping='/ventaSM/*')
global class DSALES_VentaSMRest {
	@HttpPost
    global static DSALES_VentaSM.VentaSMResponse createVenta() {
        String id_cliente='';
        String id_pago= '';
        String id_activo = '';
        Boolean success=false;
        String mensaje_error='';
        Integer codigo_error;
        String partidas ='';
        DSALES_VentaSM.VentaSMResponse ventaSM= new DSALES_VentaSM.VentaSMResponse();
        
        if(RestContext.request != null){

            String Body = System.RestContext.request.requestBody.toString();
           
            
            if(String.isNotBlank(Body)){
                try{
                    
                    DSALES_VentaSM.VentaSMRequest venta = (DSALES_VentaSM.VentaSMRequest)JSON.deserialize(body, DSALES_VentaSM.VentaSMRequest.class);
                    DSALES_AccountWrapper.AccountResponse cliente = DSALES_AccountWrapperRequest.upsertAccount(venta.cliente);
                    validarCliente(venta.id_cotizacion, cliente.id_cuenta);
                    id_cliente=cliente.id_cuenta;
                    System.debug('cliente:'+cliente);
                    Quote cotizacion=[SELECT  Id,OpportunityId FROM Quote WHERE Id=:venta.id_cotizacion];
                    System.debug('cotizacion: '+cotizacion);
                    Opportunity oppor=[SELECT Id,StageName,SyncedQuoteId FROM Opportunity WHERE Id=:cotizacion.OpportunityId ];
                    System.debug('oportunidad: '+oppor);
                    
                    venta.pagos.id_oportunidad=oppor.Id;

                    //System.debug('opp en pago2: '+venta.pagos.id_oportunidad);
                    partidas=venta.id_partida_presupuesto;
                    List<String> listaPartidas = partidas.split(',');
                    System.debug('lista de partidas recibidas: '+listaPartidas);
                    List<String> partidasSeleccionadas= new List<String>();
                    if(listaPartidas!=null){
                        for(String id:listaPartidas){
                            partidasSeleccionadas.add(id);
                        }
                    }
                    //DSALES_PaymentInfoWrapper.PaymentResponse resp= DSALES_PaymentInfoWrapperRequest.insertPagos(venta.pagos);
                    DSALES_PaymentInfoWrapper.PaymentResponse resp= DSALES_PaymentInfoWrapperRequest.insertarPago(venta.pagos);
                    System.debug('pago:'+resp);
                    DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Plazodecomprademoto__c,DSALES_Seguro__c,DSALES_SKU__c  
                                            FROM DSALES_InformacionDePago__c 
                                            WHERE Id=:resp.pago_id];
                    System.debug('pagox:'+pago);
                    if(pago!=null){
                        System.debug('cotizaciones');
                        DSALES_QuotePagoSM.cotizacionesNuevas(pago.Id,partidasSeleccionadas,pago.DSALES_SKU__c);
                        String temp=insertIPAsset(venta.activo,pago.Id,cliente.id_cuenta);
                        id_pago=resp.pago_id;
                        id_activo=temp;

                        
                    }

                    success=true;
                }catch(Exception.JSONException je ){
                    success =false;
                    mensaje_error=DSALES_Utility.BAD_REQUEST_MSJ;
                    codigo_error=DSALES_Utility.BAD_REQUEST_CODE;
                }catch(Exception ex){
                    mensaje_error=DSALES_Utility.INTERNAL_ERROR_MSJ;
                    success=false;
                    codigo_error=DSALES_Utility.INTERNAL_ERROR_CODE;
                    System.debug('error en linea: '+ex.getLineNumber());
                    System.debug(ex.getMessage());
                    
                }
            }    

        }
        ventaSM.success=success;
        ventaSM.codigo_error=codigo_error;
        ventaSM.mensaje_error=mensaje_error;
        ventaSM.id_cliente=id_cliente;
        ventaSM.id_pago=id_pago;
        ventaSM.id_activo_poliza=id_activo;
		return ventaSM;
    }


    
    public static String insertIPAsset(DSALES_IPAssetWrapper.IPAssetRequest asset, String pagoId, String clientId){
        DSALES_IPAssetWrapper.IPAssetResponse response = new DSALES_IPAssetWrapper.IPAssetResponse();
        Account clientNumber =[ SELECT Id, CP_WalletCustomerNumber__c FROM Account WHERE ID= :clientId];
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_SKU__c FROM DSALES_InformacionDePago__c WHERE Id=:pagoId];
        asset.id_pago=pago.Id;
        if(pago.DSALES_SKU__c!=null){
            response= DSALES_IPAssetWrapperRequestActivo.insertIPAsset(asset);//moto entregada
           
        }
        else{
            response=DSALES_IPAssetWrapperRequest.insertIPAsset(asset);//moto externa
        }
            
        return response.id_activo;
    }

    public static Boolean validarCliente(String quoteId, String accountId){ 
        Quote cotizacion = [SELECT Id,AccountId,OpportunityId,Opportunity.AccountId FROM Quote WHERE Id= :quoteId]; 
        //cotizacion.DSALES_Enviarcotizacion__c = true;

        
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = accountId;
       // oportunidad.SyncedQuoteId=quoteId;
        oportunidad.Id = cotizacion.OpportunityId;
        
        try{
            //update cotizacion;
            update oportunidad;
            return true;
        }catch(Exception e){
            return false;
        }
        
        
    }
    

    
}