@RestResource(urlMapping='/ventaGex/*')
global with sharing class DSALES_VentaGEXRest {
   
    @HttpPost
    global static DSALES_VentaGEX.VentaGexResponse createVenta() {
        List<String> assetsId = new List<String>();
        List<String> paymentIds= new List<String>();
        List<String> certifiedIds= new List <String>();
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
                    
                    DSALES_VentaGEX.VentaGexRequest venta = (DSALES_VentaGEX.VentaGexRequest)JSON.deserialize(cuerpo, DSALES_VentaGEX.VentaGexRequest.class);
                    assignFields(venta,ventaGEX);
                    
                    DSALES_AccountWrapper.AccountResponse cliente = DSALES_AccountWrapperRequest.upsertAccount(venta.cliente);
                    clienteId=cliente.idCuenta;
                    System.debug('Cliente Response '+cliente.mensajeError);
                    validarCliente(venta.quoteId, cliente.idCuenta,venta.nombreVendedor);
                    
                   
                   system.debug('INSERTANDO ASSETS Y VER ID CUENTA: '+cliente.idCuenta);
                    Map<String, String> mapAssets = insertAssets(venta.listaDeProductos, cliente.idCuenta); 
                    
                    for (String assetId : mapAssets.values())
                    {
                        assetsId.add(assetId);
                    }
                    
                    Map<String, String> mapCertifieds = insertCertified(venta.listaDeCertificados, cliente.idCuenta, mapAssets);
                    system.debug('MapCertifieds Values' + mapCertifieds.values());
                    if(mapCertifieds.size()>0)
                    {
                        
                        
                        for(String certificadoId: mapCertifieds.values())
                        {
                            system.debug('CERTIFICADOID '+certificadoId);
                            certifiedIds.add(certificadoId);
                        }
                    }
                    
                    
                    paymentIds=insertPaymentInfo(venta.pago,  mapAssets, venta.quoteId);
                    DSALES_ValidarClienteHelper.deleteUnpurchasedItem(venta.listaDeProductos,venta.listaDeCertificados, venta.quoteId);
                    DSALES_ValidarClienteHelper.actualizarCotizacion(venta.quoteId,ventaGEX,mapAssets,mapCertifieds);
                    

                    success=true;
                    message='';
                    
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
        ventaGex.mensaje='';
        ventaGEX.exito = success;
        if(ventaGex.exito)
        {
        	ventaGEX.mensaje='Venta Generada con Éxito';    
        }
        
        ventaGEX.codigoDeError=code;
        ventaGEX.idClienteSalesforce=clienteId;
        ventaGEX.idDePago=paymentIds;
        
        
        
        List<Asset> product= [SELECT id,Product2.StockKeepingUnit,DSALES_SKU__c FROM ASSET WHERE id IN: assetsId WITH SECURITY_ENFORCED];
        system.debug('Lista de productos: '+product);
        List<DSALES_InformacionDePago__c> pago=[Select id,DSALES_SKU__c FROM DSALES_InformacionDePago__c WHERE id IN:paymentIds WITH SECURITY_ENFORCED];
        system.debug('Lista de pagos: '+pago);
        List<DSALES_Certificado__c> certi=[Select id,DSALES_SKU__c,DSALES_SKUTangible__c,DSALES_Precio_del_Articulo__c FROM DSALES_Certificado__c WHERE id IN:certifiedIds WITH SECURITY_ENFORCED];
        system.debug('Lista de cert: '+certi);
        
        try{
        for(Asset a: product)
        { 
            system.debug('Total de Assets: '+a.Id);
            if(pago.size()>0)
            {
                pago[0].DSALES_ProductoAdquirido__c=a.id;
                a.DSales_Informacion_pago__c=pago[0].Id;
            }
            
            for(DSALES_Certificado__c c:certi)
            {
                
                system.debug('Sí pasó! el certificado');
                
                if( pago.size()>0)
                {
                    pago[0].DSALES_Certificado__c=c.id;
                    //aqui
                    c.DSALES_InformacionDePago__c=pago[0].id;
                }
                system.debug('EL PRIMERO ES EL QUE HAY QUE CHECAR: '+c.DSALES_SKUTangible__c + 'Asset: '+a.DSALES_SKU__c);
                if(c.DSALES_SKUTangible__c==a.DSALES_SKU__c)
                {
                    c.DSALES_ProductoAdquirido__c=a.Id;
                    system.debug('DEBERÏA DE HABER PASADO 2 Veces: '+c.DSALES_ProductoAdquirido__c);
                    a.DSALES_Certificado__c=c.Id;
                    a.Price=c.DSALES_Precio_del_Articulo__c;
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
    
    public static Map<String, String> insertAssets(List<DSALES_AssetWrapper.AssetRequest> listAssets, String accountId){
        Map<String, String> mapAssets = new Map<String, String>();
        List<String> listSKU = new List<String>();
        List<String> idsAssets = new List<String>();
        
        for(DSALES_AssetWrapper.AssetRequest sku: listAssets){
            listSKU.add(sku.skuDeTangible);
        }
        
        
        for(Product2 t: [Select StockKeepingUnit,Id from Product2 where StockKeepingUnit in :listSKU and DSales_Tipo_de_Producto__c='Producto' WITH SECURITY_ENFORCED] ){
            for(DSALES_AssetWrapper.AssetRequest producto: listAssets){
                if(t.StockKeepingUnit == producto.skuDeTangible){
                    producto.idCuenta=accountId;
                    producto.idProducto=t.Id;
                    producto.estado='Adquirido';
                    
                    DSALES_AssetWrapper.AssetResponse responsePayloadAsset = DSALES_AssetWrapperRequest.insertaAssets(producto);
                    system.debug('Mensaje de ASSET: '+responsePayloadAsset.mensajeError);
                    mapAssets.put(t.StockKeepingUnit, responsePayloadAsset.idAsset);
                    idsAssets.add(responsePayloadAsset.idAsset);
                    
                }
            }
        }
        return mapAssets;
    }
   
    public static Map<String, String> insertCertified(List<DSALES_CertificadoWrapper.CertificadoRequest> certificado, String accountId, Map<String, String> mapAssets){
        Map<String, String> mapCertifieds = new Map<String, String>();
        Map<String, String> mapStores = new Map<String, String>();
        List<String> listSKUCertifieds = new List<String>();
        List<String> listProducts= new List<String>();
        List<String> listStores= new List<String>();
        system.debug('Aquí sí llegó');
        for(DSALES_CertificadoWrapper.CertificadoRequest sku: certificado){
            if(!String.isEmpty(sku.idPartidaPresupuesto) )
            {system.debug('Entró al for: y el SKU es: '+sku.sku);
             listSKUCertifieds.add(sku.sku+sku.skuDeTangible);
             listProducts.add(sku.sku);
             listStores.add(sku.claveTienda);
            }
            system.debug('Aquí sí llegó: SKU: '+listStores);
            
        }
        for(Tienda__c store: [select id,dsales_TiendaID__c from Tienda__c where dsales_TiendaID__c in :listStores WITH SECURITY_ENFORCED]){
            mapStores.put(store.dsales_TiendaID__c, store.Id);
        }
        
        system.debug('Seguimos bien con sku '+listSKUCertifieds);
        for(Product2 t: [Select StockKeepingUnit from Product2 where StockKeepingUnit in :listProducts and DSales_Tipo_de_Producto__c='Servicio' WITH SECURITY_ENFORCED]){
            system.debug('Entramos1 '+mapStores);
            for(DSALES_CertificadoWrapper.CertificadoRequest productoGex: certificado){
                if(!String.isEmpty(productoGex.idPartidaPresupuesto) )
                {
                    system.debug('Entramos '+mapStores);
                    if(t.StockKeepingUnit+productoGex.skuDeTangible == productoGex.sku+productoGex.skuDeTangible){
                        productoGex.idCuenta =accountId;
                        productoGex.idProductoAdquirido = mapAssets.get(productoGex.skuDeTangible);
                        productoGex.idTienda = mapStores.get(productoGex.claveTienda);
                        system.debug('Asset al que va: '+productoGex.idProductoAdquirido);
                        DSALES_CertificadoWrapper.CertificadoResponse responsePayloadCertifieds = DSALES_CertificadoWrapperRequest.insertCertificado(productoGex);
                        System.debug('C E R T I: '+responsePayloadCertifieds.mensajeError);
                        mapCertifieds.put(t.StockKeepingUnit+productoGex.skuDeTangible, responsePayloadCertifieds.idCertificado);
                    }
                }
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
        
        
        //pagos.id_tienda = mapStores.get(pagos.clave_tienda);
        //system.debug('Store_id: '+pagos.id_tienda);
        // pagos.id_cliente = accountId;
        // pagos.asset_id =  assetsId.get(pagos.sku);
        paymentInformation.opportunityId = cotizacion.OpportunityId;
        
        
        DSALES_PaymentInfoWrapperGEX.PaymentGEXResponse responsePaymInfo = DSALES_PaymentInfoWrapperGexRequest.insertPaymentGex(paymentInformation);
        ids.add(responsePaymInfo.idInformacionPago);
        system.debug('Error en P A G O: '+responsePaymInfo.mensajeError);
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
        
        for(DSALES_AssetWrapper.AssetRequest assi: venta.listaDeProductos)
        {
            articulo.add(assi.articulo);
            sku.add(assi.skuDeTangible);
            assi.email=cliente.correoElectronico;
            assi.primerNombre=cliente.nombre;
            assi.apellido=cliente.apellidoPaterno + ' '+cliente.apellidoMaterno;
        }
        
        List<DSALES_CertificadoWrapper.CertificadoRequest> certificadoList= new List<DSALES_CertificadoWrapper.CertificadoRequest>();
        Map<Id,QuoteLineItem>mapPartida= new map<Id,QuoteLineitem>([SELECT Vigencia_meses__c,DSALES_SKU__c,TotalPrice FROM QuoteLineItem WHERE quoteId=:venta.quoteId ]);
        
        for(DSALES_CertificadoWrapper.CertificadoRequest certi: venta.listaDeCertificados)
        {
            certi.emailCliente=cliente.correoElectronico;
            certi.telefonoCliente=cliente.telefono;
            certi.direccionCliente=cliente.codigoPostal;
            certi.claveTienda=venta.idTienda;
            certi.nombreVendedor=venta.nombreVendedor;    
            certi.numeroCajaCoppel=venta.numeroCaja;
            certi.idVendedor=venta.idVendedor;
            certi.idFactura=venta.idFactura;
            certi.fechaVenta=venta.fechaCompra;
            certi.fechaCompraGarantia=venta.fechaCompra;
            certi.numeroCliente=cliente.numeroCliente;
            certi.nombreCompletoCliente=cliente.nombre + ' '+cliente.apellidoPaterno + ' '+cliente.apellidoMaterno;
            system.debug('VA A PASAR AL IF DEL MAPA PARTIDA');
            if(!String.isEmpty(certi.idPartidaPresupuesto) && mapPartida.containsKey(certi.idPartidaPresupuesto))
            {
                            system.debug('PASÓ AL IF DEL MAPA PARTIDA');

                certi.sku= mapPartida.get(certi.idPartidaPresupuesto).DSALES_SKU__c;
                System.debug('Aquí si pasó donde agarra el SKU: '+certi.sku);
                if(mapPartida.get(certi.idPartidaPresupuesto).Vigencia_meses__c!=null)
                {
                    certi.garantiaCoppelTangible=Integer.valueOf(mapPartida.get(certi.idPartidaPresupuesto).Vigencia_meses__c);
                }
                
                certi.costoGarantia=mapPartida.get(certi.idPartidaPresupuesto).TotalPrice;
                certificadoList.add(certi);
            }
        }
        //pays.direccion_cliente=cliente.codigo_postal;
        //pays.numero_de_cliente=cliente.numero_de_cliente;
        //pays.telefono=cliente.telefono;
        venta.pago.fechaVenta=venta.fechaCompra;
        venta.pago.claveTienda=venta.idTienda;
        venta.pago.idFactura=venta.idFactura;
        venta.pago.caja=venta.numeroCaja;
        venta.pago.idVendedor=venta.idVendedor;
        venta.pago.nombreVendedor=venta.nombreVendedor;              
    }

}