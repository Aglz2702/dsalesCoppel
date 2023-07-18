public class DSALES_Matriz extends fflib_SObjectDomain{
    
    
    public DSALES_Matriz(List<DSales_Matriz_GEX__c> sObjectList){
    //public salesMatriz(List<DSales_Matriz_GEX__c> sObjectList){
        Super(sObjectList);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<Sobject> sObjectList){
        //public fflib_SObjectDomain constructMatriz(List<Sobject> sObjectList){
            return new DSALES_Matriz(sObjectList);
            //return new salesMatriz(sObjectList);
        }
        
    }
    /*
    
    public override void onAfterInsert() {
        DSALES_MatrizHelper.crearClon(records);
    }
*/
}