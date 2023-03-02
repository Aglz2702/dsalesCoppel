global class DSALES_ReembolsoWrapper {
    global class ReembolsoRequest{
        global String pago_universal {get;set;}
        global String comentarios {get;set;}
        global date fecha {get;set;}
        //Efectivo/Tarjeta
        global String metodo_pago {get;set;}
        global String numero_referencia {get;set;}
        global double cantidad {get;set;}
        
    }  
    global class ReembolsoResponse
    {
        global String id_reembolso {get;set;}
         global Boolean exito {get;set;}
        global String codigo_error {get;set;}
        global String mensaje_error {get;set;}
        
        
    }

}