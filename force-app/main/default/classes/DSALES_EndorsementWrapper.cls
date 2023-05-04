@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_EndorsementWrapper {
    global class Documento {
        global String idDocumento{ get; set; }
        global String tipoDocumento{ get; set; }
        global String documento{ get; set; }   
    }
    
    global class Dato {
        global String idDato {get; set;}
        global String tipoDato {get; set;}
        global String valor {get; set;}
    }
    
    global class EndorsementRequest {
        global String uid{ get; set; }
        global String numeroPoliza { get; set; }
        global String tipoEndoso { get; set; }
        global String tipoDocumento { get; set; }
        global Date fechaEndoso { get; set; }
        global String estatus { get; set; }
        global String estatusComentario{get; set;}
        global String solucion {get; set;}
        global Decimal montoDevolucion {get; set;}
        global Dato datos { get; set; } 
        global String salesforceId { get; set; } 
    }
    
    global class EndorsementResponse{
        global String mensaje {get;set;}
        global Boolean success {get;set;}
        global String codigoError {get;set;}
        global String mensajeError {get;set;}
        global String idEndoso { get; set; } 
    } 
}