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

        if(Schema.sObjectType.Claim.isCreateable()) {
            insert siniestro;
        }else{
            System.debug('Permisos insuficientes para insertar');
        }
        
        return siniestro.Id;
    }
    public static String actualizaSiniestro(DSALES_SiniestroWrapper.SiniestroGet data){
        List<ClaimPaymentSummary> listaPagos = new List<ClaimPaymentSummary>();
        Claim siniestro = [SELECT Id,ClaimType,PolicyNumberId,DSALES_Estatus__c,DSALES_SolucionaDevoluci_n__c,DSALES_MotivodeDevolucion__c 
                           FROM Claim WHERE DSALES_SiniestroUid__c =:data.uid WITH SECURITY_ENFORCED LIMIT 1];
        if(data.estatus =='En requerimiento de información'){
            siniestro.DSALES_Estatus__c = data.estatus;
            siniestro.DSALES_MotivodeDevolucion__c = data.motivoDevolucion;
            siniestro.DSALES_SolucionaDevoluci_n__c = data.solucionDevolucion;
        }
        if(data.estatus =='Pendiente de información'){
            siniestro.DSALES_Estatus__c = data.estatus;
            siniestro.DSALES_SolucionDevolver__c = data.solucionDevolucion;
        }
        if(data.estatus =='Rechazado'){
            siniestro.DSALES_Estatus__c = data.estatus;
            siniestro.DSALES_Motivo_rechazo__c = data.motivoRechazo;
        }
        if(data.estatus =='En solicitud de saldo insoluto'){
            siniestro.DSALES_Estatus__c = data.estatus;
            siniestro.DSALES_SaldoInsoluto__c = Double.ValueOf(data.saldoinsoluto);
        }
        if(data.estatus =='Pagado'){ 
            for (DSALES_SiniestroWrapper.listaSiniestros aux : data.listSiniestro) {
                ClaimPaymentSummary siniestroRPRecord = new ClaimPaymentSummary();
                SiniestroRPRecord.ClaimId=siniestro.Id;
                SiniestroRPRecord.PaymentAmount= aux.paymentAmount;
                SiniestroRPRecord.Name = aux.claimpaymentName;
                SiniestroRPRecord.DSALES_Tipopago__c= aux.paymentType;
                SiniestroRPRecord.PaymentDate= aux.paymentDate;
                listaPagos.add(siniestroRPRecord);
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
        
        return siniestro.Id;
    }
}