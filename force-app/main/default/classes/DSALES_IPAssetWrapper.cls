global class DSALES_IPAssetWrapper {
    global class IPAssetRequest{
        global Boolean emitir_poliza {get;set;}
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