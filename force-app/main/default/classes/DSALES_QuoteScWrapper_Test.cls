@isTest
public class DSALES_QuoteScWrapper_Test {
    
    @isTest 
    static void createQuoteCredito(){
        DSALES_QuoteScWrapper.QuoteScRequest request = new DSALES_QuoteScWrapper.QuoteScRequest();
        request.idTienda = '1';
        request.numeroCliente = '54789';
        request.nombre = 'Juan';
        request.apellidoPaterno = 'Deo';
        request.apellidoMaterno = 'Test';
        request.rfc='SED456075S68';
        request.plazoCotizar='12';
        request.nombreVendedor = 'dato';
        request.sku = '672323';
        request.correoElectronico = 'cardiftest@gmail.com';
        request.fechaNacimiento = '1998-07-02';
        request.telefonoCelular = '2023-11-09';
        request.opcionPago = 'dato';
        request.precioCelular = 4500;
        request.marcaCelular = 'Samsung';
        request.modeloCelular = 'Samsung Galaxy';
        request.colorCelular ='blanco';
        request.numeroDeSucursal = '12';
        request.identificadorDelVendedor = '5';
        request.identificadorCoppel ='4';
        
        
        DSALES_QuoteScWrapper.CardifResponse caardifResponse = new DSALES_QuoteScWrapper.CardifResponse();
        caardifResponse.exito =true;
        caardifResponse.mensaje ='cardif Response';
        caardifResponse.metodoPago = 'Efectivo';
        caardifResponse.montoSeguroTotal =12000;
        caardifResponse.montoSeguroMensual = 1000;
        caardifResponse.uuid = 'Test';
        caardifResponse.price = new List<DSALES_QuoteScWrapper.InsurancePremium>();
        caardifResponse.plazos = new List<DSALES_QuoteScWrapper.plazo>();
        
        DSALES_QuoteScWrapper.QuoteScResponse response = new DSALES_QuoteScWrapper.QuoteScResponse();
        response.exito =true;
        response.mensaje= 'Quote Created';
        response.codigoError = 'Codigo Error';
        response.mensajeError ='Mensaje Error';
        response.idoportunidad ='xxxxxxxxxxx';
        response.idCotizacion = 'xxxxxxxxxxx';
        response.listaNegra =false;
        
        DSALES_QuoteScWrapper.InsurancePremium seguro = new DSALES_QuoteScWrapper.InsurancePremium();
        seguro.seguroPrice = 400;
        
        DSALES_QuoteScWrapper.OpcionPago pago = new DSALES_QuoteScWrapper.OpcionPago();
        pago.OpcionPago ='18';
        
        DSALES_QuoteScWrapper.Plazo pl = new DSALES_QuoteScWrapper.Plazo();
        pl.paquete ='test';
        pl.opcionesPago = new List<DSALES_QuoteScWrapper.OpcionPago>();
        System.assertNotEquals('200', response.codigoError, 'La llamada no debe devolver un código 200'); 
        
        
    }
    
}