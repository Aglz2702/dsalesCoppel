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
    @HttpPut
    global static DSALES_CertificadoWrapper.CertificadoResponse  putCertificado(String id_factura, String clave_tienda, List<String> sku_de_tangible, List<String> numero_de_certificado, String estado,String motivo)
    {
        
        List<DSALES_Certificado__c> certificado = new List<DSALES_Certificado__c>(); 
        List<Asset> producto = new List<Asset>(); 
        String message='',certId='', code='';
        Boolean success=false;
        
        
        
        try{
            
            
            if(!String.isEmpty(clave_tienda)&&!String.isEmpty(id_factura))
            {
                
                
                id_factura=id_factura.toUpperCase();
                try{
                     DSALES_InformacionDePago__c factura=[SELECT DSALES_Factura__c,id
                                                     FROM DSALES_InformacionDePago__c
                                                     WHERE DSALES_Factura__c=:id_factura AND DSALES_Clave_Tienda__c=:clave_tienda];
                    List<DSALES_Certificado__c> actualCertificates = [Select Name, Id,DSALES_Estatus__c,DSales_Motivo__c
                                                   FROM DSALES_Certificado__c WHERE   DSALES_InformacionDePago__c=:factura.Id];
                     for(String name:numero_de_certificado)
                {
                    name=name.toUpperCase();  
                    getCertificates(actualCertificates, name, certificado);
                }
               
                List<Asset> actualAssets =[Select Id, Product2.StockKeepingUnit FROM Asset Where 
                                           DSales_Informacion_pago__c=:factura.Id];
                     for (String sku:sku_de_tangible) 
                {
                    getAssets(actualAssets, sku, producto);
                }
                	}
                catch(Exception e)
                {
                    message=DSALES_Utility.INTERNAL_ERROR_MSJ;
                
                code=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                success=false;
                }
               
                
                
                
               
               
                
            } 
        }
        catch(Exception e)
        {
            message+=e.getMessage() + ' ' + e.getLineNumber();
        }
        
        if(estado.containsIgnoreCase('dev') ||estado.containsIgnoreCase('can'))
        { 
            try{
                
                if(estado.containsIgnoreCase('dev'))
                {
                    estado='Devuelto';
                }
                else if (estado.containsIgnoreCase('can'))
                {
                    estado='Cancelado';
                }
                
                if(certificado.size()!=0)
                {
                    List<DSALES_Certificado__c> noDupesCertificado= new List<DSALES_Certificado__c>(new Set<DSALES_Certificado__c>(certificado));
                    for(DSALES_Certificado__c c: noDupesCertificado)
                    {
                        c.DSALES_Estatus__c=estado;
                        c.DSales_Motivo__c=motivo;
                        certId+=c.Id +' ';
                    }
                    Update noDupesCertificado;
                    success=true;
                    message+='Certificado(s) actualizado(s): ' ;
                    
                    
                }
                
                
                
                
                if(producto.size()!=0)
                {
                    system.Debug('Llegó aqui???');
                    //132 checa que no haya dubplicados ids
                    List<Asset> noDupesProducto= new List<Asset>(new Set<Asset>(producto));
                    for(Asset p: noDupesProducto)
                    {
                        
                        p.Status=estado;
                        p.DSales_Motivo__c=motivo;
                        certId+=p.id+' ';
                    }
                    system.debug(noDupesProducto);
                    Upsert noDupesProducto;
                    message+= ' y Producto Adquirido actualizado';
                    success=true;
                }
                
                
                
            }
            catch(Exception.JSONException e)
            {
                message=DSALES_Utility.BAD_REQUEST_MSJ;
                code=String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                success=false;       
            }
            catch(Exception e)
            {
                message=DSALES_Utility.INTERNAL_ERROR_MSJ + ' '+ e.GetMessage() +e.getLineNumber() ;
                
                code=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                success=false;       
            }
        }
        else
        {
            message=DSALES_Utility.INTERNAL_ERROR_MSJ;
            code=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
            success=false;    
        }
        
        
        DSALES_CertificadoWrapper.CertificadoResponse responsePayload = new DSALES_CertificadoWrapper.CertificadoResponse();
        responsePayload.exito = success;
        responsePayload.mensaje_error = message;
        responsePayload.codigo_error=code;
        responsePayload.id_certificado =certId;
        return responsePayload;
        
    }
    
    global static void getCertificates(List<DSALES_Certificado__c> actualCertificates,String name, List<DSALES_Certificado__c> certificado)
    {
        for(DSALES_Certificado__c c:actualCertificates)
        {
            if(name==c.Name)
            {
                certificado.add(c);
            }
        }
                
    }
     global static void getAssets(List<Asset> actualAssets, String sku, List<Asset> producto)
        {
            for(Asset a:actualAssets)
                    {
                        system.debug(a.Id);
                        if(sku==a.Product2.StockKeepingUnit)
                        {
                            producto.add(a);
                            
                        }
                    }
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