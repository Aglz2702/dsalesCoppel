@isTest
public class DSALES_QuoteSmWrapperTest {
    @isTest 
    static void createQuoteCredito(){
        DSALES_QuoteSmWrapper.QuoteSmRequest requestnpv = new DSALES_QuoteSmWrapper.QuoteSmRequest();
        requestnpv.numeroCliente = 'dato';
        requestnpv.tipoUso='Moto';
        requestnpv.tipoVehiculo='Comercial';
        requestnpv.rfc='wrr2r2r';
        requestnpv.plazoCotizar='12';
        requestnpv.nombre = 'dato';
        requestnpv.apellidoPaterno = 'dato';
        requestnpv.apellidoMaterno = 'dato';
        requestnpv.idTienda = 'dato';
        requestnpv.nombreVendedor = 'dato';
        DSALES_QuoteSmWrapper.Product aux = new DSALES_QuoteSmWrapper.Product();
        aux.sku = '2323';
        requestnpv.telefonoCelular = 'dato';
        requestnpv.correoElectronico = 'dato';
        requestnpv.generoContacto = 'dato';
        requestnpv.fechaNacimiento = date.newInstance(1991, 2, 15);
        requestnpv.codigoPostal = 'dato';
        requestnpv.idVehiculo = 'dato';
        requestnpv.opcionPago = 'dato';
        requestnpv.fechaInicio = date.newInstance(1991, 2, 15);
        requestnpv.precioProducto = 'dato';
        requestnpv.sku = 'dato';
        
        DSALES_QuoteSmWrapper.QuotePostProvedor requesAInter = new DSALES_QuoteSmWrapper.QuotePostProvedor();
        requesAInter.negocio = 'dato';
        requesAInter.aseguradora = 'dato';
        requesAInter.nombreCompleto = 'dato';
        requesAInter.metodoContacto = 'dato';
        requesAInter.telefonoContacto = 'dato';
        requesAInter.correoContacto = 'dato';
        requesAInter.generoContacto = 'dato';
        requesAInter.fechaNacimientoContacto ='23-2-333';
        requesAInter.cpContacto ='23';
        requesAInter.contactar = true;
        requesAInter.idVehiculo = 'dato';
        requesAInter.servicioVehiculo = '34';
        requesAInter.usoVehiculo = 'dato';
        requesAInter.tipoVehiculo = 'dato';
        requesAInter.opcionPago = 'dato';
        requesAInter.paquete = 'dato';
        requesAInter.codigoPromocion = 'dato';
        requesAInter.idAsociado = 'dato';
        requesAInter.fechaCotizacion = '12-12-12';
        requesAInter.fechaInicio = '12-12-12';     
        requesAInter.plazo = '12';
        
        DSALES_QuoteSmWrapper.respuestaDelProveedor response = new DSALES_QuoteSmWrapper.respuestaDelProveedor();
        //response.code = 12;
        response.plazos = new List<DSALES_QuoteSmWrapper.ArmadoMuleSoft>();
        response.success = true;
        
        
        DSALES_QuoteSmWrapper.RespuestaParaNpv responseNpv = new DSALES_QuoteSmWrapper.RespuestaParaNpv();
        responseNpv.idCotizacion = 'dads';
        responseNpv.mensaje= 'dads';
        responseNpv.Idoportunidad ='dads';
        responseNpv.listaNegra =true;
        responseNpv.success =true;
        responseNpv.codigoError = 0;
        responseNpv.listaSeguros =new List<DSALES_QuoteSmWrapper.RespuestaPlazos>();
        responseNpv.listaproducto = new DSALES_QuoteSmWrapper.RespuestaPlazos();
        responseNpv.campanias = new List<DSALES_QuoteSmWrapper.Campanias>();
        
        DSALES_QuoteSmWrapper.Data dat = new DSALES_QuoteSmWrapper.Data();       
        DSALES_QuoteSmWrapper.Receipt recep = new DSALES_QuoteSmWrapper.Receipt();
        recep.numero=1;
        recep.comision='12';
        recep.fechaTermino='10-12';
        //recep.netPremium='12';
        recep.recargo='12';
        recep.derechosPoliza='12';
        recep.fechaInicio='12-12';
        recep.impuestos='12';
        //recep.totalPremium='12';
        recep.pagoTotalEfectivo = 'dato prueba';
        recep.pagoMensual = 'dato prueba';
       	
        DSALES_QuoteSmWrapper.RespuestaPlazos plazos = new DSALES_QuoteSmWrapper.RespuestaPlazos();
        plazos.trackingId = 'dato prueba';
        plazos.paquete = 'dato prueba';
        plazos.vigencia = 'dato prueba';
        plazos.Idpartida = 'dato prueba';
        plazos.descripcion = 'dato prueba';
        plazos.seguroGratis = true; 
        RestResponse res3 = new RestResponse();
        System.assertNotEquals(200, res3.statusCode, 'La llamada no debe devolver un código 200');
    }
}