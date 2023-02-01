global class DSALES_PaymentInfoWrapper {
    global class PaymentRequest{
        global String num_factura { get; set; }
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
    global class ListaDePago{
        //public Integer num_pago { get; set; }
        global String metodo_pago { get; set; }
        global Integer pago { get; set; }
    }
    global class PaymentResponse{
        global String error_message {get;set;}
        global Integer error_code {get;set;}
        global Boolean success {get;set;}
        global String pago_id {get;set;}
    }
}