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
        //public Date fechaEndoso { get; set; }
        public String estatus { get; set; }
        public String motivoDevolucion {get; set;}
        public String solucionDevolucion {get; set;}
        public String motivoRechazo {get; set;}
        public Decimal montoDevolver {get; set;}
        //public Documento documentos { get; set; } 
        public Dato datos { get; set; } 
        public String salesforceId { get; set; } 
    }
    
    global class EndorsementResponse{
        global Boolean success {get;set;}
        global String codigoError {get;set;}
        global String mensajeError {get;set;}
        global String idEndoso { get; set; } 
    } 
}