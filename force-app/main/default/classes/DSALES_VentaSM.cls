global class DSALES_VentaSM {
		global class VentaSMRequest{
			global String id_cotizacion{get;set;}
			global String id_partida_presupuesto{get;set;}
			global DSALES_PaymentInfoWrapper.PaymentRequest pagos {get;set;}
			global DSALES_IPAssetWrapper.IPAssetRequest activo {get;set;}
			global DSALES_AccountWrapper.AccountRequest cliente{get;set;}
		}

		global class VentaSMResponse{
			global Boolean success {get;set;}
			global String id_cliente{get;set;}
			global String id_pago {get;set;}
			global String id_activo_poliza {get;set;}
			global String mensaje_error {get;set;}
			global Integer codigo_error {get;set;}
		
		}
}