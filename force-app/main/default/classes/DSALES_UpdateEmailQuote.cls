@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_UpdateEmailQuote {
    global class DSALES_UpdateEmailQuoteRequest{
		global String idCotizacion{get;set;}
		global String correo{get;set;}
		global String idOportunidad{get;set;}
	}
 
    global class DSALES_UpdateEmailQuoteResponse{
		global Boolean exito{get;set;}
		global Integer codigoError{get;set;}
        global String mensaje{get;set;}	
	}
  
}