public with sharing class DSALES_VentaSMRestAux {
    public static  List<DSALES_VentaSM.ListaPartidasOportunidad> obtenerPartidas(String idOportunidad){
        List<DSALES_VentaSMRest.WrapperDatosProductos> productosSincronisados= DSALES_VentaSMRest.obtenerProductosEnPartidasOportunidad(idOportunidad);
        List<DSALES_VentaSM.ListaPartidasOportunidad> listaPartidas= new List<DSALES_VentaSM.ListaPartidasOportunidad>();
        for(DSALES_VentaSMRest.WrapperDatosProductos listSin:productosSincronisados){
            DSALES_VentaSM.ListaPartidasOportunidad partida = new DSALES_VentaSM.ListaPartidasOportunidad();
            partida.idPartidaOportunidad=listSin.idPartidaDeOportunidad;
            partida.nombreProducto=listSin.nombreProducto;
            partida.sku=listSin.sku; 
            listaPartidas.add(partida);
        }
        return listaPartidas;
    }
    public static void cotizacionesNuevas(DSALES_InformacionDePago__c pago,List<String> partidasSeleccionadas,Integer precioRedondeado){
        DSALES_VentaSM.ListaPartidasOportunidad listaIds= new DSALES_VentaSM.ListaPartidasOportunidad();
        DSALES_VentaSM.ListaPartidasOportunidad listaPartidaOportunidad= new DSALES_VentaSM.ListaPartidasOportunidad();
        List<DSALES_VentaSM.ListaPartidasOportunidad> listaPartidas= new List<DSALES_VentaSM.ListaPartidasOportunidad>();
        if(pago!=null){
            DSALES_QuotePagoSM.cotizacionesNuevas(pago.Id,partidasSeleccionadas,pago.DSALES_SKU__c,precioRedondeado);
        }
    }

    public static String crearActivo(DSALES_InformacionDePago__c pago, DSALES_IPAssetWrapper.IPAssetRequest datosActivo, String polizaId){
        String idActivo ='';
        InsurancePolicyAsset activo = new InsurancePolicyAsset();
        if(datosActivo!=null && (datosActivo.numeroSerie!=null || datosActivo.imei!=null || !String.isEmpty(datosActivo.numeroSerie) || !String.isEmpty(datosActivo.imei))){
            datosActivo.idUniversal=pago.DSALES_IDUniversal1__c;
           activo= DSALES_IPAssetWrapperRequest.creacionActivos(datosActivo);
            idActivo=activo.Id;
            DSALES_CreateInsurancePolicy.agregarDatosDeActivo(activo,polizaId);        
        }
        return idActivo;
    }
    public static String crearPrePoliza(DSALES_InformacionDePago__c pago,List<DSALES_VentaSM.DatosParticipante> listaDatos,DSALES_VentaSMRest.DatosPrepoliza  datosPrepoliza){
        InsurancePolicy poliza = new InsurancePolicy();
        if(pago.DSALES_Seguro__c==true && pago.DSALES_Poliza__c==null){
            datosPrepoliza.idPago=pago.Id;
            poliza=DSALES_CreateInsurancePolicy.crearPoliza(listaDatos,datosPrepoliza);
            pago.DSALES_Poliza__c=poliza.Id;       
        }
        else if(pago.DSALES_Seguro__c==false){
            Insurancepolicy universal =[SELECT Id, Name FROM Insurancepolicy WHERE Name=:DSALES_Utility.SEGURO_PREDETERMINADO  WITH SECURITY_ENFORCED LIMIT 1];
            pago.DSALES_Poliza__c=universal.Id;
        }
        if(DSALES_InformacionDePago__c.SObjectType.getDescribe().isUpdateable()) {
            update pago;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        }
        return pago.DSALES_Poliza__c;
    }
}