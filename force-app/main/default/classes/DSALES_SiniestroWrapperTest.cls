@Istest
public class DSALES_SiniestroWrapperTest {
    @Istest
    static void wrapperTest() {
        DSALES_SiniestroWrapper.siniestroPostResponse obj2= new DSALES_SiniestroWrapper.siniestroPostResponse();
        obj2.success = true;
        obj2.mensaje = 'prueba';
        obj2.codigoError = 0;
        obj2.idSiniestro = 'prueba';
        
        DSALES_SiniestroWrapper.SiniestroGet obj4= new DSALES_SiniestroWrapper.SiniestroGet();
        obj4.uid = 'prueba'; 
        obj4.Reporte = 'prueba'; 
        obj4.NumeroSiniestro = 'prueba'; 
        obj4.TipoSiniestro = 'prueba'; 
        obj4.FechaSiniestro = 'prueba'; 
        obj4.NombreConductor = 'prueba'; 
        obj4.Causa = 'prueba'; 

        obj4.Vehiculo = new DSALES_SiniestroWrapper.vehiculo();
        obj4.Vehiculo.Descripcion = 'prueba';
        obj4.Vehiculo.Anio= 'prueba';
        obj4.Vehiculo.Placa= 'prueba';
        obj4.Vehiculo.Serie= 'prueba';

        obj4.Poliza = new DSALES_SiniestroWrapper.poliza();
        obj4.Poliza.NumeroPoliza= 'prueba';
        obj4.Poliza.Inciso= 'prueba';
        obj4.Poliza.FechaInicioVigencia= 'prueba';
        obj4.Poliza.FechaFinVigencia= 'prueba';
        obj4.Poliza.NombreAsegurado= 'prueba';
        obj4.ComoOcurrio = 'prueba';
        obj4.Ubicacion = 'prueba';
        obj4.Municipio = 'prueba';
        obj4.Estado = 'prueba';
        obj4.Estatus = 'Nuevo';
        obj4.salesforceid = 'prueba';
        obj4.solucion = 'prueba';
        obj4.comentarioDeEstatus = 'prueba';
        obj4.saldo = 'prueba';
        obj4.saldoinsoluto = 'prueba';
        obj4.motivodeRechazo = 'prueba';
        obj4.remanente = 'prueba';
        obj4.tipoDePago = 'prueba';
        obj4.fechaDePago = date.ValueOf('2023-05-05');
    }
}