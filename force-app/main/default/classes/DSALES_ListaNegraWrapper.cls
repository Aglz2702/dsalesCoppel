public class DSALES_ListaNegraWrapper {
    public class ResponseListaNegra {
        public string ok{ get; set; }
        public Boolean estatus{ get; set; }
        public string rfc{ get; set; } 
        public string nombreContribuyente{ get; set; }   
    }
    public class EnviarListaNegra {
        public string nombre{ get; set; }
        public string rfc{ get; set; }
        public string business{ get; set; }
        public string company{ get; set; }
        public string transaccion{ get; set; }
    }

}