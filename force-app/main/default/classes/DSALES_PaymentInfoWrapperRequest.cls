@RestResource(urlMapping='/insertPaymentInformationSM/*')
global with sharing class DSALES_PaymentInfoWrapperRequest {
    
    @HttpPost
    global static DSALES_PaymentInfoWrapper.PaymentResponse createPayment(){
        DSALES_PaymentInfoWrapper.PaymentResponse responsePayload = new DSALES_PaymentInfoWrapper.PaymentResponse();      
        Boolean success = false;
        String error_message = '';
        Integer error_code;
        if(RestContext.request != null){
            try{
                String body = System.RestContext.request.requestBody.toString();
                if(String.isNotBlank(body)){
                    DSALES_PaymentInfoWrapper.PaymentRequest pago = (DSALES_PaymentInfoWrapper.PaymentRequest)JSON.deserialize(body, DSALES_PaymentInfoWrapper.PaymentRequest.class);            
                    responsePayload = insertarPago(pago);
                    success=true;
                }
            }catch(Exception.JSONException jsonException){
                success = false;
                error_message = DSALES_Utility.BAD_REQUEST_MSJ;
                error_code = DSALES_Utility.BAD_REQUEST_CODE; 
            }catch(Exception e){
                success = false;
                error_message = DSALES_Utility.INTERNAL_ERROR_MSJ;
                error_code = DSALES_Utility.INTERNAL_ERROR_CODE;
            }
        }
        responsePayload.success = success;
        responsePayload.error_message = error_message;
        responsePayload.error_code = error_code;
        
        
        return responsePayload;
    }
    public static DSALES_PaymentInfoWrapper.PaymentResponse insertarPago(DSALES_PaymentInfoWrapper.PaymentRequest pago){
        Boolean success = false;
        String error_message = '';
        Integer code;
        System.debug('Pago request1:'+pago.ListaDePagos);
        DSALES_InformacionDePago__c nuevoPago = new DSALES_InformacionDePago__c();
        List<DSALES_Partidadepago__c> listaPartidas = new List<DSALES_Partidadepago__c>();
        try{
            String recordTypePago = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_PagosdeVentaenNPVSM_c').getRecordTypeId();
            Opportunity oportunidad =[SELECT Id,AccountId FROM Opportunity WHERE Id=:pago.id_oportunidad];
            Tienda__c tienda =[SELECT Id,DSales_TiendaID__c FROM Tienda__c WHERE DSales_TiendaID__c=:pago.clave_tienda ];
            Account cliente=[SELECT Id,	FinServ__BillingAddress__pc FROM Account WHERE Id=:oportunidad.AccountId];
            nuevoPago.DSALES_Cliente__c=cliente.Id;
            nuevoPago.DSALES_Oportunidad__c=pago.id_oportunidad;
            nuevoPago.RecordTypeId=recordTypePago;
            nuevoPago.DSALES_Estatus__c='Acreditado';
            //nuevoPago.DSALES_Factura__c=String.valueOf(pago.num_factura);
            nuevoPago.DSALES_SKU__c=pago.sku;
            nuevoPago.DSALES_Montototal__c=pago.total_factura;
            nuevoPago.DSALES_Nombre_del_Vendedor__c=pago.nombre_vendedor;
            nuevoPago.DSALES_Caja__c=pago.numero_caja;
            nuevoPago.DSALES_Seguro__c=pago.Seguro;
            nuevoPago.DSALES_Plazodecomprademoto__c=pago.plazos;
            if(pago.fecha_de_entrega!=null){
              nuevoPago.DSALES_Fechadeentregaestimada__c=pago.fecha_de_entrega;   
            }
            nuevoPago.DSALES_Fecha__c=pago.fecha_venta;
           	nuevoPago.DSales_Tienda__c=tienda.Id;
            nuevoPago.DSALES_IDUniversal1__c=pago.id_universal;
            nuevoPago.DSALES_FolioTransaccion__c=pago.folio_transaccion;
            nuevoPago.DSALES_TipoFolio__c=pago.tipo_folio;
            if(cliente.FinServ__BillingAddress__pc!=null){
                String direcion =cliente.FinServ__BillingAddress__pc.replace('<br>', ',');
                nuevoPago.DSALES_DireccionCliente__c=direcion;
            }
            insert nuevoPago;
            System.debug('Pago request:'+pago.ListaDePagos);
            
            if(pago.ListaDePagos!=null){
                for(DSALES_PaymentInfoWrapper.ListaDePago part : pago.ListaDePagos){
                    DSALES_Partidadepago__c partida = new DSALES_Partidadepago__c();
                    partida.DSALES_Informaciondepago__c=nuevoPago.Id;
                    partida.DSALES_Tipodepago__c=part.metodo_pago;
                    partida.DSALES_Pago__c=part.pago;
                    listaPartidas.add(partida);
                }
                insert listaPartidas;
            }
            success=true;

        }catch(Exception e){
            System.debug(e.getLineNumber()+ e.getMessage());
            success = false;
            error_message = DSALES_Utility.INTERNAL_ERROR_MSJ;
            code = DSALES_Utility.INTERNAL_ERROR_CODE;
        }
        DSALES_PaymentInfoWrapper.PaymentResponse responsePayload = new  DSALES_PaymentInfoWrapper.PaymentResponse();
        responsePayload.success = success;
        responsePayload.error_code=code;
        responsePayload.error_message=error_message;
        responsePayload.pago_id=nuevoPago.Id;
        
        return responsePayload;
    }
}