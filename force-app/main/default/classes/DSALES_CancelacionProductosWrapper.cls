global with sharing class DSALES_CancelacionProductosWrapper {
    global class request{
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
        global List<ListaProducto> ListaProductos { get; set; }
        global List<DSALES_ReembolsoWrapper.ReembolsoRequest> ListaReembolso {get;set;}
    }
    global class ListaProducto
    {
        global String idPartidaOportunidad { get; set; }
        global String estatus { get; set; }
        global String motivoCancelacion { get; set; }
        global String idCertificado { get; set; }
    }

    global class response{
        global Boolean success{get;set;}
        global Integer codigoError{set;get;}
        global String mensajeError{set;get;}
    }

}