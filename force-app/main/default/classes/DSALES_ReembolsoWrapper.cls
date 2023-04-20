/**
 * @description       : Test class for PaymentInfoWrapperGex
 * @author            : 
 * @group             : 
 * @last modified on  : 04-18-2023
 * @last modified by  : Juan Antonio Flores
 * Modifications Log 
 * Ver   Date          Author             Modification 
 * 1.0   04-18-2023                       Initial Version
**/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_ReembolsoWrapper {

    global class ReembolsoRequest {
        //global String pago_universal {get;set;}
        global String comentarios {get;set;}
        global date fechaReembolso {get;set;}
        global String nombreProducto {get;set;}
        global String numeroCancelacion {get;set;}
        //Efectivo/Tarjeta
        global String metodoPago {get;set;}
        global String numeroReferencia {get;set;}
        global double cantidadReembolsada {get;set;}    
    }  

    global class Reembolso {
        global list<ReembolsoRequest> reembolsos {get;set;}
    }

    global class ReembolsoResponse {
        global List<String> idReembolsos {get;set;}
        global Boolean exito {get;set;}
        global String codigoError {get;set;}
        global String mensajeError {get;set;}    
    }
}