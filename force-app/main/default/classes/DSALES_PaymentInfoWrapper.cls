global class DSALES_PaymentInfoWrapper {
    public class PaymentRequest{
        public Integer num_factura { get; set; }
        public Integer total_factura { get; set; }
        public Boolean Seguro { get; set; }
        public String nombre_vendedor { get; set; }
        public String numero_caja { get; set; }
        public String id_oportunidad { get; set; }
        public String clave_tienda { get; set; }
        public Date fecha_de_entrega { get; set; }//pdf
        public Date fecha_venta { get; set; }
        public String sku { get; set; }
        public Integer plazos { get; set; }
        public List<ListaDePago> ListaDePagos { get; set; }
    }
    public class ListaDePago{
        //public Integer num_pago { get; set; }
        public String metodo_pago { get; set; }
        public Integer pago { get; set; }
    }
    global class PaymentResponse{
        global String error_message {get;set;}
        global Integer error_code {get;set;}
        global Boolean success {get;set;}
        global String paymentInfo_id {get;set;}
    }
}