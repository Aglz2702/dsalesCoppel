global class DSALES_PaymentInfoWrapper {
    global class PaymentRequest{
<<<<<<< HEAD
<<<<<<< HEAD
        global String cashier_box {get;set;} 
        global String article_description {get;set;}
        global String payment_method {get;set;}
        global String bill {get;set;}
        global String customer_adress {get;set;}
        global String sku {get;set;}
        global String telephone {get;set;}
        global double total {get;set;}
        global String salesman_name {get;set;}
        global String opportunity_name {get;set;}
        global boolean moto_delivered {get;set;}
        global boolean external_moto {get;set;}
        global boolean moto_noInsurance {get;set;}
        global String tipoProducto{get;set;}
        
        //Lo nuevo
        global String quoteid {get;set;}
        global String AccountId {get;set;}
        global List<Pago> ListadePagos{get;set;}
=======
=======
>>>>>>> Deuda-Tecnica
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
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> deuda-tecnica
    global class ListaDePago{
        //public Integer num_pago { get; set; }
        global String metodo_pago { get; set; }
        global Integer pago { get; set; }
<<<<<<< HEAD
>>>>>>> Deuda-Tecnica
    }
=======
>>>>>>> Deuda-Tecnica

    global class PaymentResponse{
        global String message {get;set;}
        global Integer errorCode {get;set;}
        global Boolean success {get;set;}
        global List<String> paymentInfo_ids {get;set;}
=======
>>>>>>> deuda-tecnica
    }
    global class PaymentResponse{
        global String error_message {get;set;}
        global Integer error_code {get;set;}
        global Boolean success {get;set;}
        global String pago_id {get;set;}
    }
}