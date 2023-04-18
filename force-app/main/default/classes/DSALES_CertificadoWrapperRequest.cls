@RestResource(urlMapping='/insertCertificado/*')
global with sharing class DSALES_CertificadoWrapperRequest {
    @HttpPost
    global static DSALES_CertificadoWrapper.CertificadoResponse createCertificado(){
        
        DSALES_CertificadoWrapper.CertificadoResponse responsePayload = new DSALES_CertificadoWrapper.CertificadoResponse();
        if(RestContext.request != null){
            String Body = System.RestContext.request.requestBody.toString();
            
            if(String.isNotBlank(Body)){
                try{
                    DSALES_CertificadoWrapper.CertificadoRequest certificado = (DSALES_CertificadoWrapper.CertificadoRequest)JSON.deserialize(body, DSALES_CertificadoWrapper.CertificadoRequest.class);
                    responsePayload = insertCertificado(certificado);
                }
                
                catch(Exception.JSONException e)
                {
                    responsePayload.exito = false;
                    responsePayload.mensaje_error = DSALES_Utility.BAD_REQUEST_MSJ;
                    responsePayload.codigo_error=String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    
                }
                catch(Exception e){
                    responsePayload.exito = false;
                    responsePayload.mensaje_error = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    responsePayload.codigo_error=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    
                    
                }
            }
        }
        
        return responsePayload;
        
    }
  
    global static void  putCertificado(String id_universal,List<DSALES_CancelacionProductosWrapper.ListaProducto> listaProductos,String estatusGlobal,String motivoGlobal)
    {
         List<OpportunityLineItem> listaOportunidades = new List<OpportunityLineItem>();
            List<Asset> listaAssetsModificar = new List<Asset>();
        List<DSALES_Certificado__c> listaCertificados = new List<DSALES_Certificado__c>();
        List<DSALES_Certificado__c> listaCertificadosModificar= new List<DSALES_Certificado__c>();
      List<DSALES_InformacionDePago__c> pago =[SELECT Id,DSALES_Oportunidad__c
                                                    FROM DSALES_InformacionDePago__c WHERE   DSALES_IDUniversal1__c=:id_universal];
        if(listaProductos.size()==0 || listaProductos==null)
        {
            if(!String.isEmpty(id_universal))
            {
                if(pago.size()>0)
                {
                Integer contador =0;
                List<OpportunityLineItem> productoOpor= [SELECT DSALES_Estatus__c FROM OpportunityLineItem WHERE OpportunityId=:pago[0].DSALES_Oportunidad__c ]; 
                List<DSALES_Certificado__c> certificados= [SELECT DSALES_Estatus__c FROM DSALES_Certificado__c WHERE
                                                          DSALES_InformacionDePago__c=:pago[0].Id];
                List<Asset> productos=[Select Status FROM Asset WHERE DSales_Informacion_pago__c=:pago[0].Id ];
            	
                for(OpportunityLineItem oportunidad:productoOpor)
                {
                    oportunidad.DSALES_Estatus__c=estatusGlobal;
                    listaOportunidades.add(oportunidad);
                    if(certificados.size()>contador)
                        {
                            certificados[contador].DSALES_Estatus__c =estatusGlobal;
                            certificados[contador].DSales_Motivo__c=motivoGlobal;
                            listaCertificadosModificar.add(certificados[contador]);
                        }
                   
                     if(productos.size()>contador)
                        {
                            productos[contador].Status =estatusGlobal;
                             productos[contador].DSALES_Motivo__c=motivoGlobal;
                            listaAssetsModificar.add(productos[contador]);
                        }
                    contador++;
                }
            }
                }
        }
        else
        {
        
            List<Asset> listaAssets = new List<Asset>();
           
            List<String> listaSku= new List<String>();
            Map<String,DSALES_CertificadoWrapper.cancelacionGex> mapaCancela = new Map<String,DSALES_CertificadoWrapper.cancelacionGex>();
            if(pago.size()>0)
            {
                     listaAssets=[SELECT Id,DSALES_SKU__c FROM Asset WHERE  DSales_Informacion_pago__c=:pago[0].id];
            listaCertificados= [SELECT Name, DSALES_Estatus__c, DSales_Motivo__c FROM
                                                           DSALES_Certificado__c WHERE DSALES_InformacionDePago__c =:pago[0].id];
            }
       
            List<String> idOportunidades= new List<String>(); 
            List<String> foliosCertificados = new List<String>();
      
            for(DSALES_CancelacionProductosWrapper.ListaProducto lp:ListaProductos)
            {
                if(!String.isEmpty(lp.idPartidaOportunidad))
                {
                    OpportunityLineItem oppor = new OpportunityLineItem();
                  
                    oppor.Id=lp.idPartidaOportunidad;
                    oppor.DSALES_Estatus__c=lp.estatus;
                    DSALES_CertificadoWrapper.cancelacionGex cancelacion = new DSALES_CertificadoWrapper.cancelacionGex();
                    idOportunidades.add(lp.idPartidaOportunidad);
                    cancelacion.estatus=lp.estatus;
                    cancelacion.motivoCancelacion=lp.motivoCancelacion;
                    mapaCancela.put(lp.idPartidaOportunidad,cancelacion);
                    listaOportunidades.add(oppor);
                   
                }
                else
                {
                    if(!String.isEmpty(lp.idCertificado))
                    {
                        
                    }
                }
            }
            
            List<OpportunityLineItem> sku =[SELECT Id,Product2.StockKeepingUnit,DSALES_FolioCertificado__c FROM OpportunityLineItem
                                           WHERE Id IN:idOportunidades];
           
           for(OpportunityLineItem s:sku)
           {
               if(mapaCancela.containsKey(s.Id))
               {
                     for(Asset a:listaAssets)
                   {
                       if(s.Product2.StockKeepingUnit==a.DSALES_SKU__c)
                       {
                           mapaCancela.get(s.Id).idProducto=a.Id;
                           Asset asset = new Asset();
                           asset.id=a.Id;
                           asset.Status=mapaCancela.get(s.Id).estatus;
                           asset.DSales_Motivo__c=mapaCancela.get(s.id).motivoCancelacion;
                           listaAssetsModificar.add(asset);
                       }
                   }
                   for(DSALES_Certificado__c c:listaCertificados)
                       {
                           if(s.DSALES_FolioCertificado__c==c.Name)
                               {
                                   mapaCancela.get(s.Id).idProducto=c.Id;
                           DSALES_Certificado__c certificado = new DSALES_Certificado__c();
                           certificado.id=c.Id;
                           certificado.DSALES_Estatus__c=mapaCancela.get(s.Id).estatus;
                           certificado.DSales_Motivo__c=mapaCancela.get(s.id).motivoCancelacion;
                           listaCertificadosModificar.add(certificado);
                               }
                       }
               }
             
             
           }
          
        }
          update listaAssetsModificar;
            update listaOportunidades;
            update listaCertificadosModificar;
        
        
        

     
        
    }
    
   
   
    
    global static DSALES_CertificadoWrapper.CertificadoResponse insertCertificado(DSALES_CertificadoWrapper.CertificadoRequest certificado){
        DSALES_Certificado__c certificadoRecord = new DSALES_Certificado__c();
        Boolean success = false;
        String message = '';
        String code='';
        try{
            if(certificado.numero_cliente!=null)
            {
                Account cliente =[SELECT Id FROM ACCOUNT WHERE CP_WalletCustomerNumber__c=:Double.valueOf(certificado.numero_cliente) LIMIT 1]; 
                certificadoRecord.DSALES_Cliente__c=cliente.Id;
            }
            else
            {
                certificadoRecord.DSALES_Cliente__c=certificado.id_cuenta;
            }
            
            certificadoRecord.DSALES_ProductoAdquirido__c=certificado.id_producto_adquirido;
            
            certificadoRecord.DSALES_Ticket__c=certificado.id_factura;
            certificadoRecord.DSALES_Tienda__c=certificado.clave_tienda;
            certificadoRecord.DSALES_TiendaId__c=certificado.id_tienda;
            certificadoRecord.DSALES_Caja_GEX__c=certificado.numero_caja_coppel;
            certificadoRecord.DSALES_Numero_de_Vendedor__c=certificado.id_vendedor;
            certificadoRecord.DSALES_Nombre_Vendedor__c=certificado.nombre_vendedor;	
            certificadoRecord.DSALES_Domicilio_del_Client_e__c=certificado.direccion_cliente;
            certificadoRecord.DSALES_Email__c=certificado.email_cliente;
            certificadoRecord.DSALES_No_de_Telefono__c=certificado.telefono_cliente;
            certificadoRecord.DSALES_Numero_celular__c=certificado.celular_cliente;
            certificadoRecord.DSALES_SKU__c=certificado.sku;	
            certificadoRecord.DSALES_Modelo__c=certificado.modelo_tangible;	
            certificadoRecord.DSALES_Marca__c=certificado.marca_tangible;	
            certificadoRecord.DSALES_Numero_serie__c=certificado.numero_serie;	
            certificadoRecord.DSALES_DescripcionDelArtculo__c=certificado.descripcion_tangible;
            certificadoRecord.DSALES_Precio_del_Articulo__c=certificado.precio_tangible;
            certificadoRecord.DSALES_Duracion_de_GEX__c=certificado.garantia_coppel_tangible;
            certificadoRecord.DSales_Garantia_Coppel__c=certificado.garantia_coppel_producto;
            certificadoRecord.DSALES_Fecha_de_compra_GEX__c=certificado.fecha_compra_garantia;	
            certificadoRecord.DSALES_Fecha_Inicio_de_Vigencia__c=certificado.fecha_inicio_garantia_extendida;
            certificadoRecord.DSALES_Costo_de_Garantia_Extendida__c=certificado.costo_garantia;
            certificadoRecord.DSALES_Fecha_Fin_Vigencia__c=certificado.fecha_fin_garantia_extendida;
            certificadoRecord.DSALES_Fecha_de_venta_del_articulo__c=certificado.fecha_venta;
            certificadoRecord.DSALES_InformacionDePago__c=certificado.id_pago;
            certificadoRecord.DSALES_ProductoAdquirido__c=certificado.id_producto_adquirido;
            certificadoRecord.DSALES_SKUTangible__c=certificado.sku_de_tangible;
            
            insert certificadoRecord;
            
            success = true;
            message = '';
            system.debug('message' +message);
            
        } catch(Exception e){
            success = false;
            message = DSALES_Utility.INTERNAL_ERROR_MSJ;
            code=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
            
            
        }
        
        DSALES_CertificadoWrapper.CertificadoResponse responsePayload = new DSALES_CertificadoWrapper.CertificadoResponse();
        responsePayload.exito = success;
        responsePayload.mensaje_error = message;
        responsePayload.codigo_error=code;
        responsePayload.id_certificado = certificadoRecord.id;
        
        return responsePayload;
    }
    
}