@isTest
public class DSALES_QuoteSmWrapperTest {
    @isTest 
    static void CreateQuoteCredito(){
        DSALES_QuoteSmWrapper.QuoteSmRequest requestnpv = new DSALES_QuoteSmWrapper.QuoteSmRequest();
        requestnpv.numero_cliente = 'dato';
        requestnpv.tipo_uso='Moto';
        requestnpv.tipo_vehiculo='Comercial';
        requestnpv.rfc='wrr2r2r';
        requestnpv.plazo_cotizar='12';
        requestnpv.nombre = 'dato';
        requestnpv.apellido_paterno = 'dato';
        requestnpv.apellido_materno = 'dato';
        requestnpv.id_tienda = 'dato';
        requestnpv.nombre_vendedor = 'dato';
        DSALES_QuoteSmWrapper.Product aux = new DSALES_QuoteSmWrapper.Product();
        aux.sku = '2323';
        requestnpv.telefono_celular = 'dato';
        requestnpv.correo_electronico = 'dato';
        requestnpv.genero_contacto = 'dato';
        requestnpv.fecha_nacimiento = date.newInstance(1991, 2, 15);
        requestnpv.codigo_postal = 'dato';
        requestnpv.id_vehiculo = 'dato';
        requestnpv.opcion_pago = 'dato';
        requestnpv.fecha_inicio = date.newInstance(1991, 2, 15);
        requestnpv.precioProducto = 'dato';
        requestnpv.sku = 'dato';
        
        DSALES_QuoteSmWrapper.QuotePostProvedor requesAInter = new DSALES_QuoteSmWrapper.QuotePostProvedor();
        requesAInter.business = 'dato';
        requesAInter.insurance = 'dato';
        requesAInter.contact_name = 'dato';
        requesAInter.contact_method = 'dato';
        requesAInter.contact_phone = 'dato';
        requesAInter.contact_email = 'dato';
        requesAInter.contact_gender = 'dato';
        requesAInter.contact_birth_date ='23-2-333';
        requesAInter.contact_zip_code ='23';
        requesAInter.contact_now = true;
        requesAInter.vehicle_id = 'dato';
        requesAInter.vehicle_service = '34';
        requesAInter.vehicle_use = 'dato';
        requesAInter.vehicle_type = 'dato';
        requesAInter.payment_option = 'dato';
        requesAInter.packagge = 'dato';
        requesAInter.promotion_code = 'dato';
        requesAInter.associate_id = 'dato';
        requesAInter.quote_date = '12-12-12';
        requesAInter.start_at = '12-12-12';     
        requesAInter.plazo = '12';
        
        DSALES_QuoteSmWrapper.respuestaDelProveedor response = new DSALES_QuoteSmWrapper.respuestaDelProveedor();
        response.code = 12;
        response.plazos = new List<DSALES_QuoteSmWrapper.ArmadoMuleSoft>();
        response.success = true;
        
        
        DSALES_QuoteSmWrapper.RespuestaParaNpv responseNpv = new DSALES_QuoteSmWrapper.RespuestaParaNpv();
        responseNpv.idCotizacion = 'dads';
        responseNpv.mensaje= 'dads';
        responseNpv.Idoportunidad ='dads';
        responseNpv.listaNegra =true;
        responseNpv.success =true;
        responseNpv.codigo_error = 0;
        responseNpv.listaSeguros =new List<DSALES_QuoteSmWrapper.RespuestaPlazos>();
        responseNpv.listaproducto = new DSALES_QuoteSmWrapper.RespuestaPlazos();
        responseNpv.campanias = new List<DSALES_QuoteSmWrapper.Campanias>();
        
        DSALES_QuoteSmWrapper.Data dat = new DSALES_QuoteSmWrapper.Data();
        dat.coverages_array = new List<DSALES_QuoteSmWrapper.CoveragesArray>();
        DSALES_QuoteSmWrapper.CoveragesArray cover = new DSALES_QuoteSmWrapper.CoveragesArray();
        cover.code='2';
        cover.deductive=123;
        cover.name='2';
        cover.sum_assured='2';
        dat.coverages_array.add(cover);
        
        dat.quote_id = 'nsq';
        dat.receipts = new List<DSALES_QuoteSmWrapper.Receipt>();
        dat.insurance_premium = new DSALES_QuoteSmWrapper.InsurancePremium();
        dat.insurance_premium.net_premium = 12.43;
        dat.insurance_premium.commission = 12;
        dat.insurance_premium.surcharge = 12.43;
        dat.insurance_premium.tax = 12.43;
        dat.insurance_premium.right = 12.43;
        
        dat.payment_options_json = new List<DSALES_QuoteSmWrapper.PaymentOptionsJson>();
        DSALES_QuoteSmWrapper.PaymentOptionsJson payOption = new DSALES_QuoteSmWrapper.PaymentOptionsJson();
        payOption.value = 'ads';
        payOption.label = 'ads';
        dat.payment_options_json.add(payOption);
        dat.police_id ='123';
        dat.company_logo = 'qweq';
        
        DSALES_QuoteSmWrapper.Receipt recep = new DSALES_QuoteSmWrapper.Receipt();
        recep.numbere=1;
        recep.commission='12';
        recep.end_date='10-12';
        recep.net_premium='12';
        recep.recharge='12';
        recep.recharge='12';
        recep.right='12';
        recep.start_date='12-12';
        recep.tax='12';
        recep.total_premium='12';
        recep.pagoTotalEfectivo = 'dato prueba';
        recep.pagoMensual = 'dato prueba';
        
        DSALES_QuoteSmWrapper.ReceiptEspa recEspanol = new DSALES_QuoteSmWrapper.ReceiptEspa();
        recEspanol.numero = 1;
        recEspanol.fecha_inicio = 'dato prueba';
        recEspanol.fecha_termino = 'dato prueba';
        recEspanol.prima_neta = 'dato prueba';
        recEspanol.precio_venta = 'dato prueba';
        recEspanol.derechos_poliza = 'dato prueba';
        recEspanol.recargos = 'dato prueba';
        recEspanol.impuestos = 'dato prueba';
        recEspanol.comision = 'dato prueba';
        recEspanol.pagoTotalEfectivo = 'dato prueba';
        recEspanol.pagoMensual = 'dato prueba';
       	
        DSALES_QuoteSmWrapper.RespuestaPlazos plazos = new DSALES_QuoteSmWrapper.RespuestaPlazos();
        plazos.tracking_id = 'dato prueba';
        plazos.nombreProducto = 'dato prueba';
        plazos.vigencia = 'dato prueba';
        plazos.Idpartida = 'dato prueba';
        plazos.descripcion = 'dato prueba';
        plazos.seguro_gratis = true;
        
    }
    

}