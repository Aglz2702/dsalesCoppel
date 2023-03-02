global class DSALES_PaymentInfoWrapperGEX {
    global class PaymentGEXRequest{
        global Date fecha_venta {get;set;}
        global String clave_tienda {get;set;}
        global String id_factura {get;set;}
        global String caja {get;set;}
        global String id_vendedor {get;set;}
        global String nombre_vendedor {get;set;}
        global Double precio_total {get;set;}
        global String asset_id {get;set;}
        global String certified_id {get;set;}
        global String opportunity_id {get;set;}
        //global String sku{get;set;}
    	global List<Pagos> PartidasDePago {get;set;}
 }
	global class Pagos {
        global String tipo_de_pago {get;set;}
        global Double pago {get;set;}
    }
	global class PaymentGEXResponse{
        global Boolean exito {get;set;}
        global String codigo_error {get;set;}
        global String mensaje_error {get;set;}
        global String id_informacionPago {get;set;}
     }

}