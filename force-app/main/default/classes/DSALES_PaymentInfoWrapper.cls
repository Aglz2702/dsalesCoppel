/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 04-18-2023
 * @last modified by  : Juan Antonio Flores
 * Modifications Log 
 * Ver   Date          Author             Modification
 * 1.0   04-18-2023                       Initial Version
**/

global class DSALES_PaymentInfoWrapper {

    global class PaymentRequest{
        global String id_universal { get; set; }
        global String tipo_folio { get; set; }
        global String folio_transaccion { get; set; }
        global Integer total_factura { get; set; }
        global Boolean Seguro { get; set; }
        global String nombre_vendedor { get; set; }
        global String numero_caja { get; set; }
        global String id_oportunidad { get; set; }
        global String clave_tienda { get; set; }
        global Date fecha_de_entrega { get; set; }//pdf
        global Date fecha_venta { get; set; }
        global String sku { get; set; }
        global Integer plazos { get; set; }
        global List<ListaDePago> ListaDePagos { get; set; }
    }

    global class PaymentResponse{
        global String message {get;set;}
        global Integer errorCode {get;set;}
        global Boolean success {get;set;}
        global List<String> paymentInfo_ids {get;set;}
    }
        
    global class Pago{
        global double total {get;set;}
        global String producto {get;set;}
    }
}