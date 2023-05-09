@isTest
public class DSALES_CancelacionProductosRequest_Test {
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
        acc.dsalesClienteCoppel='90001';
        insert acc;
        Contact con = new Contact(lastname= 'Test', AccountId= acc.Id, Email= 'johndoeus@salesforce.com');
        insert con;
        Product2 prodAmp = new Product2(Name ='AMP',DSALES_vehculo__c='23d23d23', StockKeepingUnit='123444',DSales_Tipo_de_Producto__c='Seguro',IsActive=true,RecordTypeId=recordTypeProdSeg);
		insert prodAmp;
        
        Product2 prodM = new Product2(Name ='Moto Vento',DSALES_vehculo__c='lasicndsldicsid',StockKeepingUnit='121213',DSales_Tipo_de_Producto__c='Producto',IsActive=true );
		insert prodM;
        
        Product2 pr= new Product2(Name='Lavadora',StockKeepingUnit='123451',DSales_Tipo_de_Producto__c='Producto',RecordTypeId=recordTypeIdProd,IsActive=true);
		insert pr;
       	Product2 gex= new Product2(Name='GEX',StockKeepingUnit='123456',DSales_Tipo_de_Producto__c='Servicio',RecordTypeId=recordTypeIdProd,IsActive=true);
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
        Opportunity oppGex = new Opportunity(Name='GEX', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeIdGex);
        insert oppGex;
        
        Tienda__c t = new Tienda__c();
        t.dsalesTiendaID__c =  '1';
        insert t;
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c(
                                      	DSALES_IDUniversal1__c='0000000000000000000001',
              							DSALES_Cliente__c=acc.Id,
              							DSALES_Oportunidad__c=opp.Id,
              							dsalesSeguro__c=true,
              							RecordTypeId=recordTypeIdPagoM
                                      
                                      
          );
        insert pago;
        DSALES_InformacionDePago__c pagoGex = new DSALES_InformacionDePago__c(RecordTypeId=recordTypeIdPagoG,DSALES_Oportunidad__c=oppGex.id,DSALES_Factura__c='1234',DSALES_Clave_Tienda__c='1',DSALES_IDUniversal1__c='11111111111111111110');
        insert pagoGex;
        Asset ass = new Asset(Name='Test',AccountId= acc.Id,ContactId=con.Id,DSALES_SKU__c='123450',DSales_Informacion_pago__c=pagoGex.Id,Product2Id=pr.id,DSALES_TipoProducto__c='Producto',RecordTypeId=recordTypeIdAsset);
        insert ass; 
        DSALES_Certificado__c certificado = new DSALES_Certificado__c(DSALES_Email__c='dsanmiguel@deloittemx.com',DSALES_ProductoAdquirido__c=ass.id,
                                                                     DSALES_InformacionDePago__c=pagoGex.id);
        insert certificado;
        Quote cotizacion = new Quote(OpportunityId=opp.Id,Name='test',DSales_Tienda__c=t.Id);
        insert cotizacion;
        Quote cotGex = new Quote(OpportunityId=oppGex.Id,Name='GEX',DSales_Tienda__c=t.Id);
        insert cotGex;
		Plazo__c plazoAMP12 = new Plazo__c(Name='12',dsalesPlazo__c='12',dsalesSeguro__c=prodAmp.Id,dsalesActivo__c=true);
        insert plazoAMP12;
        
        QuoteLineItem moto = new QuoteLineItem();
        moto.QuoteId = cotizacion.Id;
        moto.PricebookEntryId = customPriceM.Id;
        moto.Product2Id = prodM.Id;
        moto.Quantity = 1.0;
        moto.UnitPrice = customPriceM.UnitPrice;
        moto.DSALES_Segurogratis__c=false;
        insert moto;
        QuoteLineItem seguroAmp = new QuoteLineItem();
        seguroAmp.QuoteId = cotizacion.Id;
        seguroAmp.PricebookEntryId = customPrice.Id;
        seguroAmp.Product2Id = prodAmp.Id;
        seguroAmp.Quantity = 1.0;
        seguroAmp.UnitPrice = customPrice.UnitPrice;
        seguroAmp.dsalesPlazo__c=plazoAMP12.Id;
        seguroAmp.DSALES_Segurogratis__c=false;
        insert seguroAmp;
        opp.SyncedQuoteId  = cotizacion.Id;     
       	update opp;
        QuoteLineItem lavadora = new QuoteLineItem();
        lavadora.QuoteId = cotGex.Id;
        lavadora.PricebookEntryId = customPricePG.Id;
        lavadora.Product2Id = pr.Id;
        lavadora.Quantity = 1.0;
        lavadora.UnitPrice = customPricePG.UnitPrice;
        insert lavadora;
        QuoteLineItem qliGex = new QuoteLineItem();
        qliGex.QuoteId = cotGex.Id;
        qliGex.PricebookEntryId = customPriceGex.Id;
        qliGex.Product2Id = gex.Id;
        qliGex.Quantity = 1.0;
        qliGex.UnitPrice = customPriceGex.UnitPrice;
        insert qliGex;
        
