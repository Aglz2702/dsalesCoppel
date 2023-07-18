@isTest
public class DSALES_ListaNegraWrapperTest {
    @isTest 
    static void wrapperTestWS(){
        DSALES_ListaNegraWrapper.responseListaNegra op = new DSALES_ListaNegraWrapper.responseListaNegra();
		DSALES_ListaNegraWrapper.enviarListaNegra op2 = new DSALES_ListaNegraWrapper.enviarListaNegra(); 
        //op.estatus='Autorizado';
        Test.startTest();
        op.estatus=true;
        op.nombreContribuyente='JUan';
        op.ok='ok';
        op.rfc='ASFAA';
        op2.nombre='ok';
        op2.rfc='GFASfas';
        Boolean expectedValue = false; // valor esperado
        Boolean actualValue = op.estatus; // valor actual
        System.assertNotEquals(expectedValue, actualValue, 'Los valores no deben ser iguales');
        Test.stopTest();
    }
}