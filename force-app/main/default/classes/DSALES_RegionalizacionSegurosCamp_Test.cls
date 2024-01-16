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
       	chih.dsalesActivo__c=true;
        insert chih;

        dsalesCiudad__c chihuahua=new dsalesCiudad__c();
        chihuahua.Name='Chihuahua';
        chihuahua.dsalesRegion__c=chih.id;
       	chihuahua.dsalesActivo__c=true;
        insert chihuahua;

       	dSalesGerente__c gerente= new dSalesGerente__c();
       	gerente.name='test';
       	gerente.DSalesActivo__c=true;
       	gerente.DSalesCiudad__c=chihuahua.id;
        insert gerente;
       
        Tienda__c coppelChih=new Tienda__c();
        coppelChih.Name='CoppelChih';
        coppelChih.dsalesCiudad__c=chihuahua.id;
       	coppelChih.dSalesGerente__c=gerente.id;
       	coppelChih.Activa__c=true;
        insert coppelChih;
       
       DSales_Matriz_GEX__c mat= new DSales_Matriz_GEX__c();
       mat.name='matrizprueba';
       mat.DSALES_Activo__c=true;
       mat.DSALES_Tiempogex__c= '1 año';
       insert mat;

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
       
        dsalesAsignacionDeTienda__c asignacionTiendaMatriz= new dsalesAsignacionDeTienda__c();
        asignacionTiendaMatriz.dsalesTienda__c=coppelChih.id;
        asignacionTiendaMatriz.dsalesActivo__c=true;
        asignacionTiendaMatriz.dsalesMatriz__c=mat.id;
        insert asignacionTiendaMatriz;
       
       

   }
   @istest
    static void regionalizacionSegurosCamp_Test() {
        DSALES_RegionalizacionSegurosCampanas.DSALES_ClasificacionServicioWrapper controller = DSALES_RegionalizacionSegurosCampanas.getPickListRegiones();
        controller.listRegiones[0].seleccionado = true;
        controller = DSALES_RegionalizacionSegurosCampanas.getPicklistOptionsDependent(JSON.serialize(controller));
        controller.listCiudades[0].seleccionado = true;
        controller = DSALES_RegionalizacionSegurosCampanas.getPicklistOptionsDependent(JSON.serialize(controller));
        //controller.listTiendas[0].seleccionado = true;
        controller = DSALES_RegionalizacionSegurosCampanas.getPicklistOptionsDependent(JSON.serialize(controller));
        //controller.listGerentes[0].seleccionado = true;
        //controller = DSALES_ClasificacionServicio.getRecords(JSON.serialize(controller), 'Administrador del sistema', 'AllRecords');
        //controller = DSALES_ClasificacionServicio.getRecords(JSON.serialize(controller), 'Administrador GEX', 'opcion2');
        //controller = DSALES_ClasificacionServicio.getRecords(JSON.serialize(controller), 'Administrador GEX', 'AllRecords');
        controller.sku = 'SKU1234353464565654665';
        //controller.listServicios = DSALES_ClasificacionServicio.getBuscarSKU(controller.sku);
        Campaign campana=[select id from campaign where name= 'TestCampaing'  LIMIT 1];
        Product2 seguro=[select id from Product2 where StockKeepingUnit='221122' LIMIT 1];
        DSales_Matriz_GEX__c matriz=[select id from DSales_Matriz_GEX__c where name='matrizprueba' LIMIT 1];
        System.debug('seguro: '+seguro);
        Tienda__c tienda=[select id from Tienda__c LIMIT 1];
        dSalesGerente__c gerente=[select id from dSalesGerente__c LIMIT 1];
        dsalesRegion__c region=[select id from dsalesRegion__c LIMIT 1];
        dsalesCiudad__c ciudad=[select id from dsalesCiudad__c LIMIT 1];
        dsalesAsignacionDeTienda__c asign=[select id, dsalesTienda__c, Producto__c from dsalesAsignacionDeTienda__c LIMIT 1];
        System.debug('hola'+asign);

        DSALES_RegionalizacionSegurosCampanas.getPickListRegiones();
       	DSALES_RegionalizacionSegurosCampanas.getPickListTiendas(campana.id);
        DSALES_RegionalizacionSegurosCampanas.getPickListTiendasMatriz(matriz.id);
        DSALES_RegionalizacionSegurosCampanas.seleccionCampanaMatriz(campana.id);
        DSALES_RegionalizacionSegurosCampanas.getPickListTiendasSeguro(seguro.id);
        DSALES_RegionalizacionSegurosCampanas.seleccionSegurosServicios(seguro.id);
        DSALES_RegionalizacionSegurosCampanas.getPicklistOptionsDependent('{"listCiudades":[{"etiqueta":"Hermosillo","mostrar":true,"seleccionado":true,"valor":"'+ciudad.id+'"}],"listGerentes":[{"etiqueta":"test","mostrar":true,"seleccionado":true,"valor":"'+gerente.id+'"}],"listRegiones":[{"etiqueta":"Hermosillo","mostrar":true,"seleccionado":true,"valor":"'+region.id+'"}], "listTiendas":[]}');
         DSALES_RegionalizacionSegurosCampanas.getPicklistOptionsDependentSM('{"listCiudades":[{"etiqueta":"Hermosillo","mostrar":true,"seleccionado":true,"valor":"'+ciudad.id+'"}],"listGerentes":[],"listRegiones":[{"etiqueta":"Hermosillo","mostrar":true,"seleccionado":true,"valor":"'+region.id+'"}], "listTiendas":[]}');
        DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaCampana('[{"depende":"'+ciudad.id+'","etiqueta":"Coppel Chih","mostrar":true,"seleccionado":true,"valor":"'+ tienda.id+'"}]', campana.id,true);
        DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaSeguro('[{"depende":"'+ciudad.id+'","etiqueta":"Coppel Chih","mostrar":true,"seleccionado":true,"valor":"'+ tienda.id+'"}]', seguro.id,true);
        DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaMatriz('[{"depende":"'+ciudad.id+'","etiqueta":"Coppel Chih","mostrar":true,"seleccionado":true,"valor":"'+ tienda.id+'"}]', matriz.id,true);
        DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaMatriz('[{"depende":"'+ciudad.id+'","etiqueta":"Coppel Chih","mostrar":true,"seleccionado":true,"valor":"'+ tienda.id+'"}]', matriz.id,false);
  		DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaCampana('[{"depende":"'+ciudad.id+'","etiqueta":"Coppel Chih","mostrar":true,"seleccionado":true,"valor":"'+ tienda.id+'"}]', campana.id,false);
        DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaSeguro('[{"depende":"'+ciudad.id+'","etiqueta":"Coppel Chih","mostrar":true,"seleccionado":true,"valor":"'+ tienda.id+'"}]', seguro.id,false);
    }
}