@RestResource(urlMapping='/ventaSM/*')
global without sharing class DSALES_VentaSMRest {
    public static final String NOMBRE_CONTRATANTE =DSALES_Utility.getNombreContratante('dsalesNombre');
    public static final String CONDUCTOR='Conductor';
    @HttpPost
    global static DSALES_VentaSM.VentaSMResponse crearVenta() {
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c();
        DSALES_VentaSM.VentaSMResponse ventaSM= new DSALES_VentaSM.VentaSMResponse();
        DSALES_VentaSM.IdsARetornar idsLista = new DSALES_VentaSM.IdsARetornar();
        DSALES_VentaSM.DatosParaEmitir datosEmitir = new DSALES_VentaSM.DatosParaEmitir();
         List<DSALES_VentaSM.DatosParticipante> datos = new List<DSALES_VentaSM.DatosParticipante>();
        List<DSALES_VentaSM.ListaPartidasOportunidad> listaPartidas = new List<DSALES_VentaSM.ListaPartidasOportunidad>();
        Boolean exito=false;
        String mensajeError='';
        Integer codigoError;
        String idUniversal='';
        Quote cotizacion= new Quote ();
        Opportunity oppor= new  Opportunity ();
        DatosRetornoVenta datosx = new  DatosRetornoVenta();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    DSALES_VentaSM.VentaSMRequest venta = (DSALES_VentaSM.VentaSMRequest)JSON.deserialize(body, DSALES_VentaSM.VentaSMRequest.class);
                    System.debug('venta request: '+body);
                    String idUnico=venta.pagos.idUniversal;
                    List<DSALES_InformacionDePago__c> verificaIdUniversal =[SELECT Id,DSALES_IDUniversal1__c FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c =: idUnico WITH SECURITY_ENFORCED LIMIT 1];
                    if(verificaIdUniversal!=null && verificaIdUniversal.size()>0){
                        mensajeError='El id universal: '+idUnico+ ' ya existe' ;
                        System.debug('El id universal: ' +idUnico+ ' ya existe');
                        exito=false;
                        codigoError=401;
                    }
                    else{
                        idUniversal=venta.pagos.idUniversal;
                        cotizacion=[SELECT  Id,OpportunityId FROM Quote WHERE Id=:venta.idCotizacion WITH SECURITY_ENFORCED];
                        oppor=[SELECT Id,StageName,SyncedQuoteId,RecordTypeId,RecordType.DeveloperName FROM Opportunity WHERE Id=:cotizacion.OpportunityId WITH SECURITY_ENFORCED ];
                        datosx= seleccionaVenta(venta,oppor);
                        listaPartidas=DSALES_VentaSMRestAux.obtenerPartidas(oppor.Id);
                        exito=true;
                    }
                }catch(Exception.JSONException e){
                    exito = false;
                    mensajeError= DSALES_Utility.BAD_REQUEST_MSJ+' '+e.getLineNumber()+ ': '+e.getMessage()+' '+e.getCause();
                    codigoError=DSALES_Utility.BAD_REQUEST_CODE; 
                }
                catch(Exception e){
                    
                    System.debug('**ERROR VENTA**'+e.getLineNumber()+ ': '+e.getMessage());
                    exito = false;
                    listaPartidas=null;
                    mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ+' '+e.getLineNumber()+ ': '+e.getMessage();
                    codigoError=DSALES_Utility.INTERNAL_ERROR_CODE;
                    idUniversal='';
                    Quote cotSincro = [SELECT Id FROM Quote WHERE OpportunityId=:oppor.Id AND IsSyncing=true WITH SECURITY_ENFORCED ];
                    DSALES_EliminarRegistrosDeVenta.IdsBorrar datosE = new DSALES_EliminarRegistrosDeVenta.IdsBorrar();
                    datosE.idCotPrincipal=cotizacion.Id;
                    datosE.idCotSincro=cotSincro.Id;
                    DSALES_EliminarRegistrosDeVenta.eliminarRegistros(oppor,datosE);
                }
            }
        }
        System.debug('datos recived: '+datosEmitir);
       // ventaSM.datosParaEmitir=datosEmitir;
        ventaSM.datosParaEmitir=datosx.datosEmitir;
        ventaSM.exito=exito;
        ventaSM.codigoError=codigoError;
        ventaSM.mensajeError=mensajeError;
        ventaSM.idUniversal =idUniversal;
       // ventaSM.idClienteSalesforce=idCliente;
        ventaSM.idClienteSalesforce=datosx.idCliente;
        ventaSM.listaPartidasOportunidad=listaPartidas;
        return ventaSM;
    }
    private static Boolean sincronizarOportunidad(String quoteId, String accountId){
        Quote cotizacion = [SELECT Id,AccountId,OpportunityId,Opportunity.AccountId FROM Quote WHERE Id= :quoteId WITH SECURITY_ENFORCED]; 
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = accountId;
        oportunidad.Id = cotizacion.OpportunityId;
        if(Opportunity.SObjectType.getDescribe().isUpdateable()) {
            update oportunidad;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        }
        return true; 
    }

    public static List<WrapperDatosProductos> obtenerProductosEnPartidasOportunidad(Id opportunityId) {
        List<WrapperDatosProductos> listaWrapperProducto = new List<WrapperDatosProductos>();
        List<OpportunityLineItem> oliLista = [SELECT Id, Product2Id FROM OpportunityLineItem WHERE OpportunityId = :opportunityId WITH SECURITY_ENFORCED];
        List<Id> listaIdsProducto = new List<Id>();
        for(OpportunityLineItem oli : oliLista) {
            listaIdsProducto.add(oli.Product2Id);
        }
        Map<Id, String> mapaNombresProductos = new Map<Id, String>();
        Map<Id, String> mapaSkuProductos = new Map<Id, String>();
        if(listaIdsProducto.size() > 0) {
            List<Product2> listaProductos = [SELECT Id, Name,StockKeepingUnit FROM Product2 WHERE Id IN :listaIdsProducto WITH SECURITY_ENFORCED];
            for(Product2 producto : listaProductos) {
                mapaNombresProductos.put(producto.Id, producto.Name);
                mapaSkuProductos.put(producto.Id,producto.StockKeepingUnit);
            }
        }
        for(OpportunityLineItem oli : oliLista) {
            WrapperDatosProductos productoWrapper = new WrapperDatosProductos();
            productoWrapper.idPartidaDeOportunidad = oli.Id;
            productoWrapper.nombreProducto = mapaNombresProductos.get(oli.Product2Id);
            productoWrapper.sku=mapaSkuProductos.get(oli.Product2Id);
            listaWrapperProducto.add(productoWrapper);
        }
        
        return listaWrapperProducto;
    }

    public static String crearCliente(List<DSALES_VentaSM.DatosParticipante> participantes, String recortypeName){
        DSALES_VentaSM.DatosParticipante participante = new DSALES_VentaSM.DatosParticipante();
        DSALES_AccountWrapper.AccountRequest cliente= new DSALES_AccountWrapper.AccountRequest();
        for(DSALES_VentaSM.DatosParticipante item: participantes){
            if((item.figura==CONDUCTOR && recortypeName=='Seguro_de_Moto') || (item.figura==DSALES_Utility.FIGURA_CONTRATANTE && recortypeName=='dsalesSeguroCelulares')){
                participante.numeroCliente=item.numeroCliente;
                participante.nombre = item.nombre;
                participante.apellidoPaterno = item.apellidoPaterno;
                participante.apellidoMaterno = item.apellidoMaterno;
                participante.telefono = item.telefono;
                participante.correoElectronico = item.correoElectronico;
                participante.genero = item.genero;
                participante.fechaNacimiento = item.fechaNacimiento;
                participante.calle = item.calle;
                participante.codigoCiudad =  item.codigoCiudad;
                participante.codigoPostal = item.codigoPostal;
                participante.numeroInterior=item.numeroInterior;
                participante.numeroExterior=item.numeroExterior;
                participante.codigoEstado=item.codigoEstado; //clave de estado en SM
                participante.codigoColonia=item.codigoColonia; //clave colonia SM
                participante.rfc=item.rfc;
                participante.codigoMunicipio=item.codigoMunicipio;
            }
        } 
        cliente.numeroCliente=participante.numeroCliente;
        cliente.nombre = participante.nombre;
        cliente.apellidoPaterno=participante.apellidoPaterno;
        cliente.apellidoMaterno=participante.apellidoMaterno;
        cliente.telefono=participante.telefono;
        cliente.correoElectronico =participante.correoElectronico;
        cliente.genero=participante.genero;
        system.debug('genero ');
        cliente.fechaNacimiento=participante.fechaNacimiento;
        cliente.calle=participante.calle;
        cliente.nombreCiudad=participante.codigoCiudad;
        cliente.codigoPostal=String.valueOf(participante.codigoPostal);
        cliente.numeroInterior=participante.numeroInterior;
        cliente.numeroExterior =participante.numeroExterior;
        cliente.codigoEstado=participante.codigoEstado; //clave de estado en SM
        cliente.codigoColonia=participante.codigoColonia; //clave colonia SM
        cliente.codigoMunicipio=participante.codigoMunicipio; //clave municipio SM
        cliente.rfc=participante.rfc;
        System.debug('participante cliente: '+cliente);
        DSALES_AccountWrapper.AccountResponse response= DSALES_AccountWrapperRequest.upsertAccount(cliente);
        return response.idCuenta;
    }
    public static DSALES_VentaSM.DatosParaEmitir datosParaEmitir(DSALES_VentaSM.VentaSMRequest venta,String idPoliza){ 
        DSALES_VentaSM.DatosParaEmitir response = new DSALES_VentaSM.DatosParaEmitir();
        DSALES_VentaSM.DatosSeguro datosSeguro= new DSALES_VentaSM.DatosSeguro();
        //DSALES_VentaSM.DatosVehiculo vehiculo = new DSALES_VentaSM.DatosVehiculo();
        //DSALES_VentaSM.DatosCelular celular = new DSALES_VentaSM.DatosCelular();
        List<DSALES_VentaSM.DatosParticipante> datos = new List<DSALES_VentaSM.DatosParticipante>();
        DSALES_VentaSM.DatosParticipante contratante = new DSALES_VentaSM.DatosParticipante();
        DSALES_VentaSM.DatosParaEmitir pruenas = new DSALES_VentaSM.DatosParaEmitir();
        DSALES_VentaSM.DatosConductor datosConductor = new DSALES_VentaSM.DatosConductor();
        DSALES_VentaSM.DatosContratante datosContratante = new DSALES_VentaSM.DatosContratante();
        ValoresParaAsignar valores = new ValoresParaAsignar();
        if(venta.activo.emitirPoliza==true){
            Insurancepolicy poliza =[SELECT Id,dsalesIMEI__c,DSALES_Modelo__c,RecordType.DeveloperName, dsalesEstatusPoliza__c,DSALES_Uso__c,PlanType,DSALES_Tipovehiculo__c,DSALES_Servicio__c,DSALES_Placas__c,DSALES_Numeroserie__c,SourceQuoteId,DSALES_Aseguradora__c,DSALES_Cobertura__c,dsalesFechaDeEmision__c,EffectiveDate,DSALES_Negocio__c,DSALES_Opcionpago__c,dsalesTipoServicio__c,dsalesTipoUso__c FROM Insurancepolicy WHERE Id=:idPoliza WITH SECURITY_ENFORCED];
            Quote cotizacion =[SELECT Id,dsalesIdDeVehiculo__c,dsalesNumeroSucursal__c,	dsalesCodigoDePromocion__c,DSALES_IDdelasociado__c,DSALES_RFC__c,dsalesFechaDeComienzoDePoliza__c,dsalesValorFactura__c FROM Quote WHERE Id=:poliza.SourceQuoteId WITH SECURITY_ENFORCED];
            QuoteLineItem seguro =[SELECT Id,dsalesQuoteId__c,UnitPrice,	DSALES_TrackingID__c,dsalesOpcionPago__c FROM QuoteLineItem WHERE QuoteId=:cotizacion.Id AND DSALES_Tipodeproducto__c=:'Seguro' WITH SECURITY_ENFORCED LIMIT 1];
            poliza.dsalesEstatusPoliza__c='En tramite';
            if(Insurancepolicy.SObjectType.getDescribe().isUpdateable()) {
                update poliza;  
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            }
            
            FiguraAEnviar figuras=asignarParticipante(venta.datosParticipantes,poliza,venta.envioContratante);
            datosConductor=figuras.datosConductor;
            datosContratante=figuras.datosContratante;
            System.debug('datosContratante_______________________'+datosContratante);
            System.debug('datosConductor_________________________'+datosConductor);
            datosContratante=validarContratante(venta.envioContratante,datosContratante);
            datosSeguro.quote_id=seguro.dsalesQuoteId__c;
            datosSeguro.fechaEmision=poliza.dsalesFechaDeEmision__c;
            datosSeguro.aseguradora=poliza.DSALES_Aseguradora__c;
            datosSeguro.negocio=poliza.DSALES_Negocio__c;
            datosSeguro.opcionPago=seguro.dsalesOpcionPago__c;
            datosSeguro.paquete=poliza.DSALES_Cobertura__c;
            valores.poliza=poliza;
            valores.cotizacion=cotizacion;
            valores.seguro=seguro;
            response=asignarDatos(valores,venta,datosConductor);
            response.datosContratante=datosContratante; 
            response.datosSeguro=datosSeguro;       
        }
        System.debug('response: '+response);
        return response;
    }
    public static FiguraAEnviar asignarParticipante(List<DSALES_VentaSM.DatosParticipante> datosParticipantes,Insurancepolicy poliza, Boolean envioContratante){
        DSALES_VentaSM.DatosConductor datosConductor = new DSALES_VentaSM.DatosConductor ();
        DSALES_VentaSM.DatosContratante datosContratante = new DSALES_VentaSM.DatosContratante();
        FiguraAEnviar figuras= new FiguraAEnviar();
        for(DSALES_VentaSM.DatosParticipante p:datosParticipantes){
            if(p.figura==DSALES_Utility.FIGURA_CONDUCTOR ){
                datosConductor.nombre=p.nombre;
                datosConductor.apellidoPaterno=p.apellidoPaterno;
                datosConductor.apellidoMaterno=p.apellidoMaterno;
                datosConductor.telefono=p.telefono;
                datosConductor.correoElectronico=p.correoElectronico;
                datosConductor.genero=p.genero;
                datosConductor.fechaNacimiento=p.fechaNacimiento;
                datosConductor.rfc=p.rfc;
                datosConductor.codigoPostal=p.codigoPostal;
                datosConductor.calle=p.calle;
                datosConductor.codigoEstado=p.codigoEstado;
                datosConductor.codigoCiudad=p.codigoCiudad;
                datosConductor.codigoColonia=p.codigoColonia;
                datosConductor.numeroInterior=p.numeroInterior;
                datosConductor.numeroExterior=p.numeroExterior;
                datosConductor.codigoMunicipio=p.codigoMunicipio;
                figuras.datosConductor=datosConductor;
            }
            if(envioContratante==true && p.figura==DSALES_Utility.FIGURA_CONTRATANTE ){
                if(poliza.RecordType.DeveloperName=='dsalesSeguroCelulares'){
                    datosContratante.nombre=p.nombre;
                    datosContratante.apellidoPaterno=p.apellidoPaterno;
                    datosContratante.apellidoMaterno=p.apellidoMaterno;
                    datosContratante.regimenFiscal=p.regimenFiscal;
                    datosContratante.nacionalidad=p.nacionalidad;
                    datosContratante.codigoMunicipio=p.codigoMunicipio;
                }
                datosContratante.telefono=p.telefono;
                datosContratante.correoElectronico=p.correoElectronico;
                datosContratante.genero=p.genero;
                datosContratante.fechaNacimiento=p.fechaNacimiento;
                datosContratante.rfc=p.rfc;
                datosContratante.codigoPostal=p.codigoPostal;
                datosContratante.calle=p.calle;
                datosContratante.codigoEstado=p.codigoEstado;
                datosContratante.codigoCiudad=p.codigoCiudad;
                datosContratante.codigoColonia=p.codigoColonia;
                datosContratante.numeroInterior=p.numeroInterior;
                datosContratante.numeroExterior=p.numeroExterior;
                figuras.datosContratante=datosContratante;
            }
        }
        return figuras;

    }
    public static DSALES_VentaSM.DatosParaEmitir asignarDatos(ValoresParaAsignar valores,DSALES_VentaSM.VentaSMRequest venta,DSALES_VentaSM.DatosConductor datosConductor ){
        DSALES_VentaSM.DatosSeguro datosSeguro = new DSALES_VentaSM.DatosSeguro();
        DSALES_VentaSM.DatosVehiculo vehiculo = new DSALES_VentaSM.DatosVehiculo();
        DSALES_VentaSM.DatosCelular celular = new  DSALES_VentaSM.DatosCelular ();
        DSALES_VentaSM.DatosParaEmitir response = new DSALES_VentaSM.DatosParaEmitir();
        if(valores.poliza.RecordType.DeveloperName=='dsalesSeguroMotos'){
            datosSeguro.valorfactura=String.valueOf(valores.cotizacion.dsalesValorFactura__c);
            datosSeguro.trackingId=valores.seguro.DSALES_TrackingID__c;
            datosSeguro.codigoPromocion=valores.cotizacion.dsalesCodigoDePromocion__c;
            datosSeguro.fechaInicio=valores.cotizacion.dsalesFechaDeComienzoDePoliza__c;
            datosSeguro.idAsociado=valores.cotizacion.DSALES_IDdelasociado__c;
            datosSeguro.planPago='';
            datosSeguro.tarjetaPago='';
            datosSeguro.sumaAsegurada=0;
            vehiculo.idVehiculo=valores.cotizacion.dsalesIdDeVehiculo__c;
            vehiculo.modelo=valores.poliza.DSALES_Modelo__c;
            vehiculo.numeroSerie=valores.poliza.DSALES_Numeroserie__c;
            vehiculo.placas=valores.poliza.DSALES_Placas__c;
            vehiculo.sevicio=valores.poliza.dsalesTipoServicio__c;
            vehiculo.tipo=valores.poliza.DSALES_Tipovehiculo__c;
            vehiculo.uso=valores.poliza.dsalesTipoUso__c;
            response.datosVehiculo=vehiculo;
            response.beneficiarioPreferente=String.valueOf(venta.beneficiarioPreferente);
            response.contratante=venta.contratante;
            response.datosConductor=datosConductor;
        }
        else if(valores.poliza.RecordType.DeveloperName=='dsalesSeguroCelulares'){
            datosSeguro.montoSeguro=valores.seguro.UnitPrice;
            response.sucursal=valores.cotizacion.dsalesNumeroSucursal__c;
            celular.imei=valores.poliza.dsalesIMEI__c;
            celular.marcacelular=venta.activo.marca;
            celular.modeloCelular=venta.activo.modelo;
            //celular.numeroCredito=venta.activo.
            celular.numeroSerie=venta.activo.numeroSerie;
            celular.plazoCredito=venta.pagos.plazos;
            response.datosCelular=celular;
        }
        return response;

    }
    public static DSALES_VentaSM.DatosContratante validarContratante(Boolean envioContratante, DSALES_VentaSM.DatosContratante participante){
        DSALES_VentaSM.DatosContratante contratante = new DSALES_VentaSM.DatosContratante();
        if(envioContratante==true){
           contratante=participante;
        }else{
            Account item =[SELECT Id,CP_WalletCustomerNumber__c,dsalesRfc__c,FirstName,LastName,Suffix,PersonMobilePhone,PersonEmail,CP_Gender__pc,PersonBirthdate,BillingStreet,BillingCity,BillingState,BillingPostalCode,dsalesNumeroInterior__c,
            dsalesNumeroExterior__c,CP_BillingStateCode__c,dsalesCodigoColonia__c,dsalesSegundoCorreo__c,dsalesNacionalidadSociedad__c,dsalesFechaConstitucion__c,dsalesGiroComercial__c,dsalesTipoPersona__c,dsalesNombreApoderadoLegal__c,dsalesActividad__c 
            FROM Account WHERE FirstName=:NOMBRE_CONTRATANTE WITH SECURITY_ENFORCED LIMIT 1];
            contratante.rfc=item.dsalesRfc__c;
            //contratante.nombre = item.FirstName;
            //contratante.apellidoPaterno = item.LastName;
            //contratante.apellidoMaterno = item.Suffix;
            contratante.telefono = item.PersonMobilePhone;
            contratante.correoElectronico = item.PersonEmail;
            contratante.genero = item.CP_Gender__pc;
            contratante.fechaNacimiento = item.PersonBirthdate;
            contratante.calle = item.BillingStreet;
            contratante.codigoCiudad =  item.BillingCity;
            contratante.codigoPostal = Integer.valueOf(item.BillingPostalCode);
            contratante.numeroInterior=String.valueOf(item.dsalesNumeroInterior__c);
            contratante.numeroExterior=String.valueOf(item.dsalesNumeroExterior__c);
            contratante.codigoEstado=item.BillingState;
            contratante.codigoColonia=String.valueOf(item.dsalesCodigoColonia__c); 
            contratante.segundoCorreoContratante=item.dsalesSegundoCorreo__c;
            contratante.nacionalidadSociedad=item.dsalesNacionalidadSociedad__c;
            contratante.fechaConstitucion=item.dsalesFechaConstitucion__c;
            contratante.giroComercial=item.dsalesGiroComercial__c;
            contratante.tipoPersona=item.dsalesTipoPersona__c;
            contratante.nombreApoderadoLegal=item.dsalesNombreApoderadoLegal__c;
            contratante.contratante=item.FirstName +''+ item.LastName + ''+ item.Suffix;
            contratante.actividad=item.dsalesActividad__c;

        }
        return contratante;
    }
    public class WrapperDatosProductos {
        public Id idPartidaDeOportunidad { get; set; }
        public String nombreProducto { get; set; }
        public String sku {get;set;}
    }
    public class DatosPrepoliza{
        public String idPago{get;set;}
        public Boolean enviaContratante{get;set;}
        public Boolean beneficiarioPreferente {get;set;}
        public Integer plazo{get;set;}
    } 
    public class DatosParticipantes{
        DSALES_VentaSM.DatosParticipante conductor{get;set;}
        DSALES_VentaSM.DatosParticipante contratante{get;set;}
    }
    private static  DatosRetornoVenta ventaMotos(DSALES_VentaSM.VentaSMRequest venta, Opportunity oppor){
        DSALES_VentaSM.DatosParaEmitir datosEmitir = new DSALES_VentaSM.DatosParaEmitir();
        DSALES_VentaSM.DatosParaEmitir recived = new DSALES_VentaSM.DatosParaEmitir();
        DSALES_VentaSM.DatosSeguro datosSeguro= new DSALES_VentaSM.DatosSeguro();
        DSALES_VentaSM.DatosVehiculo vehiculo = new DSALES_VentaSM.DatosVehiculo();
        DatosRetornoVenta datosx = new  DatosRetornoVenta();
        String idCliente=crearCliente(venta.datosParticipantes,oppor.RecordType.DeveloperName);
        sincronizarOportunidad(venta.idCotizacion, idCliente);
        String idUniversal=venta.pagos.idUniversal;
        venta.pagos.idOportunidad=oppor.Id;
        List<String> partidasSeleccionadas= venta.idPartidaPresupuesto;
        String pagoId= DSALES_PaymentInfoWrapperRequest.insertarPago(venta.pagos,venta.contratante);
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Factura__c,DSALES_IDUniversal1__c,DSALES_Oportunidad__c,DSALES_Plazodecomprademoto__c,DSALES_Poliza__c,DSALES_Seguro__c,DSALES_SKU__c  
                                FROM DSALES_InformacionDePago__c 
                                WHERE Id=:pagoId WITH SECURITY_ENFORCED];
        String idPago=pago.Id;
        DSALES_VentaSMRestAux.cotizacionesNuevas(pago, partidasSeleccionadas,venta.pagos.precioRedondeado);
        DatosPrepoliza datosPrepoliza= new DatosPrepoliza();
        datosPrepoliza.enviaContratante=venta.envioContratante;
        datosPrepoliza.beneficiarioPreferente=venta.beneficiarioPreferente;
        String polizaId=DSALES_VentaSMRestAux.crearPrePoliza(pago,venta.datosParticipantes,datosPrepoliza);
        String idActivo= DSALES_VentaSMRestAux.crearActivo(pago,venta.activo,polizaId);
        if(String.isNotEmpty(idActivo)){
            recived=datosParaEmitir(venta, polizaId);
            datosSeguro=recived.datosSeguro;
            vehiculo=recived.datosVehiculo;
            datosEmitir=recived;
        }
        datosx.datosEmitir=datosEmitir;
        datosx.idCliente=idCliente;
        return datosx;

    }
    private static DatosRetornoVenta  seleccionaVenta(DSALES_VentaSM.VentaSMRequest venta, Opportunity oppor){
        DSALES_VentaSM.DatosParaEmitir datosEmitir = new DSALES_VentaSM.DatosParaEmitir();
        DatosRetornoVenta  retorno = new DatosRetornoVenta ();
        if(!String.isEmpty(venta.servico) && venta.servico=='CELULAR'){ //venta celulares
            DSALES_VentaSM.VentaSMResponse responseCelular= DSALES_VentaSCRest.crearVenta(venta);
            retorno.idCliente=responseCelular.idClienteSalesforce;
            retorno.datosEmitir=responseCelular.datosParaEmitir;
        }
        else{ //venta motos
            retorno= ventaMotos(venta,oppor);
        }
        return retorno;
    }

    public class DatosRetornoVenta{
        public DSALES_VentaSM.DatosParaEmitir datosEmitir {get;set;}
        public String idCliente{get;set;}
    }
    private class ValoresParaAsignar{
        Insurancepolicy poliza{get;set;}
        Quote cotizacion{get;set;}
        QuoteLineItem seguro{get;set;}
    }
    private class FiguraAEnviar{
        DSALES_VentaSM.DatosConductor datosConductor {get;set;}
        DSALES_VentaSM.DatosContratante datosContratante {get;set;}
    }
}