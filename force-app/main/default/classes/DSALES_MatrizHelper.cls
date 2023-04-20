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
public class DSALES_MatrizHelper {
    public static void crearClon(List<DSales_Matriz_GEX__c> records){
        for(DSales_Matriz_GEX__c item: records){
            if(!item.DSALES_EsClone__c){
                DSALES_ClonarMatriz.clonarMatriz(item.Id);
            }
        }
    }
}