@RestResource(urlMapping='/obtenerPoliza')
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class DSALES_NuevaPoliza {
    @HttpPut 
    global static DSALES_PolizaWrapper.Response actualizarPoliza(){
        DSALES_PolizaWrapper.Response response = new DSALES_PolizaWrapper.Response();
        List<DSALES_VentaSMRest.WrapperDatosProductos> listaIds = new List<DSALES_VentaSMRest.WrapperDatosProductos>();
        Boolean exito=false ;
        Integer codigoError; 
        String mensajeError='';
        String idPoliza='';
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    DSALES_PolizaWrapper.Request poliza = (DSALES_PolizaWrapper.Request)JSON.deserialize(body, DSALES_PolizaWrapper.Request.class);
                    InsurancePolicy polizaA = [SELECT Id,SourceQuoteId,dsalesQuoteId__c,SourceOpportunityId FROM InsurancePolicy WHERE dsalesQuoteId__c=:poliza.quote WITH SECURITY_ENFORCED LIMIT 1];
                    listaIds=DSALES_VentaSMRest.obtenerProductosEnPartidasOportunidad(polizaA.SourceOpportunityId);
                    
                    idPoliza=service(poliza,polizaA.Id);    
                    exito=true;
                }catch(Exception.JSONException e){
                    exito = false;
                    mensajeError= DSALES_Utility.BAD_REQUEST_MSJ;
                    codigoError=DSALES_Utility.BAD_REQUEST_CODE;
                }
                catch(Exception e){
                    System.debug('**ERROR**'+e.getLineNumber()+ ': '+e.getMessage());
                    exito = false;
                    mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ +': '+e.getLineNumber()+ ': '+e.getMessage();
                    codigoError=DSALES_Utility.INTERNAL_ERROR_CODE;
                }
            }
        }
        System.debug('idPoliza: '+idPoliza);
        response.listaPartidasOportunidad=listaIds;
        response.exito=exito;
        response.codigoError=codigoError;
        response.mensajeError=mensajeError;
        return response;
    }
    
     
    public static String service( DSALES_PolizaWrapper.Request polizaNueva, String idPoliza){
        InsurancePolicy poliza =new InsurancePolicy();
        try{
           
            String datos='SELECT Id,DSALES_Numeroseguimiento__c,PolicyName,';
            String dats='dsalesEstatusPoliza__c,Name,EffectiveDate,ExpirationDate,DSALES_Prima_Neta__c,DSALES_Prima_total__c,DSALES_Gastos_expedicion__c,DSALES_IVA__c,SourceOpportunityId,TotalSumInsured,DSALES_IDemision__c,DSALES_Servicio__c,DSALES_Uso__c,';
            String dat='DSALES_Telefono__c,DSALES_Codigomunicipio__c,DSALES_Codigocolonia__c,DSALES_Fechanacimiento__c,DSALES_Numeroserie__c,NameInsuredId,DSALES_RFC__c,dsalesFechaDeEmision__c,CreatedDate,DSALES_Opcionpago__c,DSALES_Tipovehiculo__c,';
            String query =datos+ dats + dat + 'dsalesQuoteId__c,dsalesQuote__c,DSALES_PDF_poliza__c,DSALES_ClaveAMIS__c,DSALES_Marca__c,DSALES_Polizaenviada__c FROM InsurancePolicy WHERE Id =:idPoliza';
            poliza = Database.query(String.escapeSingleQuotes(query));
            poliza.DSALES_IDemision__c=polizaNueva.idEmision;
            poliza.DSALES_PDF_poliza__c=polizaNueva.urlPdf;
            poliza.Name=polizaNueva.numeroPoliza;
            poliza.PolicyName=polizaNueva.numeroPoliza;
            poliza.DSALES_Numeroseguimiento__c=polizaNueva.trackingId;
            poliza.dsalesEstatusPoliza__c='Vigente';
            poliza.EffectiveDate=polizaNueva.fechaVigencia;
            poliza.DSALES_Polizaenviada__c=true;
            poliza.dsalesFechaDeEmision__c=polizaNueva.fechaEmision;
            poliza.ExpirationDate=polizaNueva.fechaVencimiento;
            poliza.TotalSumInsured =Decimal.valueOf(!String.isEmpty(polizaNueva.sumaAsegurada) ? polizaNueva.sumaAsegurada : '0');
            poliza.DSALES_Prima_Neta__c=Decimal.valueOf(!String.isEmpty(polizaNueva.primaNeta) ? polizaNueva.primaNeta  : '0');
            poliza.DSALES_Prima_total__c=Decimal.valueOf(!String.isEmpty(polizaNueva.primaTotal) ? polizaNueva.primaTotal : '0');
            poliza.DSALES_Gastos_expedicion__c=Decimal.valueOf(!String.isEmpty(polizaNueva.gastosExpedicion) ? polizaNueva.gastosExpedicion : '0');
            poliza.DSALES_IVA__c=polizaNueva.iva;

           // mapear campo de mensaje cuando no se haya generado una póliza.
            poliza.dsalesQuote__c=polizaNueva.quoteId;
            if(InsurancePolicy.SObjectType.getDescribe().isUpdateable()) {
                update poliza;   
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            }
        }catch(Exception e){
            System.debug('error: '+e.getLineNumber()+e.getMessage());
        }
        return poliza.Id;
    }
    
    
}