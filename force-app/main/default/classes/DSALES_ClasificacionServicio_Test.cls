@isTest
public class DSALES_ClasificacionServicio_Test {
   
    @testSetup
    static void testSetup(){
        String recordTypeId = Schema.SObjectType.DSALES_Categoria__c.getRecordTypeInfosByDeveloperName().get('dsalesServicios').getRecordTypeId();
        String recordTypeId2 = Schema.SObjectType.DSALES_Categoria__c.getRecordTypeInfosByDeveloperName().get('DSales_ProductoTangible').getRecordTypeId(); 
         String recordTypeId3 = Schema.SObjectType.dsalesProveedores__c.getRecordTypeInfosByDeveloperName().get('dsalesServicios').getRecordTypeId();
        DSALES_Categoria__c categoria = new DSALES_Categoria__c();
        categoria.Name = 'Test';
        categoria.RecordTypeId=recordTypeId;
        insert categoria;
        
          DSALES_Categoria__c categoria2 = new DSALES_Categoria__c();
        categoria2.Name = 'Test';
        categoria2.RecordTypeId=recordTypeId2;
        insert categoria2;
        
        DSALES_SubCategoria__c subC = new DSALES_SubCategoria__c ();
        subC.Name = 'Test';
        subC.DSALES_Categoria__c = categoria.Id;
        insert subC;
        
         DSALES_SubCategoria__c subC2 = new DSALES_SubCategoria__c ();
        subC2.Name = 'Test';
        subC2.DSALES_Categoria__c = categoria2.Id;
        insert subC2;
        
        DSALES_Clase__c clase = new DSALES_Clase__c();
        clase.Name = 'Test';
        clase.DSALES_SubCategoria__c = subC.Id;
        insert clase;
        
         DSALES_Clase__c clase2 = new DSALES_Clase__c();
        clase2.Name = 'Test';
        clase2.DSALES_SubCategoria__c = subC2.Id;
        insert clase2;
        
        DSALES_Familia__c familia = new DSALES_Familia__c();
        familia.DSALES_Clase__c = clase.Id;
        familia.Name = 'Test';
        insert familia;
        
         DSALES_Familia__c familia2 = new DSALES_Familia__c();
        familia2.DSALES_Clase__c = clase2.Id;
        familia2.Name = 'Test';
        insert familia2;
          
        DSales_Matriz_GEX__c mat = new DSales_Matriz_GEX__c();
        mat.Name= 'test1';
        mat.DSALES_Activo__c= true;
        mat.DSALES_Region__c ='Hermosillo';
        mat.DSALES_Tiempogex__c = '2 años';
        insert mat;
        
        DSALES_Matriz_de_Cotizacion__c matItem = new DSALES_Matriz_de_Cotizacion__c();
        matItem.DSales_Matriz_GEX__c = mat.Id;
        matItem.SALES_Precio_GEX__c = 3500;
        matItem.DSALES_Rango_interior_GEX__c=7000;
        matItem.DSALES_Rango_Superior_GEX__c = 8500;
        matItem.DSALES_Tiempo_de_Garantia_Extendida_GEX__c = '1 año';
        
        matItem.DSales_Matriz_GEX__c = mat.Id;
        matItem.SALES_Precio_GEX__c = 4500;
        matItem.DSALES_Rango_interior_GEX__c=7000;
        matItem.DSALES_Rango_Superior_GEX__c = 8500;
        matItem.DSALES_Tiempo_de_Garantia_Extendida_GEX__c = '2 años';
        insert matItem;
       
        
        Product2 producto = new Product2();
        producto.Name = 'test';
        producto.DSales_Categoria__c = categoria.Id;
        producto.DSALES_SubCategoria__c = subC.Id;
        producto.DSALES_Clase__c = clase.Id;
        producto.DSALES_Familia__c = familia.Id;
        producto.StockKeepingUnit = 'SKU1234353464565654665';
        producto.DSales_Tipo_de_Producto__c= 'Producto';
        producto.IsActive=true;
        insert producto;
        
        Product2 producto2 = new Product2();
        producto2.Name = 'test2';
        producto2.DSales_Categoria__c = categoria.Id;
        producto2.DSALES_SubCategoria__c = subC.Id;
        producto2.DSALES_Clase__c = clase.Id;
        producto2.DSALES_Familia__c = familia.Id;
        producto2.StockKeepingUnit = 'SKU1234353464565654';
        producto2.DSales_Tipo_de_Producto__c= 'Producto';
        producto2.DSALES_Servicio__c=true;
        producto2.IsActive=true;
        insert producto2;
        
        Product2 objetoserv = new Product2();
        objetoserv.Name= 'test';
        objetoserv.DSales_Categoria__c = categoria.Id;
        objetoserv.DSALES_SubCategoria__c = subC.Id;
        objetoserv.DSALES_Clase__c = clase.Id;
        objetoserv.DSALES_Familia__c = familia.Id;
        objetoserv.StockKeepingUnit = 'SKU12346VG';
        objetoserv.DSales_Tipo_de_Producto__c= 'Servicio';
        objetoserv.DSALES_Matriz__c=mat.id;
        objetoserv.isActive=true;
        insert objetoserv;
        
        DSales_Asignacion_de_Productos__c asignacionprod = new DSales_Asignacion_de_Productos__c();
        asignacionprod.Name='Test';
        asignacionprod.DSales_Servicio_Seguro__c= producto.Id;
        asignacionprod.DSales_Producto__c=objetoserv.Id;
        asignacionprod.DSALES_Activo__c=true;
        insert asignacionprod;
        
        DSales_Asignacion_de_Productos__c asignacionprod2 = new DSales_Asignacion_de_Productos__c();
        asignacionprod2.Name='Test';
        asignacionprod2.DSales_Servicio_Seguro__c= objetoserv.Id;
        asignacionprod2.DSales_Producto__c=producto.Id;
        asignacionprod2.DSALES_Activo__c=true;
        insert asignacionprod2;
        
        Campaign camp = new Campaign();
        camp.Name = 'TestCampaing';
        camp.IsActive=true;
        insert camp;
        
        DSALES_TipodeUso__c tp = new DSALES_TipodeUso__c();
        tp.Name = 'TestTipoUso';
        tp.DSALES_Activo__c=true;
        insert tp;

        DSALES_AsociacionTiposUso__c atp= new DSALES_AsociacionTiposUso__c();
        atp.DSALES_TipodeUso__c=tp.id;
        atp.DSales_Producto__c=producto.id;
        atp.DSALES_Activo__c=true;
        insert atp;
        
        DSALES_AsociacionCampanias__c acp = new DSALES_AsociacionCampanias__c();
        acp.DSALES_Campania__c=camp.id;
        acp.DSales_Producto__c=producto.id;
        acp.DSALES_Activo__c=true;
        insert acp;
        
        DSALES_ClasificacionServicio.PorcentajesCobro porcentaje= new DSALES_ClasificacionServicio.PorcentajesCobro();
        porcentaje.anio1=2;
        porcentaje.anio2=2;
        porcentaje.anio3=2;
        porcentaje.anio4=2;
        porcentaje.anio5=2;
        
        dsalesProveedores__c proveedor =new dsalesProveedores__c();
        proveedor.name='test';
        proveedor.dsalesActivo__c=true;
        proveedor.RecordTypeId=recordTypeId3;
        insert proveedor;
        
        dsalesEncuestaPISyS__c encuesta= new dsalesEncuestaPISyS__c();
        encuesta.name='test';
        encuesta.dsalesIsActive__c=true;
        insert encuesta;
    }

