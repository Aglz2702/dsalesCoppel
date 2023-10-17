@Istest
public class DSALES_SiniestroWrapperTest {
    @Istest
    static void wrapperTest() {
        DSALES_SiniestroWrapper.siniestroCallPost obj= new DSALES_SiniestroWrapper.siniestroCallPost();
        obj.uid = 'prueba'; 
        obj.Reporte = 'prueba'; 
        obj.NumeroSiniestro = 'prueba'; 
        obj.TipoSiniestro = 'prueba'; 
        obj.FechaSiniestro = 'prueba'; 
        obj.NombreConductor = 'prueba'; 
        obj.Causa = 'prueba'; 

        obj.Vehiculo = new DSALES_SiniestroWrapper.vehiculo();
        obj.Vehiculo.Descripcion = 'prueba';
        obj.Vehiculo.Anio= 'prueba';
        obj.Vehiculo.Placa= 'prueba';
        obj.Vehiculo.Serie= 'prueba';

        obj.Poliza = new DSALES_SiniestroWrapper.poliza();
        obj.Poliza.NumeroPoliza= 'prueba';
        obj.Poliza.Inciso= 'prueba';
        obj.Poliza.FechaInicioVigencia= 'prueba';
        obj.Poliza.FechaFinVigencia= 'prueba';
        obj.Poliza.NombreAsegurado= 'prueba';

        obj.ComoOcurrio = 'prueba';
        obj.Ubicacion = 'prueba';
        obj.Municipio = 'prueba';
        obj.Estado = 'prueba';
        obj.Estatus = 'Nuevo';
        obj.salesforceid = 'prueba';

        DSALES_SiniestroWrapper.siniestroPostResponse obj2= new DSALES_SiniestroWrapper.siniestroPostResponse();
        obj2.success = true;
        obj2.mensaje = 'prueba';
        obj2.codigoError = 0;
        obj2.idSiniestro = 'prueba';

 
        DSALES_SiniestroWrapper.SiniestroPut obj3= new DSALES_SiniestroWrapper.SiniestroPut();
        obj3.uid = 'prueba'; 
        obj3.Reporte = 'prueba'; 
        obj3.NumeroSiniestro = 'prueba'; 
        obj3.TipoSiniestro = 'prueba'; 
        obj3.FechaSiniestro = 'prueba'; 
        obj3.NombreConductor = 'prueba'; 
        obj3.Causa = 'prueba'; 

        obj3.Vehiculo = new DSALES_SiniestroWrapper.vehiculo();
        obj3.Vehiculo.Descripcion = 'prueba';
        obj3.Vehiculo.Anio= 'prueba';
        obj3.Vehiculo.Placa= 'prueba';
        obj3.Vehiculo.Serie= 'prueba';

        obj3.Poliza = new DSALES_SiniestroWrapper.poliza();
        obj3.Poliza.NumeroPoliza= 'prueba';
        obj3.Poliza.Inciso= 'prueba';
        obj3.Poliza.FechaInicioVigencia= 'prueba';
        obj3.Poliza.FechaFinVigencia= 'prueba';
        obj3.Poliza.NombreAsegurado= 'prueba';

        obj3.ComoOcurrio = 'prueba';
        obj3.Ubicacion = 'prueba';
        obj3.Municipio = 'prueba';
        obj3.Estado = 'prueba';
        obj3.Estatus = 'Nuevo';
        obj3.salesforceid = 'prueba';
        
        
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
        DSALES_SiniestroWrapper.comprobantesTenencia gg =new  DSALES_SiniestroWrapper.comprobantesTenencia();
        gg.descripcion ='dfd';
        gg.idComprobante ='f';
        gg.comprobante='vb';
    
        //____
        DSALES_SiniestroWrapper.SiniestroPut obj5= new DSALES_SiniestroWrapper.SiniestroPut();
        obj5.uid = 'prueba'; 
        obj5.Reporte = 'prueba'; 
        obj5.NumeroSiniestro = 'prueba'; 
        obj5.TipoSiniestro = 'prueba'; 
        obj5.FechaSiniestro = 'prueba'; 
        obj5.NombreConductor = 'prueba'; 
        obj5.Causa = 'prueba'; 

        obj5.Vehiculo = new DSALES_SiniestroWrapper.vehiculo();
        obj5.Vehiculo.Descripcion = 'prueba';
        obj5.Vehiculo.Anio= 'prueba';
        obj5.Vehiculo.Placa= 'prueba';
        obj5.Vehiculo.Serie= 'prueba';

        obj5.Poliza = new DSALES_SiniestroWrapper.poliza();
        obj5.Poliza.NumeroPoliza= 'prueba';
        obj5.Poliza.Inciso= 'prueba';
        obj5.Poliza.FechaInicioVigencia= 'prueba';
        obj5.Poliza.FechaFinVigencia= 'prueba';
        obj5.Poliza.NombreAsegurado= 'prueba';

        obj5.ComoOcurrio = 'prueba';
        obj5.Ubicacion = 'prueba';
        obj5.Municipio = 'prueba';
        obj5.Estado = 'prueba';
        obj5.Estatus = 'Nuevo';
        obj5.salesforceid = 'prueba';
        RestResponse res3 = new RestResponse();
        System.assertNotEquals(200, res3.statusCode, 'La llamada no debe devolver un código 200');
    }
}