@SuppressWarnings('PMD.AvoidGlobalModifier')
global  with sharing class DSALES_VentaSC {
    global class VentaSCRequest {
        global string idCotizacion { get; set; }
        global List<String> idPartidaPresupuesto { get; set; }
        global Oportunidad oportunidad { get; set; } 
        global String envioContratante {get;set;}
        global List<DSALES_VentaSM.DatosParticipante> datosParticipantes { get; set; } 
        global DSALES_PaymentInfoWrapper.PaymentRequest pagos {get;set;}
        global DSALES_IPAssetWrapper.IPAssetRequest activo {get;set;}
        
        }

        global class Oportunidad {
        global Integer socio { get; set; }
        global Integer producto { get; set; }
        global Integer plan { get; set; }
        global string identificadorCoppel { get; set; }
        //global string cotizacion { get; set; }
    
    }
    global class Cliente {
        global string numeroCliente { get; set; }
        global string nombre { get; set; }
        global string apellidoPaterno { get; set; }
        global string apellidoMaterno { get; set; }
        global string fechaNacimiento { get; set; }
        global string rfc { get; set; }
        global string curp { get; set; }
        global Integer regimenFiscal { get; set; }
        global string sexo { get; set; }
        global Integer numeroCelular { get; set; }
        global string correoElectronico { get; set; }
        global string nacionalidad { get; set; }
        global string estado { get; set; }
        global string municipio { get; set; }
        global string colonia { get; set; }
        global DateTime calle { get; set; }
        global string numeroExterior { get; set; }
        global string numeroInterior { get; set; }
        global Integer codigoPostal { get; set; }
    
    }
    global class VentaSCResponse{
		global Boolean exito {get;set;}
		global String mensajeError {get;set;}
		global Integer codigoError {get;set;}
		global String idUniversal{get;set;}
		global String idClienteSalesforce {get;set;}
		global List<DSALES_VentaSM.ListaPartidasOportunidad> listaPartidasOportunidad { get; set; }
		global DSALES_VentaSM.DatosParaEmitir datosParaEmitir { get; set; } 
	}
}