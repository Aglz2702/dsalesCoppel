@RestResource(urlMapping='/insertPaymentInformationSM/*')
global with sharing class DSALES_PaymentInfoWrapperRequest {
    @HttpPost
    global static DSALES_PaymentInfoWrapper.PaymentResponse crearPago(){
        DSALES_PaymentInfoWrapper.PaymentResponse responsePago = new DSALES_PaymentInfoWrapper.PaymentResponse();      
        Boolean exito = false;
        String mensajeError = '';
        Integer codigoError;
        String pagoId='';
        if(RestContext.request != null){
            try{
                String body = System.RestContext.request.requestBody.toString();
                if(String.isNotBlank(body)){
                    DSALES_PaymentInfoWrapper.PaymentRequest pago = (DSALES_PaymentInfoWrapper.PaymentRequest)JSON.deserialize(body, DSALES_PaymentInfoWrapper.PaymentRequest.class);            
                    pagoId = insertarPago(pago,'');
                    exito=true;
                }
            }catch(Exception.JSONException jsonException){
                exito = false;
                mensajeError = DSALES_Utility.BAD_REQUEST_MSJ;
                codigoError = DSALES_Utility.BAD_REQUEST_CODE; 
            }catch(Exception e){
                exito = false;
                mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ;
                codigoError = DSALES_Utility.INTERNAL_ERROR_CODE;
            }
        }
        responsePago.pagoId=pagoId;
        responsePago.exito = exito;
        responsePago.mensajeError = mensajeError;
        responsePago.codigoError = codigoError;
        
        
        return responsePago;
    }
    public static String insertarPago(DSALES_PaymentInfoWrapper.PaymentRequest pago,String contratante){
        Boolean exito = false;
        String mensajeError = '';
        Integer codigoError;
        DSALES_InformacionDePago__c nuevoPago = new DSALES_InformacionDePago__c();
        List<DSALES_Partidadepago__c> listaPartidasPago = new List<DSALES_Partidadepago__c>();
        try{
            String recordTypePagoSM = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_PagosdeVentaenNPVSM_c').getRecordTypeId();
            String recordTypePagoSC =Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('Pagos_de_Venta_de_SC').getRecordTypeId();
            Opportunity oportunidad =[SELECT Id,AccountId,RecordTypeId FROM Opportunity WHERE Id=:pago.idOportunidad WITH SECURITY_ENFORCED];
            String recordTypeOpportSC =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('dsalesSeguroCelulares').getRecordTypeId();
            String recordTypeOpportSM =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Seguro_de_Moto').getRecordTypeId();
            Tienda__c tienda =[SELECT Id,DSales_TiendaID__c FROM Tienda__c WHERE DSales_TiendaID__c=:pago.claveTienda WITH SECURITY_ENFORCED];
            Account cliente=[SELECT Id,	FinServ__BillingAddress__pc FROM Account WHERE Id=:oportunidad.AccountId WITH SECURITY_ENFORCED];
            String tipoDeRegOpp=oportunidad.RecordTypeId;
            if(tipoDeRegOpp==recordTypeOpportSM){
                nuevoPago.RecordTypeId=recordTypePagoSM;
                nuevoPago.DSALES_Plazodecomprademoto__c=pago.plazos;
            }
            else if(tipoDeRegOpp==recordTypeOpportSC){
                nuevoPago.RecordTypeId=recordTypePagoSC;
            }
            nuevoPago.DSALES_Cliente__c=cliente.Id;
            nuevoPago.DSALES_Oportunidad__c=pago.idOportunidad;
            
            nuevoPago.DSALES_Estatus__c='Acreditado';
            nuevoPago.DSALES_SKU__c=pago.sku;
            nuevoPago.DSALES_Montototal__c=pago.totalFactura;
            nuevoPago.DSALES_Nombre_del_Vendedor__c=pago.nombreVendedor;
            nuevoPago.DSALES_Caja__c=pago.numeroCaja;
            nuevoPago.DSALES_Seguro__c=pago.seguro;
            
            if(pago.fechaEntrega!=null){
              nuevoPago.DSALES_Fechadeentregaestimada__c=pago.fechaEntrega;   
            }
            nuevoPago.DSALES_Fecha__c=pago.fechaVenta;
           	nuevoPago.DSales_Tienda__c=tienda.Id;
            nuevoPago.DSALES_IDUniversal1__c=pago.idUniversal;
            nuevoPago.DSALES_FolioTransaccion__c=pago.folioTransaccion;
           
            nuevoPago.DSALES_TipoFolio__c=pago.tipoFolio;
            nuevoPago.dsalesContratante__c=contratante;
            if(cliente.FinServ__BillingAddress__pc!=null){
                String direcion =cliente.FinServ__BillingAddress__pc.replace('<br>', ',');
                nuevoPago.DSALES_DireccionCliente__c=direcion;
            }
            if(Schema.sObjectType.DSALES_InformacionDePago__c.isCreateable()) {
                insert nuevoPago;
                System.debug('pago creado');
            }else{
                System.debug('Permisos insuficientes para insertar');
            }
            if(pago.ListaDePagos!=null){
                for(DSALES_PaymentInfoWrapper.listaDePago part : pago.listaDePagos){
                    DSALES_Partidadepago__c partida = new DSALES_Partidadepago__c();
                    partida.DSALES_Informaciondepago__c=nuevoPago.Id;
                    partida.DSALES_Tipodepago__c=part.metodoPago;
                    partida.DSALES_Pago__c=part.pago;
                    listaPartidasPago.add(partida);
                }
                if(Schema.sObjectType.DSALES_Partidadepago__c.isCreateable()) {
                    insert listaPartidasPago;
                }else{
                    System.debug('Permisos insuficientes para insertar');
                }
                
            }
        }catch(Exception e){
            System.debug('ERROR EN PAGO_______'+e.getLineNumber()+e.getMessage());
            if(nuevoPago!=null && nuevoPago.Id!=null){
                delete nuevoPago;
            }
        }
        
        return nuevoPago.Id;
    }
}