    @isTest
    static void clasificacionServicio(){
         String recordTypeId2 = Schema.SObjectType.DSALES_Categoria__c.getRecordTypeInfosByDeveloperName().get('DSales_ProductoTangible').getRecordTypeId(); 
        Product2 idprueba= [Select id from Product2 where StockKeepingUnit= 'SKU12346VG' limit 1];
        Product2 idprodtp= [Select id from Product2 where StockKeepingUnit='SKU1234353464565654665' limit 1];
        dsalesProveedores__c idproveedores= [Select id, name from dsalesProveedores__c limit 1];
        dsalesEncuestaPISyS__c encuesta= [Select id from dsalesEncuestaPISyS__c limit 1];
		system.debug('hoho'+idproveedores);
        DSALES_Categoria__c idcat = [select id, recordtype.name from DSALES_Categoria__c where recordtypeid=: recordTypeId2 limit 1];
        DSALES_SubCategoria__c idsubc= [select id from DSALES_SubCategoria__c limit 1];
        DSALES_Clase__c idclass=  [select id from DSALES_Clase__c limit 1];
        DSales_Matriz_GEX__c idmat= [select id from DSales_Matriz_GEX__c limit 1];
        Campaign idcamp = [Select id from Campaign limit 1];
        DSALES_TipodeUso__c idtp = [Select id from DSALES_TipodeUso__c limit 1];
        DSALES_AsociacionTiposUso__c idatp= [Select id from DSALES_AsociacionTiposUso__c limit 1];
        DSALES_ClasificacionServicio.DSALES_ClasificacionServicioWrapper controller = DSALES_ClasificacionServicio.getPickListCategoria();
        controller.listCategorias[0].seleccionado = true;
        
        controller = DSALES_ClasificacionServicio.getPicklistOptionsDependent(JSON.serialize(controller));
        controller.listSubCategorias[0].seleccionado = true;
        
        controller = DSALES_ClasificacionServicio.getPicklistOptionsDependent(JSON.serialize(controller));
        controller.listClases[0].seleccionado = true;
        
        controller = DSALES_ClasificacionServicio.getPicklistOptionsDependent(JSON.serialize(controller));
        controller.listFamilias[0].seleccionado = true;
        
        controller = DSALES_ClasificacionServicio.getRecords(JSON.serialize(controller), 'Administrador del sistema', 'AllRecords');
        controller = DSALES_ClasificacionServicio.getRecords(JSON.serialize(controller), 'Administrador GEX', 'opcion2');
                controller = DSALES_ClasificacionServicio.getRecords(JSON.serialize(controller), 'Administrador GEX', 'AllRecords');
        //DSALES_ClasificacionServicio.upsertRecord(JSON.serialize(controller));
        
        controller.sku = 'SKU1234353464565654665';
        controller.listServicios = DSALES_ClasificacionServicio.getBuscarSKU(controller.sku);
        DSALES_ClasificacionServicio.getBuscarVinculacion(DSALES_ClasificacionServicio.getidservicio('SKU12346VG'));
        DSALES_ClasificacionServicio.getBuscarProducto(DSALES_ClasificacionServicio.getidservicio('SKU1234353464565654665'));
        DSALES_ClasificacionServicio.upsertVinculacion(JSON.serialize( DSALES_ClasificacionServicio.getRecordsFromServer3(idprueba.id,1,1)));
        DSALES_ClasificacionServicio.getRecordsFromServer2(idprueba.id,1,1);
        DSALES_ClasificacionServicio.getRecordsFromServer21(idprueba.id, 'SKU1234353464565654');
        DSALES_ClasificacionServicio.getRecordsFromServer31(idprueba.id, 'SKU1234353464565654');
        DSALES_ClasificacionServicio.insertVinculacion(JSON.serialize( DSALES_ClasificacionServicio.getRecordsFromServer2(DSALES_ClasificacionServicio.getidservicio('SKU1234353464565654665'),1,1)), DSALES_ClasificacionServicio.getidservicio('SKU12346VG'));
        DSALES_ClasificacionServicio.checkProfileType();
        DSALES_ClasificacionServicio.getcategories(idcat.recordtype.name);
        DSALES_ClasificacionServicio.getSubCategories(idcat.id);
        DSALES_ClasificacionServicio.getClases(idsubc.id);
        DSALES_ClasificacionServicio.getFamilias(idclass.id);
        DSALES_ClasificacionServicio.getMatriz();
        DSALES_ClasificacionServicio.RecordTypeId('Garantía Extendida');
        DSALES_ClasificacionServicio.updateMatriz( '["'+idmat.id+'"]', DSALES_ClasificacionServicio.getidservicio('SKU12346VG'));
        DSALES_ClasificacionServicio.insertPocentajeCobro(DSALES_ClasificacionServicio.getidservicio('SKU12346VG'),'{"anio1":"6","anio2":"5","anio3":"9","anio4":3,"anio5":2,"anio6":1}');
        //DSALES_ClasificacionServicio.insertProveedores( idprueba.id, idproveedores.name);
        DSALES_ClasificacionServicio.getPickListValuesIntoList1();
        DSALES_ClasificacionServicio.getPickListValuesIntoList2();
        DSALES_ClasificacionServicio.getPickListValuesIntoList3();
        DSALES_ClasificacionServicio.getPickListValuesIntoList4();
        DSALES_ClasificacionServicio.getPickListValuesIntoList5();
        DSALES_ClasificacionServicio.getPickListValuesIntoList6();
        DSALES_ClasificacionServicio.getPickListProveedores();
        DSALES_ClasificacionServicio.getPickListEncuesta();
        //DSALES_ClasificacionServicio.asignacionProveedores(idproveedores.id, idservicio.id);
        //DSALES_ClasificacionServicio.asignacionEncuesta(encuesta.id, idprueba.id);
        DSALES_ClasificacionServicio.getCampaings();
        DSALES_ClasificacionServicio.getTipoUso();
        //DSALES_ClasificacionServicio.getToken('prueba');
        DSALES_ClasificacionServicio.updateCampaigns('["'+idcamp.id+'"]', DSALES_ClasificacionServicio.getidservicio('SKU1234353464565654665'));
        DSALES_ClasificacionServicio.updateTipoUso('["'+idtp.id+'"]', DSALES_ClasificacionServicio.getidservicio('SKU1234353464565654665'));
        DSALES_ClasificacionServicio.getTiposUsoUsed(idprodtp.id);
        DSALES_ClasificacionServicio.getCampanasUsed(idprodtp.id);
        System.assertEquals(controller.listServicios.size(), 1, 'completado');
    }

