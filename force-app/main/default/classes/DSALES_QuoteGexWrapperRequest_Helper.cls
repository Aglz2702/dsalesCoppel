/**
 * @description       : Clase de apoyo para DSALES_QuoteGexWrapperRequest
 * @author            : Juan Antonio Flores
 * @group             : Deloitte
 * @last modified on  : 09-05-2023
 * @last modified by  : Juan Antonio Flores
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   09-05-2023   Juan Antonio Flores  Initial Version
**/ 

public with sharing class DSALES_QuoteGexWrapperRequest_Helper {
    
     public static DSALES_QuoteGexWrapper.Nodos respuestaDescripcion(String nombre, String cotizaId,String tipoServicio){
        List<Quotelineitem> lstSkus = [SELECT id,Product2.StockKeepingUnit,Product2.Description,Product2.DSALES_ServEspecifico__c FROM Quotelineitem WHERE Quoteid=:cotizaId AND Product2.DSales_Tipo_de_Producto__c='Servicio' AND Product2.Description=:nombre WITH SECURITY_ENFORCED];
        DSALES_QuoteGexWrapper.Nodos nodoAux = new DSALES_QuoteGexWrapper.Nodos();
        nodoAux.Description = nombre;
        nodoAux.tipoDeServicio = tipoServicio;
        nodoAux.sku = new List<String>();
        
        for(Quotelineitem valores :lstSkus){
            String subTipoAux = valores.Product2.DSALES_ServEspecifico__c;
            nodoAux.subTipo = subTipoAux;
            
            String skuAux = valores.Product2.StockKeepingUnit;
            nodoAux.sku.add(skuAux);
        }
        return nodoAux;
    }
    
    public static List<DSALES_QuoteGexWrapper.Nodos> responseDescription(String tipoProducto, String cotizaId){
        List<Quotelineitem> valores = [SELECT id,Product2.StockKeepingUnit,Product2.Description FROM Quotelineitem WHERE Quoteid=:cotizaId AND Product2.DSales_Tipo_de_Producto__c=:tipoProducto WITH SECURITY_ENFORCED ORDER BY Product2.Description];
        List<String> valoresBusqueda = new List<String>();
        if(valores.size()>0){
            String valorDescripcion=valores[0].Product2.Description;
            valoresBusqueda.add(valorDescripcion);
            for(Quotelineitem aux :valores){
                if(valorDescripcion!=aux.Product2.Description){
                    valoresBusqueda.add(aux.Product2.Description);
                    valorDescripcion=aux.Product2.Description;
                }
            }
        }
        List<DSALES_QuoteGexWrapper.Nodos> response = new List<DSALES_QuoteGexWrapper.Nodos>();
        for(String aux :valoresBusqueda){
            DSALES_QuoteGexWrapper.Nodos respuesta = respuestaDescripcion(aux, cotizaId,'Servicio');
            response.add(respuesta);
        }
        return response;
    }
    
     public static List<DASALES_Porcentajedecobro__c> obtenerPorcentajeCobro(Id intangibleId) {
        List<DASALES_Porcentajedecobro__c> porcent = [SELECT Id, Name, DSALES_Anios__c, DSALES_Porcentaje__c FROM DASALES_Porcentajedecobro__c WHERE DSALES_Product__c=:intangibleId WITH SECURITY_ENFORCED];
        return porcent;
     }
    
     public static List<DSALES_Matriz_de_Cotizacion__c> obtenerMatricesPrecio(Id matrizId) {
        List<DSALES_Matriz_de_Cotizacion__c> matrizPrecio = [SELECT id, Name, SALES_Precio_GEX__c, DSales_Matriz_GEX__c, DSALES_Rango_interior_GEX__c, DSALES_Rango_Superior_GEX__c, DSALES_Tiempo_de_Garantia_Extendida_GEX__c FROM DSALES_Matriz_de_Cotizacion__c WHERE DSales_Matriz_GEX__c = :matrizId WITH SECURITY_ENFORCED ORDER BY SALES_Precio_GEX__c DESC];
        return matrizPrecio;
     }
    
     public static String matrizArPrice(String skuProd, dsalesAsignacionDeTienda__c asigTienda, QuoteLineItem quoteLineItem){ 
        String skuMatriz;
        Product2 prodAr=[SELECT Id, dsalesAR__c, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit=:skuProd LIMIT 1]; 
        DSALES_Matriz_de_Cotizacion__c matrizCot=[SELECT Id,Name,SALES_Precio_GEX__c FROM DSALES_Matriz_de_Cotizacion__c WHERE SALES_Precio_GEX__c = :quoteLineItem.UnitPrice AND DSales_Matriz_GEX__r.DSALES_Activo__c = true AND DSALES_Rango_Superior_GEX__c >= : prodAr.dsalesAR__c AND DSales_Matriz_GEX__c = :asigTienda.dsalesMatriz__c WITH SECURITY_ENFORCED LIMIT 1]; 
        skuMatriz = matrizCot.Name;   
        return skuMatriz;
      }
    public static List<dsalesCP__c> consultaCodigoPostal(DSALES_QuoteGexWrapper.QuoteGexRequest data){
        List<dsalesCP__c> codigoPos =[SELECT dsalesIsActive__c,Name FROM dsalesCP__c WHERE Name=:data.codigoPostal AND dsalesIsActive__c=true WITH SECURITY_ENFORCED LIMIT 1];
        return codigoPos;
    }
    public static List<DSALES_QuoteGexWrapper.Encuestas> obtenerEncuesta(List<QuoteLineItem> listaPartida, Id productoId, Id QuoteId, String QuoteName) {
        List<DSALES_QuoteGexWrapper.Encuestas> listaEncuestas = new List<DSALES_QuoteGexWrapper.Encuestas>();
                List<dsalesAsignacionEncuesta__c> survey = [SELECT dsalesEncuestaPISyS__c,dsalesEncuestaPISyS__r.dsalesCuestionario__c,dsalesEncuestaPISyS__r.Name,dsalesServicio__c FROM dsalesAsignacionEncuesta__c WHERE dsalesServicio__c=:productoId];
                DSALES_QuoteGexWrapper.Encuestas encuesta = new DSALES_QuoteGexWrapper.Encuestas();
                encuesta.nombreEncuesta = survey[0].dsalesEncuestaPISyS__r.Name;
                encuesta.preguntas = survey[0].dsalesEncuestaPISyS__r.dsalesCuestionario__c;
                listaEncuestas.add(encuesta);
        
        dsalesEncuestaPISyS__c encuestaNew = new dsalesEncuestaPISyS__c();
        String recordTypeId = Schema.SObjectType.dsalesEncuestaPISyS__c.getRecordTypeInfosByName().get('Respuestas').getRecordTypeId();
        encuestaNew.RecordTypeId = recordTypeId;
        encuestaNew.Name = survey[0].dsalesEncuestaPISyS__r.Name+' '+QuoteName;
        encuestaNew.dsalesCuestionario__c = survey[0].dsalesEncuestaPISyS__r.dsalesCuestionario__c;
        encuestaNew.dsalesCotizacion__c = QuoteId;
        insert encuestaNew;
        
        return listaEncuestas;
    }
}