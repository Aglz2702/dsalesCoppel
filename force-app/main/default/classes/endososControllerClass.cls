public with sharing class endososControllerClass {
    
    @AuraEnabled(cacheable= true)
    public static Map<Id, string> endosoDocuments (string TipoDeEndoso){
        try{
            List<Tipo_de_endoso__mdt> endoso = [SELECT Id, MasterLabel, Tipo_de_endoso__c, ClaimType__c from Tipo_de_endoso__mdt where Tipo_de_endoso__c=:TipoDeEndoso];
            Map<Id, string> doc = new Map <Id, string>();
            for(Tipo_de_endoso__mdt type: endoso){
                doc.put(type.Id, type.MasterLabel);
            }
            return doc;
            
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
}