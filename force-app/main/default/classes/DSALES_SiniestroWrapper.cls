@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_SiniestroWrapper {
    
    global class Vehiculo{
        global String descripcion { get; set;}
        global String anio { get; set;}
        global String placa { get; set;}
        global String serie { get; set;}
    }

    global class Poliza{
        global String numeroPoliza { get; set;}
        global String inciso { get; set;}
        global String fechaInicioVigencia { get; set;}
        global String fechaFinVigencia { get; set;}
        global String nombreAsegurado { get; set;}
    }

    global class SiniestroPostResponse{
        global Boolean success { get; set;}
        global String mensaje { get; set;}
        global Integer codigoError { get; set;}
        global String idSiniestro { get; set;}      
    }
    global class SiniestroGet{
        global String uid { get; set;}
        global String reporte { get; set;}
        global String numeroSiniestro { get; set;}
        global String tipoSiniestro { get; set;}
        global String fechaSiniestro { get; set;}
        global String nombreConductor { get; set;}
        global String causa { get; set;}
        global Vehiculo vehiculo { get; set;}
        global Poliza poliza { get; set;}
        global String comoOcurrio { get; set;}
        global String ubicacion { get; set;}
        global String municipio { get; set;}
        global String estado { get; set;}
        global String estatus { get; set;}
        global String solucion { get; set;}
        global String comentarioDeEstatus { get; set;}
        global String saldo {get;set;}
        global String saldoinsoluto {get;set;}
        global String motivodeRechazo {get;set;}
        global String remanente {get;set;}
        global String salesforceid { get; set;}
        global String tipoDePago{get;set;}
        global Date fechaDePago{get;set;}
    }
}