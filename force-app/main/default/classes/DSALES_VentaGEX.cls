global class DSALES_VentaGEX {
    
    global class VentaGexRequest{
        global String quoteId{get;set;}
        global List<DSALES_AssetWrapper.AssetRequest> lista_de_productos {get;set;}
        global DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest pago {get;set;}
        global List<DSALES_CertificadoWrapper.CertificadoRequest> lista_de_certificados{get;set;}
        global DSALES_AccountWrapper.AccountRequest cliente{get;set;}
        global Date fecha_compra {get;set;}
        global String id_tienda {get;set;} //sólo número
        global String numero_caja {get;set;}
        global String id_vendedor {get;set;}
        global String nombre_vendedor{get;set;}
        global String id_factura {get;set;}
        //fecha_compra
    }

    global class ServicioCorrespondiente{
        global String sku {get;set;}
		global String nombre_producto {get;set;}
		global String  id_partida_de_oportunidad {get;set;}
		global String tipo_producto {get;set;}
		global String  folio_certificado {get;set;} 
    }
    global class OpporLineItem{
       	global String id_partida_de_oportunidad {get;set;}
        global String nombre_producto {get;set;}
        global String sku {get;set;}
        global String tipo_producto {get;set;}
        global String id_producto_adquirido {get;set;}
        global List<ServicioCorrespondiente> entregaServicioCorrespondiente{get;set;}
    }
   
    
    global class VentaGexResponse{
        global Boolean exito {get;set;}
        global String mensaje_de_error {get;set;}
        global String codigo_de_error {get;set;}
        global List<String> id_de_pago {get;set;}
        global List<OpporLineItem> ListaPartidasOportunidad {get;set;}
    }
    
}