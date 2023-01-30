@isTest
public with sharing class DSALES_QuotePagoSmTest {
    @TestSetup
    static void makeData(){
        Account acc = new Account();
        acc.Name='testL';
        acc.BillingCity = 'test';
        acc.BillingStreet = 'calle 3 test';
        acc.BillingState = 'CDMX';
        acc.BillingPostalCode = '666666';
        acc.BillingCountry='México';
        insert acc;
        String recordTypeId = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_PagosdeVentaenNPVSM_c').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.Name = 'testL';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Nuevo';
        insert opp;
        
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  'CPPL-UGARTE';
        insert t;

        Quote cotizacion = new Quote();
        cotizacion.OpportunityId=opp.Id;
        cotizacion.Name='Test';
        cotizacion.DSALES_Fechadenacimiento__c='2022/01/01';
        cotizacion.Email='pruebas@inv.com';
        cotizacion.DSALES_Cobertura__c='A';
        cotizacion.DSALES_Opcindepago__c='Mensual';
        cotizacion.DSALES_Gnero__c='F';
        cotizacion.Phone='9564562123';
        cotizacion.DSALES_Cdigopostal__c=12;
        cotizacion.DSALES_Fechadecomienzodepliza__c=beforeCot.DSALES_Fechadecomienzodepliza__c;
        cotizacion.Lista_negra__c=beforeCot.Lista_negra__c;
        cotizacion.Motivo_de_lista_negra__c=beforeCot.Motivo_de_lista_negra__c;
        cotizacion.DSALES_TrakingID__c=beforeCot.DSALES_TrakingID__c;
        cotizacion.DSales_Vendedor__c=pago.DSALES_Nombre_del_Vendedor__c;
        cotizacion.DSales_Vendedor__c=beforeCot.DSales_Vendedor__c;
        cotizacion.DSales_Tienda__c=pago.DSales_Tienda__c;
        cotizacion.DSales_Tienda__c=beforeCot.DSales_Tienda__c;
        cotizacion.Tax=beforeCot.Tax;
        cotizacion.DSALES_IDdelvehculo__c=beforeCot.DSALES_IDdelvehculo__c;
        cotizacion.DSALES_Plazoacotizar__c=pago.DSALES_Plazodecomprademoto__c;
        cotizacion.DSALES_PlazoacotizarRC__c=beforeCot.DSALES_PlazoacotizarRC__c;
        cotizacion.DSALES_Tipodeuso__c=beforeCot.DSALES_Tipodeuso__c;
        cotizacion.DSALES_RFC__c=beforeCot.DSALES_RFC__c;
        cotizacion.DSALES_TipoUso__c=beforeCot.DSALES_TipoUso__c;
        cotizacion.DSALES_Tipodeveihculo__c=beforeCot.DSALES_Tipodeveihculo__c;
        insert cotizacion;
    }
    
}