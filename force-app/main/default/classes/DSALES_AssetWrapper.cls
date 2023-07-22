@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_AssetWrapper {
    
    global class AssetRequest{
        global String idPago{get;set;} 
        global String idPartidaPresupuesto{get;set;}
        global Decimal idSecuencia{get;set;}
        global String idProducto{get;set;}
        global String primerNombre {get; set;}
        global String apellido {get;set;}
        global String email {get;set;}
        global String articulo{get;set;}
        global String numeroCliente{get;set;}
        global String idCuenta {get;set;}
        global String idContacto{get;set;}
        global String tipoProducto {get;set;}
        global String tipoSeguro {get;set;}
        global String tipoServicio {get;set;}
        global String categoria {get;set;}
        global String subcategoria {get;set;}
        global String clase {get;set;}
        global String familia {get;set;}
        //picklist values for Status: Adquirido,Cancelado,Devuelto 
        global String estado {get;set;}
        global String meses{get;set;}
        global String skuDeTangible {get;set;}
        global String duracionGarantia {get;set;}
        global String numeroSerie {get;set;}
        global Date fechaCompra {get;set;}
        global Integer cantidad{get;set;}
        global String marca{get;set;}
        global String modelo{get;set;}
            global String descripcion{get;set;}    
        
   
    }
    global class AssetResponse{
        global Boolean exito {get;set;}
        global String mensajeError {get;set;}
        global String codigoError{get;set;}
        global String idAsset {get;set;}
    }

}