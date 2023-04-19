public with sharing class DSALES_GetPolicyPDF {
    public static final String NOMBRE_SERVICIO = 'DSALES_GetPolicyPDF';
    public static String  service(InsurancePolicy poliza){
        System.debug('POLIZA EN GETPDF:'+poliza);
        String pdf='';
        String body = obtenerCampos(poliza);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = DSALES_Utility.getEndpoint(NOMBRE_SERVICIO);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = http.send(request);
        System.debug('responseGet: '+ response.getbody());
        DSALES_GetPolicyPdfWrapper.responseWrapper respuesta = (DSALES_GetPolicyPdfWrapper.responseWrapper)JSON.deserialize(response.getbody(),DSALES_GetPolicyPdfWrapper.responseWrapper.class);
        if(respuesta.code == 200 || respuesta.code == 201 ){
            if(respuesta.success == true){
                pdf=respuesta.data.policy_url;
                System.debug('url pdf: '+pdf);
                //update poliza;
            }
            
        }
        else{
            List<DSALES_GetPolicyPdfWrapper.Errors> errores = respuesta.data.errors;
            System.debug('error'+ errores);
        }
        System.debug('url en getPolicyPdf:'+pdf);    
        return pdf;
    }

    public static String obtenerCampos(InsurancePolicy poliza){
        System.debug('******************************************');
        System.debug('****NOMBRE PÓLIZA ****:'+poliza.Name);
        System.debug('****tracking_id****:'+poliza.DSALES_Numeroseguimiento__c);
        DSALES_GetPolicyPdfWrapper.requestWrapper req= new DSALES_GetPolicyPdfWrapper.requestWrapper();
        req.tracking_id=poliza.DSALES_Numeroseguimiento__c;
        req.business=poliza.DSALES_Negocio__c;
        req.insurance=poliza.DSALES_Aseguradora__c;
        req.Poliza=poliza.Name;
        String str = JSON.serialize(poliza);
        return str;
    }

}