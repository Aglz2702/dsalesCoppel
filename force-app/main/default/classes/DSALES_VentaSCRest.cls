//@RestResource(urlMapping='/ventaSC/*')
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class DSALES_VentaSCRest {
    global static DSALES_VentaSM.VentaSMResponse crearVenta(DSALES_VentaSM.VentaSMRequest venta) {
        Boolean exito=false;
        String mensajeError='';
        Integer codigoError;
        String idUniversal='';
        Boolean idUniversalExiste=false;
        String idCliente='';
        String polizaId='';
        String idActivo='';
        Opportunity oportunidad= new Opportunity();
        DSALES_VentaSM.VentaSMResponse ventaSC= new DSALES_VentaSM.VentaSMResponse();
        Quote cotizacionPrincipal= new Quote();
        Quote cotizacionASincronizar= new Quote();
        List<String> partidasSeleccionadas = new List<String>();
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c();
        List<DSALES_VentaSM.ListaPartidasOportunidad> listaPartidas = new List<DSALES_VentaSM.ListaPartidasOportunidad>();
        DSALES_VentaSMRest.DatosPrepoliza datosPrepoliza = new DSALES_VentaSMRest.DatosPrepoliza();
        DSALES_VentaSM.DatosParaEmitir recived = new DSALES_VentaSM.DatosParaEmitir();
        DSALES_VentaSM.DatosParaEmitir datosEmitir = new DSALES_VentaSM.DatosParaEmitir();
        String pagoId='';
        DSALES_QuoteDuplicateSC.Datos datos= new DSALES_QuoteDuplicateSC.Datos();
        if(venta!=null){
            idUniversal=venta.pagos.idUniversal;
            idCliente=crearCliente(venta.datosParticipantes);
            cotizacionPrincipal=consultaCotizacion(venta.idCotizacion);
            relacionarClienteAOportunidad(cotizacionPrincipal,idCliente);
            oportunidad=consultarOportunidad(cotizacionPrincipal.OpportunityId);
            venta.pagos.idOportunidad =oportunidad.Id;
            partidasSeleccionadas= venta.idPartidaPresupuesto;
            String contratante = String.valueOf(venta.envioContratante);
            pagoId= DSALES_PaymentInfoWrapperRequest.insertarPago(venta.pagos,contratante);
            pago=consultaPago(idUniversal,oportunidad.Id);
            datos.idCotizacionAnt=cotizacionPrincipal.Id;
            datos.idOportunidad=venta.pagos.idOportunidad;
            datos.pago=pago;
            datos.plazo=venta.pagos.plazos;
            cotizacionASincronizar=DSALES_QuoteDuplicateSC.cotizacionesNuevas(partidasSeleccionadas,datos);
            datosPrepoliza.idPago=pago.Id;
            datosPrepoliza.beneficiarioPreferente=false;
            datosPrepoliza.enviaContratante=Boolean.valueOf(venta.envioContratante);
            datosPrepoliza.plazo=venta.pagos.plazos;
            sincronizarOportunidad(cotizacionASincronizar.Id, oportunidad);
            polizaId=DSALES_VentaSMRestAux.crearPrePoliza(pago,venta.datosParticipantes,datosPrepoliza);
            idActivo= DSALES_VentaSMRestAux.crearActivo(pago,venta.activo,polizaId);
            //listaPartidas=DSALES_VentaSMRestAux.obtenerPartidas(oportunidad.Id);   
            if(String.isNotEmpty(idActivo)){
                recived=DSALES_VentaSMRest.datosParaEmitir(venta, polizaId);
                System.debug('Datos para emitir recived_____:'+recived);
                //datosSeguro=recived.datosSeguro;
                //vehiculo=recived.datosVehiculo;
                datosEmitir=recived;
            }  
        }
        System.debug('Datos para emitir datosPara Emitir:'+datosEmitir);
        ventaSC.idClienteSalesforce=idCliente;
        ventaSC.datosParaEmitir=datosEmitir;
        return ventaSC;
    }
    /*public static Boolean validarIdUniversal(String idUniversal){
        Boolean existe=false;
        List<DSALES_InformacionDePago__c> verificaIdUniversal =[SELECT Id,DSALES_IDUniversal1__c FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c =: idUniversal WITH SECURITY_ENFORCED LIMIT 1];
        if(verificaIdUniversal!=null && verificaIdUniversal.size()>0){
            existe=true;
        }
        return existe;
    }*/
    public static Boolean relacionarClienteAOportunidad(Quote cotizacion, String accountId){
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = accountId;
        oportunidad.Id = cotizacion.OpportunityId;
        if(Opportunity.SObjectType.getDescribe().isUpdateable()) {
            update oportunidad;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        }
        System.debug('oportunidad actualizada: '+oportunidad);
        return true; 
    }
    public static Quote consultaCotizacion(String idCotizacion){
      
        Quote cotizacionPrincial = new Quote();
        if(!String.isEmpty(idCotizacion)){ 
            cotizacionPrincial= [SELECT Id,AccountId,Name,dsalesGenero__c,DSALES_Fechadenacimiento__c,dsalesListaNegra__c,
                                                    Phone,Email,DSALES_RFC__c,dsalesMotivoDeListaNegra__c,DSales_Vendedor__c,DSales_Tienda__c,DSALES_Fechadecreacionpresupuesto__c,
                                                    dsalesFechaDeComienzoDePoliza__c,dsalesOpcionDePago__c,OpportunityId,Status,ExpirationDate,
                                                    DSALES_Enviarcotizacion__c,dsalesIdentificadorCoppel__c,dsalesIdentificadorVendedor__c,dsalesNumeroSucursal__c,QuoteNumber,IsSyncing,dsalesPrecioCelular__c,dsalesMarcaCelular__c,dsalesModeloCelular__c,dsalesColorCelular__c,dsalesCodigoPostal__c,
                                                    Subtotal,TotalPrice,Discount,RecordTypeId FROM Quote WHERE Id=:idCotizacion  WITH SECURITY_ENFORCED ];
        }
        return cotizacionPrincial;
    }
    public static Opportunity consultarOportunidad(String idOportunidad){
        Opportunity oportunidad=[SELECT Id,StageName,SyncedQuoteId FROM Opportunity WHERE Id=:idOportunidad WITH SECURITY_ENFORCED ];
        
        return oportunidad;
    }
    public static DSALES_InformacionDePago__c consultaPago(String idUniversal,String idOportunidad){

        DSALES_InformacionDePago__c pago= new  DSALES_InformacionDePago__c();
        if(idUniversal!=null){
            pago=[SELECT Id,DSALES_Factura__c,DSALES_IDUniversal1__c,DSALES_Oportunidad__c,DSALES_Plazodecomprademoto__c,DSALES_Poliza__c,DSALES_Poliza__r.Name,DSALES_Seguro__c,DSALES_SKU__c  
                                                    FROM DSALES_InformacionDePago__c 
                                                    WHERE DSALES_IDUniversal1__c =:idUniversal OR DSALES_Oportunidad__c=:idOportunidad WITH SECURITY_ENFORCED LIMIT 1];
        }  
        if(pago!=null){
            return pago;
        }   
        else{
            return null;
        }
    }
    public static void sincronizarOportunidad(String idCotizacion, Opportunity oportunidad){
        oportunidad.StageName='Cerrada ganada';
        oportunidad.SyncedQuoteId=idCotizacion;
        if(Opportunity.SObjectType.getDescribe().isUpdateable()) {
            update oportunidad;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        } 
    }

    public static String crearCliente(List<DSALES_VentaSM.DatosParticipante> participantes){
        DSALES_VentaSM.DatosParticipante participante = new DSALES_VentaSM.DatosParticipante();
        DSALES_AccountWrapper.AccountRequest cliente= new DSALES_AccountWrapper.AccountRequest();
        for(DSALES_VentaSM.DatosParticipante item: participantes){
            if(item.figura==DSALES_Utility.FIGURA_CONTRATANTE){
                cliente.numeroCliente=item.numeroCliente;
                cliente.nombre = item.nombre;
                cliente.apellidoPaterno = item.apellidoPaterno;
                cliente.apellidoMaterno = item.apellidoMaterno;
                cliente.telefono = item.telefono;
                cliente.correoElectronico= item.correoElectronico;
                cliente.genero = item.genero;
                cliente.fechaNacimiento = item.fechaNacimiento;
                cliente.calle = item.calle;
                cliente.nombreCiudad =  item.codigoCiudad;
                cliente.codigoPostal = String.valueOf(item.codigoPostal);
                cliente.numeroInterior=item.numeroInterior;
                cliente.numeroExterior=item.numeroExterior;
                cliente.codigoEstado=item.codigoEstado; //clave de estado en SM
                cliente.codigoColonia=item.codigoColonia; //clave colonia SM
                cliente.rfc=item.rfc;
                cliente.codigoMunicipio=item.codigoMunicipio;
            }
        } 
        DSALES_AccountWrapper.AccountResponse response= DSALES_AccountWrapperRequest.upsertAccount(cliente);
        return response.idCuenta;
    }
    public static List<Quote> consultarCotizacionAEliminar(String idOportunidad, String idCotPrincipal){
        List<Quote> cotizaciones = new List<Quote>();
        if(!String.isEmpty(idOportunidad) && !String.isEmpty(idCotPrincipal) ){ 
            cotizaciones= [SELECT Id,AccountId,Name,dsalesGenero__c,DSALES_Fechadenacimiento__c,dsalesListaNegra__c,
                                                    Phone,Email,DSALES_RFC__c,dsalesMotivoDeListaNegra__c,DSales_Vendedor__c,DSales_Tienda__c,DSALES_Fechadecreacionpresupuesto__c,
                                                    dsalesFechaDeComienzoDePoliza__c,dsalesOpcionDePago__c,OpportunityId,Status,ExpirationDate,
                                                    DSALES_Enviarcotizacion__c,dsalesIdentificadorCoppel__c,dsalesIdentificadorVendedor__c,dsalesNumeroSucursal__c,QuoteNumber,IsSyncing,dsalesPrecioCelular__c,dsalesMarcaCelular__c,dsalesModeloCelular__c,dsalesColorCelular__c,dsalesCodigoPostal__c,
                                                    Subtotal,TotalPrice,Discount,RecordTypeId FROM Quote WHERE Id !=:idCotPrincipal AND  OpportunityId=:idOportunidad WITH SECURITY_ENFORCED ];
        }
        return cotizaciones;

    }
    public static List<OpportunityLineItem> obtenerPartidasSincronizadas(Opportunity oportunidad){
        
        List<DSALES_VentaSMRest.WrapperDatosProductos> partidas= DSALES_VentaSMRest.obtenerProductosEnPartidasOportunidad( oportunidad.Id);
        List<String> idsPartidas = new List<String>();
        if(partidas!=null && partidas.size()>0){
            for(DSALES_VentaSMRest.WrapperDatosProductos part:partidas){
                idsPartidas.add(part.idPartidaDeOportunidad);
            }
        }
        List<OpportunityLineItem> oliLista = [SELECT Id, Product2Id FROM OpportunityLineItem WHERE Id IN :idsPartidas WITH SECURITY_ENFORCED];
        oportunidad.StageName='Nuevo';
        if(Opportunity.SObjectType.getDescribe().isUpdateable()) {
            update oportunidad;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        } 
        return  oliLista;
    }
    public static Insurancepolicy consultarPoliza(String idOportunidad, String idCot){

        Insurancepolicy poliza =[SELECT Id, Name,SourceQuoteId FROM Insurancepolicy WHERE SourceOpportunityId=:idOportunidad AND SourceQuoteId=:idCot  WITH SECURITY_ENFORCED LIMIT 1];
        if(poliza.Name!=DSALES_Utility.SEGURO_PREDETERMINADO){
               return poliza;
        }
        else{
            return null;
        }
    }
    public static List<InsurancePolicyAsset> consultarActivo(String idPoliza){
        List<InsurancePolicyAsset> activo =[SELECT Id, Name FROM InsurancePolicyAsset WHERE InsurancePolicyId=:idPoliza  WITH SECURITY_ENFORCED];
        if(activo!=null){
            return activo;
        }
        else{
            return null;
        }
    }
    public static Boolean eliminarRegistros(Opportunity oportunidad,IdsBorrar datos){
        Boolean borrar=false;
        List<OpportunityLineItem> oliLista = obtenerPartidasSincronizadas(oportunidad);
        DSALES_InformacionDePago__c pagoAEliminar= consultaPago('',oportunidad.Id);
        if(pagoAEliminar.DSALES_Poliza__c!=null && pagoAEliminar.DSALES_Poliza__r.Name!=DSALES_Utility.SEGURO_PREDETERMINADO){
            Insurancepolicy poliza =consultarPoliza(oportunidad.Id,datos.idCotSincro);
            if(poliza.dsalesActivoPolizaSeguro__c!=null){
                List<InsurancePolicyAsset> activo = consultarActivo(poliza.Id);
                if(activo!=null){
                    delete activo;
                }
            }
            if(poliza!=null){
                delete poliza;
            }
        }
        List<Quote> cotizaciones=consultarCotizacionAEliminar( oportunidad.Id,datos.idCotPrincipal);
        if(oliLista!=null){
          delete oliLista;
          borrar=true;
        }
        if(pagoAEliminar!=null){
            delete pagoAEliminar;
        }
        if(cotizaciones!=null){
          delete cotizaciones;
          borrar=true;
        }
        return borrar;
    }

    public class IdsBorrar{
        public String idCotPrincipal{get;set;}
        public String idCotSincro{get;set;}
    }
}