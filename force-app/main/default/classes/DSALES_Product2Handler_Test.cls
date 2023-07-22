@isTest
public with sharing class DSALES_Product2Handler_Test {
    @TestSetup
    static void configuracionRegistro(){
        Product2 producto = new Product2();
        producto.Name = 'test';
        producto.StockKeepingUnit = '123456';
        producto.DSales_Tipo_de_Producto__c= 'Producto';
        producto.IsActive=true;
        insert producto;
        

    }
    @isTest
    static void product2HandlerTest() {

        Product2 producto = new Product2();
        producto.Name = 'testNuevo';
        producto.StockKeepingUnit = '123457';
        producto.DSales_Tipo_de_Producto__c= 'Producto';
        producto.IsActive=true;
        insert producto;
        List<Product2> newList= new List<Product2>();
        newList.add(producto);
        DSALES_Product2Helper.actualizarSkusNuevos(newList);
       Product2 testActualizacion= [Select id, StockKeepingUnit from product2 where Name= 'test'];
       Product2 testActualizacion2= [Select id, StockKeepingUnit from product2 where Name= 'testNuevo'];
    }
}