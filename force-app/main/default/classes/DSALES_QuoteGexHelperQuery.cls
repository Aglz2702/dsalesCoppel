public class DSALES_QuoteGexHelperQuery {
    public static dsalesAsignacionDeTienda__c obtenerIdMatrizPrecio(Id tiendaId, Id IntangibleId) {
        List<dsalesAsignacionDeTienda__c> asignaciones = [SELECT dsalesMatriz__c
                                                         FROM dsalesAsignacionDeTienda__c 
                                                         WHERE dsalesTienda__c = :tiendaId 
                                                         AND dsalesMatriz__c <> null
                                                         AND dsalesMatriz__r.DSALES_Servicio__c = :IntangibleId 
                                                         WITH SECURITY_ENFORCED LIMIT 1];
        
        if (!asignaciones.isEmpty()) {
            return asignaciones[0];
        } else {
            return null;
        }
    }
    
    public static DSALES_Matriz_de_Cotizacion__c obtenerSkuPrecio(Decimal resIntangible, Decimal resTangible, Id idMat) {
    List<DSALES_Matriz_de_Cotizacion__c> matrices = [
        SELECT Id, Name, DSALES_Rango_interior_GEX__c, DSALES_Rango_Superior_GEX__c, DSALES_Tiempo_de_Garantia_Extendida_GEX__c, SALES_Precio_GEX__c, DSales_Matriz_GEX__c 
        FROM DSALES_Matriz_de_Cotizacion__c 
        WHERE SALES_Precio_GEX__c = :resIntangible 
            AND DSales_Matriz_GEX__r.DSALES_Activo__c = true 
            AND DSALES_Rango_Superior_GEX__c >= :resTangible 
            AND DSales_Matriz_GEX__c = :idMat
        WITH SECURITY_ENFORCED
        LIMIT 1
    ];

    if (!matrices.isEmpty()) {
        return matrices[0];
    } else {
        return null;
    }
    }

}