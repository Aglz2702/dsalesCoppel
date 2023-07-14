public with sharing class DSALES_Product2Handler extends fflib_SObjectDomain {
    public DSALES_Product2Handler(List<Product2> sObjectList){
        Super(sObjectList);
        
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<Sobject> sObjectList){
            return new DSALES_Product2Handler(sObjectList);
        }
    }

    public override void onBeforeInsert() {
         DSALES_Product2Helper.actualizarSkusNuevos(records);
    System.debug(records);
    }
}