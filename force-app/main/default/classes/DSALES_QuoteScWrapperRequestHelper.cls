/*********************************************************************************************************************************************************************
@ Class Name :  DSALES_QuoteScWrapperRequestHelper
@ Author : Namrata Katore
@ Purpose : Helper class to insert Quote & QuoteLineItem of Seguro de Celular in salesforce
@ Date : 30/8/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/

public without sharing class DSALES_QuoteScWrapperRequestHelper{
    public static final String SEGURO ='Seguro Celular';   
    
    /*********************************************************************************************************************************************************************
@ Method Name : insertQuote
@ Author : Namrata Katore
@ Purpose :insert quote in Salesforce 
@ Date : 30/8/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/    
    public static Quote insertQuote(DSALES_QuoteScWrapper.QuoteScRequest data,Id opportunityId, Tienda__c tienda){
        Boolean listaNegra = false;
        
        Quote quoteRecord = new Quote();
        
        String recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Venta de Seguro de Celulares').getRecordTypeId();
        try{
            quoteRecord.Name = data.nombre;
            if(data.apellidoMaterno != null ){
                quoteRecord.Name+=' '+data.apellidoPaterno + ' '+data.apellidoMaterno;
            }
            else{
                quoteRecord.Name+= ' '+data.apellidoPaterno;
            }
            
            quoteRecord.OpportunityId =opportunityId;
            quoteRecord.ExpirationDate = date.today()+7;
            quoteRecord.RecordTypeId = recordTypeId;
            date dat = date.today();
            quoteRecord.DSALES_Fechadecreacionpresupuesto__c = date.newInstance(dat.year(), dat.month(), dat.day());
            quoteRecord.dsalesListaNegra__c = listaNegra;
            quoteRecord.dsalesMotivoDeListaNegra__c= 'Sin Definir';
            quoteRecord.DSALES_Fechadenacimiento__c = Date.valueOf(data.fechaNacimiento);
            quoteRecord.dsalesOpcionDePago__c = data.opcionPago;
            quoteRecord.DSales_Vendedor__c = data.nombreVendedor;
            //quoteRecord.dsalesGenero__c = data.generoContacto;
            //quoteRecord.dsalesFechaDeComienzoDePoliza__c = Date.valueOf(data.fechaInicio);
            quoteRecord.DSales_ID_Tienda__c = data.idTienda;
            quoteRecord.DSales_Tienda__c = tienda.Id;
            quoteRecord.Phone = data.telefonoCelular;
            
            quoteRecord.Email = data.correoElectronico;
            quoteRecord.DSALES_RFC__c = data.rfc;
            quoteRecord.dsalesIdentificadorCoppel__c = decimal.valueOf(data.identificadorCoppel);
            quoteRecord.DSALES_Plazoacotizar__c= decimal.valueOf(data.plazoCotizar); 
            quoteRecord.dsalesPrecioCelular__c = data.precioCelular;
            quoteRecord.dsalesColorCelular__c = data.colorCelular;
            quoteRecord.dsalesMarcaCelular__c = data.marcaCelular;
            quoteRecord.dsalesModeloCelular__c = data.modeloCelular;
            quoteRecord.dsalesNumeroSucursal__c = Decimal.valueOf(data.numeroDeSucursal);
            quoteRecord.dsalesIdentificadorVendedor__c = Decimal.valueOf(data.identificadorDelVendedor);
            if(Schema.sObjectType.Quote.isCreateable()){
                insert quoteRecord; 
            }
            else{            
                System.debug('Permisos insuficientes para insertar');           
            }
            
        }catch(Exception e){
            System.debug('Error---->'+e.getMessage()+','+e.getLineNumber());
        }
        return quoteRecord;
    }
    /************************************************************************************************************************************************************************
@ Method Name :  insertAccount
@ Author : Namrata Katore
@ Purpose : insert Account in Salesforce
@ Date : 1/9/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/    
    
    public static Account insertAccount (DSALES_QuoteScWrapper.QuoteScRequest data){
        Account cliente = new Account();
        cliente.CP_WalletCustomerNumber__c = Decimal.valueOf(data.numeroCliente);
        cliente.FirstName = data.nombre;
        cliente.LastName = data.apellidoPaterno;
        cliente.Suffix = data.apellidoMaterno;
        cliente.PersonBirthdate = Date.valueOf(data.fechaNacimiento);
        cliente.PersonEmail = data.correoElectronico;
        cliente.AccountNumber = data.numeroCliente;
        cliente.PersonMobilePhone = data.telefonoCelular;
        if(Schema.sObjectType.Account.isCreateable()) {
            insert cliente;
        }
        else{            
            System.debug('Permisos insuficientes para insertar');           
        }
        
        return cliente;
    }
    
    /*********************************************************************************************************************************************************************
@ Method Name :  insertOpportunity
@ Author : Namrata Katore
@ Purpose : cell phone sales Opportunity generated in Salesforce
@ Date : 1/9/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/    
    
    public static Opportunity insertOpportunity (DSALES_QuoteScWrapper.QuoteScRequest data, Id clienteId, Tienda__c tienda){
        Opportunity oppor = new Opportunity();
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seguro de celulares').getRecordTypeId();
        Pricebook2 precioLista = [SELECT id,Name FROM Pricebook2 WHERE Name= 'Standard Price Book' and IsActive=true WITH SECURITY_ENFORCED LIMIT 1];
        oppor.AccountId = clienteId;
        oppor.Name = data.nombre;
        //oppor.Name+=' '+lastName;
        if(data.apellidoMaterno != null ){
            oppor.Name+=' '+data.apellidoPaterno+ ' '+data.apellidoMaterno;
        }
        else{
                oppor.Name+= ' '+data.apellidoPaterno;
            }
        oppor.CloseDate = date.today()+30;
        oppor.StageName = 'Nuevo';
        oppor.RecordTypeId = recordTypeId;
        oppor.DSALES_Tiend__c = tienda.Id;
        oppor.Pricebook2Id = precioLista.Id;
        if(Schema.sObjectType.Opportunity.isCreateable())
        {
            insert oppor;        
        }
        return oppor;
    }
    
    /*********************************************************************************************************************************************************************
@ Method Name :  createQuote
@ Author : Namrata Katore
@ Purpose :Quote request send to Cardiff
@ Date : 1/9/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/    
    
    public static DSALES_QuoteScWrapper.CardifResponse createQuote(DSALES_QuoteScWrapper.QuoteScRequest obj){
        String body = JSON.serialize(obj);
        System.debug('body: '+body);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = 'https://dc2f757c-06da-4b1a-8451-234565748544.mock.pstmn.io/QuoteSeguroCelular';
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(body);
        request.setTimeout(120000);
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
            DSALES_QuoteScWrapper.CardifResponse respuesta = (DSALES_QuoteScWrapper.CardifResponse) JSON.deserialize(response.getbody(), DSALES_QuoteScWrapper.CardifResponse.class);
            System.debug('Received by Cardiff----> '+response.getBody());
            return respuesta;
        }else{
            System.debug('Communication failed---> ' + response.getStatusCode()+','+response.getBody());
            return null;
        }     
    }
    /*********************************************************************************************************************************************************************
@ Method Name :  insertQuoteLineItem
@ Author : Namrata Katore
@ Purpose : insert mobile product only
@ Date : 1/9/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/    
    
    public static QuoteLineItem insertQuoteLineItem(Quote cotiza,String sku,Double price){
        Product2 producto = [SELECT Id, Name, StockKeepingUnit, dsalesOpcionPago__c,DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku WITH SECURITY_ENFORCED LIMIT 1];
        PricebookEntry precio = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id =:producto.Id WITH SECURITY_ENFORCED LIMIT 1];
        QuoteLineItem item = new QuoteLineItem();
        try{
            item.QuoteId = cotiza.Id;
            item.PricebookEntryId = precio.Id;
            item.Product2Id = precio.Product2Id;
            item.Quantity = 1;
            item.DSALES_Segurogratis__c = false;
            item.UnitPrice = decimal.valueOf(price);
            if(Schema.sObjectType.QuoteLineItem.isCreateable()){
                insert item;
            }else{            
                System.debug('Permisos insuficientes para insertar');           
            }
        }catch(Exception e){
            System.debug('Error---->'+e.getMessage()+','+e.getLineNumber());
        }
        
        return item;
    }
   
    /*********************************************************************************************************************************************************************
@ Method Name : insertPlazos
@ Author : Namrata Katore
@ Purpose :Add all the plazo & payment option of the insurance in salesforce 
@ Date : 4/9/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/      
    public static List<DSALES_QuoteScWrapper.Plazo> insertPlazos(String seguro,Quote cotiza, List<DSALES_QuoteScWrapper.InsurancePremium> priceSeg,String obj, String opPagoRecibido, String plazoMaxima) {
        Product2 producto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c, dsalesOpcionPago__c FROM Product2 WHERE Name=:seguro WITH SECURITY_ENFORCED LIMIT 1];
        PricebookEntry precio = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id = :producto.Id WITH SECURITY_ENFORCED LIMIT 1];
        List<Plazo__c> plazos = [SELECT Id, Name, DSALES_Activo__c, dsalesOpcionPago__c,Dsales_Plazo__c, dsalesSeguro__r.Name FROM Plazo__c WHERE dsalesSeguro__r.Name = :seguro AND DSALES_Activo__c = true AND Dsales_Plazo__c<=:plazoMaxima WITH SECURITY_ENFORCED LIMIT 10];
        
        List<QuoteLineItem> listaPartidas = new List<QuoteLineItem>();
        List<DSALES_QuoteScWrapper.Plazo> listaSeguros = new List<DSALES_QuoteScWrapper.Plazo>();
        List<DSALES_QuoteScWrapper.OpcionPago> opcionesPagoLst = new List<DSALES_QuoteScWrapper.OpcionPago>();
        for(Plazo__c plazo:plazos){
            QuoteLineItem partida = new QuoteLineItem();
            partida.QuoteId = cotiza.Id;
            partida.PricebookEntryId = precio.Id;
            partida.Product2Id = precio.Product2Id;
            partida.Quantity = 1;
            partida.DSALES_Segurogratis__c = false;
            partida.dsalesQuoteId__c = obj;     
       
            DSALES_QuoteScWrapper.OpcionPago paquetesOpcionesPago = new DSALES_QuoteScWrapper.OpcionPago();
            if (producto != null && producto.dsalesOpcionPago__c != null) {
                List<String> opcionPago = producto.dsalesOpcionPago__c.split(';');
                if (opPagoRecibido == 'Mensual') {
                    partida.DSALES_Plazo__c = plazo.Id;
                    DSALES_QuoteScWrapper.opcionPago opcion = new DSALES_QuoteScWrapper.opcionPago();
                    opcion.opcionPago = plazo.Dsales_Plazo__c + 'M';
                    paquetesOpcionesPago= opcion;
                    opcionesPagoLst.add(opcion);
                } 
                else if (opPagoRecibido == 'Contado' && plazo.DSALES_Plazo__c=='12') {
                    partida.DSALES_Plazo__c = plazo.Id;
                    DSALES_QuoteScWrapper.opcionPago opcion = new DSALES_QuoteScWrapper.opcionPago();
                    opcion.opcionPago = '12C';
                    paquetesOpcionesPago=opcion;
                    opcionesPagoLst.add(opcion);
                }
            }
            partida.dsalesOpcionPago__c= paquetesOpcionesPago.opcionPago;
            if(priceSeg.size()>0){
           partida.UnitPrice = priceSeg[0].seguroPrice;
                }
            
            if(partida.DSALES_Plazo__c!=null){
                listaPartidas.add(partida);
            }
            
        }
        
        List<String> pagolst = new List<String>();
        for(DSALES_QuoteScWrapper.OpcionPago pl:opcionesPagoLst){
            pagoLst.add(String.valueOf(pl));
        }
        
        
        for (String paquete : pagolst) {
            DSALES_QuoteScWrapper.Plazo aux = new DSALES_QuoteScWrapper.Plazo();
            aux.paquete = paquete;
            aux.opcionesPago = opcionesPagoLst; 
            listaSeguros.add(aux);
        }
        
        try {
            insert listaPartidas;
            
        } catch (Exception e) {
            System.debug('Error inserting Partida: ' + e.getMessage()+ ' '+e.getLineNumber());
        }
        
        return listaSeguros;
    }
    
    /**************************************************************************************************************************************************************************
@ Method Name : productCelular
@ Author : Namrata Katore
@ Purpose :method return only celular product form the salesforce
@ Date : 1/9/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/        
    public static Product2 productCelular(String sku){
        Product2 celular=new Product2();
        if(!String.isEmpty(sku)){
            try{
                celular =[SELECT Id, Name, StockKeepingUnit, DSales_Modelo__c,DSales_Marca__c, DSALES_Seguro__c, DSales_Articulo__c,DSales_Tipo_de_Producto__c, dsalesOpcionPago__c FROM Product2 WHERE StockKeepingUnit=:sku AND DSales_Tipo_de_Producto__c='Producto' WITH SECURITY_ENFORCED LIMIT 1];
            }catch (Exception e){
                system.debug('Error de Query: '+e.getMessage() + e.getLineNumber());
            }
        }
        return celular;
    }
    
}