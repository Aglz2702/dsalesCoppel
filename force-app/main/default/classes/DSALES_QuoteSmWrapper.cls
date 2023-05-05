@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_QuoteSmWrapper {
    global class QuoteSmRequest{
        global String numeroCliente {get;set;}
        global String nombre {get; set;}
        global String apellidoMaterno {get;set;}
        global String apellidoPaterno {get;set;}
        global String idTienda {get; set;}
        global String sku {get;set;}
        //pedido por inter
        global String tipoUso {get; set;}
        global String tipoVehiculo {get; set;}
        global String rfc {get; set;}
        global String plazoCotizar {get; set;}
        global String nombreVendedor {get; set;}
        global String telefonoCelular {get; set;}
        global String correoElectronico {get;set;}
        global String generoContacto {get; set;}
        global Date fechaNacimiento {get; set;}
        global String codigoPostal {get; set;}
        global String idVehiculo {get; set;}
        global String opcionPago {get; set;}
        global date fechaInicio {get; set;}
        global String precioProducto {get; set;}
    }
    global class QuotePostProvedor{
        //Inter Cotizacion
        global String negocio {get; set;} //sales-fijo
        global String aseguradora {get; set;} //sales-fijo
        global String nombreCompleto {get; set;}//combinacion
        global String metodoContacto {get; set;}//sales-fijo
        global String telefonoContacto {get; set;}
        global String correoContacto {get;set;}
        global String generoContacto {get; set;}
        global String fechaNacimientoContacto {get; set;}
        global String cpContacto{get; set;}
        global Boolean contactar {get; set;}//fijo-sales
        global String idVehiculo {get; set;}
        global String servicioVehiculo {get; set;}//fijo-sales
        global String usoVehiculo {get; set;}//fijo-sales
        global String tipoVehiculo {get; set;}//fijo-sales
        global String opcionPago {get; set;}
        global String paquete {get; set;}
        global String codigoPromocion {get; set;}//fijo
        global String idAsociado {get; set;}//fijo
        global String fechaCotizacion {get; set;}//fecha creacion-sales
        global String fechaInicio {get; set;}      
        global String plazo {get; set;}
        global List<Plazo> listaPlazos {get; set;}
    }
    global class Plazo {
		global String paquete {get;set;}
        global String opcionPago {get;set;}
	}  
	global class Product {
		global String sku {get;set;}
	}   
    global class RespuestaDelProveedor{
		global Integer codigo {get;set;}
        global Boolean success {get;set;}
        global List<ArmadoMuleSoft> plazos {get;set;}
	}    
    global class ArmadoMuleSoft{
        global String trackingId {get;set;}
        global String nombre {get;set;}
        global String plazo {get;set;}
        global Data data {get;set;}
	}
    global class Campanias{
        global String nombre {get;set;}
        global String tipoCampana {get;set;}
        global String descripcion {get;set;}
	}
    global class RespuestaPlazos{
        global String trackingId {get;set;}
        global String paquete {get;set;}
        global String vigencia {get;set;}  
        global String idpartida {get;set;}
        global String descripcion {get;set;}
        global Boolean seguroGratis {get;set;}
        global Data data {get;set;}
        
	}
    global class RespuestaParaNpv{
        global String idCotizacion {get;set;}
        global String mensaje {get;set;}
        global Integer codigoError {get;set;}
        global Boolean success {get;set;}
        global Boolean listaNegra {get;set;}
        global List<RespuestaPlazos> listaSeguros {get;set;}
        global RespuestaPlazos listaproducto {get;set;}
        global List<Campanias> campanias{get;set;}
        global String idOportunidad{get;set;}
    }
    global class CoveragesArray{
        global String codigo {get;set;}
        global String nombre {get;set;}
        global Integer deducible {get;set;}
        global String sumaAsegurada {get;set;}
    }  
    global class Data{
        global List<CoveragesArray> listaCoberturas {get;set;}
        global String idCotizacion {get;set;}
        global List<Receipt> recibos {get;set;}
        global InsurancePremium primaSeguro {get;set;}
        global String idPoliza {get;set;}
        global String logotipoEmpresa {get;set;}
        global List<PaymentOptionsJson> paymentOptionsJson {get;set;}
    }   
    global class InsurancePremium{
        global Double primaNeta {get;set;}
        global Integer comision {get;set;}
        global Double recargo {get;set;}
        global Double impuestos {get;set;}
        global Double derecho {get;set;}
    }   
    global class PaymentOptionsJson{
        global String value {get;set;}
        global String label {get;set;}
    }
    global class Receipt{
        global Integer numero {get;set;}
        global String fechaInicio {get;set;}
        global String fechaTermino {get;set;}
        global String primaNeta {get;set;}
        global String primaTotal {get;set;}//precioVenta
        global String derechosPoliza {get;set;}
        global String recargo {get;set;}
        global String impuestos {get;set;}
        global String comision {get;set;}
        global String pagoTotalEfectivo {get;set;}
        global String pagoMensual {get;set;}
    }
}