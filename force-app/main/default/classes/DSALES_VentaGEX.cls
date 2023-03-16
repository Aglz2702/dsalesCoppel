global class DSALES_VentaGEX {
    
    global class VentaGexRequest{
        global String quoteId{get;set;}
        global List<DSALES_AssetWrapper.AssetRequest> listAssets {get;set;}
        global DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest paymentInformation {get;set;}
        global List<DSALES_CertificadoWrapper.CertificadoRequest> certificado{get;set;}
        global DSALES_AccountWrapper.AccountRequest cliente{get;set;}
        global Date fecha_compra {get;set;}
        global String id_tienda {get;set;} //sólo número
        global String numero_caja {get;set;}
        global String id_vendedor {get;set;}
        global String nombre_vendedor{get;set;}
        global String id_factura {get;set;}
        //fecha_compra
    }
    global class OpporLineItem{
       	global String id_partida_de_oportunidad {get;set;}
        global String nombre_producto {get;set;}
        global String sku {get;set;}
    }
    global class Assets{
        global String idAsset{get;set;}
        global String sku{get;set;}
        global String articulo {get;set;}
    }
     global class Certificado{
         global String idCertificado {get;set;}
         global String	sku_de_tangible {get;set;} 
         global String id_partida_de_presupuesto{get;set;}
         global String modelo_tangible{get;set;}
         global String marca_tangible{get;set;}
         global String precio_tangible{get;set;}
         global String garantia_coppel_producto{get;set;}
    }
    
    global class VentaGexResponse{
        global Boolean success {get;set;}
        global String error_message {get;set;}
        global String error_code {get;set;}
        global List<String> assets_id {get;set;}
        global List<String> certifieds_id {get;set;}
        global List<String> payments_id {get;set;}
        global List<OpporLineItem> ListaPartidasOportunidad {get;set;}
    }
    
}