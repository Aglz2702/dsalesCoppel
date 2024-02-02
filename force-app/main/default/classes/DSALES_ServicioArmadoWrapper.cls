@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_ServicioArmadoWrapper {
    
    global class ArmadoRequest{
        global List<Ars> ars {get;set;}
        global List<Estatus> estatus {get;set;}
    }
    
    global class Ars {
        global Integer ar {get;set;}
        global String skuTangible {get;set;}
    }
    
    global class Estatus {
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