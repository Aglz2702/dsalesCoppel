public without sharing class DSALES_ConsultaListaNegra{
   
    public static final String NOMBRE_SERVICIO = 'DSALES_ListaNegra';
    public static DSALES_ListaNegraWrapper.responseListaNegra callWebService(String rfc, String name){
        DSALES_ListaNegraWrapper.responseListaNegra respuesta;
        DSALES_ListaNegraWrapper.enviarListaNegra dato = new  DSALES_ListaNegraWrapper.enviarListaNegra();
        dato.nombre = name;
        dato.rfc = rfc;
        dato.business='serviciosPoliza';
        dato.company='coppel';
        dato.transaccion='get';
        String token = DSALES_obtenerToken.getToken();
        String body = JSON.serialize(dato);
        body = body.replace('transaccion', 'transaction');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = DSALES_Utility.getEndpoint(NOMBRE_SERVICIO);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Authorization','Bearer '+token);
        request.setHeader('Content-Type','application/json');
        request.setBody(body);
        System.debug('Se envia de lista negra: '+body);
        HttpResponse response = http.send(request);
        System.debug('recibimos de lista negra: ' + response.getBody());
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
            DSALES_ListaNegraWrapper.responseListaNegra resp = (DSALES_ListaNegraWrapper.responseListaNegra) JSON.deserialize(response.getbody(), DSALES_ListaNegraWrapper.responseListaNegra.class);
            if(resp.estatus == true){
                return resp;
            }else{
                System.debug('Respuesta no es true');
                return resp;
            }    
        }else{
            System.debug('Fallo en la comuncacion ConsultaListaNegra: ' + response.getBody());
        }
        return null;           
    }

}