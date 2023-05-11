@isTest
public class DSALES_ClasificacionServicio_Test {
   
    @testSetup
    static void testSetup(){
        String recordTypeId = Schema.SObjectType.DSALES_Categoria__c.getRecordTypeInfosByDeveloperName().get('dsalesServicios').getRecordTypeId();
        DSALES_Categoria__c categoria = new DSALES_Categoria__c();
        categoria.Name = 'Test';
        categoria.RecordTypeId=recordTypeId;
        insert categoria;
        
        DSALES_SubCategoria__c subC = new DSALES_SubCategoria__c ();
        subC.Name = 'Test';
        subC.DSALES_Categoria__c = categoria.Id;
        insert subC;
        
        DSALES_Clase__c clase = new DSALES_Clase__c();
        clase.Name = 'Test';
        clase.DSALES_SubCategoria__c = subC.Id;
        insert clase;
        
        DSALES_Familia__c familia = new DSALES_Familia__c();
        familia.DSALES_Clase__c = clase.Id;
        familia.Name = 'Test';
        insert familia;
          
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
        objetoserv.isActive=true;
        insert objetoserv;
        
        DSales_Asignacion_de_Productos__c asignacionprod = new DSales_Asignacion_de_Productos__c();
        asignacionprod.Name='Test';
        asignacionprod.DSales_Servicio_Seguro__c= producto.Id;
        asignacionprod.DSales_Producto__c=objetoserv.Id;
        asignacionprod.DSALES_Activo__c=true;
        insert asignacionprod;
        
        Campaign camp = new Campaign();
        camp.Name = 'TestCampaing';
        insert camp;
        
        dsalesTipoUso__c tp = new dsalesTipoUso__c();
        tp.Name = 'TestTipoUso';
        insert tp;
        
    }

    @isTest
    static void clasificacionServicio(){
        Product2 idprueba= [Select id from Product2 limit 1];
        DSALES_Categoria__c idcat = [select id from DSALES_Categoria__c limit 1];
        DSALES_SubCategoria__c idsubc= [select id from DSALES_SubCategoria__c limit 1];
        DSALES_Clase__c idclass=  [select id from DSALES_Clase__c limit 1];
        DSales_Matriz_GEX__c idmat= [select id from DSales_Matriz_GEX__c limit 1];
        Campaign idcamp = [Select id from Campaign limit 1];
        dsalesTipoUso__c idtp = [Select id from dsalesTipoUso__c limit 1];
        DSALES_ClasificacionServicio.DSALES_ClasificacionServicioWrapper controller = DSALES_ClasificacionServicio.getPickListCategoria();
        controller.listCategorias[0].seleccionado = true;
        
        controller = DSALES_ClasificacionServicio.getPicklistOptionsDependent(JSON.serialize(controller));
        controller.listSubCategorias[0].seleccionado = true;
        
        controller = DSALES_ClasificacionServicio.getPicklistOptionsDependent(JSON.serialize(controller));
        controller.listClases[0].seleccionado = true;
        
        controller = DSALES_ClasificacionServicio.getPicklistOptionsDependent(JSON.serialize(controller));
        controller.listFamilias[0].seleccionado = true;
        
        controller = DSALES_ClasificacionServicio.getRecords(JSON.serialize(controller), 'Administrador del sistema', 'Opcion2');
        //DSALES_ClasificacionServicio.upsertRecord(JSON.serialize(controller));
        
        controller.sku = 'SKU1234353464565654665';
        controller.listServicios = DSALES_ClasificacionServicio.getBuscarSKU(controller.sku);
        DSALES_ClasificacionServicio.getBuscarVinculacion(DSALES_ClasificacionServicio.getidservicio('SKU12346VG'));
        DSALES_ClasificacionServicio.getBuscarProducto(DSALES_ClasificacionServicio.getidservicio('SKU1234353464565654665'));
        DSALES_ClasificacionServicio.upsertVinculacion(JSON.serialize( DSALES_ClasificacionServicio.getBuscarVinculacion(DSALES_ClasificacionServicio.getidservicio('SKU12346VG'))));
        DSALES_ClasificacionServicio.insertVinculacion(JSON.serialize( DSALES_ClasificacionServicio.getBuscarProducto(DSALES_ClasificacionServicio.getidservicio('SKU12346VG'))), DSALES_ClasificacionServicio.getidservicio('SKU12346VG'));
        DSALES_ClasificacionServicio.checkProfileType('Administrador GEX');
        DSALES_ClasificacionServicio.getcategories('Garantía Extendida');
        DSALES_ClasificacionServicio.getSubCategories(idcat.id);
        DSALES_ClasificacionServicio.getClases(idsubc.id);
        DSALES_ClasificacionServicio.getFamilias(idclass.id);
        DSALES_ClasificacionServicio.getMatriz();
        DSALES_ClasificacionServicio.RecordTypeId('Garantía Extendida');
        DSALES_ClasificacionServicio.updateMatriz( '["'+idmat.id+'"]', DSALES_ClasificacionServicio.getidservicio('SKU12346VG'));
        DSALES_ClasificacionServicio.insertPocentajeCobro(DSALES_ClasificacionServicio.getidservicio('SKU12346VG'),'{"anio1":"6","anio2":"5","anio3":"9","anio4":3,"anio5":2,"anio6":1}');
        DSALES_ClasificacionServicio.getPickListValuesIntoList1();
        DSALES_ClasificacionServicio.getPickListValuesIntoList2();
        DSALES_ClasificacionServicio.getPickListValuesIntoList3();
        DSALES_ClasificacionServicio.getPickListValuesIntoList4();
        DSALES_ClasificacionServicio.getCampaings();
        DSALES_ClasificacionServicio.getTipoUso();
        DSALES_ClasificacionServicio.updateCampaigns('["'+idcamp.id+'"]', DSALES_ClasificacionServicio.getidservicio('SKU1234353464565654665'));
        DSALES_ClasificacionServicio.updateTipoUso('["'+idtp.id+'"]', DSALES_ClasificacionServicio.getidservicio('SKU1234353464565654665'));
        System.assertEquals(controller.listServicios.size(), 1, 'completado');
    }

