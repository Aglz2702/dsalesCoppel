global class DSALES_QuoteSmWrapper {
    global class QuoteSmRequest{
        global String numero_cliente {get;set;}
        global String nombre {get; set;}
        global String apellido_materno {get;set;}
        global String apellido_paterno {get;set;}
        global String id_tienda {get; set;}
        global String sku {get;set;}
        //pedido por inter
        global String tipo_uso {get; set;}
        global String tipo_vehiculo {get; set;}
        global String rfc {get; set;}
        global String plazo_cotizar {get; set;}
        global String nombre_vendedor {get; set;}
        global String telefono_celular {get; set;}
        global String correo_electronico {get;set;}
        global String genero_contacto {get; set;}
        global Date fecha_nacimiento {get; set;}
        global String codigo_postal {get; set;}
        global String id_vehiculo {get; set;}
        global String opcion_pago {get; set;}
        global date fecha_inicio {get; set;}
        global String precioProducto {get; set;}
    }
    global class QuotePostProvedor{
        //Inter Cotizacion
        global String plazo {get; set;}
        global String business {get; set;} //sales-fijo
        global String insurance {get; set;} //sales-fijo
        global String contact_name {get; set;}//combinacion
        global String contact_method {get; set;}//sales-fijo
        global String contact_phone {get; set;}
        global String contact_email {get;set;}
        global String contact_gender {get; set;}
        global String contact_birth_date {get; set;}
        global String contact_zip_code{get; set;}
        global Boolean contact_now {get; set;}//fijo-sales
        global String vehicle_id {get; set;}
        global String vehicle_service {get; set;}//fijo-sales
        global String vehicle_use {get; set;}//fijo-sales
        global String vehicle_type {get; set;}//fijo-sales
        global String payment_option {get; set;}
        global String packagge {get; set;}
        global String promotion_code {get; set;}//fijo
        global String associate_id {get; set;}//fijo
        global String quote_date {get; set;}//fecha creacion-sales
        global String start_at {get; set;}
        global List<Plazo> listaPlazos {get; set;}
        
    }
    global class Plazo {
		global String producto {get;set;}
        global String plazo {get;set;}
	}
    
	global class Product {
		global String sku {get;set;}
	}
    
    global class respuestaDelProveedor{
		global Integer code {get;set;}
        global Boolean success {get;set;}
        global List<ArmadoMuleSoft> plazos {get;set;}
	}
    
    global class ArmadoMuleSoft{
        global String tracking_id {get;set;}
        global String name {get;set;}
        global String plazo {get;set;}
        global Data data {get;set;}
	}
    global class Campanias{
        global String nombre {get;set;}
        global String tipoCampana {get;set;}
        global String descripcion {get;set;}
	}
    global class RespuestaPlazos{
        global String tracking_id {get;set;}
        global String nombreProducto {get;set;}
        global String vigencia {get;set;}  
        global String Idpartida {get;set;}
        global String descripcion {get;set;}
        global Boolean seguro_gratis {get;set;}
        global ReceiptEspa costos {get;set;}
	}

    global class RespuestaParaNpv{
        global String idCotizacion {get;set;}
        global String mensaje {get;set;}
        global Integer codigo_error {get;set;}
        global Boolean success {get;set;}
        global Boolean listaNegra {get;set;}
        global List<RespuestaPlazos> listaSeguros {get;set;}
        global RespuestaPlazos listaproducto {get;set;}
        global List<Campanias> campanias{get;set;}
        global String Idoportunidad{get;set;}   
    }

    global class CoveragesArray{
        global String code {get;set;}
        global String name {get;set;}
        global Integer deductive {get;set;}
        global String sum_assured {get;set;}
    }
    
    global class Data{
        global List<CoveragesArray> coverages_array {get;set;}
        global String quote_id {get;set;}
        global List<Receipt> receipts {get;set;}
        global InsurancePremium insurance_premium {get;set;}
        global String police_id {get;set;}
        global String company_logo {get;set;}
        global List<PaymentOptionsJson> payment_options_json {get;set;}
    }
    
    global class InsurancePremium{
        global Double net_premium {get;set;}
        global Integer commission {get;set;}
        global Double surcharge {get;set;}
        global Double tax {get;set;}
        global Double right {get;set;}
    }
    
    global class PaymentOptionsJson{
        global String value {get;set;}
        global String label {get;set;}
    }
    
    global class Receipt{
        global Integer numbere {get;set;}
        global String start_date {get;set;}
        global String end_date {get;set;}
        global String net_premium {get;set;}
        global String total_premium {get;set;}
        global String right {get;set;}
        global String recharge {get;set;}
        global String tax {get;set;}
        global String commission {get;set;}
        global String pagoTotalEfectivo {get;set;}
        global String pagoMensual {get;set;}
        
    }
    global class ReceiptEspa{
        global Integer numero {get;set;}
        global String fecha_inicio {get;set;}
        global String fecha_termino {get;set;}
        global String prima_neta {get;set;}
        global String precio_venta {get;set;}
        global String derechos_poliza {get;set;}
        global String recargos {get;set;}
        global String impuestos {get;set;}
        global String comision {get;set;}
        global String pagoTotalEfectivo {get;set;}
        global String pagoMensual {get;set;}
    }
}