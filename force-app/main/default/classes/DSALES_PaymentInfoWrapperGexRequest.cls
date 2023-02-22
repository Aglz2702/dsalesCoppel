@RestResource(urlMapping='/insertPaymentInformationGEX/*')
global with sharing class DSALES_PaymentInfoWrapperGexRequest {
    
   
    @HttpPost
    global static DSALES_PaymentInfoWrapperGEX.PaymentGEXResponse createPayment(){
        DSALES_PaymentInfoWrapperGEX.PaymentGEXResponse responsePayload = new DSALES_PaymentInfoWrapperGEX.PaymentGEXResponse();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            
            if(String.isNotBlank(body)){
                try{
                    DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest pago = (DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest)JSON.deserialize(body, DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest.class);
                    responsePayload = insertPaymentGex(pago);
                }catch(JSONException e){
                    responsePayload.exito = false;
                    responsePayload.codigo_error = String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    responsePayload.mensaje_error = DSALES_Utility.BAD_REQUEST_MSJ;
                }catch(Exception e){
                    responsePayload.exito = false;
                    responsePayload.codigo_error = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);

                    responsePayload.mensaje_error = DSALES_Utility.INTERNAL_ERROR_MSJ;
                  
                }
            }
        }
        return responsePayload;
    }
    
    global static DSALES_PaymentInfoWrapperGEX.PaymentGEXResponse insertPaymentGex(DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest payment){
        Boolean success = false;
        String message = '';
        String code = '';
        DSALES_InformacionDePago__c info = new DSALES_InformacionDePago__c();
       
        List<DSALES_Partidadepago__c> partidaPagolst = new List<DSALES_Partidadepago__c>();
                try{
                    system.debug('pagoss:  '+payment.PartidasDePago);
                    String recordTypeId = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByName().get('Pagos de venta de servicios').getRecordTypeId();
                    List<Tienda__c> idTienda = [SELECT id FROM Tienda__c WHERE DSales_TiendaID__c =:payment.clave_tienda LIMIT 1];
                    List<Opportunity> cliente = [SELECT id,AccountId,Account.Name,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,Account.AccountNumber,Account.PersonMobilePhone FROM Opportunity WHERE Id=:payment.opportunity_id LIMIT 1];
                    system.debug('pagoss 222:  '+payment.PartidasDePago);
                    info.RecordTypeId = recordTypeId;
                    info.DSALES_Fecha__c = payment.fecha_venta;
                    info.DSALES_Clave_Tienda__c = payment.clave_tienda;
                    info.DSales_Tienda__c = idTienda[0].Id;
                    info.DSALES_Estatus__c = 'Acreditado';
                    info.DSALES_Factura__c = payment.id_factura;
                    info.DSALES_TotalContado__c = payment.precio_total;
                    info.DSALES_Cliente__c = cliente[0].AccountId;
                    info.DSALES_Oportunidad__c = payment.opportunity_id;
					info.DSALES_DireccionCliente__c = cliente[0].Account.BillingStreet+' '+cliente[0].Account.BillingCity+' '+cliente[0].Account.BillingState+' '+cliente[0].Account.BillingPostalCode;
                    info.DSALES_No_de_cliente__c = cliente[0].Account.AccountNumber;
                    info.DSALES_TelefonoCliente__c = cliente[0].Account.PersonMobilePhone;
                    info.DSALES_Nombre_del_Vendedor__c= payment.nombre_vendedor;
                    info.DSALES_Vendedor__c=payment.id_vendedor;
                    info.DSALES_Caja__c=payment.caja;
                    info.DSALES_Factura__c=payment.id_factura;
                    info.DSALES_Oportunidad__c = payment.opportunity_id;
                    //info.DSALES_SKU__c=payment.sku;
                    //info.DSALES_Certificado__c = payment.certified_id;
                   // info.DSALES_ProductoAdquirido__c = payment.asset_id;
                    //insert info;
						
                    for(DSALES_PaymentInfoWrapperGEX.Pagos p : payment.PartidasDePago){
                        DSALES_Partidadepago__c partidaPago = new DSALES_Partidadepago__c();
                        partidaPago.DSALES_Informaciondepago__c = info.Id;
                        partidaPago.DSALES_Tipodepago__c = p.tipo_de_pago;
                        partidaPago.DSALES_Pago__c = p.pago;
                        partidaPagolst.add(partidaPago);
                    }
                    insert partidaPagolst;
                    
                    
                    success = true;
                    message = '';
                    code = '';
                }catch(Exception e){
                    success = false;
                    message = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    code = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);

        }
        DSALES_PaymentInfoWrapperGEX.PaymentGEXResponse responsePayload = new DSALES_PaymentInfoWrapperGEX.PaymentGEXResponse();
        responsePayload.exito = success;
        responsePayload.mensaje_error = message;
        responsePayload.codigo_error = code;
        responsePayload.id_informacionPago = info.Id;
        
        return responsePayload;
    }
}