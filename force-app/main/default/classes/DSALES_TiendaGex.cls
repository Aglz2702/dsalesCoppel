@SuppressWarnings('PMD.AvoidGlobalModifier')
Global with sharing class DSALES_TiendaGex {
    global class tiendaRequest{
        global String idTienda{get;set;} //limit 20
        global Boolean activa {get;set;}
        global String tiendaBase {get;set;} //limit 10
         global String telefono {get;set;}
        global String telefonoTiendaBase {get;set;}
        global String nombreTienda {get;set;} //limit 80
        global String direccion {get;set;}
        global String estado {get;set;}
         global String ciudad{get;set;}
        global String region{get;set;}
        global String codigoPostal{get;set;}
       
        global String division{get;set;}
        global String nombreGerente{get;set;}
        global String numeroCelular{get;set;}
        global String emailGerente{get;set;}
        global Boolean banco{get;set;}
        global Boolean optica{get;set;}
        global Boolean moduloAfore{get;set;}
        global Date fechaApertura{get;set;}
        global Date ultimaRemodelacion{get;set;}
        global String tipoDeTienda{get;set;}
        global String formato {get;set;}
    }
    global class tiendaResponse{
        global String mensajeError {get;set;}
        global String idTienda {get;set;}
        global Boolean exito {get;set;}
        global String codigoError {get;set;}
    }
}