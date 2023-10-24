@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_ServicioArmadoWrapper {
    
    global class ArmadoRequest{
        global List<ars> ars {get;set;}
        global List<estatus> estatus {get;set;}
    }
    
    global class ars {
        global Integer ar {get;set;}
        global String skuTangible {get;set;}
    }
    
    global class estatus {
        global String numeroCertificado {get;set;}
        global String estatus {get;set;}
        global String fechaArmado {get;set;}
    } 
    
    global class ArmadoResponse{        
        global Boolean 	exito {get;set;}
        global String 	codigoError {get;set;}
        global String 	mensaje {get;set;}
    }
    
}