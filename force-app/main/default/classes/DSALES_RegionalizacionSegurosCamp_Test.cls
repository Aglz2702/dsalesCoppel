@isTest
public with sharing class DSALES_RegionalizacionSegurosCamp_Test {
   @TestSetup
   public static void testSetup(){
        Product2 objetoserv = new Product2();
            objetoserv.Name= 'test';
            objetoserv.StockKeepingUnit = '221122';
            objetoserv.DSales_Tipo_de_Producto__c= 'Seguro';
            objetoserv.isActive=true;
            insert objetoserv;
        	

            
        Campaign camp = new Campaign();
            camp.Name = 'TestCampaing';
            insert camp;

        
        dsalesRegion__c chih=new dsalesRegion__c();
        chih.Name='RegChih';
        insert chih;

        dsalesCiudad__c chihuahua=new dsalesCiudad__c();
        chihuahua.Name='Chihuahua';
        chihuahua.dsalesRegion__c=chih.id;
        insert chihuahua;

        Tienda__c coppelChih=new Tienda__c();
        coppelChih.Name='CoppelChih';
        coppelChih.dsalesCiudad__c=chihuahua.id;
        insert coppelChih;

       dsalesAsignacionDeTienda__c asignacionTienda= new dsalesAsignacionDeTienda__c();
        asignacionTienda.dsalesTienda__c=coppelChih.id;
        asignacionTienda.dsalesActivo__c=true;
        asignacionTienda.dsalesCampana__c=camp.id;
        insert asignacionTienda;

        dsalesAsignacionDeTienda__c asignacionTiendaSeguro= new dsalesAsignacionDeTienda__c();
        asignacionTiendaSeguro.dsalesTienda__c=coppelChih.id;
        asignacionTiendaSeguro.dsalesActivo__c=true;
        asignacionTiendaSeguro.Producto__c=objetoserv.id;
        insert asignacionTiendaSeguro;

   }
   @istest
    static void regionalizacionSegurosCamp_Test() {
        Campaign campana=[select id from campaign where name= 'TestCampaing'  LIMIT 1];
        Product2 seguro=[select id from Product2 where StockKeepingUnit='221122' LIMIT 1];
        System.debug('seguro: '+seguro);
        Tienda__c tienda=[select id from Tienda__c LIMIT 1];
        dsalesRegion__c region=[select id from dsalesRegion__c LIMIT 1];
        dsalesCiudad__c ciudad=[select id from dsalesCiudad__c LIMIT 1];
        dsalesAsignacionDeTienda__c asign=[select id, dsalesTienda__c, Producto__c from dsalesAsignacionDeTienda__c LIMIT 1];
        System.debug('hola'+asign);

        DSALES_RegionalizacionSegurosCampanas.getPickListRegiones();
       	DSALES_RegionalizacionSegurosCampanas.getPickListTiendas(campana.id);
        DSALES_RegionalizacionSegurosCampanas.getPickListTiendasSeguro(seguro.id);
        DSALES_RegionalizacionSegurosCampanas.getPicklistOptionsDependent('{"listCiudades":[],"listRegiones":[{"etiqueta":"Hermosillo","mostrar":true,"seleccionado":true,"valor":"'+region.id+'"}], "listTiendas":[]}');
        DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaCampana('[{"depende":"'+ciudad.id+'","etiqueta":"Coppel Chih","mostrar":true,"seleccionado":true,"valor":"'+ tienda.id+'"}]', campana.id,true);
        DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaSeguro('[{"depende":"'+ciudad.id+'","etiqueta":"Coppel Chih","mostrar":true,"seleccionado":true,"valor":"'+ tienda.id+'"}]', seguro.id,true);
    }
}