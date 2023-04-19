@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_VentaSM {
		global class VentaSMRequest{
			global String idCotizacion{get;set;}
			global List<String> idPartidaPresupuesto{get;set;}
			global DSALES_PaymentInfoWrapper.PaymentRequest pagos {get;set;}
			global DSALES_IPAssetWrapper.IPAssetRequest activo {get;set;}
			global DSALES_AccountWrapper.AccountRequest cliente{get;set;}
		}

		global class ListaPartidasOportunidad
		{
			global String idPartidaOportunidad { get; set; }
			global String nombreProducto { get; set; }
			global String sku { get; set; }
		}
	
		global class VentaSMResponse{
			global Boolean exito {get;set;}
			global String idCliente{get;set;}
			global String idPago{get;set;}
            global String idUniversal{get;set;}
			global String idActivo{get;set;}
			global List<ListaPartidasOportunidad> listaPartidasOportunidad { get; set; }
			global String mensajeError {get;set;}
			global Integer codigoError {get;set;}
		}
}