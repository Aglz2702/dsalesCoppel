global class DSALES_EndorsementWrapper {
    public class documento {
        public string id_documento{ get; set; }
        public string tipo_documento{ get; set; }
        public string documento{ get; set; }   
    }
    
    public class dato {
        public string id_dato {get; set;}
        public string tipo_dato {get; set;}
        public string valor {get; set;}
    }
    
    public class endorsementRequest {
        public string uid{ get; set; }
        public String numero_poliza { get; set; }
        public String tipo_endoso { get; set; }
        public String tipo_documento { get; set; }
        //public Date fecha_endoso { get; set; }
        public String estatus { get; set; }
        public string motivo_devolucion {get; set;}
        public string solucion_devolucion {get; set;}
        public string motivo_rechazo {get; set;}
        public Decimal monto_a_devolver {get; set;}
        //public documento documentos { get; set; } 
        public dato datos { get; set; } 
        public string salesforce_id { get; set; } 
    }
    
    global class endorsementResponse{
        global Boolean success {get;set;}
        global String codigo_error {get;set;}
        global String mensaje_error {get;set;}
   		global String id_endoso { get; set; } 
    } 
}