@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_QuoteScWrapper {
    global class QuoteScRequest{
        global String numeroCliente {get;set;}
        global String nombre {get; set;}
        global String apellidoMaterno {get;set;}
        global String apellidoPaterno {get;set;}
        global String idTienda {get; set;}
        global String rfc {get; set;}
        global String plazoCotizar {get; set;}
        global String nombreVendedor {get; set;}
        global String telefonoCelular {get; set;}
        global String correoElectronico {get;set;}
        global String fechaNacimiento {get; set;}
        global String opcionPago {get; set;}
        //global String fechaDeVenta {get; set;}
        global Double precioCelular {get; set;}
        global String numeroDeSucursal {get;set;}
        global String identificadorDelVendedor {get; set;}
        global String sku {get;set;}
        global String marcaCelular {get; set;}
        global String modeloCelular {get; set;}
        global String colorCelular {get; set;}
        global String identificadorCoppel {get; set;}
        global String quoteId {get;set;}
        
        //global String generoContacto {get; set;}
        //global String codigoPostal {get; set;}
        // global String fechaInicio {get; set;}

    }
    global class CardifResponse{
        global Boolean exito {get;set;}
        global String mensaje {get;set;}
        global String metodoPago {get; set;}
        global Double montoSeguroTotal {get; set;}
        global Double montoSeguroMensual {get;set;}
        global String uuid {get; set;}
        global List<plazo> plazos{get; set;}
        global List<InsurancePremium> price{get;set;}

    }
   
    global class QuoteScResponse{
        global Boolean exito {get;set;}
        global String mensaje {get;set;}
        global String mensajeError {get;set;}
        global String codigoError {get;set;}
        global String idCotizacion {get;set;}
        global String idOportunidad {get;set;}
        global Boolean listaNegra {get;set;}     
    }
    global class Plazo {
        global String paquete {get;set;}
        global List<opcionPago> opcionesPago {get;set;}
        
    }
    
    global class OpcionPago {
        global String opcionPago {get;set;}
    }
    global class InsurancePremium{
        global Double seguroPrice {get;set;}
        
    }
   
}