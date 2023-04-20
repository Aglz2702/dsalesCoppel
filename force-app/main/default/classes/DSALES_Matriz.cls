/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 04-18-2023
 * @last modified by  : Juan Antonio Flores
 * Modifications Log 
 * Ver   Date          Author             Modification 
 * 1.0   04-18-2023                       Initial Version
**/
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
    
    public override void onAfterInsert() {
        DSALES_MatrizHelper.crearClon(records);
    }
}