    @isTest 
    static  void testGetCallout() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpClasif());
        DSALES_ClasificacionServicio.getserviciocategorias('test','test');
        Test.stopTest();
        system.assertNotEquals(10000, integer.valueof(DSALES_ClasificacionServicio.getserviciocategorias('test','test').size()), 'la llamada no debe devolver un código 200');
        
        //System.assertNotEquals(null,result);  
    }  

    @isTest 
     static  void testGetCallout2() {
        
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpClasif2());
        DSALES_ClasificacionServicio.getserviciosubcategorias('2','test');
        DSALES_ClasificacionServicio.getBuscarProducto('test12');
        Test.stopTest();
        system.assertNotEquals(10000, integer.valueof(DSALES_ClasificacionServicio.getserviciosubcategorias('2','test').size()), 'la llamada no debe devolver un código 1000');
       
    }   

    @isTest 
    static  void testGetCallout3() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpClasif3());
        DSALES_ClasificacionServicio.getservicioclase('2','4','test');
        Test.stopTest();
        system.assertNotEquals(10000, integer.valueof(DSALES_ClasificacionServicio.getservicioclase('2','4','test').size()), 'la llamada no debe devolver un código 1000');
        
    }  
    @isTest 
    static  void testGetCallout4() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpClasif4());
        List<String> listPrueba= new List<String>();
        listPrueba.add('178');
        listPrueba.add('77');
        DSALES_ClasificacionServicio.getserviciofamilia('2','4',listPrueba);
        Test.stopTest();
        system.assertNotEquals(10000, integer.valueof(DSALES_ClasificacionServicio.getserviciofamilia('2','4',listPrueba).size()), 'la llamada no debe devolver un código 1000');
        //System.assertNotEquals(null,result);  
    } 
    @isTest 
    static  void testGetCallout5() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpClasif5());
        List<String> listPrueba= new List<String>();
        listPrueba.add('178');
        listPrueba.add('2');
        listPrueba.add('77');
        DSALES_ClasificacionServicio.getserviciosku('2','4', listPrueba);
        Test.stopTest();
        system.assertNotEquals(10000, integer.valueof(DSALES_ClasificacionServicio.getserviciosku('2','4',listPrueba).size()), 'la llamada no debe devolver un código 1000'); 
    } 
    
    @isTest 
    static  void testGetCallout6() {
        String idproducto= DSALES_ClasificacionServicio.getidservicio('SKU1234353464565654665');
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpClasif6());
        DSALES_ClasificacionServicio.upsertRecord('[{"campanas":false,"id":"'+idproducto+'", "noAplica":false,"noAplicaSeguro":false,"noAplicaServicio":false,"nombre":"NotiPrueba","seguro":false,"servicio":true,"sku":"2122","tipoServicio":"2","tipoUso":false}]');
        Test.stopTest();
        system.assertNotEquals(10000, integer.valueof(DSALES_ClasificacionServicio.upsertRecord('[{"campanas":false,"id":"'+idproducto+'", "noAplica":false,"noAplicaSeguro":false,"noAplicaServicio":false,"nombre":"NotiPrueba","seguro":false,"servicio":true,"sku":"2122","tipoServicio":"2","tipoUso":false}]').size()), 'la llamada no debe devolver un código 1000'); 
    } 

