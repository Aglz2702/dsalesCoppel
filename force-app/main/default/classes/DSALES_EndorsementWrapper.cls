global class DSALES_EndorsementWrapper {
    public class Documento {
        public String idDocumento{ get; set; }
        public String tipoDocumento{ get; set; }
        public String documento{ get; set; }   
    }
    
    public class Dato {
        public String idDato {get; set;}
        public String tipoDato {get; set;}
        public String valor {get; set;}
    }
    
    public class EndorsementRequest {
        public String uid{ get; set; }
        public String numeroPoliza { get; set; }
        public String tipoEndoso { get; set; }
        public String tipoDocumento { get; set; }
        public Date fechaEndoso { get; set; }
        public String estatus { get; set; }
        public String estatusComentario{get; set;}
        public String solucion {get; set;}
        public Decimal montoDevolucion {get; set;}
        public Dato datos { get; set; } 
        public String salesforceId { get; set; } 
    }
    
    global class EndorsementResponse{
        global String mensaje {get;set;}
        global Boolean success {get;set;}
        global String codigoError {get;set;}
        global String mensajeError {get;set;}
        global String idEndoso { get; set; } 
    } 
}