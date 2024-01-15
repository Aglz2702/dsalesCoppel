@RestResource(urlMapping='/insertCertificado/*')
global with sharing class DSALES_CertificadoWrapperRequest {

    @HttpPost
    global static DSALES_CertificadoWrapper.CertificadoResponse createCertificado(){
       
        DSALES_CertificadoWrapper.CertificadoResponse responsePayload = new DSALES_CertificadoWrapper.CertificadoResponse();
        if(RestContext.request != null){
            String cuerpo = System.RestContext.request.requestBody.toString();
            
            if(String.isNotBlank(cuerpo)){
                try{
                    DSALES_CertificadoWrapper.CertificadoRequest certificado = (DSALES_CertificadoWrapper.CertificadoRequest)JSON.deserialize(cuerpo, DSALES_CertificadoWrapper.CertificadoRequest.class);
                    responsePayload = insertCertificado(certificado);
                }
                
                catch(Exception.JSONException e)
                {
                    responsePayload.exito = false;
                    responsePayload.mensajeError = DSALES_Utility.BAD_REQUEST_MSJ;
                    responsePayload.codigoError=String.valueOf(DSALES_Utility.BAD_REQUEST_CODE);
                    
                }
                catch(Exception e){
                    responsePayload.exito = false;
                    responsePayload.mensajeError = DSALES_Utility.INTERNAL_ERROR_MSJ + e.getMessage() + e.getLineNumber();
                    responsePayload.codigoError=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                    
                    
                }
            }
        }
        
        return responsePayload;
        
    }
  
    global static void  putCertificado(String idUniversal,List<DSALES_CancelacionProductosWrapper.ListaProducto> listaProductos,String estatusGlobal,String motivoGlobal)
    {
         List<OpportunityLineItem> listaOportunidades = new List<OpportunityLineItem>();
            List<Asset> listaAssetsModificar = new List<Asset>();
        List<DSALES_Certificado__c> listaCertificados = new List<DSALES_Certificado__c>();
        List<DSALES_Certificado__c> listaCertificadosModificar= new List<DSALES_Certificado__c>();
      //List<DSALES_InformacionDePago__c> pago =[SELECT Id,DSALES_Oportunidad__c
        //                                            FROM DSALES_InformacionDePago__c WHERE   DSALES_IDUniversal1__c=:idUniversal WITH SECURITY_ENFORCED];
        List<DSALES_InformacionDePago__c> pago =[SELECT Id,DSALES_Oportunidad__c,DSALES_Estatus__c
                                                    FROM DSALES_InformacionDePago__c WHERE   DSALES_IDUniversal1__c=:idUniversal WITH SECURITY_ENFORCED];
	  	List<DSALES_InformacionDePago__c> listaPagoAct= new  List<DSALES_InformacionDePago__c> ();
        if(listaProductos.size()==0 || listaProductos==null)
        {
            if(!String.isEmpty(estatusGlobal) && (!String.isEmpty(motivoGlobal)))
            {
                switch on pago.size() {
                    when 0  {
                       System.debug('El size es 0');
                    }
                    when else {
                    system.debug('El size es diferente');
                        Integer contador =0;
                        List<OpportunityLineItem> productoOpor= [SELECT DSALES_Estatus__c FROM OpportunityLineItem WHERE OpportunityId=:pago[0].DSALES_Oportunidad__c  WITH SECURITY_ENFORCED]; 
                        List<DSALES_Certificado__c> certificados= [SELECT DSALES_Estatus__c FROM DSALES_Certificado__c WHERE
                                                                  DSALES_InformacionDePago__c=:pago[0].Id WITH SECURITY_ENFORCED];
                        //List<Asset> productos=[Select Status FROM Asset WHERE DSales_Informacion_pago__c=:pago[0].Id WITH SECURITY_ENFORCED];
                        //system.debug('');
                        List<Asset> productos=[Select Status,DSales_Informacion_pago__c FROM Asset WHERE DSales_Informacion_pago__c=:pago[0].Id WITH SECURITY_ENFORCED];
                        system.debug('asset_________'+productos);
                        system.debug('pago'+pago);
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
                            if(pago.size()>contador){
                                pago[contador].DSALES_Estatus__c=estatusGlobal;
                                listaPagoAct.add(pago[contador]);
                            }
                            contador++;
                        }
                        
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
                     listaAssets=[SELECT Id,DSALES_SKU__c,DSales_Informacion_pago__c  FROM Asset WHERE  DSales_Informacion_pago__c=:pago[0].id WITH SECURITY_ENFORCED];
            listaCertificados= [SELECT Name, DSALES_Estatus__c,DSALES_SKU__c, DSales_Motivo__c FROM
                                                           DSALES_Certificado__c WHERE DSALES_InformacionDePago__c =:pago[0].id WITH SECURITY_ENFORCED];
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
                
            }
            
            List<OpportunityLineItem> sku =[SELECT Id,Product2.StockKeepingUnit,DSALES_FolioCertificado__c FROM OpportunityLineItem
                                           WHERE Id IN:idOportunidades WITH SECURITY_ENFORCED];
           system.debug('MARCA LA TOTALIZACIÓN');
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
                   for(DSALES_InformacionDePago__c p:pago){
						p.DSALES_Estatus__c='No Acreditado';//mapaCancela.get(s.Id).estatus;
                       	listaPagoAct.add(p);
                   }
                   for(DSALES_Certificado__c c:listaCertificados)
                       {
                           if(s.Product2.StockKeepingUnit==c.DSALES_SKU__c)
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

          //actualizaListas(listaAssetsModificar,listaOportunidades,listaCertificadosModificar);
        System.debug('opp________'+listaOportunidades);
        System.debug('asset_________'+listaAssetsModificar);
         System.debug('listaCertificadosModificar'+listaCertificadosModificar);
         System.debug('listaPagoAct'+listaPagoAct);
	    actualizaListas(listaAssetsModificar,listaOportunidades,listaCertificadosModificar,listaPagoAct);
         
        
        

     
        
    }
    
   //public static void actualizaListas(List<Asset> listaAssetsModificar, List<OpportunityLineItem> listaOportunidades, List<DSALES_Certificado__c> listaCertificadosModificar)
   public static void actualizaListas(List<Asset> listaAssetsModificar, List<OpportunityLineItem> listaOportunidades, List<DSALES_Certificado__c> listaCertificadosModificar,List<DSALES_InformacionDePago__c> listaPagosModificar)
    {
            if(Schema.sObjectType.Asset.isUpdateable())
            {
                update listaAssetsModificar;
            }
          
            if(Schema.sObjectType.OpportunityLineItem.isUpdateable())
            {
                update listaOportunidades;
            }
           
            if(Schema.sObjectType.DSALES_Certificado__c.isUpdateable())
            {
                update listaCertificadosModificar;
            }
        	if(Schema.sObjectType.DSALES_InformacionDePago__c.isUpdateable()){
           update listaPagosModificar;
       		}
   }
   
    
    public static DSALES_CertificadoWrapper.CertificadoResponse insertCertificado(DSALES_CertificadoWrapper.CertificadoRequest certificado){
        
        DSALES_Certificado__c certificadoRecord = new DSALES_Certificado__c();
        Boolean success = false;
        String message = '';
        String code='';
        String idInstalacion='';
        Map<String,String> eventoDelCertificado= new Map<String,String>();
        try{
            if((certificado.numeroCliente!='' || !String.isEmpty(certificado.numeroCliente))&&  (!certificado.numeroCliente.Equals('90001') || certificado.numeroCliente!='90001'))
            {
                List<Account> cliente =[SELECT Id FROM ACCOUNT WHERE CP_WalletCustomerNumber__c=:Double.valueOf(certificado.numeroCliente) WITH SECURITY_ENFORCED LIMIT 1 ]; 
                if (cliente.size()>0)
                    {
                        certificadoRecord.DSALES_Cliente__c=cliente[0].Id;
                    }
                
            }
            else
            {
                certificadoRecord.DSALES_Cliente__c=certificado.idCuenta;
            }
            system.debug('Id Producto Adquirido: '+certificado.idProductoAdquirido);
            certificadoRecord.DSALES_ProductoAdquirido__c=certificado.idProductoAdquirido;
            certificadoRecord.dsalesIdSecuencia__c=certificado.idSecuencia;
            certificadoRecord.DSALES_Ticket__c=certificado.idFactura;
            certificadoRecord.DSALES_Tienda__c=certificado.claveTienda;
            certificadoRecord.dsales_TiendaID__c=certificado.idTienda;
            certificadoRecord.DSALES_Caja_GEX__c=certificado.numeroCajaCoppel;
            certificadoRecord.DSALES_Numero_de_Vendedor__c=certificado.idVendedor;
            certificadoRecord.DSALES_Nombre_Vendedor__c=certificado.nombreVendedor; 
            certificadoRecord.DSALES_Domicilio_del_Client_e__c=certificado.direccionCliente;
            certificadoRecord.DSALES_Email__c=certificado.emailCliente;
            //certificadoRecord.DSALES_No_de_Telefono__c=certificado.telefonoCliente;
            certificadoRecord.DSALES_Numero_celular__c=certificado.telefonoCliente;
            certificadoRecord.DSALES_SKU__c=certificado.sku;    
            certificadoRecord.DSALES_Modelo__c=certificado.modeloTangible;  
            certificadoRecord.DSALES_Marca__c=certificado.marcaTangible;    
            certificadoRecord.DSALES_Numero_serie__c=certificado.numeroSerie;   
            certificadoRecord.DSALES_DescripcionDelArtculo__c=certificado.descripcionTangible;
            certificadoRecord.DSALES_Precio_del_Articulo__c=certificado.precioTangible;
            certificadoRecord.DSALES_Duracion_de_GEX__c=certificado.garantiaCoppelTangible;
            certificadoRecord.DSales_Garantia_Coppel__c=certificado.garantiaCoppelProducto;
            certificadoRecord.DSALES_Fecha_de_compra_GEX__c=certificado.fechaCompraGarantia;    
            certificadoRecord.DSALES_Fecha_Inicio_de_Vigencia__c=certificado.fechaInicioGarantiaExtendida;
            certificadoRecord.DSALES_Costo_de_Garantia_Extendida__c=certificado.costoGarantia;
            certificadoRecord.DSALES_Fecha_Fin_Vigencia__c=certificado.fechaFinGarantiaExtendida;
            certificadoRecord.DSALES_Fecha_de_venta_del_articulo__c=certificado.fechaVenta;
            certificadoRecord.DSALES_InformacionDePago__c=certificado.idPago;
            certificadoRecord.DSALES_ProductoAdquirido__c=certificado.idProductoAdquirido;
            certificadoRecord.DSALES_SKUTangible__c=certificado.skuDeTangible;
            certificadoRecord.DSALES_Costo_de_Garantia_Extendida__c=certificado.precio;
            certificadoRecord.dsalesPrecioSinIVA__c=certificado.precioSinIva;
            certificadoRecord.DSalesNombreServicio__c=certificado.nombreServicio;
             String recordTypeId ='';
            if(certificado.ar!=null)
                {
                    recordTypeId = Schema.SObjectType.Dsales_Certificado__c.getRecordTypeInfosByDeveloperName().get('dsalesArmadoMuebles').getRecordTypeId();
                  certificadoRecord.RecordTypeId=recordTypeId;
                 certificadoRecord.dsalesFechaPromesa__c=certificado.fechaPromesa; 
                    system.debug('RECORD TYPE: ARM');
                }
            else if(!String.isBlank(certificado.garantiaCoppelProducto)) {
                certificadoRecord.RecordTypeId=Schema.SObjectType.Dsales_Certificado__c.getRecordTypeInfosByDeveloperName().get('dsalesGarantiaExtendida').getRecordTypeId();
                idInstalacion=certificadoRecord.RecordTypeId;
                system.debug('RECORD TYPE: GEX');
                system.debug(certificado.garantiaCoppelProducto);
            }
            
            else {
                certificadoRecord.RecordTypeId=Schema.SObjectType.Dsales_Certificado__c.getRecordTypeInfosByDeveloperName().get('dsalesInstalacion').getRecordTypeId();
                system.debug('RECORD TYPE: Instalación');
            }
            if(Schema.sObjectType.DSALES_Certificado__c.isCreateable())
            {
                insert certificadoRecord;
            }
          system.debug('Exito');
          
             
            success = true;
            message = '';
            system.debug('message' +message);
            
        } catch(Exception e){
            success = false;
            message = DSALES_Utility.INTERNAL_ERROR_MSJ+ e.getMessage() + e.getLineNumber();
            code=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
            system.debug(message);
            
            
        }
        
        DSALES_CertificadoWrapper.CertificadoResponse responsePayload = new DSALES_CertificadoWrapper.CertificadoResponse();
        responsePayload.exito = success;
        responsePayload.mensajeError = message;
        responsePayload.codigoError=code;
        responsePayload.idCertificado = certificadoRecord.id;
        
        return responsePayload;
    }
    
}