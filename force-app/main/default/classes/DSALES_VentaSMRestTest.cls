@istest
public with sharing class DSALES_VentaSMRestTest {
   @testSetup
    static void creacionRegistros(){
        String tipoProducto = 'Producto';
        String message = '';
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Seguro_de_Moto').getRecordTypeId();
        String recordTypeAccountId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        String  quoteRecordType = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Venta de Seguro de Motos').getRecordTypeId();
        Product2 prodRc = new Product2(Name ='RC',	dsalesVehiculo__c='sadkncdcs' ,StockKeepingUnit='0000',DSales_Tipo_de_Producto__c='Seguro',IsActive=true);
		insert prodRc;
        
        Product2 prodAmp = new Product2(Name ='PLUS',	dsalesVehiculo__c='23d23d23', StockKeepingUnit='123444',DSales_Tipo_de_Producto__c='Seguro',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
		insert prodAmp;
        
        Product2 prodM = new Product2(Name ='Moto',	dsalesVehiculo__c='lasicndsldicsid',StockKeepingUnit='12121212',DSales_Tipo_de_Producto__c='Producto',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
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
        acc.RecordTypeId=recordTypeAccountId;
        acc.FirstName='Sayra';
        acc.LastName='Martinez';
        acc.Suffix='Quiroz';
        acc.PersonEmail='saymartinez@deloittemx.com';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.BillingPostalCode='123';
        acc.CP_BillingStateCode__c='123';
        insert acc;
        Account coppel = new Account();
        coppel.RecordTypeId=recordTypeAccountId;
        coppel.FirstName='COPPEL';
        coppel.LastName='SA';
        coppel.Suffix='DE CV';
        coppel.BillingPostalCode='123';
        coppel.dsalesNumeroExterior__c='12';
        coppel.CP_BillingStateCode__c='12';
        insert coppel;
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '1';
        insert t;
        Quote cotizacion = new Quote(RecordTypeId=quoteRecordType,OpportunityId=opp.Id,Name='test',DSales_Tienda__c=t.Id);
        insert cotizacion;
        DSALES_TipodeUso__c tipoUso = new DSALES_TipodeUso__c(Name='Comercial');
        insert tipoUso;
        DSALES_Tipodevehculo__c tipovehiculo = new DSALES_Tipodevehculo__c(Name='Moto');
        insert tipovehiculo;
        
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
        
        Plazo__c plazoAMP12 = new Plazo__c(Name='12',Dsales_Plazo__c='12',	dsalesSeguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazoAMP12;
         Plazo__c plazoAMP18 = new Plazo__c(Name='18',Dsales_Plazo__c='18',	dsalesSeguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazoAMP18;
        
        QuoteLineItem seguroRcG = new QuoteLineItem();
        seguroRcG.QuoteId = cotizacion.Id;
        seguroRcG.PricebookEntryId = customPrice.Id;
        seguroRcG.Product2Id = prodRc.Id;
        seguroRcG.Quantity = 1.0;
        seguroRcG.UnitPrice = customPrice.UnitPrice;
        seguroRcG.DSALES_Plazo__c=plazoRC12.Id;
        seguroRcG.DSALES_Segurogratis__c=false;
        insert seguroRcG;
        
        QuoteLineItem seguroAmp = new QuoteLineItem();
        seguroAmp.QuoteId = cotizacion.Id;
        seguroAmp.PricebookEntryId = customPrice.Id;
        seguroAmp.Product2Id = prodAmp.Id;
        seguroAmp.Quantity = 1.0;
        seguroAmp.UnitPrice = customPrice.UnitPrice;
        seguroAmp.DSALES_Plazo__c=plazoAMP12.Id;
        seguroAmp.DSALES_Segurogratis__c=false;
        insert seguroAmp;
    }
    
    
    @isTest
    public static void ventaExternaTest(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        Plazo__c plazo=[SELECT Id FROM Plazo__c WHERE Name='12' LIMIT 1];
        Quote cot =[SELECT Id,OpportunityId,Opportunity.Name FROM Quote  LIMIT 1];
        QuoteLineItem partida =[SELECT Id FROM QuoteLineItem WHERE  QuoteId=: cot.Id AND DSALES_Tipodeproducto__c='Seguro' LIMIT 1];
		String idPartida=partida.Id;
        System.debug('TEST COTIZACION:'+cot);
        System.debug('TEST SEGURO:'+partida);
        String body='{"servico":"","idCotizacion":"'+cot.Id+'","idPartidaPresupuesto":["'+partida.Id+'"],"pagos":{"idUniversal":"20600919967516521534","tipoFolio":"01","folioTransaccion":"614100","precioRedondeado":803,"seguro":true,"nombreVendedor":"ELIBERT FERNANDO PARRA BAEZ","numeroCaja":"33","claveTienda":"1","sku":"","fechaVenta":"2022-10-09","plazos":12,"ListaDePagos":[{"metodoPago":"Efectivo","pago":32707}]},"beneficiarioPreferente":true,"contratante":"false","envioContratante":false,"datosParticipantes":[{"figura":"Conductor","numeroCliente":"","nombre":"RICARDO","apellidoPaterno":"NORIEGA","apellidoMaterno":"GUERRERO","telefono":"1234567890","relacionConParticipante":"","porcentaje":"0","correoElectronico":"saymartinez@deloittemx.com","genero":"M","fechaNacimiento":"1987-09-23","rfc":"NOGR001011","codigoPostal":99010,"codigoEstado":"32","codigoMunicipio":"12","codigoCiudad":"10","codigoColonia":"2","calle":"TAYAHUA","numeroExterior":"218","numeroInterior":"0","curp":"MAQS9834582DURN","regimenFiscal":1345,"nacionalidad":"Mexicana"}],"activo":{"emitirPoliza":true,"uso":"NORMAL","claveTienda":"2","servicio":"Particular","numeroSerie":"1HGCF9540WA609671","numeroMotor":"","modelo":"2021","placas":"","claveVehicular":"","valorFactura":0,"bajoDemanda":true,"descripcion":"","marca":"HONDA","nombreActivo":"test"}}';
        request.requestURI='/apexrest/ventaSM'; 
        request.httpMethod='POST'; 
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        Boolean envioContratante =false;
        DSALES_VentaSM.VentaSMRequest venta =(DSALES_VentaSM.VentaSMRequest)JSON.deserialize (body,DSALES_VentaSM.VentaSMRequest.class);
        Test.startTest();
        DSALES_VentaSMRest.crearVenta();
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200');
    }
    
    
}