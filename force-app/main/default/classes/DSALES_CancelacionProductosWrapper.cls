@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class DSALES_CancelacionProductosWrapper {
    global class Request{
        global String canal { get; set; }
        global Date fechaCancelacion { get; set; }
        global String folioCancelacion { get; set; }
        global String idUniversal { get; set; }
        global String idTienda { get; set; }
        global String numeroCliente { get; set; }
        global String nombreVendedor { get; set; }
        global String numeroVendedor { get; set; }
        global String estatus { get; set; }
        global String motivoCancelacion { get; set; }
        global String causa {get;set;}
        global List<ListaProducto> listaProductos { get; set; }
        global List<DSALES_ReembolsoWrapper.ReembolsoRequest> listaReembolso {get;set;}
    }
    global class ListaProducto
    {
        global String idPartidaOportunidad { get; set; }
        global String estatus { get; set; }
        global String motivoCancelacion { get; set; }
        global String idCertificado { get; set; }
        global String causa{get;set;}
    }

    global class Response{
        global Boolean exito{get;set;}
        global String idCancelacion{get;set;}
        global Integer codigoError{set;get;}
        global String mensaje{set;get;}
    }

}