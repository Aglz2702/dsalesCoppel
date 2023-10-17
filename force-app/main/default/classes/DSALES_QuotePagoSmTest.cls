@isTest
public with sharing class DSALES_QuotePagoSmTest {
    @testSetup
    static void setUp(){
        String tipoProducto = 'Producto';
        String message = '';
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Seguro_de_Moto').getRecordTypeId();
        String recordTypeQuoteId=Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DSALES_VentaSM').getRecordTypeId();
        DSALES_Familia__c family = new DSALES_Familia__c();
        family.Name = 'test';
        insert family;
        
        DSALES_Categoria__c category = new DSALES_Categoria__c();
        category.Name = 'test';
        insert category;
        
        DSALES_Clase__c classs = new DSALES_Clase__c();
        classs.Name = 'test';
        insert classs;
        
        Product2 prodRc = new Product2(Name ='RC',dsalesVehiculo__c='sadkncdcs' ,StockKeepingUnit='0000',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',IsActive=true);
        insert prodRc;
        
        Product2 prodAmp = new Product2(Name ='AMP',dsalesVehiculo__c='23d23d23', StockKeepingUnit='123444',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
        insert prodAmp;
        
        Product2 prodM = new Product2(Name ='Moto',dsalesVehiculo__c='lasicndsldicsid',StockKeepingUnit='109876',DSales_Tipo_de_Producto__c='Producto',IsActive=true);
        insert prodM;
        
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
        
        Opportunity opp = new Opportunity(Name='MOTO SEG GRATIS', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        Opportunity opp2 = new Opportunity(Name='MOTO CON AMP', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp2;
        Opportunity opp3 = new Opportunity(Name='MOTO', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp3;
        
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  'CPPL-UGARTE';
        insert t;
        
        Quote cotizacion = new Quote( RecordTypeId=recordTypeQuoteId,OpportunityId=opp3.Id,Name='test3',DSales_Tienda__c=t.Id);
        insert cotizacion;
        
        Quote cotMS = new Quote( RecordTypeId=recordTypeQuoteId,OpportunityId=opp2.Id,Name='test2',DSales_Tienda__c=t.Id);
        insert cotMS;
        Quote cotMRc = new Quote( RecordTypeId=recordTypeQuoteId,OpportunityId=opp.Id,Name='test1',DSales_Tienda__c=t.Id);
        insert cotMRc;
        
        DSALES_TipodeUso__c tipoUso = new DSALES_TipodeUso__c(Name='Comercial');
        insert tipoUso;
        DSALES_Tipodevehculo__c tipovehiculo = new DSALES_Tipodevehculo__c(Name='Moto');
        insert tipovehiculo;
        //PLAZO PARA RC
        Plazo__c plazoRC12 = new Plazo__c();
        plazoRC12.Name='12';
        plazoRC12.dsalesSeguro__c=prodRc.Id;
        plazoRC12.Dsales_Plazo__c='12';
        plazoRC12.DSALES_Activo__c=true;
        insert plazoRC12;
        
        Plazo__c plazoRC18 = new Plazo__c();
        plazoRC18.Name='18';
        plazoRC18.dsalesSeguro__c=prodRc.Id;
        plazoRC18.Dsales_Plazo__c='18';
        plazoRC18.DSALES_Activo__c=true;
        insert plazoRC18;
        //PLAZO PARA AMP
        Plazo__c plazoAMP12 = new Plazo__c(Name='12',Dsales_Plazo__c='12',dsalesSeguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazoAMP12;
        Plazo__c plazoAMP18 = new Plazo__c(Name='18',Dsales_Plazo__c='18',dsalesSeguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazoAMP18;
        
        //VENTA SOLO MOTO
        QuoteLineItem moto3 = new QuoteLineItem();
        moto3.QuoteId = cotizacion.Id;
        moto3.PricebookEntryId = customPrice.Id;
        moto3.Product2Id = prodM.Id;
        moto3.Quantity = 1.0;
        moto3.UnitPrice = customPrice.UnitPrice;
        moto3.DSALES_Segurogratis__c=false;
        insert moto3;
        
        QuoteLineItem seguroRc = new QuoteLineItem();
        seguroRc.QuoteId = cotizacion.Id;
        seguroRc.PricebookEntryId = customPrice.Id;
        seguroRc.Product2Id = prodRc.Id;
        seguroRc.Quantity = 1.0;
        seguroRc.UnitPrice = customPrice.UnitPrice;
        //seguroRc.DSALES_Tipodeproducto__c = 'Producto';
        seguroRc.DSALES_Plazo__c=plazoRC12.Id;
        seguroRc.DSALES_Segurogratis__c=false;
        insert seguroRc;
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
        
        QuoteLineItem seguroAmp12 = new QuoteLineItem();
        seguroAmp12.QuoteId = cotizacion.Id;
        seguroAmp12.PricebookEntryId = customPrice.Id;
        seguroAmp12.Product2Id = prodAmp.Id;
        seguroAmp12.Quantity = 1.0;
        seguroAmp12.UnitPrice = customPrice.UnitPrice;
        //seguroAmp.DSALES_Tipodeproducto__c = 'Producto';
        seguroAmp12.DSALES_Plazo__c=plazoAMP12.Id;
        seguroAmp12.DSALES_Segurogratis__c=false;
        insert seguroAmp12;
        
        //VENTA MOTO CON SEGURO
        QuoteLineItem motoMS = new QuoteLineItem();
        motoMS.QuoteId = cotMS.Id;
        motoMS.PricebookEntryId = customPrice.Id;
        motoMS.Product2Id = prodM.Id;
        motoMS.Quantity = 1.0;
        motoMS.UnitPrice = customPrice.UnitPrice;
        motoMS.DSALES_Segurogratis__c=false;
        //moto.DSALES_Tipodeproducto__c = 'Producto';
        insert motoMS;
        QuoteLineItem seguroRc2 = new QuoteLineItem();
        seguroRc2.QuoteId = cotMS.Id;
        seguroRc2.PricebookEntryId = customPrice.Id;
        seguroRc2.Product2Id = prodRc.Id;
        seguroRc2.Quantity = 1.0;
        seguroRc2.UnitPrice = customPrice.UnitPrice;
        //seguroRc.DSALES_Tipodeproducto__c = 'Producto';
        seguroRc2.DSALES_Plazo__c=plazoRC12.Id;
        seguroRc2.DSALES_Segurogratis__c=false;
        insert seguroRc2;
        
        QuoteLineItem seguroAmp2 = new QuoteLineItem();
        seguroAmp2.QuoteId = cotMS.Id;
        seguroAmp2.PricebookEntryId = customPrice.Id;
        seguroAmp2.Product2Id = prodAmp.Id;
        seguroAmp2.Quantity = 1.0;
        seguroAmp2.UnitPrice = customPrice.UnitPrice;
        //seguroAmp.DSALES_Tipodeproducto__c = 'Producto';
        seguroAmp2.DSALES_Plazo__c=plazoAMP18.Id;
        seguroAmp2.DSALES_Segurogratis__c=false;
        insert seguroAmp2;
        
        QuoteLineItem seguroAmp212 = new QuoteLineItem();
        seguroAmp212.QuoteId = cotMS.Id;
        seguroAmp212.PricebookEntryId = customPrice.Id;
        seguroAmp212.Product2Id = prodAmp.Id;
        seguroAmp212.Quantity = 1.0;
        seguroAmp212.UnitPrice = customPrice.UnitPrice;
        //seguroAmp.DSALES_Tipodeproducto__c = 'Producto';
        seguroAmp212.DSALES_Plazo__c=plazoAMP12.Id;
        seguroAmp212.DSALES_Segurogratis__c=false;
        insert seguroAmp212;  
        //VENTA MOTO CON RC GRATIS
        QuoteLineItem moto = new QuoteLineItem();
        moto.QuoteId = cotMRc.Id;
        moto.PricebookEntryId = customPrice.Id;
        moto.Product2Id = prodM.Id;
        moto.Quantity = 1.0;
        moto.UnitPrice = customPrice.UnitPrice;
        moto.DSALES_Segurogratis__c=true;
        insert moto;
        
        QuoteLineItem seguroRcM = new QuoteLineItem();
        seguroRcM.QuoteId = cotMRc.Id;
        seguroRcM.PricebookEntryId = customPrice.Id;
        seguroRcM.Product2Id = prodRc.Id;
        seguroRcM.Quantity = 1.0;
        seguroRcM.UnitPrice = customPrice.UnitPrice;
        //seguroRc.DSALES_Tipodeproducto__c = 'Producto';
        seguroRcM.DSALES_Plazo__c=plazoRC12.Id;
        seguroRcM.DSALES_Segurogratis__c=true;
        insert seguroRcM;
        
        QuoteLineItem seguroAmp12M = new QuoteLineItem();
        seguroAmp12M.QuoteId = cotMRc.Id;
        seguroAmp12M.PricebookEntryId = customPrice.Id;
        seguroAmp12M.Product2Id = prodAmp.Id;
        seguroAmp12M.Quantity = 1.0;
        seguroAmp12M.UnitPrice = customPrice.UnitPrice;
        seguroAmp12M.DSALES_Plazo__c=plazoAMP12.Id;
        seguroAmp12M.DSALES_Segurogratis__c=false;
        insert seguroAmp12M;
        QuoteLineItem seguroAmpR = new QuoteLineItem();
        seguroAmpR.QuoteId = cotMRc.Id;
        seguroAmpR.PricebookEntryId = customPrice.Id;
        seguroAmpR.Product2Id = prodAmp.Id;
        seguroAmpR.Quantity = 1.0;
        seguroAmpR.UnitPrice = customPrice.UnitPrice;
        //seguroAmp.DSALES_Tipodeproducto__c = 'Producto';
        seguroAmpR.DSALES_Plazo__c=plazoAMP18.Id;
        seguroAmpR.DSALES_Segurogratis__c=false;
        insert seguroAmpR;
    }
    @isTest 
    public static void ventaMotoYSeguroTest(){
        Quote cotizacion=[SELECT Id,DSales_Vendedor__c,OpportunityId FROM Quote WHERE Name='test2' WITH SECURITY_ENFORCED LIMIT 1 ];
        Plazo__c pl =[SELECT Id,Dsales_Plazo__c FROM Plazo__c  WHERE Dsales_Plazo__c='18' AND dsalesSeguro__r.Name='AMP' WITH SECURITY_ENFORCED LIMIT 1];
        System.debug('plazo de partida:'+ pl);
        List<QuoteLineItem> partidas =[SELECT Id,DSALES_SKU__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c,Product2Id,DSALES_NombreProducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Seguro'  AND DSALES_Plazo__c=:pl.Id AND quoteId=:cotizacion.Id WITH SECURITY_ENFORCED LIMIT 1];
        System.debug('PARTIDA CON PLAZO:'+partidas);
        QuoteLineItem moto =[SELECT Id,DSALES_SKU__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Producto' AND DSALES_Segurogratis__c=false AND quoteId=:cotizacion.Id WITH SECURITY_ENFORCED LIMIT 1];
        // DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_SKU__c FROM DSALES_InformacionDePago__c WHERE DSALES_Seguro__c=false  AND DSALES_Oportunidad__c=:cotizacion.OpportunityId LIMIT 1];
        Account acc=[SELECT Id FROM Account WHERE FirstName = 'Daniela' WITH SECURITY_ENFORCED LIMIT 1];
        List<String> idsPartidas = new List<String>();
        for(QuoteLineItem ql:partidas){
            idsPartidas.add(ql.Id);
        }
        Test.startTest();
        System.debug('*********MOTO CON SEGURO*****************');
        System.debug('++++++PARTIDAS+++:'+ partidas);
        DSALES_InformacionDePago__c pago2 = new DSALES_InformacionDePago__c();
        pago2.DSALES_Cliente__c=acc.Id;
        pago2.DSALES_Oportunidad__c=cotizacion.OpportunityId;
        pago2.DSALES_Plazodecomprademoto__c=18;
        pago2.DSALES_Seguro__c=true;
        pago2.DSALES_Factura__c='123';
        pago2.DSALES_Nombre_del_Vendedor__c='Cristian';
        //pago2.DSales_Tienda__c=t.Id;
        insert pago2;
        DSALES_QuotePagoSM.cotizacionesNuevas(pago2.Id, idsPartidas, moto.DSALES_SKU__c,123);
        Test.stopTest();
        System.assertEquals(true, pago2.DSALES_Seguro__c, 'El valor del seguro es cierto');
        
    }
    @isTest 
    public static void ventaMotoRcGratisTest(){
        Quote cotizacion=[SELECT Id,DSales_Vendedor__c,OpportunityId FROM Quote WHERE Name='test1'  WITH SECURITY_ENFORCED LIMIT 1];
        //Plazo__c pl =[SELECT Id,Dsales_Plazo__c FROM Plazo__c  WHERE Dsales_Plazo__c='18' LIMIT 1];
        List<QuoteLineItem> partidas =[SELECT Id,DSALES_Plazo__c,DSALES_Segurogratis__c,DSALES_Tipodeproducto__c,Product2Id,DSALES_NombreProducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Seguro' AND DSALES_Segurogratis__c=true AND quoteId=:cotizacion.Id WITH SECURITY_ENFORCED LIMIT 1];
        QuoteLineItem moto =[SELECT Id,DSALES_SKU__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Producto' AND DSALES_Segurogratis__c=true AND quoteId=:cotizacion.Id WITH SECURITY_ENFORCED LIMIT 1];
        Account acc=[SELECT Id FROM Account WHERE FirstName = 'Daniela' LIMIT 1];
        
        List<String> idsPartidas = new List<String>();
        
        for(QuoteLineItem ql:partidas){
            idsPartidas.add(ql.Id);
        }
        Test.startTest();
        System.debug('####PARTIDA RC gratis######:'+partidas);
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c();
        pago.DSALES_Cliente__c=acc.Id;
        pago.DSALES_Oportunidad__c=cotizacion.OpportunityId;
        pago.DSALES_Plazodecomprademoto__c=18;
        pago.DSALES_Seguro__c=true;
        pago.DSALES_Factura__c='123';
        pago.DSALES_Nombre_del_Vendedor__c='Sayra Martinez';
        //pago.DSales_Tienda__c=t.Id;
        insert pago;
        System.debug('*********SEGURO GRATIS*****************');
        DSALES_QuotePagoSM.cotizacionesNuevas(pago.Id, idsPartidas,moto.DSALES_SKU__c, 123);
        Test.stopTest();
        System.assertEquals(true, pago.DSALES_Seguro__c, 'El valor del seguro es cierto');
        
    }
    
    @isTest 
    public static void ventaSoloMotoTest(){
        Quote cot=[SELECT Id,DSales_Vendedor__c,OpportunityId FROM Quote WHERE Name='test3'  WITH SECURITY_ENFORCED LIMIT 1];
        QuoteLineItem moto =[SELECT Id,DSALES_SKU__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Producto' AND DSALES_Segurogratis__c=false  AND quoteId=:cot.Id WITH SECURITY_ENFORCED LIMIT 1];
        //DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_SKU__c FROM DSALES_InformacionDePago__c WHERE DSALES_Seguro__c=false AND DSALES_Oportunidad__c=:cot.OpportunityId LIMIT 1];
        Account acc=[SELECT Id FROM Account WHERE FirstName = 'Daniela' WITH SECURITY_ENFORCED LIMIT 1];
        Test.startTest();
        DSALES_InformacionDePago__c pago3 = new DSALES_InformacionDePago__c();
        pago3.DSALES_Cliente__c=acc.Id;
        pago3.DSALES_Oportunidad__c=cot.OpportunityId;
        pago3.DSALES_Plazodecomprademoto__c=0;
        pago3.DSALES_Seguro__c=false;
        pago3.DSALES_Factura__c='123';
        pago3.DSALES_Nombre_del_Vendedor__c='Cristian';
        //pago3.DSales_Tienda__c=t.Id;
        insert pago3;
        System.debug('********* SOLO MOTO*****************');
        DSALES_QuotePagoSM.cotizacionesNuevas(pago3.Id, null,moto.DSALES_SKU__c, 123);
        Test.stopTest();
        System.assertEquals(false, pago3.DSALES_Seguro__c, 'El valor del seguro no es cierto');
        
    } 
    @isTest
    static void testUpdateCot() {
        //List<QuoteLineItem> listaMotoSeguroToInsert =[SELECT Id,DSALES_Segurogratis__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Seguro' LIMIT 1];
        Quote testQuote=[SELECT Id,DSales_Vendedor__c,OpportunityId FROM Quote WHERE DSALES_Enviarcotizacion__c = false  WITH SECURITY_ENFORCED LIMIT 1];
        List<String> listCotNew = new List<String>{ testQuote.Id };
            Test.startTest();
        Quote updatedQuote = DSALES_QuotePagoSM.updateCot(listCotNew);
        Test.stopTest();
        System.assertEquals(true, updatedQuote.DSALES_Enviarcotizacion__c, 'El valor de enviar cotización es verdadero');
    }
    @isTest
    static void testUpdateQot() {
        Quote testQuote=[SELECT Id,DSales_Vendedor__c,OpportunityId FROM Quote WHERE Name='test3'  WITH SECURITY_ENFORCED LIMIT 1];
        QuoteLineItem testLineItem =[SELECT Id,QuoteId,DSALES_Segurogratis__c,DSALES_Plazo__c,DSALES_Tipodeproducto__c,PricebookEntryId, Quantity, UnitPrice, Product2Id FROM QuoteLineItem WHERE QuoteId=:testQuote.Id WITH SECURITY_ENFORCED LIMIT 1];
        List<QuoteLineItem> listaMotoSeguroToInsert = new List<QuoteLineItem>{ testLineItem };
            Test.startTest();
        Quote updatedQuote =DSALES_QuotePagoSM.updateEnviarCot(listaMotoSeguroToInsert);
        Test.stopTest();
        System.assertEquals(true, updatedQuote.DSALES_Enviarcotizacion__c, 'El valor de enviar cotización es verdadero');
    }
    
    @isTest
    static void testCreateQlItms() {
        Quote cotizacion=[SELECT Id,DSales_Vendedor__c,OpportunityId FROM Quote WHERE Name='test1'  LIMIT 1];
        List<QuoteLineItem> listMotoRc =[SELECT Id,DSALES_Plazo__c,DSALES_Segurogratis__c,DSALES_Tipodeproducto__c,Product2Id,DSALES_NombreProducto__c,PricebookEntryId, UnitPrice,Quantity FROM QuoteLineItem WHERE quoteId=:cotizacion.Id LIMIT 1];
        List<QuoteLineItem> listPartidas =[SELECT Id,DSALES_Plazo__c,DSALES_Segurogratis__c,DSALES_Tipodeproducto__c,Product2Id,DSALES_NombreProducto__c FROM QuoteLineItem WHERE DSALES_Segurogratis__c!=true AND QuoteId=:cotizacion.Id AND DSALES_Plazo__r.Dsales_Plazo__c='18' LIMIT 1];
        List<Plazo__c> plazos =[SELECT Id,Dsales_Plazo__c FROM Plazo__c  WHERE Dsales_Plazo__c='18' WITH SECURITY_ENFORCED LIMIT 1];
        List<PricebookEntry> pricebookEntries=[SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Name='PLUS' WITH SECURITY_ENFORCED LIMIT 1]; 
        List<String> idsPartidas = new List<String>();
        for(QuoteLineItem ql:listPartidas){
            idsPartidas.add(ql.Id);
        } 
        Test.startTest();
        List<QuoteLineItem> result=DSALES_QuotePagoSM.createQlItms(idsPartidas, listPartidas, listMotoRc);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'El tamaño del resultado es 1.');
        
    }
    
    @isTest
    static void testCreateCotItm() {
        Quote cotizacion=[SELECT Id,DSales_Vendedor__c,OpportunityId FROM Quote WHERE Name='test1'  LIMIT 1];
        List<QuoteLineItem> listMotoRc =[SELECT Id,DSALES_Plazo__c,DSALES_Segurogratis__c,DSALES_Tipodeproducto__c,Product2Id,DSALES_NombreProducto__c FROM QuoteLineItem WHERE DSALES_Segurogratis__c=true AND DSALES_Tipodeproducto__c='Seguro' LIMIT 1];
        List<QuoteLineItem> listPartInsert =[SELECT Id,DSALES_Plazo__c,DSALES_Segurogratis__c,DSALES_Tipodeproducto__c,Product2Id,DSALES_NombreProducto__c FROM QuoteLineItem WHERE DSALES_Tipodeproducto__c='Seguro' AND DSALES_Segurogratis__c=true AND quoteId=:cotizacion.Id LIMIT 1];
        
        Test.startTest();
        List<QuoteLineItem> result = DSALES_QuotePagoSM.createCotItm(listMotoRc, listPartInsert);
        List<QuoteLineItem> result1= DSALES_QuotePagoSM.updateQuLnItm(listMotoRc, listPartInsert);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'El tamaño del resultado es 1.');
    }
    
    @isTest
	static void testCreateQlItmssss() {
        Quote cotizacion=[SELECT Id,DSales_Vendedor__c,OpportunityId FROM Quote WHERE Name='test1'  LIMIT 1];
        List<String> listCotNew = new List<String>{cotizacion.Id};
        List<QuoteLineItem> listPartidas = new List<QuoteLineItem>();
        List<QuoteLineItem> listaMotoSeguro = new List<QuoteLineItem>();

        List<QuoteLineItem> result = DSALES_QuotePagoSM.createQlItm(listCotNew, listPartidas, listaMotoSeguro);
        System.assertEquals(0, result.size()); 
        System.assert(true, 'Test completed successfully.');
    }
}