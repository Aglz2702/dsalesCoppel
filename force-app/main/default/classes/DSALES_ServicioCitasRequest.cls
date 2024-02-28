@RestResource(urlMapping='/actualizarCitas/*')
global with sharing class DSALES_ServicioCitasRequest {
    @HttpPost
    global static DSALES_ServicioCitasWrapper.CitasResponse upsertCitasResponse() {
        String message = '';
        String code = '';
        Boolean success = false;
        Event event=new Event();
        String respuesta= '';
        DSALES_ServicioCitasWrapper.CitasResponse response = new  DSALES_ServicioCitasWrapper.CitasResponse();
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    DSALES_ServicioCitasWrapper.CitasRequest data = ( DSALES_ServicioCitasWrapper.CitasRequest)JSON.deserialize(body, DSALES_ServicioCitasWrapper.CitasRequest.class);
                    try {
                        event = [SELECT Id FROM Event WHERE dsalesCertificado__r.Name = :data.certificado and dSalesNoCita__c=: data.noCita  WITH SECURITY_ENFORCED LIMIT 1];
                    } catch (QueryException e) {
                        event=null;
                    }
                    if(event != null){
                        success = true;
                        respuesta= actualizaCita(data, event.id);
                        message = '¡Se actualizó el evento exitosamente!';
                        code = '200';
                    }else{
                        success = true;
                        respuesta = crearCita(data);
                        message = '¡Se creo el evento exitosamente!';
                        code = '200';
                    } 
                }catch(JSONException e){
                    success = false;
                    code = String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    message = DSALES_Utility.BAD_REQUEST_MSJ+ ' ' +e.getMessage() + ' '+e.getLineNumber() + ' '+ e.getCause();
                }catch(Exception e){
                    success = false;
                    code = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    message = DSALES_Utility.INTERNAL_ERROR_MSJ + ' ' +e.getMessage() + ' Linea: '+e.getLineNumber() + ' '+ e.getCause();
                }
            }
        }
        response.codigoError=code;
        response.mensaje=message;
        response.exito=success;
        response.idEvento=respuesta;
        return response;

    }

    public static String crearCita(DSALES_ServicioCitasWrapper.CitasRequest data){
        Event evento = new Event(); 
        String respuesta= '';
        String message='¡Error al crear Evento!';
        String recordTypeIns= Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('dSalesServicioInstalacion').getRecordTypeId();
        DSALES_Certificado__c  certi= [Select id from DSALES_Certificado__c where name=: data.certificado WITH SECURITY_ENFORCED limit 1];
        dsalesCP__c cp= [Select id, dsalesCiudad__r.name from dsalesCP__c where name=: data.codigoP WITH SECURITY_ENFORCED limit 1];
        dsalesCiudad__c ciudad= [Select id, dsalesRegion__r.name from dsalesCiudad__c where name=: cp.dsalesCiudad__r.name WITH SECURITY_ENFORCED limit 1];
        dsalesRegion__c region= [Select id, name from dsalesRegion__c where name=: ciudad.dsalesRegion__r.name WITH SECURITY_ENFORCED limit 1];
        Calendar calendario= [Select id , Name From Calendar Where Type='Public' and name =:region.Name WITH SECURITY_ENFORCED limit 1];
        dsalesProveedores__c proveedor= [Select id from dsalesProveedores__c where name=: data.proveedor WITH SECURITY_ENFORCED limit 1];
        if(certi != null){
            evento.dsalesCertificado__c=certi.id;
            evento.OwnerId=calendario.id;
            //evento.DurationInMinutes=data.fechaHorario;
            evento.recordTypeId=recordTypeIns;
            evento.StartDateTime=Datetime.valueOf(data.inicio);
            evento.EndDateTime=Datetime.valueOf(data.fin);
            evento.dSalesProveedores__c=proveedor.id;
            evento.dSalesNoCita__c=data.noCita;
            evento.dSalesRealizado__c=data.validacion;
            evento.dSalesEstatusCita__c=data.estatus;
            evento.dSalesSkuTangible__c=data.sku;
            evento.dSalesMarca__c=data.marca;
            evento.dSalesArticulo__c=data.articulo;
            evento.dSalesModelo__c=data.modelo;
            evento.dSalesResultadosCuestionario__c=data.cuestionario;
            evento.dSalesTecnico__c=data.tecnico;
            evento.Subject=data.asunto;
            evento.dSalesCodigoPostal__c=cp.id;
            evento.dSalesDireccionCliente__c=data.direccion;
            if(Schema.sObjectType.Event.isCreateable()) {
                insert evento;
                message='¡Se creo el evento exitosamente!';
                
                respuesta=evento.id;
            }
        }
        else{
            message='¡No se encontró el certificado!';
        }
        
        return respuesta;

    }
    public static String actualizaCita(DSALES_ServicioCitasWrapper.CitasRequest data, String idEvento){
        Event evento = new Event(); 
        String respuesta= '';
        String recordTypeIns= Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('dSalesServicioInstalacion').getRecordTypeId();
        DSALES_Certificado__c certi= [Select id from DSALES_Certificado__c where name=: data.certificado WITH SECURITY_ENFORCED limit 1];
        dsalesCP__c cp= [Select id, dsalesCiudad__r.name from dsalesCP__c where name=: data.codigoP WITH SECURITY_ENFORCED limit 1];
        dsalesCiudad__c ciudad= [Select id, dsalesRegion__r.name from dsalesCiudad__c where name=: cp.dsalesCiudad__r.name WITH SECURITY_ENFORCED limit 1];
        dsalesRegion__c region= [Select id, name from dsalesRegion__c where name=: ciudad.dsalesRegion__r.name WITH SECURITY_ENFORCED limit 1];
        Calendar calendario= [Select id , Name From Calendar Where Type='Public' and name =:region.Name WITH SECURITY_ENFORCED limit 1];
        dsalesProveedores__c proveedor= [Select id from dsalesProveedores__c where name=: data.proveedor WITH SECURITY_ENFORCED limit 1];
        String message='¡Error al actualizar Evento!';
        evento.id=idEvento;
        evento.dsalesCertificado__c=certi.id;
        evento.OwnerId=calendario.id;
        //evento.DurationInMinutes=data.fechaHorario;
        evento.recordTypeId=recordTypeIns;
        evento.StartDateTime=Datetime.valueOf(data.inicio);
        evento.EndDateTime=Datetime.valueOf(data.fin);
        evento.dSalesProveedores__c=proveedor.id;
        evento.dSalesNoCita__c=data.noCita;
        evento.dSalesRealizado__c=data.validacion;
        evento.dSalesEstatusCita__c=data.estatus;
        evento.dSalesSkuTangible__c=data.sku;
        evento.dSalesMarca__c=data.marca;
        evento.dSalesArticulo__c=data.articulo;
        evento.dSalesModelo__c=data.modelo;
        evento.dSalesResultadosCuestionario__c=data.cuestionario;
        evento.dSalesTecnico__c=data.tecnico;
        evento.dSalesCodigoPostal__c=cp.id;
        evento.dSalesDireccionCliente__c=data.direccion;
        if(Event.SObjectType.getDescribe().isUpdateable()) {
            system.debug(evento);
            update evento;  
            message='¡Se actualizó el evento exitosamente!'; 
            respuesta=evento.id;
        }else{
            System.debug('Permisos insuficientes para actualizar');   
        } 
        return respuesta;
    }

}