        oppGex.SyncedQuoteId  = cotGex.Id;     
       	update oppGex;
      	InsurancePolicy poliza = new InsurancePolicy(
				SourceOpportunityId=opp.Id,
            	DSALES_Estatusdepliza__c='Vigente',
        		NameInsuredId=acc.Id,
                DSALES_Tipodepersona__c='Física',
            	DSALES_CorreoElectronico__c='saymartinez@deloittemx.com',
            	Name='1234567890'
                
        );
        insert poliza;
        pago.DSALES_Poliza__c=poliza.Id;
        update pago;
        InsurancePolicyAsset activo = new InsurancePolicyAsset (
            					
                            	InsurancePolicyId=poliza.Id,
            					AssetName='MOTO VENTO',
            					DSALES_InformacionPago__c=pago.Id,
            					DSALES_Account__c=acc.Id,
            					Estatus__c='Activo',
            					DSALES_Motoexterna__c=true
        );
        insert activo;
        poliza.DSALES_Activodeplizadeseguro__c=activo.Id;
        update poliza;
        
    }
   
    @isTest
    public static void cancelacionMotoySeguro(){
        RestRequest request=new RestRequest();
       	RestResponse response = new RestResponse();
        DSALES_InformacionDePago__c pago =[SELECT Id, RecordTypeId,DSALES_IDUniversal1__c,DSALES_Poliza__c,DSALES_Nombre_del_cliente__c FROM DSALES_InformacionDePago__c WHERE dsalesSeguro__c=true];
       	Product2 prod=[SELECT Id, Name, DSales_Tipo_de_Producto__c FROM Product2 WHERE Name='Moto Vento'];
        List<OpportunityLineItem> productosSincro =[SELECT Id,Name,DSALES_Estatus__c FROM OpportunityLineItem  WHERE Product2.Name=:'Moto Vento'];
       	OpportunityLineItem prodSincro =[SELECT Id,Name,DSALES_Estatus__c FROM OpportunityLineItem WHERE Product2.Name='AMP'];
        productosSincro.add(prodSincro);
        String bodyJson='{"canal":".EXE","fechaCancelacion":"2023-03-22","folioCancelacion":"12876","idUniversal":"'+pago.DSALES_IDUniversal1__c+'","idTienda":"1","numeroCliente":"","nombreVendedor":"Luis Perez Sanchez","numeroVendedor":"1234","estatus":"Devuelto","motivoCancelacion":"A petición del cliente","ListaProductos":[{"idPartidaOportunidad":"'+productosSincro[0].Id+'","estatus":"Devuelto","motivoCancelacion":"A petición del cliente","idCertificado":""},{"idPartidaOportunidad":"'+productosSincro[1].Id+'","estatus":"Devuelto","motivoCancelacion":"A petición del cliente","idCertificado":""}],"ListaReembolso":[{"comentarios":"El cliente decidió cancelar el producto","fechaReembolso":"2023-02-24","nombreProducto":"MOTO","metodoPago":"Efectivo","numeroReferencia":"1123456621","cantidadReembolsada":15005},{"comentarios":"El cliente decidió cancelar el producto","fechaReembolso":"2023-02-24","nombreProducto":"AMP","metodoPago":"Efectivo","numeroReferencia":"1123456621","cantidadReembolsada":15005}]}';
        request.requestURI='/apexrest/cancelacionProductos/*'; 
        request.httpMethod='POST'; 
        RestContext.request=request;
        request.requestBody=Blob.valueOf(bodyJson);
        RestContext.response=response;
        DSALES_CancelacionProductosWrapper.request requestCancelar =(DSALES_CancelacionProductosWrapper.request)JSON.deserialize (bodyJson,DSALES_CancelacionProductosWrapper.request.class);
        RestContext.request = request;
        RestContext.response= response;
        Test.startTest();
        DSALES_CancelacionProductosRequest.servicioCancelar();
        Test.stopTest();
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200');

    } 
    @isTest
    public static void devolucionMotoySeguro(){
        RestRequest request=new RestRequest();
       	RestResponse response = new RestResponse();
        DSALES_InformacionDePago__c pago =[SELECT Id, RecordTypeId,DSALES_IDUniversal1__c,DSALES_Poliza__c,DSALES_Nombre_del_cliente__c FROM DSALES_InformacionDePago__c WHERE dsalesSeguro__c=true];
        List<Product2> productos=[SELECT Id, Name, DSales_Tipo_de_Producto__c FROM Product2];
        List<OpportunityLineItem> productosSincro =[SELECT Id,Name,DSALES_Estatus__c FROM OpportunityLineItem WHERE Opportunity.Name='Venta moto'];
        String bodyJson='{"canal":".EXE","fechaCancelacion":"2023-03-22","folioCancelacion":"12876","idUniversal":"'+pago.DSALES_IDUniversal1__c+'","idTienda":"1","numeroCliente":"","nombreVendedor":"Luis Perez Sanchez","numeroVendedor":"1234","estatus":"Devuelto","motivoCancelacion":"A petición del cliente","ListaProductos":[{"idPartidaOportunidad":"'+productosSincro[0].Id+'","estatus":"Devuelto","motivoCancelacion":"A petición del cliente","idCertificado":""},{"idPartidaOportunidad":"'+productosSincro[1].Id+'","estatus":"Devuelto","motivoCancelacion":"A petición del cliente","idCertificado":""}],"ListaReembolso":[{"comentarios":"El cliente decidió cancelar el producto","fechaReembolso":"2023-02-24","nombreProducto":"MOTO","metodoPago":"Efectivo","numeroReferencia":"1123456621","cantidadReembolsada":15005},{"comentarios":"El cliente decidió cancelar el producto","fechaReembolso":"2023-02-24","nombreProducto":"AMP","metodoPago":"Efectivo","numeroReferencia":"1123456621","cantidadReembolsada":15005}]}';
        request.requestURI='/apexrest/cancelacionProductos/*'; 
        request.httpMethod='POST'; 
        RestContext.request=request;
        request.requestBody=Blob.valueOf(bodyJson);
        RestContext.response=response;
        DSALES_CancelacionProductosWrapper.request requestCancelar =(DSALES_CancelacionProductosWrapper.request)JSON.deserialize (bodyJson,DSALES_CancelacionProductosWrapper.request.class);
        RestContext.request = request;
        RestContext.response= response;
        Test.startTest();
 		DSALES_CancelacionProductosRequest.servicioCancelar();
        Test.stopTest();
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200');

    } 
    @isTest
    public static void devolucionGex(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        DSALES_InformacionDePago__c pago =[SELECT Id, RecordTypeId,DSALES_IDUniversal1__c,DSALES_Poliza__c,DSALES_Nombre_del_cliente__c FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c=:'11111111111111111110'];
        DSALES_Certificado__c certificado  =[SELECT Id,Name FROM DSALES_Certificado__c LIMIT 1];
        Product2 producto =[SELECT Id, Name, DSales_Tipo_de_Producto__c FROM Product2 WHERE Name='Lavadora'];
        List<Product2> productos=[SELECT Id, Name, DSales_Tipo_de_Producto__c FROM Product2 WHERE DSales_Tipo_de_Producto__c='Servicio'];
        productos.add(producto); 
        OpportunityLineItem productosSincro =[SELECT Id,Name,DSALES_Estatus__c FROM OpportunityLineItem WHERE Opportunity.Name='GEX' AND Product2.Name=:'Gex' ];
        String bodyJson='{"canal":".EXE","fechaCancelacion":"2023-03-22","folioCancelacion":"12876","idUniversal":"'+pago.DSALES_IDUniversal1__c+'","idTienda":"1","numeroCliente":"","nombreVendedor":"Luis Perez Sanchez","numeroVendedor":"1234","estatus":"Devuelto","motivoCancelacion":"A petición del cliente","ListaProductos":[{"idPartidaOportunidad":"'+productosSincro.Id+'","estatus":"Devuelto","motivoCancelacion":"A petición del cliente","idCertificado":"'+certificado.Name+'"}],"ListaReembolso":[{"comentarios":"El cliente decidió cancelar el producto","fechaReembolso":"2023-02-24","nombreProducto":"AMP","metodoPago":"Efectivo","numeroReferencia":"1123456621","cantidadReembolsada":15005}]}';
        request.requestURI='/apexrest/cancelacionProductos/*'; 
        request.httpMethod='POST'; 
        RestContext.request=request;
        request.requestBody=Blob.valueOf(bodyJson);
        RestContext.response=response;
        DSALES_CancelacionProductosWrapper.request requestCancelar =(DSALES_CancelacionProductosWrapper.request)JSON.deserialize (bodyJson,DSALES_CancelacionProductosWrapper.request.class);
        RestContext.request = request;
        RestContext.response= response;
        Test.startTest();
        DSALES_CancelacionProductosRequest.servicioCancelar();
        Test.stopTest();
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200');

    } 
    @isTest
    public static void cancelacionGex(){
        RestRequest request=new RestRequest();
       	RestResponse response = new RestResponse();
        DSALES_InformacionDePago__c pago =[SELECT Id, RecordTypeId,DSALES_IDUniversal1__c,DSALES_Poliza__c,DSALES_Nombre_del_cliente__c FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c=:'11111111111111111110'];
       	Product2 producto =[SELECT Id, Name, DSales_Tipo_de_Producto__c FROM Product2 WHERE Name='Lavadora'];
        List<Product2> productos=[SELECT Id, Name, DSales_Tipo_de_Producto__c FROM Product2 WHERE DSales_Tipo_de_Producto__c='Servicio'];
        productos.add(producto);
        OpportunityLineItem productosSincro =[SELECT Id,Name,DSALES_Estatus__c FROM OpportunityLineItem WHERE Opportunity.Name='GEX' AND Product2.Name=:'Lavadora'];
        String bodyJson='{"canal":".EXE","fechaCancelacion":"2023-03-22","folioCancelacion":"12876","idUniversal":"'+pago.DSALES_IDUniversal1__c+'","idTienda":"1","numeroCliente":"","nombreVendedor":"Luis Perez Sanchez","numeroVendedor":"1234","estatus":"Devuelto","motivoCancelacion":"A petición del cliente","ListaProductos":[{"idPartidaOportunidad":"","estatus":"","motivoCancelacion":"","idCertificado":""},{"idPartidaOportunidad":"","estatus":"","motivoCancelacion":"","idCertificado":""}],"ListaReembolso":[{"comentarios":"El cliente decidió cancelar el producto","fechaReembolso":"2023-02-24","nombreProducto":"MOTO","metodoPago":"Efectivo","numeroReferencia":"1123456621","cantidadReembolsada":15005}]}';
        request.requestURI='/apexrest/cancelacionProductos/*'; 
        request.httpMethod='POST'; 
        RestContext.request=request;
        request.requestBody=Blob.valueOf(bodyJson);
        RestContext.response=response;
        DSALES_CancelacionProductosWrapper.request requestCancelar =(DSALES_CancelacionProductosWrapper.request)JSON.deserialize (bodyJson,DSALES_CancelacionProductosWrapper.request.class);
        RestContext.request = request;
        RestContext.response= response;
        Test.startTest();
        DSALES_CancelacionProductosRequest.servicioCancelar();
        Test.stopTest();
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200');

    }
    
    @isTest
    public static void wrapperTest(){
        DSALES_CancelacionProductosWrapper.request req= new DSALES_CancelacionProductosWrapper.request();
        req.estatus='Cancelado';
        req.numeroCliente='12';
        req.motivoCancelacion='A petición del cliente';
        DSALES_CancelacionProductosWrapper.ListaProducto listaProducto = new DSALES_CancelacionProductosWrapper.ListaProducto();
        listaProducto.idCertificado='GEX-023';
        System.assertNotEquals(null,listaProducto,'La lista no debe estar vacia');

    }    
    @isTest
    public static void polizaCancelada(){
		DSALES_InformacionDePago__c pago =[SELECT Id, RecordTypeId,DSALES_IDUniversal1__c,DSALES_Poliza__c,DSALES_Nombre_del_cliente__c FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c=:'11111111111111111110'];
        InsurancePolicy poliza=[SELECT Id,DSALES_Estatusdepliza__c,SourceOpportunityId,DSALES_Activodeplizadeseguro__c FROM InsurancePolicy WHERE Name='1234567890'];   
        poliza.DSALES_Estatusdepliza__c='Cancelada';
        update poliza;
        DSALES_CancelacionProductosRequest.cancelarPartidaDeSeguro(poliza);
        System.assertNotEquals(null, poliza, 'El registro no debe estar en null');

    }
}