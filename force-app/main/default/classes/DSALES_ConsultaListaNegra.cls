public without sharing class DSALES_ConsultaListaNegra{
    public static final String NOMBRE_SERVICIO = 'DSALES_ListaNegra';
    public static DSALES_ListaNegraWrapper.responseListaNegra callWebService(String rfc, String name){
        DSALES_ListaNegraWrapper.responseListaNegra respuesta;
        DSALES_ListaNegraWrapper.enviarListaNegra dato = new  DSALES_ListaNegraWrapper.enviarListaNegra();
        dato.nombre = name;
        dato.rfc = rfc;
        String body = JSON.serialize(dato);
        System.debug('Campos se envian: '+ body);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = DSALES_Utility.getEndpoint(NOMBRE_SERVICIO);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
            DSALES_ListaNegraWrapper.responseListaNegra resp = (DSALES_ListaNegraWrapper.responseListaNegra) JSON.deserialize(response.getbody(), DSALES_ListaNegraWrapper.responseListaNegra.class);
            if(resp.ok == 'true'){
                return resp;
            }else{
                System.debug('Respuesta no es ok');
                return resp;
            }    
        }else{
            System.debug('___Fallo____: comuncacion: ' + response.getBody());
        }
        return null;           
    }

}