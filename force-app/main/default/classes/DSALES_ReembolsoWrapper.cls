global class DSALES_ReembolsoWrapper {
    global class ReembolsoRequest{
        //global String pago_universal {get;set;}
        global String comentarios {get;set;}
        global date fechaReembolso {get;set;}
        global String nombreProducto {get;set;}
        global String numeroCancelacion {get;set;}
        //Efectivo/Tarjeta
        global String metodoPago {get;set;}
        global String numeroReferencia {get;set;}
        global double cantidadReembolsada {get;set;}
        
    }  
    global class Reembolso
    {
       global list<ReembolsoRequest> reembolsos {get;set;}
    }
    global class ReembolsoResponse
    {
        global List<String> idReembolsos {get;set;}
         global Boolean exito {get;set;}
        global String codigoError {get;set;}
        global String mensajeError {get;set;}
        
        
    }

}