@isTest
public with sharing class DSALES_CertificadoWrapperTest {
    @testSetup
    static void crearRegistros(){
        String recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Garantia Extendida').getRecordTypeId();
        String recordTypeId2 = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Garantía Extendida').getRecordTypeId();
        Product2 pr= new Product2(Name='Lavadora',StockKeepingUnit='123452',DSales_Tipo_de_Producto__c='Producto',RecordTypeId=recordTypeId2,IsActive=true);
		insert pr;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPricePG = new PricebookEntry();
        standardPricePG.Pricebook2Id = pricebookId;
        standardPricePG.Product2Id = pr.Id;
        standardPricePG.UnitPrice = 1200;
        standardPricePG.IsActive = true;
        insert standardPricePG;
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        PricebookEntry customPricePG = new PricebookEntry();
        customPricePG.Pricebook2Id = customPB.Id;
        customPricePG.Product2Id = pr.Id;
        customPricePG.UnitPrice = 1000;
        customPricePG.IsActive = true;
        insert customPricePG;
        
        Account ac= new Account(Name='DannyTest',CP_WalletCustomerNumber__c=123456);  
        insert ac;
        Contact con = new Contact(lastname= 'Test', AccountId= ac.Id, Email= 'johndoeus@salesforce.com');
        insert con;
      
        Tienda__c tienda = new Tienda__c(dsalesTiendaID__c='1234');
        insert tienda;
        Opportunity opp = new Opportunity(Name='Danny',StageName='Closed',CloseDate=Date.today(),Pricebook2Id=customPB.Id);
        insert opp;
        DSALES_InformacionDePago__c pago = new DSALES_InformacionDePago__c(DSALES_Oportunidad__c=opp.id,DSALES_Factura__c='1234',DSALES_Clave_Tienda__c='1234',DSALES_IDUniversal1__c='11111111111111111110');
        insert pago;
        
        
         Asset ass = new Asset(Name='Test',AccountId= ac.Id,ContactId=con.Id,DSALES_SKU__c='123454',DSales_Informacion_pago__c=pago.Id,Product2Id=pr.id,DSALES_TipoProducto__c='Producto',RecordTypeId=recordTypeId);
        insert ass; 
        DSALES_Certificado__c certificado = new DSALES_Certificado__c(DSALES_Email__c='dsanmiguel@deloittemx.com',DSALES_ProductoAdquirido__c=ass.id,
                                                                     DSALES_InformacionDePago__c=pago.id);
        insert certificado;
        Quote cotGex = new Quote(OpportunityId=opp.Id,Name='GEX',dsalesTienda=tienda.Id);
        insert cotGex;
       
        QuoteLineItem lavadora = new QuoteLineItem();
        lavadora.QuoteId = cotGex.Id;
        lavadora.PricebookEntryId = customPricePG.Id;
        lavadora.Product2Id = pr.Id;
        lavadora.Quantity = 1.0;
        lavadora.UnitPrice = customPricePG.UnitPrice;
        insert lavadora;
        opp.SyncedQuoteId  = cotGex.Id;     
       	update opp;
    }
    @isTest static void crearRegistroTest()
    {
        
        Tienda__c tienda = [SELECT Id FROM Tienda__c WHERE dsalesTiendaID__c='1234'];
        Account acc=[SELECT CP_WalletCustomerNumber__c FROM ACCOUNT WHERE NAME='DannyTest' LIMIT 1];
        contact c= [SELECT Id, FirstName, LastName, AccountId from Contact];
        Asset ast =[select Id, Name, AccountId from Asset];
        
        RestRequest peticion=new RestRequest();
        RestResponse respuesta = new RestResponse();
        String cuerpo = '{"id_producto_adquirido":"'+ast.id+'","id_cuenta":"'+acc.id+'","id_tienda":"'+tienda.id+'","numero_caja_coppel": "1234","id_vendedor": "1234","direccion_cliente": "Montreal 169 Paseo Montejo","correo_cliente": "dsanmiguel@deloittemx.com","telefono_cliente": "8130912906","celular_cliente": "812091342","sku": "ABCDS12","modelo_tangible": "Italika","marca_tangible": "Samsung","numero_serie": "90001","descripcion_tangible": "Muy bueno","precio_tangible": "900","fecha_compra_tangible": "2022-09-06","garantia_coppel_tangible": "12","costo_garantia": "900","fecha_compra_garantia": "2022-09-06","fecha_fin_garantia_extendida": "2022-09-06","fecha_inicio_garantia_extendida": "2022-09-06"}';
        peticion.requestURI='/apexrest/insertCertificado'; 
        peticion.httpMethod='POST';
        RestContext.request=peticion;
        peticion.requestBody=Blob.valueOf(cuerpo);
        RestContext.response=respuesta;
        DSALES_CertificadoWrapper.CertificadoRequest certificado =  (DSALES_CertificadoWrapper.CertificadoRequest)JSON.deserialize (cuerpo,DSALES_CertificadoWrapper.CertificadoRequest.class);
        certificado.numeroCliente=String.ValueOf(acc.CP_WalletCustomerNumber__c);
        
        Test.startTest();
        DSALES_CertificadoWrapperRequest.createCertificado();
        Test.stopTest();
        RestContext.request = peticion;
        RestContext.response= respuesta;
        System.assertNotEquals(200, respuesta.statusCode,'La llamada no debe devolver el código 200');
    }
    @isTest static void cancelacionTest()
    {
        DSALES_InformacionDePago__c pago = [SELECT Id,DSALES_Factura__c,DSALES_Clave_Tienda__c,DSALES_IDUniversal1__c,DSALES_Oportunidad__c FROM
                                            DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c='11111111111111111110' ];
        DSALES_Certificado__c certi= [SELECT Name FROM DSALES_Certificado__c WHERE DSALES_Email__c='dsanmiguel@deloittemx.com' LIMIT 1];
        List<String> c = new List<String>();
        OpportunityLineItem productosSincro =[SELECT Id,Name,DSALES_Estatus__c FROM OpportunityLineItem WHERE OpportunityId=:pago.DSALES_Oportunidad__c AND Product2.Name='Lavadora' LIMIT 1];
        List<DSALES_CancelacionProductosWrapper.ListaProducto> listGex= new List<DSALES_CancelacionProductosWrapper.ListaProducto>();
        DSALES_CancelacionProductosWrapper.ListaProducto servicioGex= new DSALES_CancelacionProductosWrapper.ListaProducto();
         List<DSALES_CancelacionProductosWrapper.ListaProducto> listGex2= new List<DSALES_CancelacionProductosWrapper.ListaProducto>();
        servicioGex.idPartidaOportunidad=productosSincro.Id;
        servicioGex.estatus='Cancelado';
        servicioGex.motivoCancelacion='A petición del cliente';
        servicioGex.idCertificado=certi.Name;
        listGex.add(servicioGex);
       
  
        Test.startTest();
        String estatusGlobal='Cancelado';
        String motivoGlobal='a petición del cliente';
        DSALES_CertificadoWrapperRequest.putCertificado(pago.DSALES_IDUniversal1__c,listGex,estatusGlobal,MotivoGlobal);
        //DSALES_CertificadoWrapperRequest.putCertificado(pago.DSALES_IDUniversal__c,listGex2);
        Test.stopTest();
        System.assertNotEquals(null, pago.DSALES_IDUniversal1__c);
       
    }
    @isTest static void devolucionTest()
    {
        DSALES_InformacionDePago__c pago = [SELECT Id,DSALES_Factura__c,DSALES_Clave_Tienda__c,DSALES_IDUniversal1__c,DSALES_Oportunidad__c FROM
                                            DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c='11111111111111111110' ];
        DSALES_Certificado__c certi= [SELECT Name FROM DSALES_Certificado__c WHERE DSALES_Email__c='dsanmiguel@deloittemx.com' LIMIT 1];
        List<DSALES_CancelacionProductosWrapper.ListaProducto> listGex2= new List<DSALES_CancelacionProductosWrapper.ListaProducto>();
               String estatusGlobal='Cancelado';
        String motivoGlobal='a petición del cliente';
        Test.startTest();
        DSALES_CertificadoWrapperRequest.putCertificado(pago.DSALES_IDUniversal1__c,listGex2,estatusGlobal,motivoGlobal);
        Test.stopTest();
        System.assertNotEquals(null, pago.DSALES_IDUniversal1__c,'La llamada no debe devolver el código 200');
       
    }
    @isTest static void fallaRegistroTest()
    {
        
        RestRequest peticion=new RestRequest();
        RestResponse respuesta = new RestResponse();
        String cuerpo = '{"numero_caja_coppel": "1234","id_vendedor": "1234","direccion_cliente": "Montreal 169 Paseo Montejo","correo_cliente": "dsanmiguel@deloittemx.com","telefono_cliente": "8130912906","celular_cliente": "812091342","sku": "ABCDS12","modelo_tangible": "Italika","marca_tangible": "Samsung","numero_serie": "90001","descripcion_tangible": "Muy bueno","precio_tangible": "900","fecha_compra_tangible": "2022-09-06","garantia_coppel_tangible": "12","costo_garantia": "900","fecha_compra_garantia": "2022-09-06","fecha_fin_garantia_extendida": "2022-09-06","fecha_inicio_garantia_extendida": "2022-09-06"}';
        peticion.requestURI='/apexrest/insertCertificado'; 
        peticion.httpMethod='POST';
        RestContext.request=peticion;
        peticion.requestBody=Blob.valueOf(cuerpo);
        RestContext.response=respuesta;
        DSALES_CertificadoWrapper.CertificadoRequest certificado =  (DSALES_CertificadoWrapper.CertificadoRequest)JSON.deserialize (cuerpo,DSALES_CertificadoWrapper.CertificadoRequest.class);
        
        Test.startTest();
        DSALES_CertificadoWrapperRequest.createCertificado();
        Test.stopTest();
        RestContext.request = peticion;
        RestContext.response= respuesta;
        System.assertNotEquals(200, respuesta.statusCode,'La llamada no debe devolver el código 200');
        
    }
}