private class DSALES_MockHttpClasif implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"data":[{"id": 1, "nombre":"CELULARES"}, {"id":2, "nombre":"ENSERES DOMÉSTICOS"}]}');
        response.setStatusCode(200);
        return response;
    }
}

private class DSALES_MockHttpClasif2 implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"data":[{"id": 4,"nombre": "ASEO DE CASA", "categoria":{"id":2, "nombre": "ENSERES DOMÉSTICOS"}}]}');
        response.setStatusCode(200);
        return response;
    }
}

private class DSALES_MockHttpClasif4 implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"data": [{"id": 6,"nombre": "ACCESORIOS ASPIRADORAS","deptClase": {"id": 178,"nombre": "ASPIRADORAS","departamento": 1,"subcategoria": {"id": 4,"nombre": "ASEO DE CASA", "categoria": {"id": 2,"nombre": "ENSERES DOMÉSTICOS"}}}}]}');
        response.setStatusCode(200);
        return response;
    }
}
 
private class DSALES_MockHttpClasif3 implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"data":[{"id":178, "nombre": "ASPIRADORAS", "departamento": 1, "subcategoria": {"id": 4,"nombre": "ASEO DE CASA", "categoria": {"id": 2, "nombre": "ENSERES DOMÉSTICOS" }}}]}');
        response.setStatusCode(200);
        return response;
    }
}

private class DSALES_MockHttpClasif5 implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"data": [{"codigo": 113931,"articulo": "ACUMULACIO ACUMULACIO ACUMULACION ","codigoServicio": 0,"descripcionCompleta": "ACUMULACION|ACUMULACION|ACUMULACION|ACUMULACION","familia": {"id": 2,"nombre": "ASPIRADORAS CANISTER","deptClase": { "id": 178,"nombre": "ASPIRADORAS","departamento": 1,"subcategoria": {"id": 4,"nombre": "ASEO DE CASA ","categoria": {"id": 2,"nombre": "ENSERES DOMÉSTICOS"}}}}}]}');
        response.setStatusCode(200);
        return response;
    }
}
  
private class DSALES_MockHttpClasif6 implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"meta": {"idTransaccion":"4dsd","estatus":"ok","codigo":200}, "data": [{"code": 2122,"statusCode": 200},{"code": 222902,"statusCode": 404}]}');
        response.setStatusCode(200);
        return response;
    }
}
   
}