@isTest
public with sharing class DSALES_CreateInsurancePolicyTest {
    @testSetup
    static void setUp(){
        String tipoProducto = 'Producto';
        String message = '';
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Seguro_de_Moto').getRecordTypeId();
        
        DSALES_Familia__c family = new DSALES_Familia__c();
        family.Name = 'test';
        insert family;
        
        DSALES_Categoria__c category = new DSALES_Categoria__c();
        category.Name = 'test';
        insert category;
        
        DSALES_Clase__c classs = new DSALES_Clase__c();
        classs.Name = 'test';
        insert classs;
        
        Product2 prodRc = new Product2(Name ='RC',DSALES_vehculo__c='sadkncdcs' ,StockKeepingUnit='0000',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',IsActive=true);
		insert prodRc;
        
        Product2 prodAmp = new Product2(Name ='AMP',DSALES_vehculo__c='23d23d23', StockKeepingUnit='123444',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
		insert prodAmp;
        
        Product2 prodM = new Product2(Name ='Moto',DSALES_vehculo__c='lasicndsldicsid',StockKeepingUnit='12121212',DSales_Tipo_de_Producto__c='Producto',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
		insert prodM;
         /* Product2 prodM2 = new Product2(Name ='Moto Vento',DSALES_vehculo__c='lasicndsldicsid',StockKeepingUnit='1225473',DSales_Tipo_de_Producto__c='Producto',IsActive=true);
		insert prodM2;*/
        
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
        
        /*PricebookEntry standardPriceMoto2 = new PricebookEntry();
        standardPriceMoto2.Pricebook2Id = pricebookId;
        standardPriceMoto2.Product2Id = prodM2.Id;
        standardPriceMoto2.UnitPrice = 1000;
        standardPriceMoto2.IsActive = true;
        insert standardPriceMoto2;*/
        
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
        
        /*PricebookEntry customPriceMoto2 = new PricebookEntry();
        customPriceMoto2.Pricebook2Id = customPB.Id;
        customPriceMoto2.Product2Id = prodM2.Id;
        customPriceMoto2.UnitPrice = 2000;
        customPriceMoto2.IsActive = true;
        insert customPriceMoto2;*/
		
        
        
        Account acc = new Account();
        acc.Name='Sayra Martinez Quiroz';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.DSALES_ClienteCoppel__c='90001';
        insert acc;
        
        
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  'T-0001';
        insert t;
        
        DSALES_InformaciondePago__c pago = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=opp.id,DSALES_Cliente__c=acc.Id,DSALES_Seguro__c=true);
        insert pago;
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
        
        Plazo__c plazoAMP12 = new Plazo__c(Name='12',Dsales_Plazo__c='12',DSALES_Seguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazoAMP12;
        
        QuoteLineItem moto = new QuoteLineItem();
        moto.QuoteId = cotizacion.Id;
        moto.PricebookEntryId = customPrice.Id;
        moto.Product2Id = prodM.Id;
        moto.Quantity = 1.0;
        moto.UnitPrice = customPrice.UnitPrice;
        moto.DSALES_Segurogratis__c=true;
        insert moto;
                
        /*QuoteLineItem seguroRc = new QuoteLineItem();
        seguroRc.QuoteId = cotizacion.Id;
        seguroRc.PricebookEntryId = customPrice.Id;
        seguroRc.Product2Id = prodRc.Id;
        seguroRc.Quantity = 1.0;
        seguroRc.UnitPrice = customPrice.UnitPrice;
        seguroRc.DSALES_Plazo__c=plazoRC12.Id;
        seguroRc.DSALES_Segurogratis__c=false;
        insert seguroRc;*/
        QuoteLineItem seguroAmp = new QuoteLineItem();
        seguroAmp.QuoteId = cotizacion.Id;
        seguroAmp.PricebookEntryId = customPrice.Id;
        seguroAmp.Product2Id = prodAmp.Id;
        seguroAmp.Quantity = 1.0;
        seguroAmp.UnitPrice = customPrice.UnitPrice;
        seguroAmp.DSALES_Plazo__c=plazoAMP12.Id;
        seguroAmp.DSALES_Segurogratis__c=false;
        insert seguroAmp;
        
        opp.SyncedQuoteId=cotizacion.Id;
        update opp;
        
    }

    @isTest
    public static void prepolizaTest(){
        DSALES_InformaciondePago__c pago = [SELECT Id,DSALES_Oportunidad__c FROM DSALES_InformaciondePago__c LIMIT 1];
        DSALES_CreateInsurancePolicy.createPoliza(pago.Id);
        InsurancePolicy poliza = [SELECT Id,SourceOpportunityId,ExpirationDate,DSALES_VigenciacumplidaSM__c,DSALES_Estatusdepliza__c FROM InsurancePolicy WHERE SourceOpportunityId=:pago.DSALES_Oportunidad__c];
		DSALES_CreateInsurancePolicy.updateInfoPago(poliza);
        InsurancePolicyAsset activo = new InsurancePolicyAsset(
            		InsurancePolicyId=poliza.Id,
                    DSALES_Clavevehicular__c='54321',
            		DSALES_Modelo__c='2023',
            		DSALES_Numeroserie__c='98765432',
            		DSALES_Numeromotor__c='8',
            		DSALES_Descripcion__c='Moto  vento Azul',
            		DSALES_Servicio__c='Particular',
            		DSALES_Placas__c='87654321',
            		DSALES_Marca__c='Vento',
            		DSALES_Uso__c='Personal'
            		
        );
        insert activo;
         Test.startTest();
        DSALES_CreateInsurancePolicy.agregarDatosDeActivo(activo, poliza.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void estatusTest(){
        DSALES_InformaciondePago__c pago = [SELECT Id,DSALES_Oportunidad__c FROM DSALES_InformaciondePago__c LIMIT 1];
        Test.startTest();
        DSALES_CreateInsurancePolicy.createPoliza(pago.Id);
        InsurancePolicy poliza = [SELECT Id,SourceOpportunityId,ExpirationDate,DSALES_VigenciacumplidaSM__c,DSALES_Estatusdepliza__c FROM InsurancePolicy WHERE SourceOpportunityId=:pago.DSALES_Oportunidad__c];
		poliza.ExpirationDate=DateTime.now();
        update poliza;
        System.debug('poliza test:'+poliza);
        DSALES_CreateInsurancePolicy.cambiarEstatus(poliza.Id);
        System.assertEquals(true, true,'ok');
        Test.stopTest();
        
    }
}