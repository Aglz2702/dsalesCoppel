@isTest
public class DSALES_MatrizHelperTest {
    @isTest
    public static void testCrearClon() {
        List<DSales_Matriz_GEX__c> registros = new List<DSales_Matriz_GEX__c>();

        Test.startTest();
        DSALES_MatrizHelper.crearClon(registros);
        Test.stopTest();
    }
}