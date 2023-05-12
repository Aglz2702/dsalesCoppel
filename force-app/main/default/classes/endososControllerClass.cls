public with sharing class endososControllerClass {
    
    @AuraEnabled(cacheable= true)
    public static Map<Id, string> endosoDocuments (string tipoDeEndoso){
        try{
            List<Tipo_de_endoso__mdt> endoso = [SELECT Id, MasterLabel, Tipo_de_endoso__c, ClaimType__c from Tipo_de_endoso__mdt where Tipo_de_endoso__c=:tipoDeEndoso WITH SECURITY_ENFORCED];
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
    
    @AuraEnabled(cacheable=false)
    public static List<String> fetchFiles(String recordId){
        List<String> docsName = new List<String>();

        for (ContentDocumentLink docs : [SELECT LinkedEntityId, ContentDocument.CreatedDate, ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.FileType 
                                          FROM ContentDocumentLink  
                                          WHERE LinkedEntityId  =:recordId WITH SECURITY_ENFORCED]){
         if (docs.ContentDocument.ContentSize > 400000) {

            docsName.add(docs.ContentDocument.Title);
         }
         
        }
        System.debug(docsName);
        return docsName;

    }
}