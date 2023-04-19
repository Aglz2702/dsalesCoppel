@isTest
public class DSALES_MockHttpResponseSiniestroTest implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"ok": "true","response": "true","msg": "Actualización de Siniestro correcta","siniestro": { "uid": "1234567idwsd9221sqa","NumeroSiniestro": "04220504541"}}');
        response.setStatusCode(200);
        System.assertEquals('PUT', request.getMethod(),'mensaje de comparacion');
        return response;
    }
}