global class DSALES_IPAssetWrapper {
    global class IPAssetRequest{
        /*global String store{get;set;}
        //Información de Pago
        global String payment_info{get;set;}
        //global String ticket{get;set;}
        global String partner{get;set;}
       // global String client_id{get;set;}
        //global String client_name{get;set;}
        global Boolean external_motorcycle{get;set;}
        //global String invoice_number{get;set;}
        
        global Double invoice_value{get;set;}
        global String status{get;set;}
        global String key_amis{get;set;}
        global String key_vehicle{get;set;}
        global String description{get;set;}
        global String brand{get;set;}
        global String model{get;set;}
        global String motor_number{get;set;}
        global String serial_number{get;set;}
        global String license_plate{get;set;}
        global String service{get;set;}
        global String use{get;set;}
        global String asset_name{get;set;}
        global String motorcycle_delivered{get;set;}*/
        global String uso { get; set; }
        global String id_tienda { get; set; }
        global String servicio { get; set; }
        global String numero_serie { get; set; }
        global String numero_motor { get; set; }
        global String modelo { get; set; }
        global String placas { get; set; }
        global String clave_vehicular { get; set; }
        global Integer valor_factura { get; set; }
        global Boolean bajo_demanda { get; set; }
        global String descripcion { get; set; }
        global String marca { get; set; }
        global String nombre_activo { get; set; }
        global String id_pago { get; set; }
    }
    global class IPAssetResponse{
        global Boolean success {get;set;}
        global String mensaje_error {get;set;}
        global Integer codigo_error {get;set;}
        global String id_activo {get;set;}
    }
}