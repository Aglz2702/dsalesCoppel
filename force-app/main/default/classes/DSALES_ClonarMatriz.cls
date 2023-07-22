public without sharing class DSALES_ClonarMatriz {
    
private static final String OBJETO_PADRE = 'DSales_Matriz_GEX__c';
private static final String OBJETO_HIJO = 'DSALES_Matriz_de_Cotizacion__c';
    private static final String TEXT_CLON = ' - Clon';

public static List<String> getField(String objName){
    List<String> listCampos = new List<String>();
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
    for(Schema.SObjectField sField : fieldMap.Values()){
        schema.describefieldresult field = sField.getDescribe();
        listCampos.add(field.getName());    
    }
    return listCampos;
}

@AuraEnabled
public static DSales_Matriz_GEX__c getClone(String recordId) {
    return DSALES_ControladorMatrizTiempo.getClone(recordId);
}

@AuraEnabled
public static String clonarMatriz(String recordId){       
    List<String> listaCampo = getField(OBJETO_PADRE);
    String query = 'Select ';
    for(Integer i = 0; i < listaCampo.size(); i++){
        query += listaCampo[i]+',';  
    }
    
    query = query.substring(0, query.length()-1);
    query += ' From DSales_Matriz_GEX__c WHERE Id =: recordId'; 
    DSales_Matriz_GEX__c matrizClone = Database.query(String.escapeSingleQuotes(query));
    matrizClone.Id = null;
    matrizClone.DSALES_EsClone__c = true;
    matrizClone.DSALES_CloneMatriz__c = recordId;
    matrizClone.Name += TEXT_CLON;
    matrizClone.DSALES_Activo__c = false;
    if(Schema.sObjectType.DSales_Matriz_GEX__c.isCreateable()){
        insert matrizClone;           
        }
        else{            
        System.debug('Permisos insuficientes para insertar');           
        }
    DSales_Matriz_GEX__c matrizOriginal = new DSales_Matriz_GEX__c(Id=recordId, DSALES_CloneMatriz__c = matrizClone.Id);
    if (DSales_Matriz_GEX__c.SObjectType.getDescribe().isUpdateable()) {
        update matrizOriginal;
            } 
                        else {
            System.debug('Permisos insuficientes para actualizar');
            }
    
    return matrizClone.Id;
}
    
@AuraEnabled
public static String actualizarMatrizOriginal(Id recordId){       
    List<String> listaCampo = getField(OBJETO_PADRE);
    String query = 'Select ';
    for(Integer i = 0; i < listaCampo.size(); i++){
        query += listaCampo[i]+',';  
    }
    
    query = query.substring(0, query.length()-1);
    query += ' From DSales_Matriz_GEX__c WHERE Id =: recordId'; 
    DSales_Matriz_GEX__c matrizClone = Database.query(query);
    matrizClone.Id = matrizClone.DSALES_CloneMatriz__c;
    matrizClone.DSALES_EsClone__c = false;
    matrizClone.DSALES_CloneMatriz__c = recordId;
    matrizClone.Name = matrizClone.Name.replace(TEXT_CLON, '');
    matrizClone.DSALES_Activo__c = true;
    update matrizClone;
    clonarMatrizItem(matrizClone.Id,recordId);
    return matrizClone.Id;
    
}

public static void clonarMatrizItem(Id originalId, Id recordId){       
    List<String> listaCampo = getField(OBJETO_HIJO);
    String query = 'Select ';
    for(Integer i = 0; i < listaCampo.size(); i++){
        query += listaCampo[i]+',';  
    }
    
    query = query.substring(0, query.length()-1);
    DSales_Matriz_GEX__c ds = new DSales_Matriz_GEX__c();
    query += ' From DSALES_Matriz_de_Cotizacion__c WHERE DSales_Matriz_GEX__c =: recordId'; 
    List <DSALES_Matriz_de_Cotizacion__c> listMatrizItem = Database.query(query);
    for(DSALES_Matriz_de_Cotizacion__c matrizItem:listMatrizItem )	{
        matrizItem.DSALES_MatrizItemClone__c=matrizItem.Id;
        matrizItem.Id=null;
        matrizItem.DSales_Matriz_GEX__c=originalId;
        matrizItem.Name='';
    }
    if(Schema.sObjectType.DSALES_Matriz_de_Cotizacion__c.isCreateable() || Schema.sObjectType.DSALES_Matriz_de_Cotizacion__c.isUpdateable()){
    system.debug('NAME: '+ listMatrizItem);
        Database.upsert(listMatrizItem,DSALES_Matriz_de_Cotizacion__c.DSALES_MatrizItemClone__c);  
    compararEliminados(originalId,recordId);
        } 
        else {
        System.debug('Insufficient permissions to update');
        }
    
}

public static void compararEliminados(Id original, Id clone){
    Map<String,DSALES_Matriz_de_Cotizacion__c> mapOriginal= new Map<String,DSALES_Matriz_de_Cotizacion__c>();
    Map<String,DSALES_Matriz_de_Cotizacion__c> mapClone= new Map<String,DSALES_Matriz_de_Cotizacion__c>();
    List<DSALES_Matriz_de_Cotizacion__c> listaARemover = new List<DSALES_Matriz_de_Cotizacion__c>();
    for(DSALES_Matriz_de_Cotizacion__c item:[SELECT id,DSALES_MatrizItemClone__c From DSALES_Matriz_de_Cotizacion__c WHERE DSales_Matriz_GEX__c =: original]){
        mapOriginal.put(item.DSALES_MatrizItemClone__c,item);
    }
    
    for(DSALES_Matriz_de_Cotizacion__c item:[SELECT id,DSales_Matriz_GEX__c From DSALES_Matriz_de_Cotizacion__c WHERE DSales_Matriz_GEX__c =: clone]){
        mapClone.put(item.Id,item);
    }
    for( String item:mapOriginal.keySet()){
        if(!mapClone.containsKey(item)){
            listaARemover.add(mapOriginal.get(item));
        }      
    }
    if(DSALES_Matriz_de_Cotizacion__c.sObjectType.getDescribe().isDeletable()){
        delete listaARemover;
            } 
            else {
            System.debug('Permisos insuficientes para borrar');
            }
}

}