public with sharing class DSALES_obtenerToken {
    public static final String NOMBRE_SERVICIO = System.Label.TOKEN;
    public static String getToken(){
        String access_token;
        Http https = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = DSALES_Utility.getEndpoint(NOMBRE_SERVICIO);
        request.setHeader('Content-Type','application/json');
        request.setHeader('client_id', System.Label.client_id);
        request.setHeader('client_secret', System.Label.client_secret);
        request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        httpResponse response = https.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            access_token = (String) tokenResponse.get('access_token');
            System.debug('Access Token: ' + access_token);
        } else {
            System.debug('Error al obtener el token de acceso: ' + response.getBody());
        }
        return access_token;
    }
}