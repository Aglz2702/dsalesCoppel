@RestResource(urlMapping='/siniestroUpsert/*')
global with sharing class DSALES_Siniestro {
    
    @HttpPost
    global static DSALES_SiniestroWrapper.siniestroPostResponse siniestroUpsert(){
        String message = '';
        Integer errorCode;
        Boolean succes = false;
        String idSiniestro;
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    DSALES_SiniestroWrapper.SiniestroGet data = (DSALES_SiniestroWrapper.SiniestroGet)JSON.deserialize(body, DSALES_SiniestroWrapper.SiniestroGet.class);
                    if(data.requestSeguroCelulares != null && data.requestSeguroCelulares.uid != null && data.requestSeguroCelulares.uid != ''){
                        System.debug('Entro a seguro de celulares');
                        Integer existe = [SELECT COUNT() FROM Claim WHERE DSALES_SiniestroUid__c =:data.requestSeguroCelulares.uid WITH SECURITY_ENFORCED];
                        if(existe > 0 && data.requestSeguroCelulares.uid!=''){
                            idSiniestro = actualizaSiniestroSC(data);
                            message = 'Siniestro Actualizado';
                            succes = true;
                        }
                        else{
                            idSiniestro = createSiniestroSC(data); 
                            message = 'Siniestro Creado';
                            succes = true;
                        }
                    }else if(data.requestSeguroMotos != null && data.requestSeguroMotos.uid != null && data.requestSeguroMotos.uid != ''){
                        message = 'Entro a seguro de motos';
                        Integer existe = [SELECT COUNT() FROM Claim WHERE DSALES_SiniestroUid__c =:data.requestSeguroMotos.uid WITH SECURITY_ENFORCED];
                        if(existe > 0 && data.requestSeguroMotos.uid!=''){
                            idSiniestro = actualizaSiniestro(data);
                            message = 'Siniestro Actualizado';
                            succes = true;
                        }
                        else{
                            idSiniestro = createSiniestro(data); 
                            message = 'Siniestro Creado';
                            succes = true;
                        }
                    }else{
                        errorCode = 500;
                        idSiniestro = '0'; 
                        message = 'UID necesario para continuar';
                        succes = false;
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
        String recordTypeId = Schema.SObjectType.Claim.getRecordTypeInfosByName().get('Siniestro SM').getRecordTypeId();
        InsurancePolicy poliza = [SELECT Id, Name FROM InsurancePolicy WHERE Name =:data.requestSeguroMotos.poliza.numeroPoliza WITH SECURITY_ENFORCED LIMIT 1];
        Claim siniestro = new Claim();
        siniestro.Name = data.requestSeguroMotos.reporte;
        siniestro.ClaimType = data.requestSeguroMotos.tipoSiniestro;
        siniestro.ClaimReason = data.requestSeguroMotos.causa;
        siniestro.PolicyNumberId = poliza.Id;
        siniestro.DSALES_Estatus__c = 'Nuevo';
        siniestro.DSALES_SiniestroUid__c = data.requestSeguroMotos.uid;
        siniestro.DSALES_Ano__c=data.requestSeguroMotos.vehiculo.anio;
        siniestro.DSALES_Serie__c=data.requestSeguroMotos.vehiculo.serie;
        siniestro.dsalesFechaAltaSiniestro__c=Datetime.valueOf(data.requestSeguroMotos.fechaSiniestro);
        siniestro.DSALES_Causa__c=data.requestSeguroMotos.causa;
        siniestro.IncidentSiteCity = data.requestSeguroMotos.municipio;
        siniestro.IncidentSiteState=data.requestSeguroMotos.estado;
        siniestro.IncidentSiteStreet=data.requestSeguroMotos.ubicacion;
        siniestro.DSALES_Descripcion__c=data.requestSeguroMotos.vehiculo.descripcion;
        siniestro.DSALES_Nombre_conductor__c = data.requestSeguroMotos.nombreConductor;
        
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
                           FROM Claim WHERE DSALES_SiniestroUid__c =:data.requestSeguroMotos.uid WITH SECURITY_ENFORCED LIMIT 1];
        if(data.requestSeguroMotos.estatus =='En revisión'){
            siniestro.DSALES_Estatus__c = 'En trámite';
        }
        if(data.requestSeguroMotos.estatus =='Documentado'){
            siniestro.DSALES_Estatus__c = 'Autorizado';
        }
        if(data.requestSeguroMotos.estatus == 'Pendiente de información'){
            siniestro.DSALES_Estatus__c = 'En requerimiento de información';
            siniestro.DSALES_MotivodeDevolucion__c = data.requestSeguroMotos.comentarioDeEstatus;
            siniestro.dsalesSolucionaDevolucion__c = data.requestSeguroMotos.solucion;
        }
        if(data.requestSeguroMotos.estatus =='Rechazado'){
            siniestro.DSALES_Estatus__c = data.requestSeguroMotos.estatus;
            siniestro.DSALES_Motivo_rechazo__c = data.requestSeguroMotos.motivodeRechazo;
        }
        if(data.requestSeguroMotos.estatus == 'Solicitud de saldo'){
            siniestro.DSALES_Estatus__c = 'En solicitud de saldo insoluto';
            siniestro.DSALES_SaldoInsoluto__c = Double.ValueOf(data.requestSeguroMotos.saldoinsoluto);
        }
        if(data.requestSeguroMotos.estatus =='Pagado'){
            //siniestro.dsalesFechaPagoSiniestro__c = data.fechaDePago;
            if(decimal.valueOf(data.requestSeguroMotos.saldo)!=0.0){
                SiniestroRPRecord.ClaimId=siniestro.Id;
                SiniestroRPRecord.PaymentAmount= decimal.valueOf(data.requestSeguroMotos.saldoInsoluto);
                SiniestroRPRecord.Name = 'Pago de siniestro';
                SiniestroRPRecord.DSALES_Tipopago__c= 'Pago a cuenta Coppel';
                SiniestroRPRecord.PaymentDate= data.requestSeguroMotos.fechaDePago;
                listaPagos.add(SiniestroRPRecord);
            }
            if(decimal.valueOf(data.requestSeguroMotos.remanente)!=0.0){
                SiniestroRPRecord = new ClaimPaymentSummary();
                SiniestroRPRecord.ClaimId=siniestro.Id;
                SiniestroRPRecord.PaymentAmount= decimal.valueOf(data.requestSeguroMotos.remanente);
                SiniestroRPRecord.Name = 'Pago de siniestro';
                SiniestroRPRecord.DSALES_Tipopago__c= 'Pago a Cliente';
                SiniestroRPRecord.PaymentDate= data.requestSeguroMotos.fechaDePago;
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
        
        return siniestro.Id;
    }
    /*********************************************************************************************************************************************************************
-- Seguro de celulares code --
**********************************************************************************************************************************************************************/
    public static String createSiniestroSC(DSALES_SiniestroWrapper.SiniestroGet data){
        String recordTypeId = Schema.SObjectType.Claim.getRecordTypeInfosByName().get('Siniestro SC').getRecordTypeId();
        InsurancePolicy poliza = [SELECT Id,Name,dsalesActivoPolizaSeguro__c,dsalesActivoPolizaSeguro__r.DSALES_Marca__c,dsalesActivoPolizaSeguro__r.DSALES_Descripcion__c,dsalesActivoPolizaSeguro__r.dsalesAnio__c,dsalesActivoPolizaSeguro__r.DSALES_Modelo__c FROM InsurancePolicy WHERE Name =:data.requestSeguroCelulares.numeroPoliza WITH SECURITY_ENFORCED LIMIT 1];
        Claim siniestro = new Claim();
        siniestro.Name = 'siniestro';
        siniestro.ClaimType = data.requestSeguroCelulares.tipoSiniestro;
        siniestro.ClaimReason = data.requestSeguroCelulares.causa;
        siniestro.PolicyNumberId = poliza.Id;
        siniestro.DSALES_Estatus__c = 'Nuevo';
        siniestro.DSALES_SiniestroUid__c = data.requestSeguroCelulares.uid;
        siniestro.dsalesFechaAltaSiniestro__c=Datetime.valueOf(data.requestSeguroCelulares.fechaCreacion);
        siniestro.InsuredAssetId = poliza.dsalesActivoPolizaSeguro__c;
        siniestro.DSALES_Marca__c = poliza.dsalesActivoPolizaSeguro__r.DSALES_Marca__c;
        siniestro.DSALES_Descripcion__c = poliza.dsalesActivoPolizaSeguro__r.DSALES_Descripcion__c;
        siniestro.DSALES_Ano__c = String.valueOF(poliza.dsalesActivoPolizaSeguro__r.dsalesAnio__c);
        siniestro.Modelo__c = poliza.dsalesActivoPolizaSeguro__r.DSALES_Modelo__c;
        if(Schema.sObjectType.Claim.isCreateable()) {
            insert siniestro;
        }else{
            System.debug('Permisos insuficientes para insertar');
        }
        
        return siniestro.Id;
    }
    
    public static String actualizaSiniestroSC(DSALES_SiniestroWrapper.SiniestroGet data){
        ClaimItem elementoSiniestro = new ClaimItem();
        Claim siniestro = [SELECT Id,ClaimType,PolicyNumberId,DSALES_Estatus__c,dsalesSolucionaDevolucion__c,DSALES_MotivodeDevolucion__c,DSALES_Marca__c,DSALES_Descripcion__c 
                           FROM Claim WHERE DSALES_SiniestroUid__c =:data.requestSeguroCelulares.uid WITH SECURITY_ENFORCED LIMIT 1];
        if(data.requestSeguroCelulares.estatus =='En trámite'){
            siniestro.DSALES_Estatus__c = 'En trámite';
        }
        if(data.requestSeguroCelulares.estatus == 'En requerimiento de información'){
            siniestro.DSALES_Estatus__c = 'En requerimiento de información';
            siniestro.DSALES_MotivodeDevolucion__c = data.requestSeguroCelulares.comentarioDeEstatus;
            siniestro.dsalesSolucionaDevolucion__c = data.requestSeguroCelulares.solucion;
        }
        if(data.requestSeguroCelulares.estatus =='Rechazado'){
            siniestro.DSALES_Estatus__c = data.requestSeguroCelulares.estatus;
            siniestro.DSALES_Motivo_rechazo__c = data.requestSeguroCelulares.motivodeRechazo;
        }
        if(data.requestSeguroCelulares.estatus =='Autorizado'){
            siniestro.DSALES_Estatus__c = 'Autorizado';
            elementoSiniestro.ClaimId = siniestro.Id;
            elementoSiniestro.Name = siniestro.DSALES_Marca__c;
            elementoSiniestro.dsalesEstatus__c = 'Nuevo';
            elementoSiniestro.Description = siniestro.DSALES_Descripcion__c;
            elementoSiniestro.dsalesTipoSiniestro__c = siniestro.ClaimType;
            
            if(ClaimItem.SObjectType.getDescribe().isCreateable()) {
                insert elementoSiniestro;   
            }else{
                System.debug('Permisos insuficientes para insertar');   
            } 
        }
        if(data.requestSeguroCelulares.estatus =='Reposición/Reparación'){
            siniestro.DSALES_Estatus__c = 'Reposición/Reparación';
            
            elementoSiniestro = [SELECT Id FROM ClaimItem WHERE ClaimId=:siniestro.Id LIMIT 1];
            elementoSiniestro.id = elementoSiniestro.id;
            elementoSiniestro.dsalesEstatus__c = 'En Proceso';
            update elementoSiniestro;
        }
        if(data.requestSeguroCelulares.estatus =='Realizado'){
            siniestro.DSALES_Estatus__c = 'Realizado';
            
            elementoSiniestro = [SELECT Id FROM ClaimItem WHERE ClaimId=:siniestro.Id LIMIT 1];
            elementoSiniestro.id = elementoSiniestro.id;
            elementoSiniestro.dsalesEstatus__c = 'Entregado';
            update elementoSiniestro;
        }
        
        if(Claim.SObjectType.getDescribe().isUpdateable()) {
            update siniestro;   
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        } 
        
        return siniestro.Id;
    }
}