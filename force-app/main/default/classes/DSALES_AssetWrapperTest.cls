@isTest
public with sharing class DSALES_AssetWrapperTest {
    
    @testSetup
    static void crearRegistros(){
        DSALES_Categoria__c categoria = new DSALES_Categoria__c(Name='LÍNEA BLANCA');
        insert categoria;
        DSALES_SubCategoria__c subcategoria = new DSALES_SubCategoria__c(Name='ARTICULOS VIANA LINEA BLANCA');
        insert subcategoria;
        DSALES_Familia__c familia = new DSALES_Familia__c(Name='TEST FAMILIA');
        insert familia;
        DSALES_Clase__c clase = new DSALES_Clase__c(Name='01 • AMPLIFICADORES CAR AUDIO');
        insert clase;
        Account cuentas= new Account(Name='DannyTest',CP_WalletCustomerNumber__c=123456);  
        insert cuentas;
        
    }
    
    @isTest static void crearRegistroTest()
    {
        Account cuenta=[SELECT CP_WalletCustomerNumber__c FROM ACCOUNT WHERE NAME='DannyTest' LIMIT 1];
        Contact contacto = new Contact(lastname= 'Test1', AccountId= cuenta.Id, Email= 'johndoeus@salesforce.com');
        insert contacto;
        RestRequest peticion=new RestRequest();
        RestResponse respuesta = new RestResponse();
        String cuerpo = '{"name":"Prueba DannyTest", "account_id":"'+cuenta.Id+'", "contact_id":"'+contacto.Id+'", "client_number":"123456", "product_type":"Producto","service_type ":"Garantía Extendida","category":"LÍNEA BLANCA","subcategory" :"ARTICULOS VIANA LINEA BLANCA","class_type" :"01 • AMPLIFICADORES CAR AUDIO","family" :"TEST FAMILIA","status" :"Cancelado","region" :"1 • HERMOSILLO","division" :"1","sku" :"DannyTest","warranty_duration" :"12","serial_number" :"DannyTest","purchase_date" :"2022-09-06","quantity":"1","price" :"12"}';
        peticion.requestURI='/apexrest/insertAsset'; 
        peticion.httpMethod='POST';
        RestContext.request=peticion;
        peticion.requestBody=Blob.valueOf(cuerpo);
        RestContext.response=respuesta;
        DSALES_AssetWrapper.AssetRequest assetRegistro =  (DSALES_AssetWrapper.AssetRequest)JSON.deserialize (cuerpo,DSALES_AssetWrapper.AssetRequest.class);       
        assetRegistro.numeroCliente=String.ValueOf(cuenta.CP_WalletCustomerNumber__c);
        Test.startTest();
        DSALES_AssetWrapperRequest.crearAsset();
        Test.stopTest();
        RestContext.request = peticion;
        RestContext.response= respuesta;
        System.assertNotEquals(200, respuesta.statusCode,'La llamada no debe devolver el código 200');
        
    }
    @isTest static void crearRegistroTest1()
    {          
        Account cuenta=[SELECT Id, Name, CP_WalletCustomerNumber__c FROM ACCOUNT WHERE NAME='DannyTest' LIMIT 1];  
        Contact contacto = new Contact(lastname= 'Test', AccountId= cuenta.Id, Email= 'johndoeus@salesforce.com');
        insert contacto;
        
        RestRequest peticion=new RestRequest();
        RestResponse respuesta = new RestResponse();
        String cuerpo = '{"nombre":"Prueba DannyTest","id_cuenta":"'+cuenta.Id+'", "id_contacto":"'+contacto.Id+'", "numero_cliente":"1234567", "tipo_producto":"Servicio","tipo_servicio ":"Garantía Extendida","categoria":"LÍNEA BLANCA","subcategoria" :"ARTICULOS VIANA LINEA BLANCA","clase" :"01 • AMPLIFICADORES CAR AUDIO","familia" :"TEST FAMILIA","estado" :"Adquirido","sku" :"658019","duracion_garantia" :"12","numero_serie" :"658019","fecha_compra" :"2022-09-07","cantidad":"1","marca" :"Samsung", "modelo": "2010","descripcion":"Muy cómodo"}';
        peticion.requestURI='/apexrest/insertAsset'; 
        peticion.httpMethod='POST';
        RestContext.request=peticion;
        peticion.requestBody=Blob.valueOf(cuerpo);
        RestContext.response=respuesta;
        DSALES_AssetWrapper.AssetRequest assetRegistro =  (DSALES_AssetWrapper.AssetRequest)JSON.deserialize (cuerpo,DSALES_AssetWrapper.AssetRequest.class);
        assetRegistro.numeroCliente=String.ValueOf(cuenta.CP_WalletCustomerNumber__c);
        Test.startTest();
        DSALES_AssetWrapperRequest.crearAsset();
        Test.stopTest();
        RestContext.request = peticion;
        RestContext.response= respuesta;
        System.assertNotEquals(200, respuesta.statusCode,'La llamada no debe devolver el código 200');
        
    }
    
}