@isTest
public class DSALES_CancelacionControllerTest {
    @testSetup
    static void configuracionRegistro(){
        String tipoProducto = 'Producto';
        String message = '';
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Seguro_de_Moto').getRecordTypeId();
        String recordTypeIdGex = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DSales_Garantia_Extendida').getRecordTypeId();
		String recordTypeIdPagoM = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_PagosdeVentaenNPVSM_c').getRecordTypeId();
        String recordTypeIdPagoG = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_Pagos_en_NPV').getRecordTypeId();
		String recordTypeIdAsset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Garantia Extendida').getRecordTypeId();
        String recordTypeIdProd = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('DSales_Garantia_Extendida').getRecordTypeId();
        String recordTypeProdMotos = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('DSales_Seguro_de_Motos').getRecordTypeId();
        String recordTypeProdSeg = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('DSALES_ProdIntangible').getRecordTypeId();
        Account acc = new Account();
        acc.Name='Sayra Martinez Quiroz';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.DSALES_ClienteCoppel__c='90001';
        insert acc;
        Contact con = new Contact(lastname= 'Test', AccountId= acc.Id, Email= 'johndoeus@salesforce.com');
        insert con;
        Product2 prodAmp = new Product2(Name ='AMP',dsalesVehiculo__c='23d23d23', StockKeepingUnit='123444',DSales_Tipo_de_Producto__c='Seguro',IsActive=true,RecordTypeId=recordTypeProdSeg);
		insert prodAmp;
        
        Product2 prodM = new Product2(Name ='Moto Vento',dsalesVehiculo__c='lasicndsldicsid',StockKeepingUnit='121213',DSales_Tipo_de_Producto__c='Producto',IsActive=true );
		insert prodM;
        
        Product2 pr= new Product2(Name='Lavadora',StockKeepingUnit='123451',DSales_Tipo_de_Producto__c='Producto',RecordTypeId=recordTypeIdProd,IsActive=true);
		insert pr;
       	Product2 gex= new Product2(Name='GEX',StockKeepingUnit='123406',DSales_Tipo_de_Producto__c='Servicio',RecordTypeId=recordTypeIdProd,IsActive=true);
		insert gex;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = prodM.Id;
        standardPrice.UnitPrice = 1200;
        standardPrice.IsActive = true;
        insert standardPrice;
        
        PricebookEntry standardPriceMoto = new PricebookEntry();
        standardPriceMoto.Pricebook2Id = pricebookId;
        standardPriceMoto.Product2Id = prodAMP.Id;
        standardPriceMoto.UnitPrice = 1000;
        standardPriceMoto.IsActive = true;
        insert standardPriceMoto;
        
        PricebookEntry standardPricePG = new PricebookEntry();
        standardPricePG.Pricebook2Id = pricebookId;
        standardPricePG.Product2Id = pr.Id;
        standardPricePG.UnitPrice = 1200;
        standardPricePG.IsActive = true;
        insert standardPricePG;
        
        PricebookEntry standardPriceGex = new PricebookEntry();
        standardPriceGex.Pricebook2Id = pricebookId;
        standardPriceGex.Product2Id = gex.Id;
        standardPriceGex.UnitPrice = 1200;
        standardPriceGex.IsActive = true;
        insert standardPriceGex;
        
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        
        PricebookEntry customPriceM = new PricebookEntry();
        customPriceM.Pricebook2Id = customPB.Id;
        customPriceM.Product2Id = prodM.Id;
        customPriceM.UnitPrice = 1000;
        customPriceM.IsActive = true;
        insert customPriceM;
        PricebookEntry customPrice = new PricebookEntry();
        customPrice.Pricebook2Id = customPB.Id;
        customPrice.Product2Id = prodAmp.Id;
        customPrice.UnitPrice = 1000;
        customPrice.IsActive = true;
        insert customPrice;
        
        PricebookEntry customPricePG = new PricebookEntry();
        customPricePG.Pricebook2Id = customPB.Id;
        customPricePG.Product2Id = pr.Id;
        customPricePG.UnitPrice = 1000;
        customPricePG.IsActive = true;
        insert customPricePG;
        
        PricebookEntry customPriceGex = new PricebookEntry();
        customPriceGex.Pricebook2Id = customPB.Id;
        customPriceGex.Product2Id = gex.Id;
        customPriceGex.UnitPrice = 1000;
        customPriceGex.IsActive = true;
        insert customPriceGex;
        
        Opportunity opp = new Opportunity(Name='Venta moto', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '1';
        insert t;
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c(
                                      	DSALES_IDUniversal1__c='0000000000000000000001',
              							DSALES_Cliente__c=acc.Id,
              							DSALES_Oportunidad__c=opp.Id,
              							DSALES_Seguro__c=true,
            							DSALES_Motoentregada__c=true,
            							DSALES_Motoexterna__c=false,
              							RecordTypeId=recordTypeIdPagoM
                                      
                                      
          );
        insert pago;
       
        Quote cotizacion = new Quote(OpportunityId=opp.Id,Name='test',DSales_Tienda__c=t.Id);
        insert cotizacion;
     
		Plazo__c plazoAMP12 = new Plazo__c(Name='12',Dsales_Plazo__c='12',dsalesSeguro__c=prodAmp.Id,dsales_Activo__c=true);
        insert plazoAMP12;
        
        QuoteLineItem moto = new QuoteLineItem();
        moto.QuoteId = cotizacion.Id;
        moto.PricebookEntryId = customPriceM.Id;
        moto.Product2Id = prodM.Id;
        moto.Quantity = 1.0;
        moto.UnitPrice = customPriceM.UnitPrice;
        moto.DSALES_Segurogratis__c=false;
        insert moto;
        opp.SyncedQuoteId  = cotizacion.Id;     
       	update opp;
      	InsurancePolicy poliza = new InsurancePolicy(
				SourceOpportunityId=opp.Id,
            	dsalesEstatusPoliza__c='Prepoliza',
        		NameInsuredId=acc.Id,
                DSALES_Tipodepersona__c='Física',
            	DSALES_CorreoElectronico__c='saymartinez@deloittemx.com',
            	Name='1234567890',
            	SourceQuoteId=cotizacion.Id
                
        );
        insert poliza;
        pago.DSALES_Poliza__c=poliza.Id;
        update pago;
        InsurancePolicyAsset activo = new InsurancePolicyAsset (
            					
                            	InsurancePolicyId=poliza.Id,
            					AssetName='MOTO VENTO',
            					DSALES_InformacionPago__c=pago.Id,
            					dsalesCliente__c=acc.Id,
            					dsalesEstatus__c='Activo',
            					DSALES_Motoexterna__c=false
        );
        insert activo;
        poliza.dsalesActivoPolizaSeguro__c=activo.Id;
        update poliza;
        
    }
    @isTest
    public static void cancelarPolizaTest(){
        Opportunity op =[SELECT Id FROM Opportunity WHERE Name='Venta moto' LIMIT 1 ];
        List<OpportunityLineItem> partidas =[SELECT Id,Name,Product2.Id FROM OpportunityLineItem WHERE OpportunityId=:op.Id];
        InsurancePolicy poliza =[SELECT Id,dsalesActivoPolizaSeguro__c FROM InsurancePolicy LIMIT 1];
        System.debug(partidas.size()+'Name: '+ partidas);
        Product2 prod =[SELECT Id,DSales_Tipo_de_Producto__c FROM Product2 WHERE Id =:partidas[0].Product2.Id];
        System.debug('prod: '+ prod);
        DSALES_CancelacionController.escenarioPolizaActRegistros(partidas,poliza);
        //DSALES_CancelacionController.obtenerActivo(partidas);
    }
     @isTest
    public static void obtenerActivo(){
        Opportunity op =[SELECT Id FROM Opportunity WHERE Name='Venta moto' LIMIT 1 ];
        List<OpportunityLineItem> partidas =[SELECT Id,Name,Product2.Id FROM OpportunityLineItem WHERE OpportunityId=:op.Id];
        InsurancePolicy poliza =[SELECT Id,dsalesActivoPolizaSeguro__c FROM InsurancePolicy LIMIT 1];
        System.debug(partidas.size()+'Name: '+ partidas);
        Product2 prod =[SELECT Id,DSales_Tipo_de_Producto__c FROM Product2 WHERE Id =:partidas[0].Product2.Id];
        System.debug('prod: '+ prod);
        DSALES_CancelacionController.obtenerActivo(partidas);
        DSALES_CancelacionController.obtenerIdPago(partidas);
    }

}