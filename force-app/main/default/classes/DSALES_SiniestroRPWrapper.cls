global class DSALES_SiniestroRPWrapper {

    global class SiniestroRPRequest{
        //Información de Siniestro
        global String claimpayment_info{get;set;}
        global List<listaSiniestros> listSiniestro{get;set;}
    }
    global class listaSiniestros{
        //Informacion de Resumen de pago de poliza
        global String claimpayment_name{get;set;}
        global Double payment_amount{get;set;}
        global String payment_type{get;set;}
        global Date payment_date{get;set;}
    }
    global class SiniestroRPResponse{ 
        global Boolean success {get;set;}
        global String error_message {get;set;}
        global Integer error_code {get;set;}
        global String claimpayment_id {get;set;}
    }
    

}