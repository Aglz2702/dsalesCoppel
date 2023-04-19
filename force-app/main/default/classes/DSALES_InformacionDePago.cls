public class DSALES_InformacionDePago extends fflib_SObjectDomain{

    public DSALES_InformacionDePago(List<DSALES_InformacionDePago__c> sObjectList){
        Super(sObjectList);
        
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<Sobject> sObjectList){
            return new DSALES_InformacionDePago(sObjectList);
        }
    }

    
    public override void onAfterInsert() {
        DSALES_InformacionPagoHandler.cambiaClienteCautivo(records);
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        DSALES_InformacionPagoHandler.cambiaClienteCautivo( records);
    }
    
    
    
}