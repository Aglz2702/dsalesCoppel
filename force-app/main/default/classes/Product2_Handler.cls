public class Product2_Handler extends fflib_SObjectDomain {
     public Product2_Handler(List<Product2> sObjectList){
        Super(sObjectList);    
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<Sobject> sObjectList){
            return new Product2_Handler(sObjectList);
        }
    }

    public override void onBeforeInsert() {
            Set<String> valores = new Set<String>();
            List<Product2> records= Trigger.new;
            for (Product2 obj : records) {
                valores.add(obj.StockKeepingUnit);
            }
            List<Product2> registrosExistentes = [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :valores];
            List<Product2> registroActualizados= new List<Product2>();
            for (Product2 obj : registrosExistentes)
            {
                Product2 registroExistente = obj;
                registroExistente.DSales_SKU_anterior__c = obj.StockKeepingUnit;
                registroExistente.StockKeepingUnit = '';
                registroExistente.IsActive=false;
                registroActualizados.add(registroExistente);
            }
            update registroActualizados; 
    }

}