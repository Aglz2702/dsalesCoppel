@RestResource(urlMapping='/insertTienda/*')
Global with sharing class DSALES_TiendaGexRequest {
    @HttpPost
    global static DSALES_TiendaGex.tiendaResponse crearTienda()
    {
        DSALES_TiendaGex.tiendaResponse responsePayload = new DSALES_TiendaGex.tiendaResponse();
        if(RestContext.request!=null)
        {
            String body=System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body))
            {
                try {
                    DSALES_TiendaGex.tiendaRequest tienda = (DSALES_TiendaGex.tiendaRequest) JSON.deserialize(body,DSALES_TiendaGex.tiendaRequest.class);
                    responsePayload=upsertTienda(tienda);
                    
                } catch (Exception e) {
                    responsePayload.exito=false;
                    responsePayload.mensajeError='Error: '+e.getMessage()+ e.getLineNumber();
                }
            }
        }
        return responsePayload;
    }
    global static DSALES_TiendaGex.tiendaResponse upsertTienda(DSALES_TiendaGex.tiendaRequest tiendaRecord)
    {
        Tienda__c tienda = new Tienda__c();
        Boolean exito=false;
        String mensaje='';
        String idTienda='';
        string codigoError='';
        List<Tienda__c> tiendaUpsert = new List<Tienda__c>();
        if(!String.isEmpty(tiendaRecord.idTienda)&& tiendaRecord.idTienda!=null)
        {
            tiendaUpsert=[SELECT Id,DSales_TiendaID__c FROM Tienda__c WHERE DSales_TiendaID__c=:tiendaRecord.idTienda LIMIT 1];
        }
        if(tiendaUpsert.size()>0)
            {
                tienda.id=tiendaUpsert[0].id;
                mensaje='Tienda actualizada';
            }
        
            dsalesCiudad__c ciudad= new dsalesCiudad__c();
            dsalesRegion__c region= new dsalesRegion__c();
        dSalesGerente__c gerente= new dSalesGerente__c();
            try {
                region=[SELECT Id,Name,dsalesActivo__c FROM dsalesRegion__c WHERE Name=:tiendaRecord.region LIMIT 1];
                 ciudad=[SELECT Id,Name,dsalesActivo__c,dsalesRegion__c,dsalesRegion__r.Name FROM dsalesCiudad__c WHERE Name=:tiendaRecord.ciudad LIMIT 1];
                gerente=[SELECT Id,Name,dsalesEmailGerenteDeTiendaDeZona__c,dsalesNumeroCelular__c	 FROM dSalesGerente__c WHERE Name=:tiendaRecord.nombreGerente LIMIT 1];
            } catch (Exception e) {
                system.debug('Try catch ciudad/region/gerente: '+e.getMessage());
            }
     	if(!String.isEmpty(tiendaRecord.ciudad) && (!String.isEmpty(tiendaRecord.region) && (!String.isEmpty(tiendaREcord.nombreGerente))))
            {
			 	if(gerente.id==null)
                {
                    gerente.name=tiendaRecord.NombreGerente;
                    gerente.dsalesEmailGerenteDeTiendaDeZona__c=tiendaRecord.emailGerente;
                    gerente.dsalesNumeroCelular__c=tiendaRecord.numeroCelular;
                    if(schema.SObjectType.dsalesRegion__c.isCreateable()){
                                insert gerente;
                                system.debug('Gerente Creado');
                            }
                }
                 
                if(region.id==null)
                {
                    region.name=tiendaRecord.region;
                    region.dsalesActivo__c=true;
                    if(schema.SObjectType.dsalesRegion__c.isCreateable()){
                                insert region;
                                system.debug('Región Creada');
                            }
                }
                if(ciudad.Id==null)
                    {
                        ciudad.dsalesActivo__c=true;
                        ciudad.Name=tiendaRecord.ciudad;
                        ciudad.dsalesRegion__c=region.Id;
                        try{
                            if(schema.SObjectType.dsalesCiudad__c.isCreateable()){
                                insert ciudad;
                                system.debug('Ciudad Creada');
                                 
                            }
                               }
                               catch(Exception e)
                               {
                                   mensaje=DSALES_Utility.INTERNAL_ERROR_MSJ+e.getMessage() + e.getLineNumber();
               						 codigoError=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                               }
                        
                        
                    }
                else{
                     system.debug('Ciudad ya existe');
                    Boolean check=false;
                    if(ciudad.dsalesRegion__c!=null&&!ciudad.dsalesRegion__r.Name.Equals(region.Name))
                    {
                        ciudad.dsalesRegion__c=region.Id;
                        check=true;
                        
                    }
                   else if(ciudad.dsalesRegion__c==null)
                       {
                           ciudad.dsalesRegion__c=region.Id; 
                           check=true;
                       }
                    if(Schema.SobjectType.dsalesCiudad__c.isUpdateable() &&check)
                        {
                            update ciudad;
                            system.debug('Región actualizada');
                            
                        }
                    
                }
                tienda.dsalesCiudad__c=ciudad.id;
                tienda.dSalesGerente__c=gerente.Id;
            }
        tienda.DSales_TiendaID__c=tiendaRecord.idTienda;
        tienda.Activa__c=tiendaRecord.activa;
        tienda.DSALES_Tienda_Base__c= tiendaRecord.tiendaBase;
        tienda.dsalesTelefonoTiendaBase__c=tiendaRecord.telefonoTiendaBase;
        tienda.Name=tiendaRecord.nombreTienda;
        tienda.dsalesDireccion__c=tiendaRecord.direccion;
        tienda.DSALES_Estado__c=tiendaRecord.estado;
       // tienda.DSALES_Region__c=tiendaRecord.region; //picklist
        tienda.dsalesCodigoPostal__c=tiendaRecord.codigoPostal;
        tienda.DSALES_Ciudad__c=tiendaRecord.ciudad;
        tienda.dsalesDivision__c=tiendaRecord.division;
        tienda.dsalesNombreGerenteDeTiendaDeZona__c=tiendaRecord.nombreGerente;
        tienda.dsalesNumeroCelular__c=tiendaRecord.numeroCelular;
        tienda.dsalesEmailGerenteDeTiendaDeZona__c=tiendaRecord.emailGerente;
        tienda.dsalesTelefono__c=tiendaRecord.telefono;
        tienda.DSALES_Optica__c=tiendaRecord.optica;
        tienda.dsalesModuloAfore__c=tiendaRecord.moduloAfore;
        tienda.DSALES_Fechadeapertura__c=tiendaRecord.fechaApertura;
        tienda.dsalesAnoDeUltimaRemodelacion__c=tiendaRecord.ultimaRemodelacion;
        tienda.Tipo_de_Tienda_Inmueble_Renta__c=tiendaRecord.tipoDeTienda;
        tienda.DSALES_Formato__c=tiendaRecord.formato;
        tienda.DSALES_Banco__c=tiendaRecord.banco;
        
        
        try{
            if(schema.SObjectType.Tienda__c.isCreateable() || schema.SObjectType.tienda__c.isUpdateable())
            {
                upsert tienda;
                
            }
            if(String.isEmpty(mensaje))
                {
                     mensaje='Tienda creada';
                }
           
            idTienda=tienda.id;
            exito=true;
            
        }
        catch (Exception e)
            {
                mensaje=DSALES_Utility.INTERNAL_ERROR_MSJ+e.getMessage() + e.getLineNumber();
                codigoError=String.valueOf(DSALES_Utility.INTERNAL_ERROR_CODE);
                
            }
       DSALES_TiendaGex.tiendaResponse responsePayload = new DSALES_TiendaGex.tiendaResponse();     
        responsePayload.mensajeError=mensaje;
        responsePayload.idTienda=idTienda;
        responsePayload.codigoError=codigoError;
        responsePayload.exito=exito;
        
        return responsePayload;
    }
}