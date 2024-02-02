@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_ServicioCitasWrapper {
    
    global class CitasRequest{    
        global String 	certificado {get;set;}    
        global String inicio {get;set;}
        global String fin {get;set;}
        global String 	proveedor {get;set;}
        global String 	tecnico {get;set;}
        global String 	asunto {get;set;}
        global String 	noCita {get;set;}
        global Boolean 	validacion {get;set;}
        global String 	sku {get;set;}
        global String 	articulo {get;set;}
        global String 	marca {get;set;}
        global String 	modelo {get;set;}
        global String 	cuestionario {get;set;}
        global String 	codigoP {get;set;}
        global String 	codigoPCliente {get;set;}
        global String 	direccion {get;set;}
        global String 	estatus {get;set;}
    }

    global class CitasResponse{        
        global Boolean 	exito {get;set;}
        global String 	codigoError {get;set;}
        global String 	mensaje {get;set;}
        global String 	idEvento {get;set;}
    }
}