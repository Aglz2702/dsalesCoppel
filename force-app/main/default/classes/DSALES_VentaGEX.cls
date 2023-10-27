@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_VentaGEX {
    
    global class VentaGexRequest{
        global String quoteId{get;set;}
        global List<DSALES_AssetWrapper.AssetRequest> listaDeProductos {get;set;}
        global DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest pago {get;set;}
        global List<DSALES_CertificadoWrapper.CertificadoRequest> listaDeCertificados{get;set;}
        global DSALES_AccountWrapper.AccountRequest cliente{get;set;}
        global Date fechaCompra {get;set;}
        global String idTienda {get;set;} //sólo número
        global String numeroCaja {get;set;}
        global String idVendedor {get;set;}
        global String nombreVendedor{get;set;}
        global String idFactura {get;set;}
               
    }

    global class ServicioCorrespondiente{
        global String sku {get;set;}
		global String nombreProducto {get;set;}
		global String  idPartidaDeOportunidad {get;set;}
		global String tipoProducto {get;set;}
		global String  folioCertificado {get;set;} 
    }
    global class OpporLineItem{
       	global String idPartidaDeOportunidad {get;set;}
        global String nombreProducto {get;set;}
        global String sku {get;set;}
        global String tipoProducto {get;set;}
        global String idProductoAdquirido {get;set;}
        global List<ServicioCorrespondiente> entregaServicioCorrespondiente{get;set;}
    }
   
    
    global class VentaGexResponse{
        global Boolean exito {get;set;}
        global String mensaje {get;set;}
        global String codigoDeError {get;set;}
        global String idClienteSalesforce {get;set;}
        global List<String> idDePago {get;set;}
        global List<OpporLineItem> listaPartidasOportunidad {get;set;}
    }

}