@isTest
global class DSALES_MockHttpResponseSiniestro implements HttpCalloutMock{
    Integer opc;
    global DSALES_MockHttpResponseSiniestro(Integer opcr){
        opc = opcr;
    }
    	global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if(opc == 1){        
                response.setBody('{ "ok": "true", "response": "true", "msg": "Nuevo Siniestro insertado", "siniestro": { "uid": "aswfewefwfewfewfe", "NumeroSiniestro": "04220504541" }}');
                response.setStatusCode(200);         
            }
            if(opc == 2){        
                response.setBody('{ "ok": "true", "response": "true", "msg": "Actualización de Siniestro correcta", "siniestro": { "uid": "aswfewefwfewfewfe", "NumeroSiniestro": "04223333333" } }');
                response.setStatusCode(200);         
            }
            if(opc == 3){        
                response.setBody('{ "uid": "aswfewefwfewfewfe", "Reporte": "057486122", "NumeroSiniestro": "04220504541", "TipoSiniestro": "Robo", "FechaSiniestro": "28/07/2022 16:40:23", "NombreConductor": "José Juan Resendiz Calavera ", "Causa": "Chocó", "Vehiculo": { "Descripcion": "MOTOCICLETA VENTO WORKMAN 125 CC", "Anio": "2022", "Placa": "123HDF", "Serie": "1234DFGERS92871WD" }, "Poliza": { "NumeroPoliza": "4240072338", "Inciso": "0001", "FechaInicioVigencia": "23/03/2022", "FechaFinVigencia": "22/03/2023", "NombreAsegurado": "Graciela Guzmán Arreola" }, "ComoOcurrio": "Se cayó y chocó", "Ubicacion": "Calle Orquideas 27", "Municipio": "Tampico", "Estado": "Tamaulipas", "Estatus": "Rechazado", "DocumentosVehiculo": { "Factura": "cadena a 64 bits del documento escaneado", "ContanciaBajaPlacas": "cadena a 64 bits del documento escaneado", "ComprobantesTenencia": [ { "Descripcion": "cadena a 64 bits del documento escaneado", "Comprobante": "cadena a 64 bits del documento escaneado", "IdComprobante": "cadena a 64 bits del documento escaneado" }, { "Descripcion": "cadena a 64 bits del documento escaneado", "Comprobante": "cadena a 64 bits del documento escaneado", "IdComprobante": "cadena a 64 bits del documento escaneado" } ], "CarpetaMP": "cadena a 64 bits del documento escaneado", "AcreditacionMP": "cadena a 64 bits del documento escaneado", "OficioLiberacionRobo": "cadena a 64 bits del documento escaneado" }, "DocumentosAsegurado": { "IdentificacionFrontal": "cadena a 64 bits del documento escaneado", "IdentificacionReverso": "cadena a 64 bits del documento escaneado", "ComprobanteDomicilio": "cadena a 64 bits del documento escaneado", "CURP": "cadena a 64 bits del documento escaneado", "PoderNotarial": "cadena a 64 bits del documento escaneado", "EncabezadoCuentaBancaria": "cadena a 64 bits del documento escaneado", "ConstanciaSituacionFiscal": "cadena a 64 bits del documento escaneado" }, "DocumentosAseguradora": { "CartaConsentimientoCFDI": "cadena a 64 bits del documento escaneado", "FormatoCompraVenta": "cadena a 64 bits del documento escaneado", "FormatoFiniquito": "cadena a 64 bits del documento escaneado" }, "salesforceid": "xxxxxxxxxxxxxx" }');
                response.setStatusCode(200);         
            }
            if(opc == 4){        
                response.setBody('{ "ok": "true", "estatus": false, "rfc": "JUCE761023", "nombreContribuyente": "Juan José Castañeda Espinoza" }');
                response.setStatusCode(200);         
            }
            if(opc == 5){        
                response.setBody('{"ok":"true","estatus":false,"rfc":"JUCE761023","nombreContribuyente":"Juan José Castañeda Espinoza"}');
                response.setStatusCode(200);         
            }
            if(opc == 6){        
                response.setBody('{"codigo":201,"success":true,"plazos":[{"trackingId":"SDSSJWEJESSDNM","nombre":"RC Seguro de Moto","plazo":"12","data":{"listaCoberturas":[{"codigo":"DM","nombre":"Daños Materiales","deducible":0,"sumaAsegurada":""},{"codigo":"RT","sumaAsegurada":"","deducible":0,"nombre":"Robo Total"},{"sumaAsegurada":"3000000","nombre":"Responsabilidad Civil bienes y personas","deducible":0,"codigo":"RC"},{"sumaAsegurada":"300000","nombre":"Gastos Médicos","deducible":0,"codigo":"GM"},{"deducible":0,"nombre":"RC en el extranjero","codigo":"RCE","sumaAsegurada":"A"},{"sumaAsegurada":"A","deducible":0,"nombre":"Asistencia Vial","codigo":"AV"},{"deducible":0,"nombre":"Defensa legal","sumaAsegurada":"A","codigo":"DL"},{"deducible":0,"sumaAsegurada":"A","nombre":"Extensión Cobertura","codigo":"EC"}],"idPoliza":"0","quote_id":"0606199820","paymentOptionsJson":[{"value":"12A","label":"Anual 12 meses"}],"primaSeguro":{"derecho":100.05,"comision":2,"recargo":200,"primaNeta":1752.49,"impuestos":1880.92},"recibos":[{"numero":1,"fechaInicio":"2022-10-10","fechaTermino":"2023-10-10","primaNeta":"896.05","primaTotal":"1260.67","derechosPoliza":"100.05","recargo":"75.24","impuestos":"171.41","comision":"17.92"}],"logotipoEmpresa":"https://storage.googleapis.com/inter-public-cloudstorage-prod/cocheseguro/static/Qualitas.svg"}}]}');
                response.setStatusCode(200);         
            }
            
            return response;
    }

}