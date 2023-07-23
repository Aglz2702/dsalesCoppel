@isTest
public class DSALES_ClonarMatriz_Test {
   
    @testSetup
    static void testSetup(){
        DSales_Matriz_GEX__c temporal = new DSales_Matriz_GEX__c();
        temporal.Name = 'Temporal';
        temporal.DSALES_Tiempogex__c='1 año';
        insert temporal;

        DSales_Matriz_GEX__c temporal2 = new DSales_Matriz_GEX__c();
        temporal2.Name = 'Temporal2';
        temporal2.DSALES_Tiempogex__c='1 año';
        temporal2.DSALES_EsClone__c=false;
        insert temporal2;
        
        DSALES_Matriz_de_Cotizacion__c item = new DSALES_Matriz_de_Cotizacion__c();
        item.DSALES_Rango_interior_GEX__c = 12;
        item.DSALES_Rango_Superior_GEX__c = 23;
        item.DSales_Matriz_GEX__c = temporal.Id;
        insert item;    
    }
    
    @isTest
    static void clonarMatriz(){
        DSales_Matriz_GEX__c tempo =[SELECT Name, Id FROM DSales_Matriz_GEX__c where Name = 'Temporal' LIMIT 1];
        DSALES_ClonarMatriz.getClone(tempo.Id);
        String idClon = DSALES_ClonarMatriz.clonarMatriz(tempo.Id);
        DSALES_Matriz_de_Cotizacion__c item = new DSALES_Matriz_de_Cotizacion__c();
        item.DSALES_Rango_interior_GEX__c = 12;
        item.DSALES_Rango_Superior_GEX__c = 23;
        item.DSales_Matriz_GEX__c = idClon;
        insert item;
       	String idOriginal = DSALES_ClonarMatriz.actualizarMatrizOriginal(idClon);
        System.assertEquals(idOriginal, tempo.Id, 'la identificación es la misma');
    }

   /* @isTest
    static void DSALES_MatrizHelperTest(){
        DSales_Matriz_GEX__c tempo =[SELECT Name, Id, DSALES_EsClone__c FROM DSales_Matriz_GEX__c where Name = 'Temporal2' LIMIT 1];
        List<DSales_Matriz_GEX__c> records = new List<DSales_Matriz_GEX__c>();
        records.add(tempo);
        Test.startTest();
        DSALES_MatrizHelper.crearClon(records);
        System.assertEquals(tempo.DSALES_EsClone__c, false , 'Clonarmatriz');
        Test.stopTest();
    }*/
}