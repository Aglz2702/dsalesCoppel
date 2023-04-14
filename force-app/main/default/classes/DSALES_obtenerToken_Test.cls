@isTest
public with sharing class DSALES_obtenerToken_Test {
    
    @isTest 
    static  void testGetCallout() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpToken());
        DSALES_obtenerToken.getToken();
        Test.stopTest();
        //System.assertNotEquals(null,result);  
    } 

    private class DSALES_MockHttpToken implements HttpCalloutMock {
         // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token": "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz","token_type": "Bearer","expires_in": 86400}');
            response.setStatusCode(200);
            return response;
        }
    }
    
}