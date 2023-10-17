public with sharing class DSALES_QuoteDuplicateSC { 
    public static Quote cotizacionesNuevas(List<String> partidasSeleccionadas,Datos datos){
        QuoteLineItem cel = new QuoteLineItem();
        List<QuoteLineItem> listaToQuey = new List<QuoteLineItem>();
        List<QuoteLineItem> listToInsert = new List<QuoteLineItem>();
        Quote cotizacionSincronizar = new Quote();
        Quote cotizacionSeguros = new Quote();
        DSALES_QuotePagoSM.updatePago(datos.pago.Id); //verifica que el plazo no sea 0
        Quote cotizacionPrincipal=consultaCotizacion(datos.idCotizacionAnt, datos.idOportunidad);
        QuoteLineItem celular = consultaCelular(datos.pago.DSALES_SKU__c,cotizacionPrincipal.Id);
        if(datos.pago.DSALES_Seguro__c==true && partidasSeleccionadas!=null && partidasSeleccionadas.size()>0){ //compró el seguro; crear solo una cotización extra
            listaToQuey=consultaPartidasSeguro(partidasSeleccionadas,cotizacionPrincipal.Id);
            cotizacionSincronizar= crearNuevaCotizacion(cotizacionPrincipal);
            cel=crearPartidaCelular(celular, cotizacionSincronizar.Id);
            listToInsert=crearPartidasSeguros(listaToQuey,cotizacionSincronizar.Id);
            listToInsert.add(cel);
        }else{ //solo compro el celular; crear dos cotizaciones extras
            System.debug('crea dos cotizaciones_______________');
            listaToQuey = consultaSegurosNoComprados(cotizacionPrincipal.Id,String.valueOf(datos.plazo));
            cotizacionSincronizar =crearNuevaCotizacion(cotizacionPrincipal);
            cotizacionSeguros=crearNuevaCotizacion(cotizacionPrincipal);
            cotizacionSeguros.DSALES_Enviarcotizacion__c=true;
            update cotizacionSeguros;
            cel=crearPartidaCelular(celular, cotizacionSincronizar.Id);
            listToInsert = crearPartidasSeguros(listaToQuey,cotizacionSeguros.Id);
            listToInsert.add(cel);
        }
        if(Schema.sObjectType.QuoteLineItem.isCreateable()) {
            insert listToInsert; 
        }else{
            System.debug('Permisos insuficientes para insertar');
        }
        return cotizacionSincronizar;
    }
    public static List<QuoteLineItem> consultaSegurosNoComprados(String idCotizacion, String plazo){
        System.debug('toma el seguro al plazo de la moto para el correo');
        List<QuoteLineItem> listaSeguros  = new List<QuoteLineItem> ();
        List<QuoteLineItem> seguros =[SELECT Id,LineNumber,DSALES_Tipodeproducto__c,QuoteId,DSALES_TrackingID__c,DSALES_Segurogratis__c,dsalesQuoteId__c,Product2Id,DSALES_SKU__c,
                    DSALES_Fechadeinicio__c,DSALES_Plazo__c,Quantity,ListPrice,DSALES_Fechadetermino__c,dsalesGastosDeOperacionDelRecibo__c,DSALES_Primaneta__c,
                    dsalesDerechosDePoliza__c,DSALES_Comision__c,DSALES_Recargos__c,UnitPrice,TotalPrice,DSALES_Pagomensual__c,DSALES_PagoContado__c,
                    dsalesPagoInicial__c,dsalesOpcionPago__c,DSALES_Descripcion__c,PricebookEntryId
                    FROM QuoteLineItem WHERE QuoteId=:idCotizacion  AND DSALES_Tipodeproducto__c='Seguro' AND Dsales_Plazo__r.Dsales_Plazo__c=:plazo  WITH SECURITY_ENFORCED LIMIT 1];
        if(seguros!=null){
            listaSeguros=seguros;
        }
        System.debug('lista de seguro_____________________'+listaSeguros);
        return listaSeguros;
    }
    public static Quote consultaCotizacion(String idCotizacion, String idOportunidad){
        Quote cotizacionPrincial = new Quote();
        if(!String.isEmpty(idCotizacion)){ 
            cotizacionPrincial= [SELECT Id,AccountId,Name,dsalesGenero__c,DSALES_Fechadenacimiento__c,dsalesListaNegra__c,
                                                    Phone,Email,DSALES_RFC__c,dsalesMotivoDeListaNegra__c,DSales_Vendedor__c,DSales_Tienda__c,DSALES_Fechadecreacionpresupuesto__c,
                                                    dsalesFechaDeComienzoDePoliza__c,dsalesOpcionDePago__c,OpportunityId,Status,ExpirationDate,
                                                    DSALES_Enviarcotizacion__c,dsalesIdentificadorCoppel__c,dsalesIdentificadorVendedor__c,dsalesNumeroSucursal__c,QuoteNumber,IsSyncing,dsalesPrecioCelular__c,dsalesMarcaCelular__c,dsalesModeloCelular__c,dsalesColorCelular__c,dsalesCodigoPostal__c,
                                                    Subtotal,TotalPrice,Discount,RecordTypeId FROM Quote WHERE Id=:idCotizacion AND OpportunityId=:idOportunidad WITH SECURITY_ENFORCED ];
        }
        return cotizacionPrincial;
    }
    public static QuoteLineItem consultaCelular(String sku,String idCotizacion){
        QuoteLineItem partidaCelular= new QuoteLineItem();
        if(!String.isEmpty(sku)){
            partidaCelular=[SELECT Id,LineNumber,DSALES_Tipodeproducto__c,QuoteId,DSALES_TrackingID__c,DSALES_Segurogratis__c,dsalesQuoteId__c,Product2Id,DSALES_SKU__c,
                                            DSALES_Fechadeinicio__c,DSALES_Plazo__c,Quantity,ListPrice,DSALES_Fechadetermino__c,dsalesGastosDeOperacionDelRecibo__c,DSALES_Primaneta__c,
                                            dsalesDerechosDePoliza__c,DSALES_Comision__c,DSALES_Recargos__c,UnitPrice,TotalPrice,DSALES_Pagomensual__c,DSALES_PagoContado__c,
                                            dsalesPagoInicial__c,dsalesOpcionPago__c,DSALES_Descripcion__c,PricebookEntryId
                                            FROM QuoteLineItem WHERE DSALES_SKU__c = :sku AND QuoteId=:idCotizacion WITH SECURITY_ENFORCED LIMIT 1];
        }
        return partidaCelular;
    }
    public static List<QuoteLineItem> consultaPartidasSeguro(List<String> partidasSeleccionadas, String idCotizacion){
        List <QuoteLineItem> partidas = new List <QuoteLineItem>();
        if(partidasSeleccionadas!=null && partidasSeleccionadas.size()>0){
            partidas=[SELECT Id,LineNumber,DSALES_Tipodeproducto__c,QuoteId,DSALES_TrackingID__c,DSALES_Segurogratis__c,dsalesQuoteId__c,Product2Id,DSALES_SKU__c,
                                            DSALES_Fechadeinicio__c,DSALES_Plazo__c,Quantity,ListPrice,DSALES_Fechadetermino__c,dsalesGastosDeOperacionDelRecibo__c,DSALES_Primaneta__c,
                                            dsalesDerechosDePoliza__c,DSALES_Comision__c,DSALES_Recargos__c,UnitPrice,TotalPrice,DSALES_Pagomensual__c,DSALES_PagoContado__c,
                                            dsalesPagoInicial__c,dsalesOpcionPago__c,DSALES_Descripcion__c,PricebookEntryId
                                            FROM QuoteLineItem WHERE Id IN :partidasSeleccionadas AND QuoteId=:idCotizacion WITH SECURITY_ENFORCED];
            
        }
        return partidas;  
    }

    public static List<QuoteLineItem> crearPartidasSeguros(List<QuoteLineItem> listaPartidas,String idCotizacion){
        List<QuoteLineItem> listaNuevasPartidas = new List<QuoteLineItem>();
        for(QuoteLineItem partida:listaPartidas){
            QuoteLineItem partidaNueva = new QuoteLineItem();
            partidaNueva.QuoteId=idCotizacion;
            partidaNueva.dsalesQuoteId__c=partida.dsalesQuoteId__c;
            partidaNueva.Product2Id=partida.Product2Id;
            partidaNueva.PricebookEntryId=partida.PricebookEntryId;
            partidaNueva.DSALES_Plazo__c=partida.DSALES_Plazo__c;
            //partidaNueva.LineNumber=partida.LineNumber;
            //partidaNueva.DSALES_Tipodeproducto__c=partida.DSALES_Tipodeproducto__c;
            //partidaNueva.TotalPrice=partida.TotalPrice;
            //partidaNueva.ListPrice=partida.ListPrice;
            //partidaNueva.DSALES_SKU__c=partida.DSALES_SKU__c;
            partidaNueva.UnitPrice=partida.UnitPrice;
            partidaNueva.DSALES_TrackingID__c=partida.DSALES_TrackingID__c;
            partidaNueva.DSALES_Segurogratis__c=partida.DSALES_Segurogratis__c;
            partidaNueva.DSALES_Fechadeinicio__c=partida.DSALES_Fechadeinicio__c;
            partidaNueva.Quantity=partida.Quantity;
            partidaNueva.DSALES_Fechadetermino__c=partida.DSALES_Fechadetermino__c;
            partidaNueva.dsalesGastosDeOperacionDelRecibo__c=partida.dsalesGastosDeOperacionDelRecibo__c;
            partidaNueva.DSALES_Primaneta__c=partida.DSALES_Primaneta__c;
            partidaNueva.dsalesDerechosDePoliza__c=partida.dsalesDerechosDePoliza__c;
            partidaNueva.DSALES_Comision__c=partida.DSALES_Comision__c;
            partidaNueva.DSALES_Recargos__c=partida.DSALES_Recargos__c;
            partidaNueva.DSALES_Pagomensual__c=partida.DSALES_Pagomensual__c;
            partidaNueva.DSALES_PagoContado__c=partida.DSALES_PagoContado__c;
            partidaNueva.dsalesPagoInicial__c=partida.dsalesPagoInicial__c;
            partidaNueva.dsalesOpcionPago__c=partida.dsalesOpcionPago__c;
            partidaNueva.DSALES_Descripcion__c=partida.DSALES_Descripcion__c;
            listaNuevasPartidas.add(partidaNueva);
            
        }
        return listaNuevasPartidas;
    }
    public static QuoteLineItem crearPartidaCelular(QuoteLineItem celular, String idCotizacion){
        QuoteLineItem partidaNueva = new QuoteLineItem();
        partidaNueva.QuoteId=idCotizacion;
        partidaNueva.dsalesQuoteId__c=celular.dsalesQuoteId__c;
        partidaNueva.Product2Id=celular.Product2Id;
        partidaNueva.PricebookEntryId=celular.PricebookEntryId;
        partidaNueva.DSALES_Plazo__c=celular.DSALES_Plazo__c;
        partidaNueva.UnitPrice=celular.UnitPrice;
        partidaNueva.DSALES_TrackingID__c=celular.DSALES_TrackingID__c;
        partidaNueva.DSALES_Segurogratis__c=celular.DSALES_Segurogratis__c;
        partidaNueva.DSALES_Fechadeinicio__c=celular.DSALES_Fechadeinicio__c;
        partidaNueva.Quantity=celular.Quantity;
        partidaNueva.DSALES_Fechadetermino__c=celular.DSALES_Fechadetermino__c;
        partidaNueva.dsalesGastosDeOperacionDelRecibo__c=celular.dsalesGastosDeOperacionDelRecibo__c;
        partidaNueva.DSALES_Primaneta__c=celular.DSALES_Primaneta__c;
        partidaNueva.dsalesDerechosDePoliza__c=celular.dsalesDerechosDePoliza__c;
        partidaNueva.DSALES_Comision__c=celular.DSALES_Comision__c;
        partidaNueva.DSALES_Recargos__c=celular.DSALES_Recargos__c;
        partidaNueva.DSALES_Pagomensual__c=celular.DSALES_Pagomensual__c;
        partidaNueva.DSALES_PagoContado__c=celular.DSALES_PagoContado__c;
        partidaNueva.dsalesPagoInicial__c=celular.dsalesPagoInicial__c;
        partidaNueva.dsalesOpcionPago__c=celular.dsalesOpcionPago__c;
        partidaNueva.DSALES_Descripcion__c=celular.DSALES_Descripcion__c;
        return partidaNueva;
    }

    public static Quote crearNuevaCotizacion(Quote cotizacionAnterior){
        Quote nuevaCotizacion = new Quote();
        //nuevaCotizacion.AccountId=cotizacionAnterior.AccountId;
        nuevaCotizacion.RecordTypeId=cotizacionAnterior.RecordTypeId;
        nuevaCotizacion.Name=cotizacionAnterior.Name;
        nuevaCotizacion.dsalesGenero__c=cotizacionAnterior.dsalesGenero__c;
        nuevaCotizacion.DSALES_Fechadenacimiento__c=cotizacionAnterior.DSALES_Fechadenacimiento__c;
        nuevaCotizacion.dsalesIdentificadorCoppel__c=cotizacionAnterior.dsalesIdentificadorCoppel__c;
        nuevaCotizacion.dsalesListaNegra__c=cotizacionAnterior.dsalesListaNegra__c;
        nuevaCotizacion.Phone=cotizacionAnterior.Phone;
        nuevaCotizacion.Email=cotizacionAnterior.Email;
        nuevaCotizacion.DSALES_RFC__c=cotizacionAnterior.DSALES_RFC__c;
        nuevaCotizacion.dsalesMotivoDeListaNegra__c=cotizacionAnterior.dsalesMotivoDeListaNegra__c;
        //nuevaCotizacion.QuoteNumber=cotizacionAnterior.QuoteNumber;
        nuevaCotizacion.DSales_Vendedor__c=cotizacionAnterior.DSales_Vendedor__c;
        nuevaCotizacion.DSales_Tienda__c=cotizacionAnterior.DSales_Tienda__c;
        nuevaCotizacion.DSALES_Fechadecreacionpresupuesto__c=cotizacionAnterior.DSALES_Fechadecreacionpresupuesto__c;
        nuevaCotizacion.dsalesFechaDeComienzoDePoliza__c=cotizacionAnterior.dsalesFechaDeComienzoDePoliza__c;
        nuevaCotizacion.dsalesOpcionDePago__c=cotizacionAnterior.dsalesOpcionDePago__c;
        nuevaCotizacion.OpportunityId=cotizacionAnterior.OpportunityId;
        nuevaCotizacion.dsalesIdentificadorVendedor__c=cotizacionAnterior.dsalesIdentificadorVendedor__c;
        nuevaCotizacion.dsalesNumeroSucursal__c=cotizacionAnterior.dsalesNumeroSucursal__c;
        nuevaCotizacion.Status=cotizacionAnterior.Status;
        nuevaCotizacion.ExpirationDate=cotizacionAnterior.ExpirationDate;
        nuevaCotizacion.DSALES_Enviarcotizacion__c=cotizacionAnterior.DSALES_Enviarcotizacion__c;
        //nuevaCotizacion.IsSyncing=cotizacionAnterior.IsSyncing;
        nuevaCotizacion.dsalesPrecioCelular__c=cotizacionAnterior.dsalesPrecioCelular__c;
        nuevaCotizacion.dsalesMarcaCelular__c=cotizacionAnterior.dsalesMarcaCelular__c;
        nuevaCotizacion.dsalesModeloCelular__c=cotizacionAnterior.dsalesModeloCelular__c;
        nuevaCotizacion.dsalesColorCelular__c=cotizacionAnterior.dsalesColorCelular__c;
        nuevaCotizacion.dsalesCodigoPostal__c=cotizacionAnterior.dsalesCodigoPostal__c;
        //nuevaCotizacion.Subtotal=cotizacionAnterior.Subtotal;
        //nuevaCotizacion.TotalPrice=cotizacionAnterior.TotalPrice;
        //nuevaCotizacion.Discount=cotizacionAnterior.Discount;
        if(Schema.sObjectType.Quote.isCreateable()) {
            insert nuevaCotizacion;
        }else{
            System.debug('Permisos insuficientes para insertar');
        }
       
        return nuevaCotizacion;
    }
    
    public class Datos{
        public String idOportunidad {get;set;}
        public String idCotizacionAnt {get;set;}
        public  DSALES_InformacionDePago__c pago {get;set;}
        public Integer plazo {get;set;}

    }
    public class Mapas{
        Map<String, String> product2Map {get;set;}
        Map<String, String> productToPricebookEntryMap {get;set;}
        Map<String, String> plazosMap{get;set;}
    }
    public class ConsultasDatos{
        Quote cotizacionAnterior{get;set;}
        List<QuoteLineItem> partidasSeleccionadas{get;set;}
        QuoteLineItem celular {get;set;}
    }
}