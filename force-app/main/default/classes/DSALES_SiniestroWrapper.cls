@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_SiniestroWrapper {
    global class SiniestroCallPost { 
        global String uid { get; set;}
        global String reporte { get; set;}
        global String numeroSiniestro { get; set;}
        global String tipoSiniestro { get; set;}
        global String fechaSiniestro { get; set;}
        global String nombreConductor { get; set;}
        global String causa { get; set;}

        global vehiculo vehiculo { get; set;}
        global poliza poliza { get; set;}

        global String comoOcurrio { get; set;}
        global String ubicacion { get; set;}
        global String municipio { get; set;}
        global String estado { get; set;}
        global String estatus { get; set;}
        global String salesforceid { get; set;}
    }
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

    global class Siniestro{
        global String uid { get; set;}
        global String numeroSiniestro { get; set;}
    }

    global class SiniestroPut{
        global String uid { get; set;}
        global String reporte { get; set;}
        global String numeroSiniestro { get; set;}
        global String tipoSiniestro { get; set;}
        global String fechaSiniestro { get; set;}
        global String nombreConductor { get; set;}
        global String causa { get; set;}

        global vehiculo vehiculo { get; set;}
        global poliza poliza { get; set;}

        global String comoOcurrio { get; set;}
        global String ubicacion { get; set;}
        global String municipio { get; set;}
        global String estado { get; set;}
        global String estatus { get; set;}
        global String salesforceid { get; set;}       
    }

    global class ComprobantesTenencia{
        global String descripcion { get; set;} 
        global String comprobante { get; set;} 
        global String idComprobante { get; set;} 
        
    }

    global class SiniestroGet{
        global String uid { get; set;}
        global String reporte { get; set;}
        global String numeroSiniestro { get; set;}
        global String tipoSiniestro { get; set;}
        global String fechaSiniestro { get; set;}
        global String nombreConductor { get; set;}
        global String causa { get; set;}

        global vehiculo vehiculo { get; set;}
        global poliza poliza { get; set;}
		global List<listaSiniestros> listSiniestro{get;set;}
        global String comoOcurrio { get; set;}
        global String ubicacion { get; set;}
        global String municipio { get; set;}
        global String estado { get; set;}
        global String estatus { get; set;}

        global String solucionDevolucion { get; set;}
        global String motivoDevolucion { get; set;}
        global String saldoinsoluto {get;set;}
        global String motivoRechazo {get;set;}
        global String salesforceid { get; set;}       
    }
        global class ListaSiniestros{
        //Informacion de Resumen de pago de poliza
        global String claimpaymentName{get;set;}
        global Double paymentAmount{get;set;}
        global String paymentType{get;set;}
        global Date paymentDate{get;set;}
    }

}