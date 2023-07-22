@RestResource(urlMapping='/siniestroUpsert/*')
global with sharing class DSALES_Siniestro {

    @HttpPost
    global static DSALES_SiniestroWrapper.siniestroPostResponse siniestroUpsert(){
 String message = '';
        Integer errorCode;
        Boolean succes = false;
        String idSiniestro;
        DSALES_SiniestroWrapper.SiniestroGet data = new DSALES_SiniestroWrapper.SiniestroGet();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    data = (DSALES_SiniestroWrapper.SiniestroGet)JSON.deserialize(body, DSALES_SiniestroWrapper.SiniestroGet.class);
                    Integer existe = [SELECT COUNT() FROM Claim WHERE DSALES_SiniestroUid__c =:data.uid WITH SECURITY_ENFORCED];
                    if(existe > 0 && data.uid!=''){
                        idSiniestro = actualizaSiniestro(data);
                        message = 'Siniestro Actualizado';
                        succes = true;
                    }
                    else{
                        idSiniestro = createSiniestro(data); 
                        message = 'Siniestro Creado';
                        succes = true;
                    }                      
                }catch(Exception.JSONException jsonException){
                    message = DSALES_Utility.BAD_REQUEST_MSJ;
                    errorCode = DSALES_Utility.BAD_REQUEST_CODE;
                    succes = false;      
                }catch(Exception e){
                    //ver error en la linea message = e.getMessage()+'Linea: '+e.getLineNumber();
                    message = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    message = e.getMessage()+'Linea: '+e.getLineNumber();
                    errorCode = DSALES_Utility.INTERNAL_ERROR_CODE;
                    succes = false;
                }
            }
        }
        DSALES_SiniestroWrapper.siniestroPostResponse response = new DSALES_SiniestroWrapper.siniestroPostResponse();
        response.success = succes;
        response.mensaje = message;
        response.codigoError = errorCode;
        response.idSiniestro = idSiniestro;
        return response;
    }
    public static String createSiniestro(DSALES_SiniestroWrapper.SiniestroGet data){
        InsurancePolicy poliza = [SELECT Id, Name FROM InsurancePolicy WHERE Name =:data.poliza.numeroPoliza WITH SECURITY_ENFORCED LIMIT 1];
        Claim siniestro = new Claim();
        siniestro.Name = data.reporte;
        siniestro.ClaimType = data.tipoSiniestro;
        siniestro.ClaimReason = data.causa;
        siniestro.PolicyNumberId = poliza.Id;
        siniestro.DSALES_Estatus__c = 'Nuevo';
        siniestro.DSALES_SiniestroUid__c = data.uid;
        siniestro.DSALES_Ano__c=data.vehiculo.anio;
        siniestro.DSALES_Serie__c=data.vehiculo.serie;
        siniestro.dsalesFechaAltaSiniestro__c=Datetime.valueOf(data.fechaSiniestro);
        siniestro.DSALES_Causa__c=data.causa;
        siniestro.IncidentSiteCity = data.municipio;
        siniestro.IncidentSiteState=data.estado;
        siniestro.IncidentSiteStreet=data.ubicacion;
        siniestro.DSALES_Descripcion__c=data.vehiculo.descripcion;
        siniestro.DSALES_Nombre_conductor__c = data.nombreConductor;

        if(Schema.sObjectType.Claim.isCreateable()) {
            insert siniestro;
        }else{
            System.debug('Permisos insuficientes para insertar');
        }
        
        return siniestro.Id;
    }
    public static String actualizaSiniestro(DSALES_SiniestroWrapper.SiniestroGet data){
        List<ClaimPaymentSummary> listaPagos = new List<ClaimPaymentSummary>();
        ClaimPaymentSummary SiniestroRPRecord = new ClaimPaymentSummary();
       
        Claim siniestro = [SELECT Id,ClaimType,PolicyNumberId,DSALES_Estatus__c,dsalesSolucionaDevolucion__c,DSALES_MotivodeDevolucion__c 
                           FROM Claim WHERE DSALES_SiniestroUid__c =:data.uid WITH SECURITY_ENFORCED LIMIT 1];
        try{
        if(data.estatus =='En revisión'){
            siniestro.DSALES_Estatus__c = 'En trámite';
        }
        if(data.estatus =='Documentado'){
            siniestro.DSALES_Estatus__c = 'Autorizado';
        }
        if(data.estatus == 'Pendiente de información'){
            siniestro.DSALES_Estatus__c = 'En requerimiento de información';
            siniestro.DSALES_MotivodeDevolucion__c = data.comentarioDeEstatus;
            siniestro.dsalesSolucionaDevolucion__c = data.solucion;
        }
        if(data.estatus =='Rechazado'){
            siniestro.DSALES_Estatus__c = data.estatus;
            siniestro.DSALES_Motivo_rechazo__c = data.motivodeRechazo;
        }
        if(data.estatus == 'Solicitud de saldo'){
            siniestro.DSALES_Estatus__c = 'En solicitud de saldo insoluto';
            siniestro.DSALES_SaldoInsoluto__c = Double.ValueOf(data.saldoinsoluto);
        }
        if(data.estatus =='Pagado'){
            if(decimal.valueOf(data.saldo)!=0.0){
                SiniestroRPRecord.ClaimId=siniestro.Id;
                SiniestroRPRecord.PaymentAmount= decimal.valueOf(data.saldoInsoluto);
                SiniestroRPRecord.Name = 'Pago de siniestro';
                SiniestroRPRecord.DSALES_Tipopago__c= 'Pago a cuenta Coppel';
                SiniestroRPRecord.PaymentDate= data.fechaDePago;
                listaPagos.add(SiniestroRPRecord);
            }
            if(decimal.valueOf(data.remanente)!=0.0){
                SiniestroRPRecord = new ClaimPaymentSummary();
                SiniestroRPRecord.ClaimId=siniestro.Id;
                SiniestroRPRecord.PaymentAmount= decimal.valueOf(data.remanente);
                SiniestroRPRecord.Name = 'Pago de siniestro';
                SiniestroRPRecord.DSALES_Tipopago__c= 'Pago a Cliente';
                SiniestroRPRecord.PaymentDate= data.fechaDePago;
                listaPagos.add(SiniestroRPRecord);
            }
            if(listaPagos!=null && Schema.sObjectType.ClaimPaymentSummary.isCreateable()){
                insert listaPagos;  
            }
        }
        
        if(Claim.SObjectType.getDescribe().isUpdateable()) {
            update siniestro;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        } 
        }catch(DmlException e) {
        System.debug('Ocurrió un error: ' + e);
    }
        return siniestro.Id;
    }
}