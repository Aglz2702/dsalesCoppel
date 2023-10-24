@RestResource(urlMapping='/upsertServices/*')
global with sharing class DSALES_ServicioArmadoWrapperRequest {
    
    @HttpPost
    global static DSALES_ServicioArmadoWrapper.ArmadoResponse upsertServices(){
        String message = '';
        String code = '';
        Boolean success = false;
        
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    DSALES_ServicioArmadoWrapper.ArmadoRequest data = (DSALES_ServicioArmadoWrapper.ArmadoRequest)JSON.deserialize(body, DSALES_ServicioArmadoWrapper.ArmadoRequest.class);
                    if(!data.ars.isEmpty()){
                        success = true;
                        message = actualizaArs(data);
                        code = '200';
                    }else{
                        success = true;
                        message = actualizaEstatus(data);
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
        DSALES_ServicioArmadoWrapper.ArmadoResponse response = new DSALES_ServicioArmadoWrapper.ArmadoResponse();
        response.codigoError = code;
        response.exito = success;
        response.mensaje = message;
        return response;
    }
    
    public static String actualizaArs(DSALES_ServicioArmadoWrapper.ArmadoRequest data){
        String message = '';
        Map<String, Integer> mapArs = new  Map<String, Integer>();
        List<String> arActualizados = new  List<String>();
        List<String> arNoActualizados = new  List<String>();
        
        for(DSALES_ServicioArmadoWrapper.ars x : data.ars){
            mapArs.put(x.skuTangible,x.AR);
        }
        for (String clave : mapArs.keySet()) {
            List<Product2> registros = [SELECT Id, Name, dsalesAR__c, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit = :clave LIMIT 1];
            if (registros.isEmpty()){
                arNoActualizados.add(clave);
            }else{
                try{
                    Product2 actualizarAR = registros[0];
                    actualizarAR.dsalesAR__c = mapArs.get(clave);
                    
                    update actualizarAR;
                    
                    arActualizados.add(clave);
                }catch(Exception e){
                    message = 'ocurrio un problema '+e.getMessage();
                }
            }
            message = 'sku Actualizados '+ arActualizados + '<br>' + 'sku no Actualizados '+ arNoActualizados;
        }
        return message;     
    }
    
    public static String actualizaEstatus(DSALES_ServicioArmadoWrapper.ArmadoRequest data){
        String message = '';
        Map<String, DSALES_ServicioArmadoWrapper.estatus> mapCertificados = new  Map<String, DSALES_ServicioArmadoWrapper.estatus>();
        List<String> certificadosActualizados = new  List<String>();
        List<String> certificadosNoActualizados = new  List<String>();
        
        for(DSALES_ServicioArmadoWrapper.estatus x : data.estatus){
            mapCertificados.put(x.numeroCertificado,x);
        }
        for (String clave : mapCertificados.keySet()) {
            List<DSALES_Certificado__c> registros = [SELECT Id, dsalesEstatusServicioArmado__c FROM DSALES_Certificado__c WHERE Name = :clave LIMIT 1];
            if (registros.isEmpty()){
                certificadosNoActualizados.add(clave);
            }else{
                try{
                    DSALES_Certificado__c actualizarEstatus = registros[0];
                    DSALES_ServicioArmadoWrapper.estatus estatus = mapCertificados.get(clave); 
                    
                    actualizarEstatus.dsalesEstatusServicioArmado__c = estatus.estatus;
                    actualizarEstatus.dsalesFechaHoraServicioArmado__c = Datetime.valueOf(estatus.fechaArmado);
                    
                    update actualizarEstatus;
                    
                    certificadosActualizados.add(clave);
                }catch(Exception e){
                    message = 'ocurrio un problema '+e.getMessage();
                }
            }
            message = 'Armados completados'+ certificadosActualizados + '<br>' + 'Armados no completados '+ certificadosNoActualizados;
        }
        return message;     
    }
}