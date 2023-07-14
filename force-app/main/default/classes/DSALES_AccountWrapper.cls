@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_AccountWrapper {
    global class AccountRequest{
        global String numeroCliente {get;set;}
        global String nombre {get; set;}
        global String apellidoPaterno {get;set;}
        global String apellidoMaterno {get;set;}
        global String telefono {get;set;}
        global String correoElectronico {get;set;}
        global String genero {get;set;}
        global Date fechaNacimiento {get;set;}
        global String nombreCiudad {get;set;}
        global String nombreEstado {get;set;}
        global String codigoEstado{get;set;} //sm
        global String domicilio {get;set;}
        global String calle {get;set;}
        global String numeroExterior {get;set;}
        global String numeroInterior {get;set;}
        global String colonia {get;set;} //gex
        global String codigoColonia{get;set;} //sm
        global String codigoPostal {get;set;}  
        global String rfc {get;set;} 
    }
    global class AccountResponse{
        global Boolean success {get;set;}
        global String codigoError {get;set;}
        global String mensajeError {get;set;}
        global String idCuenta {get;set;}
    }
}