@istest
public with sharing class DSALES_VentaSMRestTest {
    /*
   @testSetup
    static void creacionRegistros(){
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
        
        Product2 prodRc = new Product2(Name ='RC',dsalesVehiculo__c='sadkncdcs' ,StockKeepingUnit='0000',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',IsActive=true);
		insert prodRc;
        
        Product2 prodAmp = new Product2(Name ='AMP',dsalesVehiculo__c='23d23d23', StockKeepingUnit='123444',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
		insert prodAmp;
        
        Product2 prodM = new Product2(Name ='Moto',dsalesVehiculo__c='lasicndsldicsid',StockKeepingUnit='12121212',DSales_Tipo_de_Producto__c='Producto',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
		insert prodM;
         /* Product2 prodM2 = new Product2(Name ='Moto Vento',dsalesVehiculo__c='lasicndsldicsid',StockKeepingUnit='1225473',DSales_Tipo_de_Producto__c='Producto',IsActive=true);
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
        acc.Name='Sayra Martinez Quiroz';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.DSALES_ClienteCoppel__c='90001';
        insert acc;
        
        Account accContado = new Account();
        accContado.FirstName = 'Sayra';
        accContado.LastName = 'Martinez';
        accContado.Middlename = 'Quiroz';
        accContado.PersonEmail = 'saymartinez@deloittemx.com';
        accContado.Phone='5579119743';
        accContado.PersonBirthdate = date.today();
        insert accContado;
        
        Account accContado2 = new Account();
        accContado2.FirstName = 'Sayra';
        accContado2.LastName = 'Martinez';
        accContado2.Middlename = 'Quiroz';
        accContado2.PersonEmail = 'saymartinez@deloittemx.com';
        accContado2.Phone='5579119743';
        insert accContado2;
        
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        
        Tienda__c t = new Tienda__c();
        t.dsalesTiendaID__c =  '1';
        insert t;
        
        Quote cotizacion = new Quote(OpportunityId=opp.Id,Name='test',DSales_Tienda__c=t.Id);
        insert cotizacion;
        
        DSALES_TipoUso__c tipoUso = new DSALES_TipoUso__c(Name='Comercial');
        insert tipoUso;
        DSALES_Tipodevehculo__c tipovehiculo = new DSALES_Tipodevehculo__c(Name='Moto');
        insert tipovehiculo;
        
        Plazo__c plazoRC12 = new Plazo__c();
        plazoRC12.Name='12';
        plazoRC12.dsalesSeguro__c=prodRc.Id;
        plazoRC12.DSALES_Plazo__c='12';
        plazoRC12.dsalesActivo__c=true;
        insert plazoRC12;
        
        Plazo__c plazoRC18 = new Plazo__c();
        plazoRC18.Name='18';
        plazoRC18.dsalesSeguro__c=prodRc.Id;
        plazoRC18.DSALES_Plazo__c='18';
        plazoRC18.dsalesActivo__c=true;
        insert plazoRC18;
        
        Plazo__c plazoAMP12 = new Plazo__c(Name='12',DSALES_Plazo__c='12',dsalesSeguro__c=prodAmp.Id,dsalesActivo__c=true);
        insert plazoAMP12;
         Plazo__c plazoAMP18 = new Plazo__c(Name='18',DSALES_Plazo__c='18',dsalesSeguro__c=prodAmp.Id,dsalesActivo__c=true);
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
        seguroRcG.DSALES_Segurogratis__c=false;
        insert seguroRcG;
        
        QuoteLineItem seguroAmp = new QuoteLineItem();
        seguroAmp.QuoteId = cotizacion.Id;
        seguroAmp.PricebookEntryId = customPrice.Id;
        seguroAmp.Product2Id = prodAmp.Id;
        seguroAmp.Quantity = 1.0;
        seguroAmp.UnitPrice = customPrice.UnitPrice;
        //seguroAmp.DSALES_Tipodeproducto__c = 'Producto';
        seguroAmp.DSALES_Plazo__c=plazoAMP12.Id;
        seguroAmp.DSALES_Segurogratis__c=false;
        insert seguroAmp;
    }
    
    @isTest
    public static void ventaTest(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        Product2 producto =[SELECT Id FROM Product2 WHERE Name='AMP Seguro de Moto' LIMIT 1];
        Plazo__c plazo=[SELECT Id FROM Plazo__c WHERE Name='18' LIMIT 1];
        Quote cot =[SELECT Id,OpportunityId,Opportunity.Name FROM Quote WHERE Name ='test' LIMIT 1];
        QuoteLineItem partida =[SELECT Id FROM QuoteLineItem WHERE  DSALES_Plazo__c=:plazo.Id LIMIT 1];
		SYstem.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        System.debug('cotizacion:'+cot.Id);
        System.debug('cotizacion:'+partida.Id);
        String idPartida=partida.Id;
        String body='{"id_cotizacion":"'+cot.Id+'","id_partida_de_presupuesto":["'+partida.Id+'"],"cliente":{"numero_de_cliente":"","nombre":"Sayra","apellido_paterno":"Martinez","apellido_materno":"Quiroz","telefono":"5579119743","correo_electronico":"saymartinez@deloittemx.com","fecha_nacimiento":"1985-09-10","codigo_postal":"12346","genero":"F"},"pagos":{"id_universal":"1111111111111111110010","tipo_folio":"01","folio_transaccion":"014564","total_factura":20000,"Seguro":true,"nombre_vendedor":"Nelson Varela","numero_caja":"1","clave_tienda":"1","sku":"","fecha_de_entrega":null,"fecha_venta":"2023-01-19","plazos":12,"ListaDePagos":[{"metodo_pago":"Dinero Electrónico","pago":1}]},"activo":{"emitir_poliza":true,"uso":"Personal","id_tienda":"1","servicio":"Particular","numero_serie":"987654321","numero_motor":"43","modelo":"2023","placas":"98765432fd","clave_vehicular":"98765432","valor_factura":3000,"bajo_demanda":true,"descripcion":"prueba","marca":"vento","nombre_activo":"MOTO VENTO"}}';
        request.requestURI='/apexrest/ventaSM'; 
        request.httpMethod='POST'; 
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_VentaSM.VentaSMRequest venta =(DSALES_VentaSM.VentaSMRequest)JSON.deserialize (body,DSALES_VentaSM.VentaSMRequest.class);
        System.debug('venta: '+venta);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        DSALES_VentaSMRest.createVenta();
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;

}
    
     @isTest
    public static void ventaExternaTest(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        Product2 producto =[SELECT Id FROM Product2 WHERE Name='AMP' LIMIT 1];
        Plazo__c plazo=[SELECT Id FROM Plazo__c WHERE Name='12' LIMIT 1];
        Quote cot =[SELECT Id,OpportunityId,Opportunity.Name FROM Quote WHERE Name ='test' LIMIT 1];
        QuoteLineItem partida =[SELECT Id FROM QuoteLineItem WHERE  DSALES_Plazo__c=:plazo.Id LIMIT 1];
		SYstem.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        System.debug('cotizacion:'+cot.Id);
        System.debug('partida:'+partida.Id);
        String idPartida=partida.Id;
        //String body='{"id_cotizacion":"'+cot.Id+'","id_partida_presupuesto":"'+partida.Id+'","cliente":{"numero_de_cliente":"","nombre":"Sayra","apellido_paterno":"Martinez","apellido_materno":"Quiroz","telefono":"5579119743","correo_electronico":"saymartinez@deloittemx.com","fecha_nacimiento":"1994-10-01","codigo_postal":"12346","genero":"F"},"pagos":{"num_factura":"545774","total_factura":20000,"Seguro":true,"nombre_vendedor":"Nelson Varela","numero_caja":"1","clave_tienda":"T-0001","sku":"12121212","fecha_de_entrega":"2023-01-20","fecha_venta":"2023-01-19","plazos":18,"ListaDePagos":[{"metodo_pago":"Dinero Electrónico","pago":10},{"metodo_pago":"Tarjeta","pago":50},{"metodo_pago":"Efectivo","pago":500}]},"activo": {"emitir_poliza":null, "uso":"","id_tienda":"","servicio":"","numero_serie":"","numero_motor":"","modelo":"","placas":"","clave_vehicular":"","valor_factura":null,"bajo_demanda":null,"descripcion":"","marca":"","nombre_activo":""}}';	
        String body='{"id_cotizacion":"'+cot.Id+'","id_partida_de_presupuesto":["'+partida.Id+'"],"cliente":{"numero_de_cliente":"","nombre":"Sayra","apellido_paterno":"Martinez","apellido_materno":"Quiroz","telefono":"5579119743","correo_electronico":"saymartinez@deloittemx.com","fecha_nacimiento":"1985-09-10","codigo_postal":"12346","genero":"F"},"pagos":{"id_universal":"1111111111111111110010","tipo_folio":"01","folio_transaccion":"014564","total_factura":20000,"Seguro":true,"nombre_vendedor":"Nelson Varela","numero_caja":"1","clave_tienda":"1","sku":"","fecha_de_entrega":null,"fecha_venta":"2023-01-19","plazos":12,"ListaDePagos":[{"metodo_pago":"Dinero Electrónico","pago":1}]},"activo":{"emitir_poliza":true,"uso":"Personal","id_tienda":"1","servicio":"Particular","numero_serie":"987654321","numero_motor":"43","modelo":"2023","placas":"98765432fd","clave_vehicular":"98765432","valor_factura":3000,"bajo_demanda":true,"descripcion":"prueba","marca":"vento","nombre_activo":"MOTO VENTO"}}';
        request.requestURI='/apexrest/ventaSM'; 
        request.httpMethod='POST'; 
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_VentaSM.VentaSMRequest venta =(DSALES_VentaSM.VentaSMRequest)JSON.deserialize (body,DSALES_VentaSM.VentaSMRequest.class);
        System.debug('venta: '+venta);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        DSALES_VentaSMRest.crearVenta();
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200');
    }
*/
}