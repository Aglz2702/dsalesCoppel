/*********************************************************************************************************************************************************************
@ Class Name :  DSALES_QuoteScWrapperRequest
@ Author : Namrata Katore
@ Purpose : exposing service for NPV/ Cardiff to insert Quote record for Seguro de Celular in salesforce
@ Date : 30/8/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/


@RestResource(urlMapping='/insertQuoteSC/*')
global with sharing class DSALES_QuoteScWrapperRequest {
    public static final String SEGURO ='Seguro Celular';
    
    /*********************************************************************************************************************************************************************
@ Method Name :  createQuoteSc (HttpPost Method)
@ Author : Namrata Katore
@ Purpose : exposing method for NPV/ Cardiff to insert Quote record for Seguro de Celular in salesforce
@ Date : 30/8/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/
    @HttpPost
    global static DSALES_QuoteScWrapper.QuoteScResponse createQuoteSc(){
        String numeroCliente = DSALES_Utility.NUMERO_CLIENTE_GENERICO;
        Boolean listaNegra = false;
        Boolean success = false;
        String message = '';
        String code = '';
        String mensaje = '';
        String idTienda;
        Double price;
        Account client = new Account();
        Opportunity oppor = new Opportunity();
        Quote cotiza = new Quote();
        Product2 temporal = new Product2();
        QuoteLineItem celular =new QuoteLineItem();
        List<DSALES_QuoteScWrapper.Plazo> plazos = new List<DSALES_QuoteScWrapper.Plazo>();
        DSALES_QuoteScWrapper.CardifResponse cardifRespo = new DSALES_QuoteScWrapper.CardifResponse();
        DSALES_QuoteScWrapper.QuoteScResponse responsePayload = new DSALES_QuoteScWrapper.QuoteScResponse();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    DSALES_QuoteScWrapper.QuoteScRequest quote = (DSALES_QuoteScWrapper.QuoteScRequest)JSON.deserialize(body, DSALES_QuoteScWrapper.QuoteScRequest.class);
                    String idProducto;
                    if(quote.sku!=''){
                        temporal = DSALES_QuoteScWrapperRequestHelper.productCelular(quote.sku);
                        quote.marcaCelular=temporal.DSales_Marca__c;
                        idProducto=temporal.Id;
                    }
                    
                    Tienda__c tienda = [Select Id from Tienda__c WHERE DSales_TiendaID__c =: quote.idTienda WITH SECURITY_ENFORCED LIMIT 1];
                    idTienda = tienda.Id;
                     if(quote.sku!= null && !listaNegra){
                    cardifRespo = DSALES_QuoteScWrapperRequestHelper.createQuote(quote);
                    Account universalAccount = [Select Id from Account WHERE DSALES_ClienteCoppel__c = :numeroCliente WITH SECURITY_ENFORCED LIMIT 1];
                    Id clienteId=null; 
                    if(quote.numeroCliente == null || quote.numeroCliente=='' ||quote.numeroCliente==numeroCliente ){
                        List<Account> resul = [Select Id, firstName, suffix, lastName, Fecha_de_Nacimiento__c, Phone, PersonEmail from Account WHERE firstName=:quote.nombre AND suffix=:quote.apellidoMaterno AND lastName=:quote.apellidoPaterno WITH SECURITY_ENFORCED];
                        if(resul.size() == 1){
                            try{
                                clienteId = resul[0].Id;
                                oppor = DSALES_QuoteScWrapperRequestHelper.insertOpportunity(quote, clienteId,tienda);
                                cotiza = DSALES_QuoteScWrapperRequestHelper.insertQuote(quote,oppor.Id, tienda);
                                if(cardifRespo!=null){
                                plazos = DSALES_QuoteScWrapperRequestHelper.insertPlazos(SEGURO,cotiza, cardifRespo.price, quote.quoteId, quote.opcionPago, quote.plazoCotizar);
                                }
                                celular = DSALES_QuoteScWrapperRequestHelper.insertQuoteLineItem(cotiza, quote.sku, quote.precioCelular);
                            }
                            catch(Exception e){
                                system.debug('Error Métodos 1: '+e.getMessage() + e.getLineNumber());
                            }
                            System.debug('cell phone added---->'+celular);
                            System.debug('cell phone  insurance added---->'+plazos);
                        }
                        else{
                            Boolean sinCoincidenciaCuenta = true;
                            if(resul.size() > 1){                
                                for(Account cuentaSimilare: resul){
                                    if(cuentaSimilare.PersonEmail == quote.correoElectronico || cuentaSimilare.Phone == quote.telefonoCelular){
                                        clienteId = cuentaSimilare.Id;
                                        sinCoincidenciaCuenta = false;
                                        oppor = DSALES_QuoteScWrapperRequestHelper.insertOpportunity(quote, clienteId,  tienda);
                                        cotiza = DSALES_QuoteScWrapperRequestHelper.insertQuote(quote,oppor.Id, tienda);
                                        plazos = DSALES_QuoteScWrapperRequestHelper.insertPlazos(SEGURO,cotiza, cardifRespo.price,quote.quoteId, quote.opcionPago, quote.plazoCotizar); 
                                        celular = DSALES_QuoteScWrapperRequestHelper.insertQuoteLineItem(cotiza, quote.sku, quote.precioCelular);
                                        
                                        System.debug('cell phone added1---->'+celular);
                                        System.debug('cell phone  insurance added1---->'+plazos);
                                        break;
                                    }
                                }                         
                            }
                            if(resul.size() == 0 || sinCoincidenciaCuenta==true){
                                clienteId = universalAccount.Id; 
                                oppor = DSALES_QuoteScWrapperRequestHelper.insertOpportunity(quote, clienteId,  tienda);
                                cotiza = DSALES_QuoteScWrapperRequestHelper.insertQuote(quote,oppor.Id,  tienda);
                                try{
                                    plazos = DSALES_QuoteScWrapperRequestHelper.insertPlazos(SEGURO,cotiza, cardifRespo.price,quote.quoteId,  quote.opcionPago, quote.plazoCotizar); 
                                    celular = DSALES_QuoteScWrapperRequestHelper.insertQuoteLineItem(cotiza, quote.sku, quote.precioCelular);  
                                    
                                    
                                }
                                catch(Exception e)
                                {
                                    system.debug('Error Métodos: '+e.getMessage() + e.getLineNumber());
                                }
                                System.debug('cell phone added2---->'+celular);
                                System.debug('cell phone  insurance added2---->'+plazos);
                            }
                        }     
                    }else{
                        List<Account> result = [Select Id,firstName,suffix,lastName from Account WHERE CP_WalletCustomerNumber__c =:Decimal.valueOf(quote.numeroCliente) WITH SECURITY_ENFORCED];
                        if(result.size() == 0){
                            client = DSALES_QuoteScWrapperRequestHelper.insertAccount(quote);
                            clienteId = client.Id;
                            oppor = DSALES_QuoteScWrapperRequestHelper.insertOpportunity(quote, clienteId, tienda);
                            cotiza = DSALES_QuoteScWrapperRequestHelper.insertQuote(quote,oppor.Id, tienda);
                            plazos = DSALES_QuoteScWrapperRequestHelper.insertPlazos(SEGURO,cotiza, cardifRespo.price,quote.quoteId, quote.opcionPago, quote.plazoCotizar);
                            celular = DSALES_QuoteScWrapperRequestHelper.insertQuoteLineItem(cotiza, quote.sku, quote.precioCelular);
                            System.debug('cell phone added3---->'+celular);
                            System.debug('cell phone  insurance added3---->'+plazos);
                        }
                        else{
                            
                            clienteId = result[0].Id;
                            oppor = DSALES_QuoteScWrapperRequestHelper.insertOpportunity(quote, clienteId,  tienda);
                            cotiza = DSALES_QuoteScWrapperRequestHelper.insertQuote(quote,oppor.Id, tienda);
                            plazos = DSALES_QuoteScWrapperRequestHelper.insertPlazos(SEGURO,cotiza, cardifRespo.price,quote.quoteId, quote.opcionPago, quote.plazoCotizar); 
                            celular = DSALES_QuoteScWrapperRequestHelper.insertQuoteLineItem(cotiza, quote.sku, quote.precioCelular);
                            System.debug('cell phone added4---->'+celular);
                            System.debug('cell phone  insurance added4---->'+plazos);
                        }
                    }
                     } 
                    
                    if(listaNegra){
                        message='Esta en lista negra';
                    }
                    
                    success = true;
                    message = '';
                    code = '';
                    mensaje = 'Quote creado';
                    
                }catch(JSONException e){
                    responsePayload.exito = false;
                    responsePayload.codigoError = String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    responsePayload.mensajeError = DSALES_Utility.BAD_REQUEST_MSJ+' '+ e.getLineNumber()+' '+e.getCause()+' '+e.getMessage();
                }catch(Exception e){
                    responsePayload.exito = false;
                    responsePayload.codigoError = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    responsePayload.mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ+' '+ e.getLineNumber()+' '+e.getCause()+' '+e.getMessage();
                }
            }
        }
        DSALES_QuoteScWrapper.QuoteScResponse response = new DSALES_QuoteScWrapper.QuoteScResponse();
        response.mensaje = mensaje;
        response.exito = success;
        response.mensajeError = message;
        response.codigoError = code;
        response.idCotizacion = cotiza.Id;
        response.idOportunidad = oppor.Id;
        response.listaNegra = listaNegra;
        return response;
        
    }
}