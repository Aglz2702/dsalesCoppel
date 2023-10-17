@isTest
public with sharing class DSALES_VentaSC_Test {
    @testSetup
    static void creacionRegistros(){
        String tipoProducto = 'Producto';
        String message = '';
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('dsalesSeguroCelulares').getRecordTypeId();
        String recordTypeAccountId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        String  quoteRecordType = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('dsalesVentaSeguroCelulares').getRecordTypeId();
        Product2 seguroCel = new Product2(Name ='Seguro de celulares',dsalesVehiculo__c='23d23d23',DSales_Tipo_de_Producto__c='Seguro',IsActive=true);
		insert seguroCel;
        Product2 celular = new Product2(Name ='Iphone 14',dsalesVehiculo__c='lasicndsldicsid',StockKeepingUnit='121212',DSales_Tipo_de_Producto__c='Producto',IsActive=true);
		insert celular;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = seguroCel.Id;
        standardPrice.UnitPrice = 1000;
        standardPrice.IsActive = true;
        insert standardPrice;
        
        PricebookEntry standardPriceCel = new PricebookEntry();
        standardPriceCel.Pricebook2Id = pricebookId;
        standardPriceCel.Product2Id = celular.Id;
        standardPriceCel.UnitPrice = 1000;
        standardPriceCel.IsActive = true;
        insert standardPriceCel;    
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        PricebookEntry customPrice = new PricebookEntry();
        customPrice.Pricebook2Id = customPB.Id;
        customPrice.Product2Id = seguroCel.Id;
        customPrice.UnitPrice = 1200;
        customPrice.IsActive = true;
        insert customPrice;
        Account acc = new Account();
        acc.RecordTypeId=recordTypeAccountId;
        acc.FirstName='RICARDO';
        acc.LastName='NORIEGA';
        acc.Suffix='GUERRERO';
        acc.PersonEmail='saymartinez@deloittemx.com';
        acc.BillingPostalCode='123';
        acc.CP_BillingStateCode__c='123';
        insert acc;
        Opportunity opp = new Opportunity(Name='Oportunidad Seguro Celular', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '2';
        insert t;
        Quote cotizacion = new Quote(RecordTypeId=quoteRecordType,OpportunityId=opp.Id,Name='test',DSales_Tienda__c=t.Id);
        insert cotizacion;
        Plazo__c plazo12 = new Plazo__c();
        plazo12.Name='12';
        plazo12.dsalesSeguro__c=seguroCel.Id;
        plazo12.Dsales_Plazo__c='12';
        plazo12.DSALES_Activo__c=true;
        insert plazo12;

        Plazo__c plazo18 = new Plazo__c();
        plazo18.Name='18';
        plazo18.dsalesSeguro__c=seguroCel.Id;
        plazo18.Dsales_Plazo__c='18';
        plazo18.DSALES_Activo__c=true;
        insert plazo18;
        QuoteLineItem seguro12 = new QuoteLineItem();
        seguro12.QuoteId = cotizacion.Id;
        seguro12.PricebookEntryId = customPrice.Id;
        seguro12.Product2Id = seguro12.Id;
        seguro12.Quantity = 1.0;
        seguro12.UnitPrice = customPrice.UnitPrice;
        seguro12.DSALES_Plazo__c=plazo12.Id;
        insert seguro12;
        
        QuoteLineItem seguro18 = new QuoteLineItem();
        seguro18.QuoteId = cotizacion.Id;
        seguro18.PricebookEntryId = customPrice.Id;
        seguro18.Product2Id = seguroCel.Id;
        seguro18.Quantity = 1.0;
        seguro18.UnitPrice = customPrice.UnitPrice;
        seguro18.DSALES_Plazo__c=plazo18.Id;
        seguro18.DSALES_Segurogratis__c=false;
        insert seguro18;
        QuoteLineItem celSeguro = new QuoteLineItem();
        celSeguro.QuoteId = cotizacion.Id;
        celSeguro.PricebookEntryId = customPrice.Id;
        celSeguro.Product2Id = celular.Id;
        celSeguro.Quantity = 1.0;
        celSeguro.UnitPrice = customPrice.UnitPrice;
        insert celSeguro;
    }
    @isTest
    public static void ventaSeguroyCelTest(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        Plazo__c plazo=[SELECT Id FROM Plazo__c WHERE Name='12' LIMIT 1];
        Quote cot =[SELECT Id,OpportunityId,Opportunity.Name FROM Quote WHERE Name='test' LIMIT 1];
       	QuoteLineItem partida =[SELECT Id FROM QuoteLineItem WHERE  QuoteId=:cot.Id AND DSALES_Tipodeproducto__c='Seguro' LIMIT 1];
        String body='{"servico":"CELULAR","idCotizacion":"'+cot.Id+'","idPartidaPresupuesto":["'+partida.Id+'"],"pagos":{"idUniversal":"206009199675811316521524","tipoFolio":"01","folioTransaccion":"614100","totalFactura":null,"precioRedondeado":803,"seguro":true,"nombreVendedor":"ELIBERT FERNANDO PARRA BAEZ","numeroCaja":"33","claveTienda":"2","sku":"121212","fechaVenta":"2022-09-26","plazos":12,"ListaDePagos":[{"metodoPago":"Efectivo","pago":32707}]},"beneficiarioPreferente":true,"contratante":"false","envioContratante":true,"datosParticipantes":[{"figura":"contratante","numeroCliente":"","nombre":"RICARDO","apellidoPaterno":"NORIEGA","apellidoMaterno":"GUERRERO","telefono":"1234567890","relacionConParticipante":"","porcentaje":"0","correoElectronico":"saymartinez@deloittemx.com","genero":"M","fechaNacimiento":"1987-09-23","rfc":"NOGR001011","codigoPostal":99010,"codigoEstado":"32","codigoCiudad":"10","codigoColonia":"2","calle":"TAYAHUA","numeroExterior":"218","numeroInterior":"0","curp":"MAQS9834582DURN","regimenFiscal":1345,"nacionalidad":"Mexicana"}],"activo":{"emitirPoliza":true,"imei":99,"almacenamiento":32,"cpu":12.3,"tamanoPantalla":6,"precio":1230,"ram":4,"operadorTelefonico":"AT&T","annio":2023,"color":"azul","nombreActivo":"Iphone 14"}}';
        DSALES_VentaSM.VentaSMRequest venta =(DSALES_VentaSM.VentaSMRequest)JSON.deserialize (body,DSALES_VentaSM.VentaSMRequest.class);
        Test.startTest();
        //Opportunity oportunidad =[SELECT Id,StageName,SyncedQuoteId FROM Opportunity WHERE Id=:cot.OpportunityId];
        DSALES_VentaSM.VentaSMResponse respuesta =DSALES_VentaSCRest.crearVenta(venta);
        /*System.debug('datos de retorno en test_____'+respuesta);
        List<OpportunityLineItem> listaPartidas=DSALES_VentaSCRest.obtenerPartidasSincronizadas(oportunidad);
        System.debug('test:: lista partidas sincronizadas_______-'+listaPartidas);*/
        Opportunity oportunidad =[SELECT Id,StageName,SyncedQuoteId FROM Opportunity WHERE Id=:cot.OpportunityId];
        System.debug('oportunidad en test:  '+oportunidad);
        
        //DSALES_VentaSCRest.consultarCotizacionAEliminar(cot.OpportunityId,cot.Id);
        DSALES_EliminarRegistrosDeVenta.IdsBorrar datos= new DSALES_EliminarRegistrosDeVenta.IdsBorrar();
        datos.idCotPrincipal=cot.Id;
        datos.idCotSincro=oportunidad.SyncedQuoteId;
        DSALES_EliminarRegistrosDeVenta.eliminarRegistros(oportunidad, datos);
        Test.stopTest();
        System.assertNotEquals(true, respuesta.exito, 'OK');
    }

    
}