    @isTest 
    static  void testGetCallout() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpClasif());
        DSALES_ClasificacionServicio.getserviciocategorias('test');
        Test.stopTest();
        system.assertNotEquals(10000, integer.valueof(DSALES_ClasificacionServicio.getserviciocategorias('test').size()), 'la llamada no debe devolver un código 200');
        
        //System.assertNotEquals(null,result);  
    }   

    @isTest 
    static  void testGetCallout2() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpClasif2());
        DSALES_ClasificacionServicio.getserviciosubcategorias('2');
        Test.stopTest();
        system.assertNotEquals(10000, integer.valueof(DSALES_ClasificacionServicio.getserviciosubcategorias('2').size()), 'la llamada no debe devolver un código 1000');
    }   

    @isTest 
    static  void testGetCallout3() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpClasif3());
        DSALES_ClasificacionServicio.getservicioclase('2','4');
        Test.stopTest();
        system.assertNotEquals(10000, integer.valueof(DSALES_ClasificacionServicio.getservicioclase('2','4').size()), 'la llamada no debe devolver un código 1000');
        
    }  
    @isTest 
    static  void testGetCallout4() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpClasif4());
        DSALES_ClasificacionServicio.getserviciofamilia('2','4','178');
        Test.stopTest();
        system.assertNotEquals(10000, integer.valueof(DSALES_ClasificacionServicio.getserviciofamilia('2','4','178').size()), 'la llamada no debe devolver un código 1000');
        //System.assertNotEquals(null,result);  
    } 
    @isTest 
    static  void testGetCallout5() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpClasif5());
        DSALES_ClasificacionServicio.getserviciosku('2','4','{178,2}');
        Test.stopTest();
        system.assertNotEquals(10000, integer.valueof(DSALES_ClasificacionServicio.getserviciosku('2','4',(178, 2)).size()), 'la llamada no debe devolver un código 1000'); 
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
        response.setBody('{"data": [{"code": 2122,"statusCode": 200},{"code": 222902,"statusCode": 404}]}');
        response.setStatusCode(200);
        return response;
    }
}
   
}