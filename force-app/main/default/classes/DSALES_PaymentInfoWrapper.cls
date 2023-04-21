/**
 * @description       : Test class for PaymentInfoWrapperGex
 * @author            : 
 * @group             : 
 * @last modified on  : 04-18-2023
 * @last modified by  : Juan Antonio Flores
 * Modifications Log 
 * Ver   Date          Author             Modification
<<<<<<< HEAD
 * 1.0   04-18-2023                       Initial Version
**/
=======
 * 1.0   04-18-2023                       Initial Version  
**/
@SuppressWarnings('PMD.AvoidGlobalModifier')
>>>>>>> 5ea51fd5305818ea0bab4c05059bc5468870ea08
global class DSALES_PaymentInfoWrapper {
    global class PaymentRequest{
        global String idUniversal { get; set; }
        global String tipoFolio { get; set; }
        global String folioTransaccion { get; set; }
        global Integer totalFactura { get; set; }
        global Boolean seguro { get; set; }
        global String nombreVendedor { get; set; }
        global String numeroCaja { get; set; }
        global String idOportunidad { get; set; }
        global String claveTienda { get; set; }
<<<<<<< HEAD
        global Date fechaDeEntrega { get; set; }//pdf
=======
        global Date fechaEntrega { get; set; }
>>>>>>> 5ea51fd5305818ea0bab4c05059bc5468870ea08
        global Date fechaVenta { get; set; }
        global String sku { get; set; }
        global Integer plazos { get; set; }
        global List<ListaDePago> listaDePagos { get; set; }
    }
    global class ListaDePago{
<<<<<<< HEAD
        //public Integer num_pago { get; set; }
=======
>>>>>>> 5ea51fd5305818ea0bab4c05059bc5468870ea08
        global String metodoPago { get; set; }
        global Integer pago { get; set; }
    }
    global class PaymentResponse{
<<<<<<< HEAD
        global String errorMessage {get;set;}
        global Integer errorCode {get;set;}
        global Boolean success {get;set;}
=======
        global String mensajeError {get;set;}
        global Integer codigoError {get;set;}
        global Boolean exito {get;set;}
>>>>>>> 5ea51fd5305818ea0bab4c05059bc5468870ea08
        global String pagoId {get;set;}
    }
}