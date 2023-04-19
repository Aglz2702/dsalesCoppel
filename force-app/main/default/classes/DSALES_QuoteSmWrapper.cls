@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_QuoteSmWrapper {
    global class QuoteSmRequest{
        global String numerocliente {get;set;}
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
        global String plazo {get; set;}
        global String business {get; set;} //sales-fijo
        global String insurance {get; set;} //sales-fijo
        global String contactName {get; set;}//combinacion
        global String contactMethod {get; set;}//sales-fijo
        global String contactPhone {get; set;}
        global String contactEmail {get;set;}
        global String contactGender {get; set;}
        global String contactBirthDate {get; set;}
        global String contactZipCode{get; set;}
        global Boolean contactNow {get; set;}//fijo-sales
        global String vehicleId {get; set;}
        global String vehicleService {get; set;}//fijo-sales
        global String vehicleUse {get; set;}//fijo-sales
        global String vehicleType {get; set;}//fijo-sales
        global String paymentOption {get; set;}
        global String packagge {get; set;}
        global String promotionCode {get; set;}//fijo
        global String associateId {get; set;}//fijo
        global String quoteDate {get; set;}//fecha creacion-sales
        global String startAt {get; set;}
        global List<Plazo> listaPlazos {get; set;}
        
    }
    global class Plazo {
		global String producto {get;set;}
        global String plazo {get;set;}
	}
    
	global class Product {
		global String sku {get;set;}
	}
    
    global class RespuestaDelProveedor{
		global Integer code {get;set;}
        global Boolean success {get;set;}
        global List<ArmadoMuleSoft> plazos {get;set;}
	}
    
    global class ArmadoMuleSoft{
        global String trackingId {get;set;}
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
        global String trackingId {get;set;}
        global String nombreProducto {get;set;}
        global String vigencia {get;set;}  
        global String idpartida {get;set;}
        global String descripcion {get;set;}
        global Boolean seguroGratis {get;set;}
        global ReceiptEspa costos {get;set;}
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
        global String idoportunidad{get;set;}   
    }

    global class CoveragesArray{
        global String code {get;set;}
        global String name {get;set;}
        global Integer deductive {get;set;}
        global String sumAssured {get;set;}
    }
    
    global class Data{
        global List<CoveragesArray> coveragesArray {get;set;}
        global String quoteId {get;set;}
        global List<Receipt> receipts {get;set;}
        global InsurancePremium insurancePremium {get;set;}
        global String policeId {get;set;}
        global String companylogo {get;set;}
        global List<PaymentOptionsJson> paymentPptionsJson {get;set;}
    }
    
    global class InsurancePremium{
        global Double netPremium {get;set;}
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
        global String startDate {get;set;}
        global String endDate {get;set;}
        global String netPremium {get;set;}
        global String totalPremium {get;set;}
        global String right {get;set;}
        global String recharge {get;set;}
        global String tax {get;set;}
        global String commission {get;set;}
        global String pagoTotalEfectivo {get;set;}
        global String pagoMensual {get;set;}
        
    }
    global class ReceiptEspa{
        global Integer numero {get;set;}
        global String fechaInicio {get;set;}
        global String fechaTermino {get;set;}
        global String primaNeta {get;set;}
        global String precioVenta {get;set;}
        global String derechosPoliza {get;set;}
        global String recargos {get;set;}
        global String impuestos {get;set;}
        global String comision {get;set;}
        global String pagoTotalEfectivo {get;set;}
        global String pagoMensual {get;set;}
    }
}