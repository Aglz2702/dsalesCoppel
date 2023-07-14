public with sharing class DSales_Product2Helper {
    
    public static void actualizarSkusNuevos( List<Product2> records){
        
    
    Set<String> valores = new Set<String>();
   // List<Product2> records= Trigger.new;
    for (Product2 obj : records) {
        valores.add(obj.StockKeepingUnit);
    }
    List<Product2> registrosExistentes = [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :valores WITH SECURITY_ENFORCED];
    List<Product2> registroActualizados= new List<Product2>();
    for (Product2 obj : registrosExistentes)
    {
        Product2 registroExistente = obj;
        registroExistente.DSales_SKU_anterior__c = obj.StockKeepingUnit;
        registroExistente.StockKeepingUnit = '';
        registroExistente.IsActive=false;
        registroActualizados.add(registroExistente);
    }
    if(Product2.SObjectType.getDescribe().isUpdateable()) {
        update registroActualizados;   
    }
}
}