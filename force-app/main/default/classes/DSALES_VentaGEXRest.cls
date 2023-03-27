@RestResource(urlMapping='/ventaGex/*')
global class DSALES_VentaGEXRest {
     

    @HttpPost
    global static DSALES_VentaGEX.VentaGexResponse createVenta() {
        List<String> assetsId = new List<String>();
         List<String> paymentIds= new List<String>();
         List<String> certifiedIds= new List <String>();
        Boolean success=false;
        String message='';
        String message2='';
        String code='';
       
    
       
        DSALES_VentaGEX.VentaGexResponse ventaGEX= new DSALES_VentaGEX.VentaGexResponse();
        
        if(RestContext.request != null){
            
            String Body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(Body)){
                try{
                   
                    DSALES_VentaGEX.VentaGexRequest venta = (DSALES_VentaGEX.VentaGexRequest)JSON.deserialize(body, DSALES_VentaGEX.VentaGexRequest.class);
                    assignFields(venta.listAssets, venta.paymentInformation, venta.certificado,venta,ventaGEX);
                    
                    DSALES_AccountWrapper.AccountResponse cliente = DSALES_AccountWrapperRequest.upsertAccount(venta.cliente);
                    validarCliente(venta.quoteId, cliente.id_cuenta,venta.nombre_vendedor);
                    
                    asignarSku();
                   
                    Map<String, String> mapAssets = insertAssets(venta.listAssets, cliente.id_cuenta); 
                    
                     for (String assetId : mapAssets.values())
                     {
                         assetsId.add(assetId);
                     }
                    if(venta.certificado!=null){
                        Map<String, String> mapCertifieds = insertCertified(venta.certificado, cliente.id_cuenta, mapAssets);
                        
                        if(mapCertifieds.size()>0)
                        {
                            
                        
                        for(String certificadoId: mapCertifieds.values())
                        {
                            certifiedIds.add(certificadoId);
                        }
                        }
                    
                    }
                  paymentIds=insertPaymentInfo(venta.paymentInformation, cliente.id_cuenta, mapAssets, venta.quoteId);
                  DSALES_ValidarClienteHelper.deleteUnpurchasedItem(venta.listAssets,venta.certificado, venta.quoteId);
                    DSALES_ValidarClienteHelper.actualizarCotizacion(venta.quoteId,ventaGEX);
                    //DSALES_ValidarClienteHelper.recepcionProductos(venta.certificado, venta.quoteid,newQuote);
                    
                    
                    success=true;
                    message='';
                 
                }catch(JSONException e){
                    success = false;
                    message = DSALES_Utility.BAD_REQUEST_MSJ; //+ e.getLineNumber()+ e.getMessage();
                    code = String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                }catch(Exception ex){
                    success = false;
                    message += ex.getMessage() + ex.getLineNumber(); // + ex.getLineNumber()+ ex.getMessage();
                    code = String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                }
            }
        }
       
        ventaGEX.success = success;
        ventaGEX.error_message=message;
        ventaGEX.error_code=code;
        ventaGEX.assets_id=assetsId;
        ventaGEX.certifieds_id=certifiedIds;
        ventaGEX.payments_id=paymentIds;
       
       
        List<Asset> product= [SELECT id,Product2.StockKeepingUnit,DSALES_SKU__c FROM ASSET WHERE id IN: assetsId];
         system.debug('Lista de productos: '+product);
        List<DSALES_InformacionDePago__c> pago=[Select id,DSALES_SKU__c FROM DSALES_InformacionDePago__c WHERE id IN:paymentIds];
        system.debug('Lista de pagos: '+pago);
        List<DSALES_Certificado__c> certi=[Select id,DSALES_SKU__c,DSALES_SKUTangible__c,DSALES_Precio_del_Articulo__c FROM DSALES_Certificado__c WHERE id IN:certifiedIds];
        system.debug('Lista de cert: '+certi);
       
            for(Asset a: product)
        {
            	if(pago.size()>0)
                {
                     pago[0].DSALES_ProductoAdquirido__c=a.id;
                a.DSales_Informacion_pago__c=pago[0].Id;
                }
            
             for(DSALES_Certificado__c c:certi)
           {

                   system.debug('Sí pasó!');
               	 
               if( pago.size()>0)
               {
                    pago[0].DSALES_Certificado__c=c.id;
                   //aqui
                   c.DSALES_InformacionDePago__c=pago[0].id;
               }
                  
				if(c.DSALES_SKUTangible__c==a.DSALES_SKU__c)
                {
                      c.DSALES_ProductoAdquirido__c=a.Id;
               		  a.DSALES_Certificado__c=c.Id;
                      a.Price=c.DSALES_Precio_del_Articulo__c;
                }
                   
               
               
               
           }
        }
          
           
       
     upsert product;
        upsert certi;
        upsert pago;
        //ventaGEX.assets_id=responsePayloadAsset;
        return ventaGEX;
    }
    
    
    
    public static Boolean validarCliente(String quoteId, String accountId,String nombreVendedor){ 
        Quote cotizacion = [SELECT Id,AccountId,OpportunityId,Opportunity.AccountId FROM Quote WHERE Id= :quoteId]; 
        

        
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = accountId;
        oportunidad.DSales_Colaborador__c=nombreVendedor;
        oportunidad.SyncedQuoteId=quoteId;
        oportunidad.Id = cotizacion.OpportunityId;
        
        try{
           
            update oportunidad;
            return true;
        }catch(Exception e){
            return false;
        }
        
        
    }
    
    public static Map<String, String> insertAssets(List<DSALES_AssetWrapper.AssetRequest> listAssets, String accountId){
        Map<String, String> mapAssets = new Map<String, String>();
        List<String> listSKU = new List<String>();
        List<String> idsAssets = new List<String>();
       
        for(DSALES_AssetWrapper.AssetRequest sku: listAssets){
            listSKU.add(sku.sku_de_tangible);
        }
       
       
        for(Product2 t: [Select StockKeepingUnit,Id from Product2 where StockKeepingUnit in :listSKU and DSales_Tipo_de_Producto__c='Producto']){
            for(DSALES_AssetWrapper.AssetRequest producto: listAssets){
                if(t.StockKeepingUnit == producto.sku_de_tangible){
                    producto.id_cuenta=accountId;
                    producto.id_producto=t.Id;
                    producto.estado='Adquirido';
                    
            		DSALES_AssetWrapper.AssetResponse responsePayloadAsset = DSALES_AssetWrapperRequest.insertAssets(producto);
                    system.debug('Mensaje de ASSET: '+responsePayloadAsset.mensaje_error);
                    mapAssets.put(t.StockKeepingUnit, responsePayloadAsset.id_asset);
                    idsAssets.add(responsePayloadAsset.id_asset);
                   
                }
            }
        }
        return mapAssets;
    }
    public static void asignarSku()
    {
        
    }
    public static Map<String, String> insertCertified(List<DSALES_CertificadoWrapper.CertificadoRequest> certificado, String accountId, Map<String, String> mapAssets){
        Map<String, String> mapCertifieds = new Map<String, String>();
         Map<String, String> mapStores = new Map<String, String>();
        List<String> listSKUCertifieds = new List<String>();
        List<String> listStores= new List<String>();
        system.debug('Aquí sí llegó');
        for(DSALES_CertificadoWrapper.CertificadoRequest sku: certificado){
           if(!String.isEmpty(sku.id_partida_presupuesto) )
           {system.debug('Entró al for: y el SKU es: '+sku.sku);
            listSKUCertifieds.add(sku.sku);
            listStores.add(sku.clave_tienda);
               }
            system.debug('Aquí sí llegó: SKU: '+listStores);
        }
         for(Tienda__c store: [select id,DSales_TiendaID__c from Tienda__c where DSales_TiendaID__c in :listStores]){
            mapStores.put(store.DSales_TiendaID__c, store.Id);
        }
         system.debug('Seguimos bien con sku '+listSKUCertifieds);
        for(Product2 t: [Select StockKeepingUnit from Product2 where StockKeepingUnit in :listSKUCertifieds and DSales_Tipo_de_Producto__c='Servicio']){
            system.debug('Entramos1 '+mapStores);
            for(DSALES_CertificadoWrapper.CertificadoRequest productoGex: certificado){
            	if(!String.isEmpty(productoGex.id_partida_presupuesto) )
                {
                     system.debug('Entramos '+mapStores);
                if(t.StockKeepingUnit == productoGex.sku){
                    productoGex.id_cuenta =accountId;
                    productoGex.id_producto_adquirido = mapAssets.get(productoGex.sku_de_tangible);
                    productoGex.id_tienda = mapStores.get(productoGex.clave_tienda);
                    system.debug('Asset al que va: '+productoGex.id_producto_adquirido);
                    DSALES_CertificadoWrapper.CertificadoResponse responsePayloadCertifieds = DSALES_CertificadoWrapperRequest.insertCertificado(productoGex);
                    System.debug('C E R T I: '+responsePayloadCertifieds.mensaje_error);
                    mapCertifieds.put(t.StockKeepingUnit, responsePayloadCertifieds.id_certificado);
                }
                }
            }
        }
        return mapCertifieds;
    }
    
    public static List<String> insertPaymentInfo(DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest paymentInformation, String accountId, Map<String, String> assetsId, String quoteId){
        Map<String, String> mapStores = new Map<String, String>();
        String stores = '';
        List<String> ids= new List<String>();
        
        Quote cotizacion = [SELECT OpportunityId FROM Quote WHERE Id= :quoteId];
        
            stores=paymentInformation.clave_tienda;
        
      
            //pagos.id_tienda = mapStores.get(pagos.clave_tienda);
            //system.debug('Store_id: '+pagos.id_tienda);
           // pagos.id_cliente = accountId;
           // pagos.asset_id =  assetsId.get(pagos.sku);
            paymentInformation.opportunity_id = cotizacion.OpportunityId;
            
            
            DSALES_PaymentInfoWrapperGEX.PaymentGEXResponse responsePaymInfo = DSALES_PaymentInfoWrapperGexRequest.insertPaymentGex(paymentInformation);
         	 ids.add(responsePaymInfo.id_informacionPago);
            system.debug('Error en P A G O: '+responsePaymInfo.mensaje_error);
        return ids;
    }
    public static void assignFields(List<DSALES_AssetWrapper.AssetRequest> listAssets,DSALES_PaymentInfoWrapperGEX.PaymentGEXRequest pays, List<DSALES_CertificadoWrapper.CertificadoRequest> listCertificado,DSALES_VentaGEX.VentaGexRequest venta,DSALES_VentaGEX.VentaGexResponse ventaGEX)
    {
        String nombreConcat='';
        Integer contadora=0;
         List<QuoteLineItem> partidas = new  List<QuoteLineItem>();
         List<String>sku= new List<String>();
        List <String> articulo = new List<String>();
       
        DSALES_AccountWrapper.AccountRequest cliente=venta.cliente;
       
        for(DSALES_AssetWrapper.AssetRequest assi: listAssets)
                    {
                        articulo.add(assi.articulo);
                        sku.add(assi.sku_de_tangible);
                        assi.email=cliente.correo_electronico;
                        assi.primer_nombre=cliente.nombre;
                        assi.apellido=cliente.apellido_paterno + ' '+cliente.apellido_materno;
                    }
     
        List<DSALES_CertificadoWrapper.CertificadoRequest> certificadoList= new List<DSALES_CertificadoWrapper.CertificadoRequest>();
        Map<Id,QuoteLineItem>mapPartida= new map<Id,QuoteLineitem>([SELECT Vigencia_meses__c,DSALES_SKU__c,TotalPrice FROM QuoteLineItem WHERE quoteId=:venta.quoteId ]);
        system.debug('Mapa: '+mapPartida);
        for(DSALES_CertificadoWrapper.CertificadoRequest certi: listCertificado)
        				{
                            certi.email_cliente=cliente.correo_electronico;
                        certi.telefono_cliente=cliente.telefono;
                        certi.direccion_cliente=cliente.codigo_postal;
                        certi.clave_tienda=venta.id_tienda;
                        certi.nombre_vendedor=venta.nombre_vendedor;    
                        certi.numero_caja_coppel=venta.numero_caja;
                        certi.id_vendedor=venta.id_vendedor;
                        certi.id_factura=venta.id_factura;
                        certi.fecha_venta=venta.fecha_compra;
                        certi.fecha_compra_garantia=venta.fecha_compra;
                        certi.numero_cliente=cliente.numero_de_cliente;
                        certi.nombre_completo_cliente=cliente.nombre + ' '+cliente.apellido_paterno + ' '+cliente.apellido_materno;
                        if(!String.isEmpty(certi.id_partida_presupuesto) && mapPartida.containsKey(certi.id_partida_presupuesto))
                        {
                            
                            certi.sku= mapPartida.get(certi.id_partida_presupuesto).DSALES_SKU__c;
                            System.debug('Aquí si pasó donde agarra el SKU: '+certi.sku);
                            if(mapPartida.get(certi.id_partida_presupuesto).Vigencia_meses__c!=null)
                                certi.garantia_coppel_tangible=Integer.valueOf(mapPartida.get(certi.id_partida_presupuesto).Vigencia_meses__c);
                        		
                            certi.costo_garantia=mapPartida.get(certi.id_partida_presupuesto).TotalPrice;
                            certificadoList.add(certi);
                        }
                       
                    }
      					
                        //pays.direccion_cliente=cliente.codigo_postal;
                        //pays.numero_de_cliente=cliente.numero_de_cliente;
                        //pays.telefono=cliente.telefono;
                        pays.fecha_venta=venta.fecha_compra;
                        pays.clave_tienda=venta.id_tienda;
                        pays.id_factura=venta.id_factura;
                        pays.caja=venta.numero_caja;
                        pays.id_vendedor=venta.id_vendedor;
                        pays.nombre_vendedor=venta.nombre_vendedor;
        				
                        
                    
    }
}