@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_SiniestroRPWrapper {

    global class SiniestroRPRequest{
        //Información de Siniestro
        global String infoResumenPago{get;set;}
        global List<listaSiniestros> listSiniestro{get;set;}
    }
    global class ListaSiniestros{
        //Informacion de Resumen de pago de poliza
        global String nombrePagoSiniestro{get;set;}
        global Double cantidadPago{get;set;}
        global String tipoPago{get;set;}
        global Date fechaPago{get;set;}
    }
    global class SiniestroRPResponse{ 
        global Boolean exitoso {get;set;}
        global String mensajeError {get;set;}
        global Integer codigoError {get;set;}
        global String idPagoSiniestro {get;set;}
    }
    

}