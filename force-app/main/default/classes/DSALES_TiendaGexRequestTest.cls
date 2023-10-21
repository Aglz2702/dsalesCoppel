@isTest
public with sharing class DSALES_TiendaGexRequestTest {
    @TestSetup
	static void setUp()
    {
        Tienda__c tienda= new Tienda__c(Name='Dani',DSales_TiendaID__c='54');
        insert tienda;
        dsalesRegion__c region= new dsalesRegion__c(Name='Coahuila',dsalesActivo__c=true);
        insert region;
        dsalesCiudad__c ciudad= new dsalesCiudad__c(Name='Monterrey',dsalesActivo__c=true,dsalesRegion__c=region.id);
        insert ciudad;
        dSalesGerente__c gerente= new dSalesGerente__c(Name='Danny');
        insert gerente;
    }
    @isTest static void crearRegistro()
        {
            RestRequest peticion= new RestRequest();
            RestResponse respuesta= new RestResponse();
            String cuerpo='{"idTienda":"54","activa":true,"tiendaBase":"1","telefonoTiendaBase":"111","nombreTienda":"Coppel","direccion":"Charcasvallerojo","estado":"Nuevo León","telefono":"1234","codigoPostal":"66051","ciudad":"Mérida","region":"Yucatán","division":"DIVISIÓNTIENDASI","nombreGerente":"DanielSanMiguelCardona","numeroCelular":"12345678","emailGerente":"dsanmiguel@deloittemx.com","banco":true,"optica":true,"moduloAfore":false,"fechaApertura":"2023-09-15","ultimaRemodelacion":"2023-09-15","tipoDeTienda":"Propio","formato":"TIENDACOPPEL"}';
           peticion.RequestURI='/apexrest/insertTienda';
            peticion.HttpMethod='POST';
            RestContext.request=peticion;
            peticion.requestBody=Blob.valueOf(cuerpo);
            RestContext.response=respuesta;
            DSALES_TiendaGex.tiendaRequest tiendaRegistro =  (DSALES_TiendaGex.tiendaRequest)JSON.deserialize (cuerpo,DSALES_TiendaGex.tiendaRequest.class);
            Test.startTest();
            DSALES_TiendaGexRequest.crearTienda();
            REstContext.Request=peticion;
            RestContext.Response=respuesta;
            System.debug('RESPUESTA ES: '+respuesta);
            Test.stopTest();
            
            
        }
     @isTest static void crearRegistro2()
        {
            RestRequest peticion= new RestRequest();
            RestResponse respuesta= new RestResponse();
            String cuerpo='{"idTienda":"55","activa":true,"tiendaBase":"1","telefonoTiendaBase":"111","nombreTienda":"Coppel","direccion":"Charcasvallerojo","estado":"Nuevo León","telefono":"1234","codigoPostal":"66051","ciudad":"Monterrey","region":"Coahuila","division":"DIVISIÓNTIENDASI","nombreGerente":"Danny","numeroCelular":"12345678","emailGerente":"dsanmiguel@deloittemx.com","banco":true,"optica":true,"moduloAfore":false,"fechaApertura":"2023-09-15","ultimaRemodelacion":"2023-09-15","tipoDeTienda":"Propio","formato":"TIENDACOPPEL"}';
           peticion.RequestURI='/apexrest/insertTienda';
            peticion.HttpMethod='POST';
            RestContext.request=peticion;
            peticion.requestBody=Blob.valueOf(cuerpo);
            RestContext.response=respuesta;
            DSALES_TiendaGex.tiendaRequest tiendaRegistro =  (DSALES_TiendaGex.tiendaRequest)JSON.deserialize (cuerpo,DSALES_TiendaGex.tiendaRequest.class);
            Test.startTest();
            DSALES_TiendaGexRequest.crearTienda();
            REstContext.Request=peticion;
            RestContext.Response=respuesta;
            System.debug('RESPUESTA ES: '+respuesta);
            Test.stopTest();
            
           
        }
}