@isTest
public with sharing class DSALES_CreateInsurancePolicyTest {
    @testSetup
    static void SetUp(){
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
        
        Product2 prodRc = new Product2(Name ='RC Seguro de Moto',DSALES_vehculo__c='sadkncdcs' ,StockKeepingUnit='0000',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',IsActive=true);
		insert prodRc;
        
        Product2 prodAmp = new Product2(Name ='AMP Seguro de Moto',DSALES_vehculo__c='23d23d23', StockKeepingUnit='123444',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
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
        t.DSales_TiendaID__c =  'T-0001';
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
        /*QuoteLineItem moto2 = new QuoteLineItem();
        moto2.QuoteId = cotizacion.Id;
        moto2.PricebookEntryId = customPrice.Id;
        moto2.Product2Id = prodM2.Id;
        moto2.Quantity = 1.0;
        moto2.UnitPrice = customPrice.UnitPrice;
        moto2.DSALES_Segurogratis__c=false;
        //moto.DSALES_Tipodeproducto__c = 'Producto';
        insert moto2;*/
        
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
    }

    
    @isTest
    public static void postVentaExternaTest(){
        RestRequest request=new RestRequest();
        //RestResponse response = new RestResponse();
        Product2 producto =[SELECT Id FROM Product2 WHERE Name='AMP Seguro de Moto' LIMIT 1];
        Plazo__c plazo=[SELECT Id FROM Plazo__c WHERE Name='18' LIMIT 1];
        Quote cot =[SELECT Id,OpportunityId,Opportunity.Name FROM Quote WHERE Name ='test' LIMIT 1];
        QuoteLineItem partida =[SELECT Id FROM QuoteLineItem WHERE  DSALES_Plazo__c=:plazo.Id LIMIT 1];
		SYstem.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        System.debug('cotizacion:'+cot.Id);
        System.debug('cotizacion:'+partida.Id);
        String idPartida=partida.Id;
        String body='{"id_cotizacion":"'+cot.Id+'","id_partida_presupuesto":"'+partida.Id+'","cliente":{"numero_de_cliente":"","nombre":"Sayra","apellido_paterno":"Martinez","apellido_materno":"Quiroz","telefono":"123456789","correo_electronico":"saymartinez@deloittemx.com","fecha_nacimiento":"1985-09-10","codigo_postal":"12346","genero":"F"},"pagos":{"num_factura":"545774","total_factura":20000,"Seguro":true,"nombre_vendedor":"Nelson Varela","numero_caja":"1","clave_tienda":"T-0001","sku":"12121212","fecha_de_entrega":"2023-01-20","fecha_venta":"2023-01-19","plazos":18,"ListaDePagos":[{"metodo_pago":"Dinero Electrónico","pago":1}]},"activo":{"emitir_poliza":true,"uso":"Personal","id_tienda":"T-0001","servicio":"Particular","numero_serie":"1334342343","numero_motor":"343434343","modelo":"2022","placas":"XRDH48","clave_vehicular":"023023834","valor_factura":8000,"bajo_demanda":true,"descripcion":"VITALIA ITALIKA ","marca":"Vento","nombre_activo":"VITALIA ITALIKA "}}';	
        request.requestURI='/apexrest/ventaSM'; 
        request.httpMethod='POST'; 
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        //RestContext.response=response;
        DSALES_VentaSM.VentaSMRequest venta =(DSALES_VentaSM.VentaSMRequest)JSON.deserialize (body,DSALES_VentaSM.VentaSMRequest.class);
        System.debug('venta: '+venta);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
       	DSALES_VentaSM.VentaSMResponse response= DSALES_VentaSMRest.createVenta();
        System.debug('******DATOS ACTIVO****');
        DSALES_InformacionDePago__c pago=[SELECT Id, DSALES_Poliza__c,DSALES_Motoentregada__c,DSALES_Motoexterna__c,DSALES_SKU__c FROM DSALES_InformacionDePago__c WHERE Id =: response.id_pago];
        InsurancePolicy pol=[SELECT Id,DSALES_Estatusdepliza__c,Name FROM InsurancePolicy WHERE Id=:pago.DSALES_Poliza__c];
        DSALES_CreateInsurancePolicy.estatusTramite(pol.Id);
        InsurancePolicyAsset activo = new InsurancePolicyAsset();
        activo.AssetName='Test';
        activo.DSALES_Account__c=response.id_cliente;
        activo.InsurancePolicyId=pago.DSALES_Poliza__c;
        activo.DSALES_InformacionPago__c=pago.Id;
        activo.DSALES_Clavevehicular__c='Test';
        activo.DSALES_Modelo__c='Test';
        activo.DSALES_Numeroserie__c='Test';
        activo.DSALES_Numeromotor__c='Test';
        activo.DSALES_Descripcion__c='Test';
        activo.DSALES_Servicio__c='Test';
        activo.DSALES_Placas__c='Test';
        activo.DSALES_Marca__c='Test';
        activo.DSALES_Uso__c='Test';
        activo.DSALES_ClaveAMIS__c='Test';
        //activo.DSALES_Motoexterna__c=true;
        activo.Estatus__c='Activo';
        activo.DSALES_Valorfactura__c=10000;
        insert activo;
        DSALES_CreateInsurancePolicy.cambiarEstatus(pol.Id);
        DSALES_CreateInsurancePolicy.updateInfoPago(pol);
        activo.Estatus__c='Devuelto';
        update activo;
        DSALES_CreateInsurancePolicy.cancelarPoliza(activo.Id);
        Test.stopTest();
    }
}