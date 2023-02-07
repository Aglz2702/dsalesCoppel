@isTest
public with sharing class DSALES_QuotePagoSmTest {
    @testSetup
    static void SetUp(){
        String tipoProducto = 'Producto';
        String message = '';
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Garantía Extendida').getRecordTypeId();
        
        DSALES_Familia__c family = new DSALES_Familia__c();
        family.Name = 'test';
        insert family;
        
        DSALES_Categoria__c category = new DSALES_Categoria__c();
        category.Name = 'test';
        insert category;
        
        DSALES_Clase__c classs = new DSALES_Clase__c();
        classs.Name = 'test';
        insert classs;
        
        Product2 prodRc = new Product2(Name ='RC Seguro de Moto',DSALES_vehculo__c='sadkncdcs' ,StockKeepingUnit='0000',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',IsActive=true);
		insert prodRc;
        
        Product2 prodAmp = new Product2(Name ='AMP Seguro de Moto',DSALES_vehculo__c='23d23d23', StockKeepingUnit='123444',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
		insert prodAmp;
        
        Product2 prodM = new Product2(Name ='Moto',DSALES_vehculo__c='lasicndsldicsid',StockKeepingUnit='109876',DSales_Tipo_de_Producto__c='Producto',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
		insert prodM;
          Product2 prodM2 = new Product2(Name ='Moto Vento',DSALES_vehculo__c='lasicndsldicsid',StockKeepingUnit='111010',DSales_Tipo_de_Producto__c='Producto',IsActive=true);
		insert prodM2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = prodRc.Id;
        standardPrice.UnitPrice = 1000;
        standardPrice.IsActive = true;
        insert standardPrice;
        
        PricebookEntry standardPriceGEX = new PricebookEntry();
        standardPriceGEX.Pricebook2Id = pricebookId;
        standardPriceGEX.Product2Id = prodAmp.Id;
        standardPriceGEX.UnitPrice = 1000;
        standardPriceGEX.IsActive = true;
        insert standardPriceGEX;
        
        PricebookEntry standardPriceMoto = new PricebookEntry();
        standardPriceMoto.Pricebook2Id = pricebookId;
        standardPriceMoto.Product2Id = prodM.Id;
        standardPriceMoto.UnitPrice = 1000;
        standardPriceMoto.IsActive = true;
        insert standardPriceMoto;
        
        PricebookEntry standardPriceMoto2 = new PricebookEntry();
        standardPriceMoto2.Pricebook2Id = pricebookId;
        standardPriceMoto2.Product2Id = prodM2.Id;
        standardPriceMoto2.UnitPrice = 1000;
        standardPriceMoto2.IsActive = true;
        insert standardPriceMoto2;
        
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry();
        customPrice.Pricebook2Id = customPB.Id;
        customPrice.Product2Id = prodRc.Id;
        customPrice.UnitPrice = 1200;
        customPrice.IsActive = true;
        insert customPrice;
        
        PricebookEntry customPriceGEX = new PricebookEntry();
        customPriceGEX.Pricebook2Id = customPB.Id;
        customPriceGEX.Product2Id = prodAmp.Id;
        customPriceGEx.UnitPrice = 2000;
        customPriceGEX.IsActive = true;
        insert customPriceGEX;
        
        PricebookEntry customPriceMoto = new PricebookEntry();
        customPriceMoto.Pricebook2Id = customPB.Id;
        customPriceMoto.Product2Id = prodM.Id;
        customPriceMoto.UnitPrice = 2000;
        customPriceMoto.IsActive = true;
        insert customPriceMoto;
        
        PricebookEntry customPriceMoto2 = new PricebookEntry();
        customPriceMoto2.Pricebook2Id = customPB.Id;
        customPriceMoto2.Product2Id = prodM2.Id;
        customPriceMoto2.UnitPrice = 2000;
        customPriceMoto2.IsActive = true;
        insert customPriceMoto2;
		
        
        
        Account acc = new Account();
        acc.Name='test';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.DSALES_ClienteCoppel__c='90001';
        insert acc;
        
        Account accContado = new Account();
        accContado.FirstName = 'Daniela';
        accContado.LastName = 'Gallegos';
        accContado.Middlename = 'Ho';
        accContado.PersonEmail = 'danigallegos@deloittemx.com';
        accContado.PersonBirthdate = date.today();
        insert accContado;
        
        Account accContado2 = new Account();
        accContado2.FirstName = 'Daniela';
        accContado2.LastName = 'Gallegos';
        accContado2.Middlename = 'Ho';
        accContado2.PersonEmail = 'danigegos@deloittemx.com';
        insert accContado2;
        
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  'CPPL-UGARTE';
        insert t;
        
        Quote cotizacion = new Quote(OpportunityId=opp.Id,Name='test',DSales_Tienda__c=t.Id);
        insert cotizacion;
        
        DSALES_TipodeUso__c tipoUso = new DSALES_TipodeUso__c(Name='Comercial');
        insert tipoUso;
        DSALES_Tipodevehculo__c tipovehiculo = new DSALES_Tipodevehculo__c(Name='Moto');
        insert tipovehiculo;
        
        Plazo__c plazoRC12 = new Plazo__c();
        plazoRC12.Name='12';
        plazoRC12.DSALES_Seguro__c=prodRc.Id;
        plazoRC12.Dsales_Plazo__c='12';
        plazoRC12.DSALES_Activo__c=true;
        insert plazoRC12;
        
        Plazo__c plazoRC18 = new Plazo__c();
        plazoRC18.Name='18';
        plazoRC18.DSALES_Seguro__c=prodRc.Id;
        plazoRC18.Dsales_Plazo__c='18';
        plazoRC18.DSALES_Activo__c=true;
        insert plazoRC18;
        
        Plazo__c plazoAMP12 = new Plazo__c(Name='12',Dsales_Plazo__c='12',DSALES_Seguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazoAMP12;
         Plazo__c plazoAMP18 = new Plazo__c(Name='18',Dsales_Plazo__c='18',DSALES_Seguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazoAMP18;
        
        QuoteLineItem moto = new QuoteLineItem();
        moto.QuoteId = cotizacion.Id;
        moto.PricebookEntryId = customPrice.Id;
        moto.Product2Id = prodM.Id;
        moto.Quantity = 1.0;
        moto.UnitPrice = customPrice.UnitPrice;
        moto.DSALES_Segurogratis__c=true;
        //moto.DSALES_Tipodeproducto__c = 'Producto';
        insert moto;
        QuoteLineItem moto2 = new QuoteLineItem();
        moto2.QuoteId = cotizacion.Id;
        moto2.PricebookEntryId = customPrice.Id;
        moto2.Product2Id = prodM2.Id;
        moto2.Quantity = 1.0;
        moto2.UnitPrice = customPrice.UnitPrice;
        moto2.DSALES_Segurogratis__c=false;
        //moto.DSALES_Tipodeproducto__c = 'Producto';
        insert moto2;
        
        QuoteLineItem seguroRc = new QuoteLineItem();
        seguroRc.QuoteId = cotizacion.Id;
        seguroRc.PricebookEntryId = customPrice.Id;
        seguroRc.Product2Id = prodRc.Id;
        seguroRc.Quantity = 1.0;
        seguroRc.UnitPrice = customPrice.UnitPrice;
        //seguroRc.DSALES_Tipodeproducto__c = 'Producto';
        seguroRc.DSALES_Plazo__c=plazoRC18.Id;
        seguroRc.DSALES_Segurogratis__c=false;
        insert seguroRc;
        
        QuoteLineItem seguroRcG = new QuoteLineItem();
        seguroRcG.QuoteId = cotizacion.Id;
        seguroRcG.PricebookEntryId = customPrice.Id;
        seguroRcG.Product2Id = prodRc.Id;
        seguroRcG.Quantity = 1.0;
        seguroRcG.UnitPrice = customPrice.UnitPrice;
        //seguroRc.DSALES_Tipodeproducto__c = 'Producto';
        seguroRcG.DSALES_Plazo__c=plazoRC12.Id;
        seguroRcG.DSALES_Segurogratis__c=true;
        insert seguroRcG;
        
        QuoteLineItem seguroAmp = new QuoteLineItem();
        seguroAmp.QuoteId = cotizacion.Id;
        seguroAmp.PricebookEntryId = customPrice.Id;
        seguroAmp.Product2Id = prodAmp.Id;
        seguroAmp.Quantity = 1.0;
        seguroAmp.UnitPrice = customPrice.UnitPrice;
        //seguroAmp.DSALES_Tipodeproducto__c = 'Producto';
        seguroAmp.DSALES_Plazo__c=plazoAMP18.Id;
        seguroAmp.DSALES_Segurogratis__c=false;
        insert seguroAmp;
        
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c();
        pago.DSALES_Cliente__c=acc.Id;
        pago.DSALES_Oportunidad__c=opp.Id;
        pago.DSALES_Plazodecomprademoto__c=18;
        pago.DSALES_Seguro__c=false;
        pago.DSALES_Factura__c='123';
        pago.DSALES_Nombre_del_Vendedor__c='Sayra Martinez';
        pago.DSales_Tienda__c=t.Id;
        insert pago;
        
        DSALES_InformacionDePago__c pago2 = new DSALES_InformacionDePago__c();
        pago2.DSALES_Cliente__c=acc.Id;
        pago2.DSALES_Oportunidad__c=opp.Id;
        pago2.DSALES_Plazodecomprademoto__c=12;
        pago2.DSALES_Seguro__c=true;
        pago2.DSALES_Factura__c='123';
        pago2.DSALES_Nombre_del_Vendedor__c='Sayra Martinez';
        pago2.DSales_Tienda__c=t.Id;
        insert pago2;
        
    }
    @isTest 
    public static void crearCotizacionTest(){
        List<Quote> cotizacion=[SELECT Id,DSales_Vendedor__c FROM Quote ];
        List<QuoteLineItem> partidas =[SELECT Id,DSALES_SKU__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Seguro' AND DSALES_Segurogratis__c=false];
        List<QuoteLineItem> moto =[SELECT Id,DSALES_SKU__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Producto' AND DSALES_Segurogratis__c=false];
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_SKU__c FROM DSALES_InformacionDePago__c WHERE DSALES_Seguro__c=false LIMIT 1];
        List<String> idsPartidas = new List<String>();
        for(QuoteLineItem ql:partidas){
            idsPartidas.add(ql.Id);
        }
        Test.startTest();
        System.assertEquals(1, cotizacion.size());
        System.debug(cotizacion);
        System.debug(partidas.size());
        System.debug('seguros'+partidas);
        System.debug('moto:'+moto);
        String idPago= pago.Id;
        DSALES_QuotePagoSM.cotizacionesNuevas(idPago, idsPartidas, '1231212');
        Test.stopTest();
    }
    @isTest 
    public static void cotizacionPartidaTest(){
        List<Quote> cotizacion=[SELECT Id,DSales_Vendedor__c FROM Quote ];
        List<QuoteLineItem> partidas =[SELECT Id,DSALES_SKU__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Seguro' AND DSALES_Segurogratis__c=true LIMIT 1];
        List<QuoteLineItem> moto =[SELECT Id,DSALES_SKU__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Producto' AND DSALES_Segurogratis__c=true];
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_SKU__c FROM DSALES_InformacionDePago__c WHERE DSALES_Seguro__c=true LIMIT 1];
        List<String> idsPartidas = new List<String>();
        for(QuoteLineItem ql:partidas){
            idsPartidas.add(ql.Id);
        }
        Test.startTest();
        System.assertEquals(1, cotizacion.size());
        System.debug(cotizacion);
        System.debug(partidas.size());
        System.debug('seguros'+partidas);
        System.debug('moto:'+moto);
        String idPago= pago.Id;
        DSALES_QuotePagoSM.cotizacionesNuevas(idPago, idsPartidas,'111010');
        Test.stopTest();
    }
    @isTest 
    public static void cotizacionPartidaSinSeguroTest(){
        List<QuoteLineItem> partidas =[SELECT Id,DSALES_Segurogratis__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Seguro' AND DSALES_Segurogratis__c=false ];
        List<QuoteLineItem> moto =[SELECT Id,DSALES_SKU__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Producto' AND DSALES_Segurogratis__c=false];
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_SKU__c FROM DSALES_InformacionDePago__c WHERE DSALES_Seguro__c=false LIMIT 1];
        System.debug('****seguro****:\n'+partidas);
        System.debug('****moto sin seguro****:\n'+moto);
        List<String> idsPartidas = new List<String>();
        for(QuoteLineItem ql:partidas){
            idsPartidas.add(ql.Id);
        }
        Test.startTest();
        String idPago= pago.Id;
        DSALES_QuotePagoSM.cotizacionesNuevas(idPago, idsPartidas,'111010');
        Test.stopTest();
    }
}