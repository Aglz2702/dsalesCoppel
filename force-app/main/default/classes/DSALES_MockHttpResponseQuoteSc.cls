/*********************************************************************************************************************************************************************
@ Class Name :  DSALES_MockHttpResponseQuoteSc
@ Author : Namrata Katore
@ Purpose : It allows developers to simulate HTTP response and test the behaviour of code that makes external API requests.
@ Date : 4/9/2023
--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
@ Change History :
**********************************************************************************************************************************************************************/
@isTest
@SuppressWarnings('PMD.AvoidGlobalModifier') 
global class DSALES_MockHttpResponseQuoteSc implements HttpCalloutMock {
     Integer opc;
    global DSALES_MockHttpResponseQuoteSc(Integer opcr){
        opc = opcr;
    }
    global HttpResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        if(opc==1){
            if(request.getEndpoint().endsWith('/token')){
                System.debug('servicio del token');
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"access_token":"eLjcwPgjV3cErShhzdo7PSaFBOomG7tppkCs5uE75hF6eY1dKMoIeGVki0b6ZM6uyFn65e6Dxy3dTWY6kfMq8g","token_type":"Bearer","expires_in":86400}');
                response.setStatusCode(200);
                System.assertEquals('POST', request.getMethod(), 'Success');
                
            }
            else if(request.getEndpoint().endsWith('/black-list')){
                System.debug('servicio de lista negra');
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"codigo":200,"ok":false,"estatus":true,"message":"Sin similitudes en los campos marcados","data":{"entity":"listasNegras","transaction":"get","black_list":{"SAT":{"value":false,"msg":""},"SATB":{"value":false,"msg":""},"PEPBLOCK":{"value":false,"msg":""},"OFAC":{"value":false,"msg":""}},"estatus":true,"rfc":"MIVE901010","nombreContribuyente":"Sayra Quiroz Martinez"}}');
                System.assertEquals('POST', request.getMethod(), 'Success');
                
            }
            else if(request.getEndpoint().endsWith('/cotizaciones-cardif')){
                System.debug('servicio de cotización');
                response.setHeader('Content-Type', 'application/json');
                //response.setBody('{"exito":true, "mensaje":"", "metodoPago":"Efectivo","montoSeguroTotal":12500, "montoSeguroMensual":10000, "uuid":"TEST1237","plazos":[{"paquete":"Seguro Celular","opcionesPago":["12C"]}, {"paquete":"Seguro Celular","opcionesPago":["12M"]}, {"paquete":"Seguro Celular","opcionesPago":["18M"]}, {"paquete":"Seguro Celular","opcionesPago":["24M"]}, {"paquete":"Seguro Celular","opcionesPago":["30M"]}, {"paquete":"Seguro Celular","opcionesPago":["36M"]}], "price":[{"seguroPrice":450.12}, {"seguroPrice":450.12},{"seguroPrice":500.12},{"seguroPrice":650.12},{"seguroPrice":750.12},{"seguroPrice":850.12}]}');
                //response.setBody('{"exito":true, "mensaje":"", "metodoPago":"Efectivo","montoSeguroTotal":12500, "montoSeguroMensual":10000, "uuid":"TEST1237","plazo":"18M", "seguroPrice":450.00}');
                response.setBody('{"exito":true, "mensaje":"", "metodoPago":"Efectivo","montoSeguroTotal":12500, "montoSeguroMensual":10000, "uuid":"TEST1237","price":[{"plazo":"12", "seguroPrice":400}, {"plazo":"18", "seguroPrice":500}, {"plazo":"24", "seguroPrice":600}, {"plazo":"30", "seguroPrice":750.00}, {"plazo":"36", "seguroPrice":800.00}]}');
                response.setStatusCode(200);
                System.assertEquals('POST', request.getMethod(), 'Success');
                
            }
        }
        return response;
    }

}