@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_QuoteGexWrapper {
    global class QuoteGexRequest{
        global String idTienda {get; set;}
        global String numeroCliente {get;set;}
        global String nombre {get; set;}
        global String apellidoPaterno {get;set;}
        global String apellidoMaterno {get;set;}
        global String correoElectronico {get;set;}
        global String idUniversal {get;set;}
        global String idOportunidad	{get;set;}
        global String iduVenta {get;set;}
        global List<Product> productos {get;set;}
 }
	global class Product {
		global String skuDeTangible {get;set;}
		global Double cantidadProductosTangibles {get;set;}
        global String articulo {get; set;}
        global String modelo {get; set;}
        global String marca {get; set;}
        global Double precioTangible {get; set;}
        //global Integer idSecuencia {get; set;}
        //global List<Integer> idSecuencia{get;set;}
    }
    global class QuoteGexResponse{
        global String	skuDeTangible	{get;set;}
        global String	skuDePrecio	{get;set;}
        global String	skuDeServicio	{get;set;}
        global String	nombreIntangible	{get;set;}
        global double	precio	{get;set;}
        global double	costoTotal	{get;set;}
        global String 	mesesCobertura {get;set;}
        global String	idPartidaDePresupuesto	{get;set;}
        global Integer	idSecuencia	{get;set;} 
    }

    global class RespuestaNPV{        
        global Boolean 	success {get;set;}
        global String	idCotizacion	{get;set;}
        global String	idOportunidad	{get;set;}
        global String	iduVenta	{get;set;}
        global String 	codigoError {get;set;}
        global String 	mensaje {get;set;}
        global List<QuoteGexResponse> respuesta {get;set;}
        global List<Nodos> descripciones {get;set;}
    }
    
    global class Nodos{
        global String	description	{get;set;}
        global String	subTipo	{get;set;}
        global String	tipoDeServicio{get;set;}
        global List<String>	sku	{get;set;}
    }
    
}