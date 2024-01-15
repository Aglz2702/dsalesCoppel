@RestResource(urlMapping='/ventaGex/*')
global with sharing class DSALES_VentaGEXRest {
   
    @HttpPost
    global static DSALES_VentaGEX.VentaGexResponse createVenta() {
        List<String> assetsId = new List<String>();
      DSALES_VentaGEX.VentaGexRequest venta = new DSALES_VentaGEX.VentaGexRequest();
        List<String> paymentIds= new List<String>();
        List<String> certifiedIds= new List <String>();
         List<String> setAssets = new List<String>();
      
        Boolean success=false;
        String message='';
        String message2='';
        String code='';
        String clienteId='';
        DSALES_VentaGEX.VentaGexResponse ventaGEX= new DSALES_VentaGEX.VentaGexResponse();
        
        if(RestContext.request != null){
            
            String cuerpo = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(cuerpo)){
                try{
                    System.debug('_______Request venta GEX:_________ '+cuerpo);
                     venta = (DSALES_VentaGEX.VentaGexRequest)JSON.deserialize(cuerpo, DSALES_VentaGEX.VentaGexRequest.class);
                     String idUnico=venta.pago.idUniversal;
                    List<DSALES_InformacionDePago__c> verificaIdUniversal =[SELECT Id,DSALES_IDUniversal1__c FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c =: idUnico WITH SECURITY_ENFORCED LIMIT 1];
                    if(verificaIdUniversal!=null && verificaIdUniversal.size()>0){
                        success = false;
                        message = 'El id universal: '+idUnico+ ' ya existe' ;
                        code = '401';
                    }else{
                    assignFields(venta,ventaGEX);
                    
                    DSALES_AccountWrapper.AccountResponse cliente = DSALES_AccountWrapperRequest.upsertAccount(venta.cliente);
                    clienteId=cliente.idCuenta;
                    System.debug('Cliente Response '+cliente.mensajeError);
                    validarCliente(venta.quoteId, cliente.idCuenta,venta.nombreVendedor);
                    responderEncuesta(venta,ventaGex);
                    
                   
                  
                    Map<String, String> mapAssets = insertAssets(venta, cliente.idCuenta); 
                   
                   system.debug('Revisar size del Map Asset: '+mapAssets.size());
                    for (String assetId : mapAssets.values())
                    {
                        assetsId.add(assetId);
                    }
                    
                    Map<String, String> mapCertifieds = insertCertified(venta.listaDeCertificados, cliente.idCuenta, mapAssets);
                 
                    if(mapCertifieds.size()>0)
                    {
                        
                        
                        for(String certificadoId: mapCertifieds.values())
                        {
                         
                            certifiedIds.add(certificadoId);
                        }
                    }
                    
                    paymentIds=insertPaymentInfo(venta.pago,  mapAssets, venta.quoteId);
                    DSALES_ValidarClienteHelper.deleteUnpurchasedItem(venta.listaDeProductos,venta.listaDeCertificados, venta.quoteId);
                    DSALES_ValidarClienteHelper.actualizarCotizacion(venta.quoteId,ventaGEX,mapAssets,mapCertifieds);
                    

                    success=true;
                    message='';
                    } 
                }catch(JSONException e){
                    success = false;
                    message = DSALES_Utility.BAD_REQUEST_MSJ + e.getLineNumber()+ e.getMessage();
                    code = String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                }catch(Exception ex){
                    success = false;
                    message += ex.getMessage() + ex.getLineNumber(); // + ex.getLineNumber()+ ex.getMessage();
                    code = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                }
            }
        }
        ventaGex.mensaje=message;
        ventaGEX.exito = success;
        if(ventaGex.exito)
        {
        	ventaGEX.mensaje='Venta Generada con Éxito';    
        }
        
        ventaGEX.codigoDeError=code;
        ventaGEX.idClienteSalesforce=clienteId;
        ventaGEX.idDePago=paymentIds;
        
        
     
        List<Asset> product= [SELECT id,Price,Product2.StockKeepingUnit,DSALES_SKU__c,dsalesIdSecuencia__c,DSALES_Certificado__c FROM ASSET WHERE id IN: assetsId WITH SECURITY_ENFORCED];
     
        List<DSALES_InformacionDePago__c> pago=[Select id,DSALES_SKU__c,DSALES_DireccionCliente__c,DSALES_Cliente__c FROM DSALES_InformacionDePago__c WHERE id IN:paymentIds WITH SECURITY_ENFORCED];
      
        List<DSALES_Certificado__c> certi=[Select id,DSALES_SKU__c,DSALES_SKUTangible__c,DSALES_Precio_del_Articulo__c,dsalesIdSecuencia__c,DSALES_Domicilio_del_Client_e__c,DSALES_Cliente__c FROM DSALES_Certificado__c WHERE id IN:certifiedIds WITH SECURITY_ENFORCED];
     
        if(!String.isBlank(venta.idUniversalPrevio))
            {
                actualizarPagoPrevio(venta.idUniversalPrevio,certi,pago);
            }
        
        try{
        if(product.size()>0)
        {
            for(Asset a: product)
        { 
           
            if(pago.size()>0)
            {
                pago[0].DSALES_ProductoAdquirido__c=a.id;
                a.DSales_Informacion_pago__c=pago[0].Id;
            }
            
            for(DSALES_Certificado__c c:certi)
            {
                
              
                
                if( pago.size()>0)
                {
                    pago[0].DSALES_Certificado__c=c.id;
                    //aqui
                    c.DSALES_InformacionDePago__c=pago[0].id;
                    c.DSALES_Cliente__c=pago[0].DSALES_Cliente__c;
                    c.DSALES_Domicilio_del_Client_e__c=pago[0].DSALES_DireccionCliente__c;
                    system.debug('DOMICILIO DEL CLIENTE: '+ c.DSALES_Domicilio_del_Client_e__c);
                }
             
                if(c.DSALES_SKUTangible__c+String.valueOf(c.dsalesIdSecuencia__c)==a.DSALES_SKU__c+String.valueOf(a.dsalesIdSecuencia__c))
                    
                {
                    c.DSALES_ProductoAdquirido__c=a.Id;
                 
                    a.DSALES_Certificado__c=c.Id;
                    c.DSALES_Precio_del_Articulo__c=a.Price;
                }  
            }
        }
        }
            else {
                for(DSALES_Certificado__c c:certi)
            {
                
              
                
                if( pago.size()>0)
                {
                    pago[0].DSALES_Certificado__c=c.id;
                    //aqui
                    c.DSALES_InformacionDePago__c=pago[0].id;
                    c.DSALES_Cliente__c=pago[0].DSALES_Cliente__c;
                    c.DSALES_Domicilio_del_Client_e__c=pago[0].DSALES_DireccionCliente__c;
                    system.debug('DOMICILIO DEL CLIENTE: '+ c.DSALES_Domicilio_del_Client_e__c);
                }
             
                
            }
            }
        if(Schema.sObjectType.Asset.isUpdateable())
        {
            update product;
        }
       
        if(Schema.sObjectType.DSALES_Certificado__c.isUpdateable())
        {
            update certi;
        }
        if(Schema.sObjectType.DSALES_InformacionDePago__c.isUpdateable())
        {
            update pago;
        }
        }
        catch (Exception e)
        {
            system.debug('ERROR de updates: '+e.getMessage() + e.getLineNumber());
        }
        
      
        //ventaGEX.assets_id=responsePayloadAsset;
      DSALES_VentaGEX.VentaGexResponse ventaGex2 = ventaGEX; 
        return ventaGEX2;
    }

    public static void actualizarPagoPrevio(String idUniversalPrevio, List<DSALES_Certificado__c> certificados, List<DSALES_InformacionDePago__c> pagoNuevo)
    {
        
        DSALES_InformacionDePago__c pagoIdPrevio=[SELECT Id FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c=:idUniversalPrevio];
        list<Asset> productos =[SELECT id,name,SerialNumber,DSALES_CategoriaBuscar__c,DSALES_ClaseBuscar__c,DSALES_FamiliaBuscar__c,Asset.Description,DSALES_SubCategoriaBuscar__c,Product2Id,DSALES_SKU__c,dsalesIdSecuencia__c,AccountId,DSALES_Certificado__c,DSales_Informacion_pago__c FROM Asset WHERE 
                                DSales_Informacion_pago__c=:pagoIdPrevio.id AND  DSALES_Certificado__c=null ];
  		list<Asset> productosDuplicados= new list<Asset>();
      
        for(DSALES_Certificado__c certificado :certificados)
        {
           
            for(Asset producto:productos)
                {
                   system.debug('Entró a la nueva lógica');
                    system.debug( producto.DSALES_SKU__c + 'Y certificado: '+ certificado.DSALES_SKUTangible__c);
                    if(producto.DSALES_SKU__c==certificado.DSALES_SKUTangible__c && String.isBlank(producto.DSALES_Certificado__c))
                    {
                       
                        Asset miProducto= producto.clone();
                        miProducto.Name=producto.Name;
                        miProducto.Product2Id=producto.Product2Id;
                        miProducto.AccountId=producto.AccountId;
                        miProducto.Price=0;
                        miProducto.DSALES_PrecioSINIVA__c=0;
                       	miProducto.DSALES_CategoriaBuscar__c=producto.DSALES_CategoriaBuscar__c;
                        miProducto.DSALES_ClaseBuscar__c=producto.DSALES_ClaseBuscar__c;
                        miProducto.DSALES_FamiliaBuscar__c=producto.DSALES_FamiliaBuscar__c;
                        miProducto.DSALES_SubCategoriaBuscar__c=producto.DSALES_SubCategoriaBuscar__c;
                        miProducto.DSALES_SKU__c=producto.DSALES_SKU__c;
                        miProducto.Description=producto.Description;
                        miProducto.SerialNumber=producto.SerialNumber;
                        
                        system.debug('Logró pasar Certificado.sku == producto.sku');
                        miProducto.DSALES_Certificado__c=certificado.id;
                       // certificado.DSALES_ProductoAdquirido__c=miProducto.id;
                        //pagoNuevo[0].DSALES_ProductoAdquirido__c=miProducto.Id;
                        miProducto.DSales_Informacion_pago__c=pagoNuevo[0].id;
                        productosDuplicados.add(miProducto);
                        Integer i= productos.IndexOf(producto);
                        productos.remove(i);
                        break;
                    }
                }
            
        }
       
        system.debug('Asset en lista antes de ser creado: '+productosDuplicados);
         if(Schema.sObjectType.Asset.isCreateable())
        {
            insert productosDuplicados;
        }
        for(DSALES_Certificado__c certificado :certificados)
                {
        for (Asset miAsset:productosDuplicados)
            {
                
                    if(miAsset.DSALES_SKU__c==certificado.DSALES_SKUTangible__c)
                    {
                        certificado.DSALES_ProductoAdquirido__c=miAsset.id;
                        certificado.DSALES_Precio_del_Articulo__c=0;
                        certificado.DSALES_DescripcionDelArtculo__c=miAsset.Description;
                        certificado.DSALES_Numero_serie__c=miAsset.SerialNumber;
                        Integer i= productosDuplicados.IndexOf(miAsset);
                        productosDuplicados.remove(i);
                        break;
                       
                    }
                     
                
                pagoNuevo[0].DSALES_ProductoAdquirido__c=miAsset.Id;
            }
            }
     
         if(Schema.sObjectType.DSALES_InformacionDePago__c.isUpdateable())
        {
            update pagoNuevo;
        }
        system.debug('Certificados antes de actualizar: '+certificados);
        if(Schema.sObjectType.DSALES_Certificado__c.isUpdateable())
        {
            update certificados;
        }
    }
    public static Boolean validarCliente(String quoteId, String accountId,String nombreVendedor){ 
        Quote cotizacion = [SELECT Id,AccountId,OpportunityId,Opportunity.AccountId FROM Quote WHERE Id= :quoteId WITH SECURITY_ENFORCED]; 
        
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = accountId;
        oportunidad.DSales_Colaborador__c=nombreVendedor;
        oportunidad.SyncedQuoteId=quoteId;
        oportunidad.Id = cotizacion.OpportunityId;
        
        try{
            if(Schema.sObjectType.Opportunity.isUpdateable())
            {
                update oportunidad;
            }
          
            
            return true;
        }catch(Exception e){
            return false;
        }  
    }
    
    public static Map<String, String> insertAssets(DSALES_VentaGEX.VentaGexRequest venta, String accountId){
      //idPartidaPresupuesto
         //Map<String,QuoteLineItem>qtLineOriginal= new map <String,QuoteLineItem>([SELECT  Id,DSALES_ListaArticulo__c, Dsales_Sku__c,Product2.DSales_Tipo_de_Producto__c FROM QuoteLineItem WHERE QuoteId=:venta.quoteId and Product2.DSales_Tipo_de_Producto__c='Producto' WITH SECURITY_ENFORCED  ]);
        Map<String, String> mapAssets = new Map<String, String>();
        List<String> listSKU = new List<String>();
        List<String> idsAssets = new List<String>();
        
        try{
            
        
        for(DSALES_AssetWrapper.AssetRequest sku: venta.listaDeProductos){
            listSKU.add(sku.skuDeTangible);
            
        }
            }
        catch(Exception e )
        {
            system.debug(e.getMessage() + e.getLineNumber());
        }
       Map<String,QuoteLineitem> mapaPartidas= new Map<String,QuoteLineitem>([SELECT DSALES_SKU__c,UnitPrice FROM QUOTELINEITEM WHERE DSALES_SKU__c IN:listSKU AND QuoteId=:venta.quoteId WITH SECURITY_ENFORCED]);
        List <String> skuNuevos= new List<String>(); 
        String nuevoSku='';
        Integer assetsSinGarant=501;
        String skuAComparar='a';
        
        for(Product2 t: [Select StockKeepingUnit,Id from Product2 where StockKeepingUnit in :listSKU and DSales_Tipo_de_Producto__c='Producto' WITH SECURITY_ENFORCED] ){
            
            for(DSALES_AssetWrapper.AssetRequest producto: venta.listaDeProductos){
                for(String idMapa:mapaPartidas.Keyset())
                    {
                        if(producto.skuDeTangible==mapaPartidas.get(idMapa).DSALES_SKU__c)
                        {
                            producto.idPartidaPresupuesto=idMapa;
                            mapaPartidas.remove(idMapa);
                            break;
                        }
                    }
                
                if(t.StockKeepingUnit == producto.skuDeTangible){
                    producto.idCuenta=accountId;
                    producto.idProducto=t.Id;
                    producto.estado='Adquirido';
                    
                    for(DSALES_CertificadoWrapper.CertificadoRequest garantia: venta.listaDeCertificados)
                        {
                             if(!String.isEmpty(garantia.idPartidaPresupuesto) && 
                                garantia.skuDeTangible+string.valueOf(garantia.idSecuencia)== producto.skuDeTangible+string.valueOf(garantia.idSecuencia) &&
                               	 !skuNuevos.contains(garantia.skuDeTangible+string.valueOf(garantia.idSecuencia)))
                      
                    {
                      
                         nuevoSku=t.stockKeepingUnit+String.valueOf(garantia.idSecuencia);
                       producto.idSecuencia=garantia.idSecuencia;
                       
                        
                        skuNuevos.add(nuevoSku);
                       
                        break;
                        
                      
                    }
                           
                    		
                        }
                   
                   if(producto.idSecuencia==null)
                   {
                       system.debug('ES NULO; No tiene certificado');
                       producto.idSecuencia=-1;
                       if(!mapAssets.containsKey(t.stockKeepingUnit))
                       {
                           nuevoSku=t.stockKeepingUnit;
                       }
                       else
                           {
                               nuevoSku=t.stockKeepingUnit+assetsSinGarant;
                      	 	assetsSinGarant=assetsSinGarant+50;
                           }
                       
                   }
                    
                     DSALES_AssetWrapper.AssetResponse responsePayloadAsset = DSALES_AssetWrapperRequest.insertaAssets(producto);
                  
                  
                    mapAssets.put(nuevoSku, responsePayloadAsset.idAsset);
                    idsAssets.add(responsePayloadAsset.idAsset);
                    
                }
            }
        }
        return mapAssets;
    }
 
    public static Map<String, String> insertCertified(List<DSALES_CertificadoWrapper.CertificadoRequest> certificado, String accountId, Map<String, String> mapAssets){
        Map<String, String> mapCertifieds = new Map<String, String>();
        Map<String, String> mapStores = new Map<String, String>();
        
        List<String> listStores= new List<String>();
        
        for(DSALES_CertificadoWrapper.CertificadoRequest sku: certificado){
            if(!String.isEmpty(sku.idPartidaPresupuesto) )
            {
            
             listStores.add(sku.claveTienda);
            }
          
            
        }
        for(Tienda__c store: [select id,dsales_TiendaID__c from Tienda__c where dsales_TiendaID__c in :listStores WITH SECURITY_ENFORCED]){
            mapStores.put(store.dsales_TiendaID__c, store.Id);
        }
        
       
      
          
            for(DSALES_CertificadoWrapper.CertificadoRequest productoGex: certificado){
                if(!String.isEmpty(productoGex.idPartidaPresupuesto) )
                {
                   
                        productoGex.idCuenta =accountId;
                        productoGex.idTienda = mapStores.get(productoGex.claveTienda);
                        DSALES_CertificadoWrapper.CertificadoResponse responsePayloadCertifieds = DSALES_CertificadoWrapperRequest.insertCertificado(productoGex);
                        mapCertifieds.put(productoGex.skuDeTangible+String.valueOf(productoGex.idSecuencia), responsePayloadCertifieds.idCertificado);
                    
                }
            }
        
        return mapCertifieds;
    }
    
    public static List<String> insertPaymentInfo(DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest paymentInformation,Map<String, String> assetsId, String quoteId){
        Map<String, String> mapStores = new Map<String, String>();
        String stores = '';
        List<String> ids= new List<String>();
        
        Quote cotizacion = [SELECT OpportunityId FROM Quote WHERE Id= :quoteId WITH SECURITY_ENFORCED];
        stores=paymentInformation.claveTienda;
        paymentInformation.opportunityId = cotizacion.OpportunityId;
            
        DSALES_PaymentInfoWrapperGEX.PaymentGEXResponse responsePaymInfo = DSALES_PaymentInfoWrapperGexRequest.insertPaymentGex(paymentInformation);
        system.debug('PAGOS ERROR: '+responsePaymInfo.mensajeError);
        ids.add(responsePaymInfo.idInformacionPago);
    
        return ids;
    }
    public static void assignFields(DSALES_VentaGEX.VentaGexRequest venta,DSALES_VentaGEX.VentaGexResponse ventaGEX)
    {
        String nombreConcat='';
        Integer contadora=0;
        List<QuoteLineItem> partidas = new  List<QuoteLineItem>();
        List<String>sku= new List<String>();
        List <String> articulo = new List<String>();
        
        DSALES_AccountWrapper.AccountRequest cliente=venta.cliente;
        
        try{
        for(DSALES_AssetWrapper.AssetRequest assi: venta.listaDeProductos)
        {
            articulo.add(assi.articulo);
            sku.add(assi.skuDeTangible);
            assi.email=cliente.correoElectronico;
            assi.primerNombre=cliente.nombre;
            assi.apellido=cliente.apellidoPaterno + ' '+cliente.apellidoMaterno;
        }
        }
        catch(Exception e)
        {
            system.debug('Error en Asset Vacío: '+e.getMessage() );
        }
        
        List<DSALES_CertificadoWrapper.CertificadoRequest> certificadoList= new List<DSALES_CertificadoWrapper.CertificadoRequest>();
        Map<Id,QuoteLineItem>mapPartida= new map<Id,QuoteLineitem>([SELECT DSalesNombreServicio_del__c, Vigencia_meses__c,dsalesAR__c,DSALES_SKU__c,TotalPrice,dsalesIdSecuencia__c FROM QuoteLineItem WHERE quoteId=:venta.quoteId ]);
       system.debug('venta.Quoteid: '+venta.quoteId);
        Quote qt = [SELECT Id,DSALES_EmailNew__c FROM QUOTE WHERE ID=:venta.quoteId ];
        qt.DSALES_EmailNew__c=cliente.correoElectronico;
        Update qt;
       if(venta.listaDeCertificados!=null)
       {
           
       
       for(DSALES_CertificadoWrapper.CertificadoRequest certi: venta.listaDeCertificados)
        {
            
            certi.emailCliente=cliente.correoElectronico;
            certi.telefonoCliente=cliente.telefono;
            //certi.direccionCliente=cliente.codigoPostal;
            certi.claveTienda=venta.idTienda;
            certi.nombreVendedor=venta.nombreVendedor;    
            certi.numeroCajaCoppel=venta.numeroCaja;
            certi.idVendedor=venta.idVendedor;
            certi.idFactura=venta.idFactura;
            certi.fechaVenta=venta.fechaCompra;
            certi.fechaCompraGarantia=venta.fechaCompra;
            certi.numeroCliente=cliente.numeroCliente;
            certi.nombreCompletoCliente=cliente.nombre + ' '+cliente.apellidoPaterno + ' '+cliente.apellidoMaterno;
            if(!String.isEmpty(certi.idPartidaPresupuesto) && mapPartida.containsKey(certi.idPartidaPresupuesto))
            {
                if(mapPartida.get(certi.idPartidaPresupuesto).dsalesAR__c!=null)
                {
                    certi.ar=mapPartida.get(certi.idPartidaPresupuesto).dsalesAR__c;
                    system.debug('OBTENIENDO NÚMERO AR: '+certi.ar);
                }
                certi.sku= mapPartida.get(certi.idPartidaPresupuesto).DSALES_SKU__c;
                certi.idSecuencia=mapPartida.get(certi.idPartidaPresupuesto).dsalesIdSecuencia__c;
                certi.nombreServicio=mapPartida.get(certi.idPartidaPresupuesto).DSalesNombreServicio_del__c;
                if(mapPartida.get(certi.idPartidaPresupuesto).Vigencia_meses__c!=null)
                {
                    certi.garantiaCoppelTangible=Integer.valueOf(mapPartida.get(certi.idPartidaPresupuesto).Vigencia_meses__c);
                }
                
                certi.costoGarantia=mapPartida.get(certi.idPartidaPresupuesto).TotalPrice;
                certificadoList.add(certi);
            }
        }
           }
        venta.pago.fechaVenta=venta.fechaCompra;
        venta.pago.claveTienda=venta.idTienda;
        venta.pago.idFactura=venta.idFactura;
        venta.pago.caja=venta.numeroCaja;
        venta.pago.idVendedor=venta.idVendedor;
        venta.pago.nombreVendedor=venta.nombreVendedor; 
        venta.pago.numeroCliente=cliente.numeroCliente;
        
    }
    public static void responderEncuesta(DSALES_VentaGEX.VentaGexRequest venta,DSALES_VentaGex.VentaGexResponse ventaGEX)
    {
        try{
            dsalesEncuestaPISyS__c encuesta =[SELECT Id,Name,dsalesCuestionario__c,dsalesRespuestas__c,dsalesCliente__c FROM
                                             dsalesEncuestaPISyS__c WHERE dsalesCotizacion__c=:venta.quoteId ];
          
            String[] textoLargo=encuesta.dsalesCuestionario__c.split('\\.');
            system.debug('encuesta.dsalesCuestionario__c: '+encuesta.dsalesCuestionario__c);
            system.debug(textoLargo.size() + 'TextoDelCuestionario');
            system.debug(venta.respuestasDeEncuesta.size() + 'respuestaDeEncuesta');
            if(textoLargo.size()==venta.respuestasDeEncuesta.size() || textoLargo.size()==(venta.respuestasDeEncuesta.size()*2))
                
            {
                system.debug('ENCUESTAS: preguntas como respuestas mismo size()');
                encuesta.dsalesRespuestas__c='';
              for(Boolean respuesta:venta.respuestasDeEncuesta)
              {
                  if(respuesta)
                      {
                          encuesta.dsalesRespuestas__c+='Sí';
                      }
                  else
                  {
                      encuesta.dsalesRespuestas__c+='No';
                  }
                  encuesta.dsalesRespuestas__c+='\n';
              }
                 if(Schema.sObjectType.dsalesEncuestaPISyS__c.isUpdateable())
            {
                update encuesta;
            }
                ventaGEX.idEncuesta=encuesta.Id;
            }
            else
                {
                    system.debug('Las respuestas y las preguntas no tienen el mismo tamaño');
                }
            
            
        }
        catch(Exception e)
        {
            system.debug('Error de Encuesta: '+e.getMessage() + e.getLineNumber());
        }
    }

}