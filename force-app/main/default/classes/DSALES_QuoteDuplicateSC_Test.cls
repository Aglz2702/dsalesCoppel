@isTest 
public with sharing class DSALES_QuoteDuplicateSC_Test {
    @testSetup
    static void setUp(){
        String tipoProducto = 'Producto';
        String message = '';
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('dsalesSeguroCelulares').getRecordTypeId();
        String recordTypeQuoteId=Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('dsalesVentaSeguroCelulares').getRecordTypeId();
        Product2 prodSc = new Product2(Name ='Seguro de Celulares',dsalesVehiculo__c='sadkncdcs',DSales_Tipo_de_Producto__c='Seguro',IsActive=true);
        insert prodSc;
        
        Product2 prodC = new Product2(Name ='Iphone 14',dsalesVehiculo__c='lasicndsldicsid',StockKeepingUnit='109876',DSales_Tipo_de_Producto__c='Producto',IsActive=true);
        insert prodC;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = prodSc.Id;
        standardPrice.UnitPrice = 1000;
        standardPrice.IsActive = true;
        insert standardPrice;
        
        
        PricebookEntry standardPriceMoto = new PricebookEntry();
        standardPriceMoto.Pricebook2Id = pricebookId;
        standardPriceMoto.Product2Id = prodC.Id;
        standardPriceMoto.UnitPrice = 1000;
        standardPriceMoto.IsActive = true;
        insert standardPriceMoto;
        
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry();
        customPrice.Pricebook2Id = customPB.Id;
        customPrice.Product2Id = prodSc.Id;
        customPrice.UnitPrice = 1200;
        customPrice.IsActive = true;
        insert customPrice;
        
        PricebookEntry customPriceMoto = new PricebookEntry();
        customPriceMoto.Pricebook2Id = customPB.Id;
        customPriceMoto.Product2Id = prodC.Id;
        customPriceMoto.UnitPrice = 2000;
        customPriceMoto.IsActive = true;
        insert customPriceMoto;
        
        
        
        Account acc = new Account();
        acc.Name='test';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.DSALES_ClienteCoppel__c='90001';
        insert acc;

        Opportunity opp = new Opportunity(Name='VENTA CELULAR', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        Opportunity opp2 = new Opportunity(Name='VENTA SEGURO', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp2;
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  'CPPL-UGARTE';
        insert t;

        Quote cotizacion = new Quote( RecordTypeId=recordTypeQuoteId,OpportunityId=opp.Id,Name='CELULAR',DSales_Tienda__c=t.Id);
        insert cotizacion;
        
        Quote cotSC = new Quote( RecordTypeId=recordTypeQuoteId,OpportunityId=opp2.Id,Name='SEGURO',DSales_Tienda__c=t.Id);
        insert cotSC;

        Plazo__c plazoSC12 = new Plazo__c();
        plazoSC12.Name='12';
        plazoSC12.dsalesSeguro__c=prodSc.Id;
        plazoSC12.Dsales_Plazo__c='12';
        plazoSC12.DSALES_Activo__c=true;
        insert plazoSC12;
        
        Plazo__c plazoSC18 = new Plazo__c();
        plazoSC18.Name='18';
        plazoSC18.dsalesSeguro__c=prodSc.Id;
        plazoSC18.Dsales_Plazo__c='18';
        plazoSC18.DSALES_Activo__c=true;
        insert plazoSC18;

        QuoteLineItem celular = new QuoteLineItem();
        celular.QuoteId = cotSC.Id;
        celular.PricebookEntryId = customPrice.Id;
        celular.Product2Id = prodC.Id;
        celular.Quantity = 1.0;
        celular.UnitPrice = customPrice.UnitPrice;
        celular.DSALES_Segurogratis__c=false;
        insert celular;

        QuoteLineItem seguroSc = new QuoteLineItem();
        seguroSc.QuoteId = cotSC.Id;
        seguroSc.PricebookEntryId = customPrice.Id;
        seguroSc.Product2Id = prodSc.Id;
        seguroSc.Quantity = 1.0;
        seguroSc.UnitPrice = customPrice.UnitPrice;
        seguroSc.DSALES_Plazo__c=plazoSC12.Id;
        seguroSc.DSALES_Segurogratis__c=false;
        insert seguroSc;

        QuoteLineItem cel = new QuoteLineItem();
        cel.QuoteId = cotizacion.Id;
        cel.PricebookEntryId = customPrice.Id;
        cel.Product2Id = prodC.Id;
        cel.Quantity = 1.0;
        cel.UnitPrice = customPrice.UnitPrice;
        cel.DSALES_Segurogratis__c=false;
        insert cel;
        QuoteLineItem seguroSc2 = new QuoteLineItem();
        seguroSc2.QuoteId = cotizacion.Id;
        seguroSc2.PricebookEntryId = customPrice.Id;
        seguroSc2.Product2Id = prodSc.Id;
        seguroSc2.Quantity = 1.0;
        seguroSc2.UnitPrice = customPrice.UnitPrice;
        seguroSc2.DSALES_Plazo__c=plazoSC12.Id;
        seguroSc2.DSALES_Segurogratis__c=false;
        insert seguroSc2;
        QuoteLineItem seguroSC18 = new QuoteLineItem();
        seguroSC18.QuoteId = cotizacion.Id;
        seguroSC18.PricebookEntryId = customPrice.Id;
        seguroSC18.Product2Id = prodSc.Id;
        seguroSC18.Quantity = 1.0;
        seguroSC18.UnitPrice = customPrice.UnitPrice;
        //seguroAmp.DSALES_Tipodeproducto__c = 'Producto';
        seguroSC18.DSALES_Plazo__c=plazoSC18.Id;
        seguroSC18.DSALES_Segurogratis__c=false;
        insert seguroSC18;
    }

    @isTest 
    public static void ventaCelularTest(){
        Quote cotizacion=[SELECT Id,DSales_Vendedor__c,OpportunityId FROM Quote WHERE Name='CELULAR' WITH SECURITY_ENFORCED LIMIT 1 ];
        Plazo__c pl =[SELECT Id,Dsales_Plazo__c FROM Plazo__c  WHERE Dsales_Plazo__c='12' WITH SECURITY_ENFORCED LIMIT 1];
        QuoteLineItem cel =[SELECT Id,DSALES_SKU__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Producto' AND DSALES_Segurogratis__c=false AND quoteId=:cotizacion.Id LIMIT 1];
        // DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_SKU__c FROM DSALES_InformacionDePago__c WHERE DSALES_Seguro__c=false  AND DSALES_Oportunidad__c=:cotizacion.OpportunityId LIMIT 1];
        Account acc=[SELECT Id FROM Account WHERE FirstName = 'Daniela' WITH SECURITY_ENFORCED LIMIT 1];
        List<String> idsPartidas = new List<String>();
        Test.startTest();
        DSALES_InformacionDePago__c pago2 = new DSALES_InformacionDePago__c();
        pago2.DSALES_Cliente__c=acc.Id;
        pago2.DSALES_Oportunidad__c=cotizacion.OpportunityId;
        pago2.DSALES_Plazodecomprademoto__c=12;
        pago2.DSALES_Seguro__c=false;
        pago2.DSALES_Factura__c='123';
        pago2.DSALES_Nombre_del_Vendedor__c='Cristian';
        insert pago2;
        DSALES_QuoteDuplicateSC.Datos datos = new DSALES_QuoteDuplicateSC.Datos();
        datos.idCotizacionAnt=cotizacion.Id;
        datos.idOportunidad=cotizacion.OpportunityId;
        datos.pago=pago2;
        Quote nuevaCot=DSALES_QuoteDuplicateSC.cotizacionesNuevas(idsPartidas,datos);
        Test.stopTest();
        System.assertEquals(false, pago2.DSALES_Seguro__c, 'El valor del seguro es false');
        
    }


}