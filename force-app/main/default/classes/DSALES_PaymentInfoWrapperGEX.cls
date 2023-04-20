/**
 * @description       : Test class for PaymentInfoWrapperGex
 * @author            : 
 * @group             : 
 * @last modified on  : 04-18-2023
 * @last modified by  : Juan Antonio Flores
 * Modifications Log 
 * Ver   Date          Author             Modification
 * 1.0   04-18-2023                       Initial Version
**/

global class DSALES_PaymentInfoWrapperGEX {
    global class PaymentGEXRequest{
        global Date fechaVenta {get;set;}
        global String claveTienda {get;set;}
        global String idFactura {get;set;}
        global String caja {get;set;}
        global String idVendedor {get;set;}
        global String nombreVendedor {get;set;}
        global Double precioTotal {get;set;}
        global String assetId {get;set;}
        global String certifiedId {get;set;}
        global String opportunityId {get;set;}
        global String idUniversal {get;set;}
        global String folioTransaccion{get;set;}
        global String tipoFolio{get;set;}
        //global String sku{get;set;}
    	global List<Pagos> partidasDePago {get;set;}
    }

	global class Pagos {
        global String tipoDePago {get;set;}
        global Double pago {get;set;}
    }

	global class PaymentGEXResponse{
        global Boolean exito {get;set;}
        global String codigoError {get;set;}
        global String mensajeError {get;set;}
        global String idInformacionPago {get;set;}
    }

}