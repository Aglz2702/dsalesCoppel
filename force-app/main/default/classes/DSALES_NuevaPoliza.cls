/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 04-18-2023
 * @last modified by  : Juan Antonio Flores
 * Modifications Log 
 * Ver   Date          Author             Modification 
 * 1.0   04-18-2023                       Initial Version
**/
public with sharing class DSALES_NuevaPoliza {
    public static final String NOMBRE_SERVICIO = 'DSALES_createPoliza';
    public static InsurancePolicy invokeService(InsurancePolicyAsset activo){
        InsurancePolicy poliza =new InsurancePolicy();
         String datos='SELECT Id,DSALES_Genero__c,DSALES_Descripcion__c,DSALES_Nmerodemotor__c,DSALES_Clavevehicular__c,DSALES_Codigopostal__c,DSALES_Codigoestado__c,DSALES_CorreoElectronico__c,DSALES_Activodeplizadeseguro__c,DSALES_Numeroseguimiento__c,SourceQuoteId,DSALES_Negocio__c,DSALES_Aseguradora__c,PlanTier,';
        String dats='DSALES_Estatusdepliza__c,Name,EffectiveDate,ExpirationDate,DSALES_Prima_Neta__c,DSALES_Prima_total__c,DSALES_Gastos_expedicion__c,DSALES_IVA__c,SourceOpportunityId,TotalSumInsured,DSALES_IDemision__c,DSALES_Servicio__c,DSALES_Uso__c,';
        String dat='DSALES_Telefono__c,DSALES_Codigomunicipio__c,DSALES_Codigocolonia__c,DSALES_Fechanacimiento__c,DSALES_Numeroserie__c,DSALES_Placas__c,DSALES_Modelo__c,NameInsuredId,DSALES_RFC__c,Fecha_de_emisi_n__c,CreatedDate,DSALES_Opcionpago__c,DSALES_Tipovehiculo__c,';
        String query =datos+ dats + dat + 'DSALES_PDF_poliza__c,DSALES_ClaveAMIS__c,DSALES_Marca__c,DSALES_Polizaenviada__c FROM InsurancePolicy WHERE Id =\'' + activo.InsurancePolicyId + '\'';
        poliza = DataBase.query(String.escapeSingleQuotes(query));
        poliza.DSALES_Activodeplizadeseguro__c=activo.Id;
        poliza.DSALES_Clavevehicular__c=activo.DSALES_Clavevehicular__c;
        poliza.DSALES_Modelo__c=activo.DSALES_Modelo__c;
        poliza.DSALES_Numeroserie__c=activo.DSALES_Numeroserie__c;
        poliza.DSALES_Nmerodemotor__c=activo.DSALES_Numeromotor__c;
        poliza.DSALES_Descripcion__c=activo.DSALES_Descripcion__c;
        poliza.DSALES_Servicio__c=activo.DSALES_Servicio__c;
        poliza.DSALES_Placas__c=activo.DSALES_Placas__c;
        poliza.DSALES_Marca__c=activo.DSALES_Marca__c;
        poliza.DSALES_Uso__c=activo.DSALES_Uso__c;
        //poliza.DSALES_ClaveAMIS__c=activo.DSALES_ClaveAMIS__c;
        InsurancePolicy polizaN=service(poliza);
        if(polizaN.DSALES_Estatusdepliza__c=='Vigente'){
            String urlPdf=DSALES_GetPolicyPDF.service(polizaN);
            if(urlPdf!='' || urlPdf!=null){
                polizaN.DSALES_PDF_poliza__c =urlPdf;
                polizaN.DSALES_Polizaenviada__c=true;
            } 
        }else{
            System.debug('No se actualizarón los datos de la póliza');
        }
        if(activo.Id==null){
            insert activo;
        }
        
        polizaN.DSALES_Activodeplizadeseguro__c=activo.Id;
        if (InsurancePolicy.SObjectType.getDescribe().isUpdateable()) {
            update polizaN;
        }
        return poliza;    
    }
    
    
    public static InsurancePolicy service(InsurancePolicy poliza){
        try{
            String body = obtenerCampos(poliza);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String endpoint = DSALES_Utility.getEndpoint(NOMBRE_SERVICIO);
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setBody(body);
            HttpResponse response = http.send(request);
            DSALES_PolizaWrapper.Application respuesta = (DSALES_PolizaWrapper.Application)JSON.deserialize(response.getbody(),DSALES_PolizaWrapper.Application.class);
            String str ='';
            poliza.DSALES_Estatusdepliza__c='En trámite';
            System.debug('Estatus despues de enviar datos: '+ poliza.DSALES_Estatusdepliza__c);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
                if(respuesta.success == true){
                  poliza=llenaPoliza(poliza, respuesta);
                }
            }else{
                System.debug('No se pudo realizar la pétición');
            }
        }catch(Exception e){
            System.debug('error: '+e.getLineNumber()+e.getMessage());
        }
        return poliza;
    }
    
    public static InsurancePolicy llenaPoliza(InsurancePolicy poliza, DSALES_PolizaWrapper.Application respuesta) { 
        poliza.DSALES_IDemision__c=respuesta.data.payment_data.data.emission_id;
        poliza.DSALES_Numeroseguimiento__c=respuesta.data.payment_data.data.tracking_id;
        poliza.Name=respuesta.data.payment_data.data.policy_number;
        poliza.PolicyName =respuesta.data.payment_data.data.insured_data.policy;
        String fechaIni=respuesta.data.payment_data.data.insured_data.start_date;
        Date fInicio= date.valueOf(fechaIni);
        poliza.EffectiveDate = Datetime.newInstance(fInicio.year(),fInicio.month(),fInicio.day());
        String fechaFin=respuesta.data.payment_data.data.insured_data.end_date;
        Date endDate= date.valueOf(fechaFin);
        poliza.ExpirationDate=Datetime.newInstance(endDate.year(),endDate.month(),endDate.day());
        poliza.Fecha_de_emisi_n__c=Date.valueOf(respuesta.data.payment_data.data.insured_data.emission_date);
        poliza.TotalSumInsured =Decimal.valueOf(!String.isEmpty(respuesta.data.payment_data.data.insured_data.vehicle_summ) ? respuesta.data.payment_data.data.insured_data.vehicle_summ : '0');
        poliza.DSALES_Prima_Neta__c=Decimal.valueOf(!String.isEmpty(respuesta.data.payment_data.data.value_resume.net_premium) ? respuesta.data.payment_data.data.value_resume.net_premium  : '0');
        poliza.DSALES_Prima_total__c=Decimal.valueOf(!String.isEmpty(respuesta.data.payment_data.data.value_resume.total_premium) ? respuesta.data.payment_data.data.value_resume.total_premium : '0');
        poliza.DSALES_Gastos_expedicion__c=Decimal.valueOf(!String.isEmpty(respuesta.data.payment_data.data.value_resume.right) ? respuesta.data.payment_data.data.value_resume.right : '0');
        poliza.DSALES_IVA__c=Decimal.valueOf(!String.isEmpty(respuesta.data.payment_data.data.value_resume.tax) ? respuesta.data.payment_data.data.value_resume.tax : '0') ;
        poliza.DSALES_Estatusdepliza__c='Vigente';
        System.debug('Estatus despues de recibir respuesta: '+ poliza.DSALES_Estatusdepliza__c); 
        return poliza;
    }


    public static String obtenerCampos(InsurancePolicy obj){
        Account cli=new Account();
        if(Account.SObjectType.getDescribe().isAccessible()) {
            cli =[SELECT Id, FirstName,LastName,Suffix,Fecha_de_Nacimiento__c FROM Account WHERE Id=:obj.NameInsuredId];
        }
        DSALES_PolizaWrapper.polizaRequest objPost= new DSALES_PolizaWrapper.polizaRequest();
        objPost.tracking_id =obj.DSALES_Numeroseguimiento__c;
        objPost.quote_id=obj.SourceQuoteId;
        objPost.business=obj.DSALES_Negocio__c;
        objPost.insurance=obj.DSALES_Aseguradora__c;
        objPost.packagge=obj.PlanTier;
        objPost.payment_plan=obj.PlanTier;
        objPost.payment_option =obj.DSALES_Opcionpago__c;
        objPost.vehicle_id=obj.DSALES_Activodeplizadeseguro__c;
        objPost.vehicle_service=obj.DSALES_Servicio__c;
        objPost.vehicle_use=obj.DSALES_Uso__c;
        objPost.vehicle_vin=obj.DSALES_Numeroserie__c;
        objPost.vehicle_plate=obj.DSALES_Placas__c;
        objPost.vehicle_model=obj.DSALES_Modelo__c;
        objPost.contractor_first_name=cli.FirstName;
        objPost.contractor_lastname=cli.LastName;
        objPost.contractor_second_lastname=cli.Suffix;
        objPost.contractor_rfc=obj.DSALES_RFC__c;
        objPost.contractor_email=obj.DSALES_CorreoElectronico__c;
        objPost.emision_date=String.valueOf( obj.Fecha_de_emisi_n__c);
        objPost.start_at=String.valueOf(obj.CreatedDate);
        System.debug('poliza json:'+objPost);
        String str = JSON.serialize(objPost);
        return str;
    }
}