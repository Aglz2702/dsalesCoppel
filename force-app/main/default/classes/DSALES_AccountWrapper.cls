global class DSALES_AccountWrapper {
	
    global class AccountRequest{
        global String numero_de_cliente {get;set;}
        global String nombre {get; set;}
        global String apellido_paterno {get;set;}
        global String apellido_materno {get;set;}
        global String telefono {get;set;}
        global String correo_electronico {get;set;}
        global String genero {get;set;}
        global Date fecha_nacimiento {get;set;}
        global String nombre_ciudad {get;set;}
        global String nombre_estado {get;set;}
        global String domicilio {get;set;}
        global String calle {get;set;}
        global String numero_exterior {get;set;}
        global String numero_interior {get;set;}
        global String colonia {get;set;}
        global String codigo_postal {get;set;}     
    }
    global class AccountResponse{
        global Boolean success {get;set;}
        global String codigo_error {get;set;}
        global String mensaje_error {get;set;}
        global String id_cuenta {get;set;}
    }
}