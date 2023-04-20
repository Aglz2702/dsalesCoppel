@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_CertificadoWrapper {
    
    
    global class CertificadoRequest{
        global String idCuenta {get;set;} 
        global String idProductoAdquirido{get;set;}
        global String idPago {get;set;}
        global String idFactura {get;set;}//remaining
        global String numeroCliente {get;set;}
        global	String	claveTienda	{get;set;}//remaining
        global  String  idTienda {get;set;}//remaining
        global	String	numeroCajaCoppel	{get;set;}
        global	String	idVendedor	{get;set;}
        global	String	nombreVendedor	{get;set;}
        global String  garantiaCoppelProducto{get;set;}
        global	String	nombreCompletoCliente	{get;set;}
        global	String	direccionCliente	{get;set;}
        global	String	emailCliente	{get;set;}
        global	String	telefonoCliente	{get;set;}
        global	String	celularCliente	{get;set;}
        global	String	sku	{get;set;}
       
         global String skuDeTangible {get;set;}
        global String idPartidaPresupuesto {get;set;}
        global	String	modeloTangible	{get;set;}
        global	String	marcaTangible	{get;set;}
        global	String	numeroSerie	{get;set;}
        global	Double	precioTangible	{get;set;}
        global	Double	garantiaCoppelTangible	{get;set;}
        global	Date	fechaInicioGarantiaExtendida	{get;set;}
        
        global	Date	fechaCompraTangible	{get;set;}
        global	String	descripcionTangible	{get;set;}
        global	Date	fechaCompraGarantia	{get;set;}
        global  Date 	fechaVenta {get;set;}
        global	Double	costoGarantia	{get;set;}
        global	Date	fechaFinGarantiaExtendida	{get;set;}
        
    }


    global class CancelacionGex{

        global String idProducto {get;set;}
        global String motivoCancelacion {get;set;}
        global String estatus {get;set;}
    }
    global class CertificadoResponse{
        global Boolean exito {get;set;}
        global String codigoError {get;set;}
        global String mensajeError {get;set;}
        global String idCertificado {get;set;}
    }
    
}