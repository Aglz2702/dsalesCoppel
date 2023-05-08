public without sharing class DSALES_ClasificacionServicio {
    
    /*private static final String NOMBRE_OBJETO_CS = 'DSales_ClasificacionDeServicio__c';
    private static final String NOMBRE_SERVICIO_CAT= 'DSALES_accesoCategorias';
    private static final String NOMBRE_SERVICIO_COD= 'DSALES_AccesoCodigos';
    @AuraEnabled
    public static DSALES_ClasificacionServicioWrapper getPickListCategoria(){
        DSALES_ClasificacionServicioWrapper respuesta = new DSALES_ClasificacionServicioWrapper();
        respuesta.listCategorias = new List <PickListOption>();
        respuesta.listSubCategorias = new List <PickListOption>();
        respuesta.listClases = new List <PickListOption>();
        respuesta.listFamilias = new List <PickListOption>();
        respuesta.listServicios = new List <Servicio>();
        if (Schema.sObjectType.DSALES_Categoria__c.isQueryable()) {
            for(DSALES_Categoria__c item: [Select Id, Name From DSALES_Categoria__c order by Name Asc]){
                PicklistOption option = new PicklistOption();
                option.etiqueta = item.Name;
                option.valor = item.Id;
                option.seleccionado = false;
                option.mostrar = true;
                respuesta.listCategorias.add(option);
            }
        }
        
        return respuesta;
    }
    
    @AuraEnabled
    public static DSALES_ClasificacionServicioWrapper getRecords(String allData, String perfilUsuario, String opcion){
        DSALES_ClasificacionServicioWrapper objeto = (DSALES_ClasificacionServicioWrapper) JSON.deserialize(allData, DSALES_ClasificacionServicioWrapper.class);
        List<String> listCategorias = itemSeleccionados(objeto.listCategorias);
        List<String> listSubCategorias = itemSeleccionados(objeto.listSubCategorias);
        List<String> listClases = itemSeleccionados(objeto.listClases);
        List<String> listFamilias = itemSeleccionados(objeto.listFamilias);
        String tipoRegistroId = '';
       if(listCategorias.size() == 0 && listSubCategorias.size() == 0 &&
           listClases.size() == 0 && listFamilias.size() == 0 && opcion!= 'AllRecords'){
               objeto.listServicios = new List<Servicio>();
               return objeto;
           }
        tipoRegistroId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Producto Tangible').getRecordTypeId();
        String producto= 'Producto';
        String query = 'Select Id, Name, StockKeepingUnit, DSALES_Categoria__r.Name, DSALES_SubCategoria__r.Name, DSALES_Clase__r.Name, ';
        query += ' DSALES_Familia__r.Name, DSales_Servicio__c, DSales_Seguro__c, DSALES_TipoServicio__c, DSALES_vehculo__c, DSALES_Noaplica__c, DSALES_NoaplicaServ__c, DSALES_NoaplicaSeg__c, RecordTypeId ';
        query += 'from Product2 Where RecordTypeId = :tipoRegistroId ';
       
        switch on opcion {
            when 'AllRecords' {
                switch on perfilUsuario {
                    when 'Administrador del sistema' {
                        query += 'and DSales_Servicio__c != true and DSales_Seguro__c!= true ';
                    }
                    when 'Seguro de Motos' {
                        query += ' And DSALES_NoaplicaSeg__c = false and DSales_Seguro__c= false ';
                    }
                    when 'Garantía Extendida' {
                        query += ' And DSALES_NoaplicaServ__c = false and DSales_Servicio__c = false ';
                    }
                }
            }
            when else {
                query += listCategorias.size() > 0 ? ' And DSales_Categoria__c in :listCategorias ' : '';
                query += listSubCategorias.size() > 0 ? ' And DSALES_SubCategoria__c in :listSubCategorias ' : '';
                query += listClases.size() > 0 ? ' And DSales_Clase__c in :listClases ' : '';
                query += listFamilias.size() > 0 ? ' And DSALES_Familia__c in :listFamilias ' : '';
            }
        }
        query += '  and DSales_Tipo_de_Producto__c= :producto';
        query += ' order by DSales_Servicio__c asc';
        objeto.listServicios = consultarProductos(DataBase.query(String.escapeSingleQuotes(query)));
        System.debug('Query: '+query);
        return objeto;
    }
    
    @AuraEnabled
    public static List<Servicio> getBuscarSKU(String sku){
        if(String.isBlank(sku)){
            return new List<Servicio>();
        }
        system.debug(sku);
        //String tipoRegistroId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('DSales_Tipo_de_Producto__c').getRecordTypeId();
        String query = 'Select Id, Name, StockKeepingUnit, DSALES_Categoria__r.Name, DSALES_SubCategoria__r.Name, DSALES_Clase__r.Name, ';
        query += ' DSALES_Familia__r.Name, DSales_Servicio__c, DSales_Seguro__c, RecordTypeId, DSALES_vehculo__c, DSALES_TipoServicio__c, DSALES_Noaplica__c, DSALES_NoaplicaServ__c, DSALES_NoaplicaSeg__c ';
        query += 'from Product2 Where StockKeepingUnit LIKE \''+ sku + '%\' OR Name LIKE \'' + sku + '%\'';
        query += ' order by DSales_Servicio__c asc';
        System.debug('Query: '+query);
        return consultarProductos(DataBase.query(query));
    }

    @AuraEnabled
    public static List<AsignarProductos> getBuscarVinculacion(String servicio){
       
        List<AsignarProductos> listasignacion = new List<AsignarProductos>();
        List<Product2> producto= new List<Product2>(); 
        List<Servicio> listServicios = new List<Servicio>();
        if (Schema.sObjectType.product2.isQueryable()) {
            producto= [Select Name, Id from product2 Where Id = :servicio and DSales_Tipo_de_Producto__c= 'Servicio'];
        }
        String idproducto= producto[0].Id;
        if (Schema.sObjectType.DSales_Asignacion_de_Productos__c.isQueryable()) {
            for(DSales_Asignacion_de_Productos__c item: [Select Id, DSales_Producto__c, DSales_NombreProducto__c, DSALES_Departamento__c, DSALES_Subcategoria__c, DSALES_Clase__c,
            DSALES_Familia__c, DSALES_SKU__c, CreatedDate, CreatedBy.Name, DSALES_Activo__c, DSales_Servicio_Seguro__c from DSales_Asignacion_de_Productos__c Where DSales_Producto__c =:idproducto and DSALES_Activo__c=:true order by DSales_NombreProducto__c asc])
            {
                AsignarProductos asignarProductos = new AsignarProductos(); 
                asignarProductos.id = item.Id;
                asignarProductos.nombre = item.DSales_NombreProducto__c;
                asignarProductos.servicio = item.DSales_Producto__c;
                asignarProductos.productoid = item.DSales_Servicio_Seguro__c;
                asignarProductos.sku = item.DSALES_SKU__c;
                asignarProductos.departamento = item.DSALES_Departamento__c;
                asignarProductos.subcategoria = item.DSALES_Subcategoria__c;
                asignarProductos.familia = item.DSALES_Familia__c;
                asignarProductos.clase = item.DSales_Clase__c;
                asignarProductos.creadoPor = item.CreatedBy.Name;
                asignarProductos.createdDate = item.CreatedDate.format();
                asignarProductos.estado = item.DSALES_Activo__c;
                asignarProductos.seleccionadoSku= false;
                listasignacion.add(asignarProductos); 
            }
        }
          
        return listasignacion;
    }
    

    @AuraEnabled
    public static String getidservicio(String sku){
       
        List<Product2> producto= new List<Product2>(); 
        producto= [Select Name, Id, StockKeepingUnit from product2 Where StockKeepingUnit = :sku];
        String idproducto= producto[0].Id;
        return idproducto;
    
    }

    
    @AuraEnabled
    public static List<AsignarProductos> getBuscarProducto(String servicio){
        List<AsignarProductos> listproductos = new List<AsignarProductos>();
        List<String> idproducto= new List<String>();
        List<DSales_Asignacion_de_Productos__c> producto= new List<DSales_Asignacion_de_Productos__c>(); 
        String checkProfile = checkProfileType('Administrador SM');
        Boolean boolserv = false;
        Boolean boolseg = false;
        producto= [Select DSales_Servicio_Seguro__c from DSales_Asignacion_de_Productos__c Where DSALES_Activo__c=true];
        
        for(integer i=0; i<producto.size(); i++)
        {
            idproducto.add(producto[i].DSales_Servicio_Seguro__c);
        }
        if(checkProfile== 'Administrador SM')
        {
            boolserv = false;
            boolseg = true;

        }
        else if (checkProfile== 'Administrador del sistema') {
            boolserv = true;
            boolseg = false;
        }
        else {
            boolserv = true;
            boolseg = false;
        }
        if (Schema.sObjectType.Product2.isQueryable()) {
            for(Product2 item: [Select Id, (Select Id from Asignaciones_de_Productos1__r Where DSales_Producto__c = :servicio and DSALES_Activo__c=false), Name, StockKeepingUnit, DSALES_Categoria__r.Name, DSALES_SubCategoria__r.Name, DSALES_Clase__r.Name,
                DSALES_Familia__r.Name from Product2 Where DSales_Tipo_de_Producto__c= 'Producto' and Id not in :idproducto and isActive = true  and DSALES_Servicio__c = :boolserv and DSALES_Seguro__c= :boolseg WITH SECURITY_ENFORCED order by Name asc])
                {
                    AsignarProductos asignarProductos = new AsignarProductos(); 
                    if(item.Asignaciones_de_Productos1__r.size()>0){
                        asignarProductos.id= item.Asignaciones_de_Productos1__r[0].Id;
                    }
                    asignarProductos.productoid = item.Id;
                    asignarProductos.nombre = item.Name;
                    //asignarProductos.servicio = item.DSales_Producto__c;
                    asignarProductos.sku = item.StockKeepingUnit;
                    asignarProductos.departamento = item.DSALES_Categoria__r.Name;
                    asignarProductos.subcategoria = item.DSALES_SubCategoria__r.Name;
                    asignarProductos.familia = item.DSALES_Familia__r.Name;
                    asignarProductos.clase = item.DSALES_Clase__r.Name;
                    asignarProductos.seleccionadoSku= false;
                    listproductos.add(asignarProductos);   
                }  
        }
        return listproductos;
        
    }

    @AuraEnabled
    public static void upsertVinculacion(String dataJSON){
        system.debug(dataJSON);
        List<AsignarProductos> listSkuSelected= (List<AsignarProductos>) JSON.deserialize(dataJSON, List<AsignarProductos>.class);
       
        List<DSales_Asignacion_de_Productos__c> listUpsertVinculacion = new List<DSales_Asignacion_de_Productos__c>();
        for(AsignarProductos item: listSkuSelected)
        {
           
            if(item.seleccionadoSku)
            {
            listUpsertVinculacion.add(new DSales_Asignacion_de_Productos__c(id=item.id,DSALES_Activo__c=!item.seleccionadoSku));
            }
            
            
        }
        if(Schema.sObjectType.DSales_Asignacion_de_Productos__c.isCreateable() && Schema.sObjectType.DSales_Asignacion_de_Productos__c.isUpdateable()){
            upsert listUpsertVinculacion;
        }
        
        
    }

    @AuraEnabled
    public static void insertVinculacion(String dataJSON,  String idservicio){
        List<AsignarProductos> listIdProductos= (List<AsignarProductos>) JSON.deserialize(dataJSON, List<AsignarProductos>.class);
        List<DSales_Asignacion_de_Productos__c> listInsertVinculacion = new List<DSales_Asignacion_de_Productos__c>();      
        
        
        for(AsignarProductos item: listIdProductos)
        {
           
            if(item.seleccionadoSku)
            {
                listInsertVinculacion.add(new DSales_Asignacion_de_Productos__c(Id=Item.id, DSALES_Servicio_Seguro__c=item.productoid, DSALES_Activo__c=true, DSales_Producto__c= idservicio));
            }
            
            
        }
        if(Schema.sObjectType.DSales_Asignacion_de_Productos__c.isCreateable() && Schema.sObjectType.DSales_Asignacion_de_Productos__c.isUpdateable()){
            upsert listInsertVinculacion;
        }
    }
    
        public static List<Servicio> consultarProductos(List<Product2> listProductos){
        List<Servicio> listServicios = new List<Servicio>();
        for(Product2 item: listProductos){
            Servicio servicio = new Servicio(); 
            
            servicio.id = item.Id;
            servicio.nombre = item.Name;
            servicio.sku = item.StockKeepingUnit;
            servicio.categoria = item.DSALES_Categoria__r.Name;
            servicio.subCategoria = item.DSALES_SubCategoria__r.Name;
            servicio.familia = item.DSALES_Familia__r.Name;
            servicio.clase = item.DSales_Clase__r.Name;
            servicio.servicio = item.DSALES_Servicio__c;
            servicio.seguro = item.DSales_Seguro__c;
            servicio.noAplica = item.DSALES_NoAplica__c;
            servicio.noAplicaServicio = item.DSALES_NoaplicaServ__c;
            servicio.noAplicaSeguro = item.DSALES_NoaplicaSeg__c;
            servicio.tipoServicio = item.DSALES_TipoServicio__c;
            servicio.tipoUso = false;
            servicio.campanas = false;
            servicio.idvehiculo = item.DSALES_vehculo__c;
            listServicios.add(servicio); 
        }
        return listServicios;
    } 
    
    @AuraEnabled
    public static List<String> upsertRecord(String allData){
        List<Servicio> objeto= (List<Servicio>) JSON.deserialize(allData, List<Servicio>.class);
        List<Product2> listProductos= new List<Product2>();
        Map<String, Integer> listProductosServicio= new Map<String, Integer>();
        List<String> tipoServicio= new List<String>();
        List<Object> listaJson = new List<Object>();
        listProductosServicio.putAll(upsertRecordAux(objeto, listProductosServicio));
        listaJson.addAll(upsertRecordAux4(listaJson, listProductosServicio));
        String cuerpoJson = JSON.serialize(listaJson);
        Http https = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:DSALES_AutorizacionToken/'+DSALES_Utility.getEndpoint(NOMBRE_SERVICIO_COD));
        request.setBody(cuerpoJson);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-HTTP-Method-Override','PATCH');
        request.setMethod('PATCH');
        //request.setHeader('Authorization', 'Bearer {!$Credential.Tokensss.AccessToken}');
        //request.setHeader('Authorization', 'Bearer ' + Credential.getName('DSALES_AutorizacionToken').AccessToken);
        HttpResponse response = https.send(request);        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> dataList = (List<Object>) responseMap.get('data');
        Map<Integer, Integer> codeStatusMap = new Map<Integer, Integer>();
        List<Integer> listCompleted= new List<Integer>();
        List<Integer> listError404= new List<Integer>();
        List<Integer> listError500= new List<Integer>();
        List<String> status= new List<String>();
        for (Object data : dataList) {
            Map<String, Object> dataMap = (Map<String, Object>) data;
            Integer code = (Integer) dataMap.get('code');
            Integer statusCode = (Integer) dataMap.get('statusCode');
            if(statusCode==200)
            {
                listCompleted.add(code);
            }
            else if(statusCode==404)
            {
                listError404.add(code);
            }
            else if(statusCode==500)
            {
                listError500.add(code);
            }
            codeStatusMap.put(code, statusCode);
        }
        status=upsertRecordAux3(listError404,listError500);
        system.debug(listCompleted);
        System.debug('Mapa de código y estado: ' + codeStatusMap);
        for(Servicio item: objeto){
            for(integer i=0; i<listCompleted.size(); i++)
            {
                if(listCompleted[i]==integer.valueof(item.sku)){
                    listProductos.add(new Product2(Id = item.id, DSALES_Servicio__c = item.servicio, DSALES_Seguro__c = item.seguro, DSALES_NoAplica__c = item.noAplica, 
                    DSALES_NoaplicaSeg__c= item.noAplicaSeguro, DSALES_NoaplicaServ__c=item.noAplicaServicio, DSALES_IsClasified__c=true, DSALES_vehculo__c = item.idvehiculo)); 
                } 
            }
        }
        if(Schema.sObjectType.Product2.isCreateable() && Schema.sObjectType.Product2.isUpdateable()){
            upsert listProductos; 
        } 
        status.add(String.valueof(response.getStatusCode())) ;       
        return status;
    }
    public static Map<String, Integer> upsertRecordAux(List<Servicio> objeto, Map<String, Integer> listProductosServicio){
        for(Servicio item: objeto){
            if(item.seguro==false && item.servicio==true && item.noAplicaServicio == false && item.noAplicaSeguro== true){
             listProductosServicio.put(item.sku, 2);
            }
            else if(item.seguro==false && item.servicio==true && item.noAplicaServicio == false && item.noAplicaSeguro== false){
             listProductosServicio.put(item.sku, 2);
            }
            else if(item.seguro==true && item.servicio==true && item.noAplicaServicio == false && item.noAplicaSeguro== false){
             listProductosServicio.put(item.sku, 3);
            }
            else if(item.seguro==true && item.servicio==false && item.noAplicaServicio == true && item.noAplicaSeguro== false){
             listProductosServicio.put(item.sku, 1);

            }
            else if(item.seguro==true && item.servicio==false && item.noAplicaServicio == false && item.noAplicaSeguro== false){
             listProductosServicio.put(item.sku, 1);
            }
            listProductosServicio.putAll(upsertRecordAux2(item,listProductosServicio));      
     }
     return listProductosServicio; 
    }

    public static Map<String, Integer> upsertRecordAux2(Servicio item, Map<String, Integer> listProductosServicio){
            if(item.seguro==false && item.servicio==false && item.noAplicaServicio == true && item.noAplicaSeguro== false){
            listProductosServicio.put(item.sku, 0);
           }
           else if(item.seguro==false && item.servicio==false && item.noAplicaServicio == false && item.noAplicaSeguro== true){
            listProductosServicio.put(item.sku, 0);
           }
           else if(item.seguro==false && item.servicio==false && item.noAplicaServicio == true && item.noAplicaSeguro== true){
                listProductosServicio.put(item.sku, 0);
           }
           else if(item.seguro==false && item.servicio==false && item.noAplicaServicio == false && item.noAplicaSeguro== false){
            listProductosServicio.put(item.sku, 0);
           }
           return listProductosServicio;
    }

    public static List<String> upsertRecordAux3(List<Integer> listError404, List<Integer> listError500){
        List<String> status= new List<String> ();
        if(listError404.size()>0){
            if(listError500.size()>0){
                status.add('Error 404 "No se encontró el recurso solicitado" en: '+listError404+ ', Error 500 en: ' +listError500);
            }
            status.add('Error 404 "No se encontró el recurso solicitado" en: '+listError404);
        }
        else if(listError500.size()>0){
            if(listError404.size()>0){
                status.add('Error 500 en: '+listError404+ ', Error 404 "No se encontró el recurso solicitado" en: ' +listError500);
            }
            status.add('Error 500 en: '+listError500);
        }
        else{
            status.add('sin errores');
        }
        return status;
    }

    public static List<Object> upsertRecordAux4(List<Object> listaJson , Map<String, Integer> listProductosServicio){
        for(String sku : listProductosServicio.keySet()) {
            Integer codigoServicio = Integer.valueOf(listProductosServicio.get(sku));
            listaJson.add(new Map<String, Object>{'codigo' => integer.valueof(sku), 'codigoServicio' => integer.valueof(codigoServicio)});
        }
        return listaJson;
    }

    public static List<String> itemSeleccionados(List<PicklistOption> listPickList){
        List<String> listItems = new List <String>();
        for(PicklistOption item: listPickList){
            if(item.seleccionado){
                listItems.add(item.valor);
            }
        }
        return listItems;
    }
          

    @AuraEnabled
    public static DSALES_ClasificacionServicioWrapper getPicklistOptionsDependent(String allData){
        DSALES_ClasificacionServicioWrapper objeto = (DSALES_ClasificacionServicioWrapper) JSON.deserialize(allData, DSALES_ClasificacionServicioWrapper.class);
        DSALES_ClasificacionServicioWrapper objetoNuevo = (DSALES_ClasificacionServicioWrapper) JSON.deserialize(allData, DSALES_ClasificacionServicioWrapper.class);
        List<String> campos = new List<String>();
        objetoNuevo.listSubCategorias = new List <PickListOption>();
        objetoNuevo.listClases = new List <PickListOption>();
        objetoNuevo.listFamilias = new List <PickListOption>();
        
        List<String> listCategorias = itemSeleccionados(objeto.listCategorias);
        List<String> listSubCategorias = itemSeleccionados(objeto.listSubCategorias);
        List<String> listClases = itemSeleccionados(objeto.listClases);
        if (Schema.sObjectType.DSALES_SubCategoria__c.isQueryable()) {
            for(DSALES_SubCategoria__c item: [Select Id, Name,DSALES_Categoria__c from DSALES_SubCategoria__c Where DSALES_Categoria__c in : listCategorias order by Name]){
                PicklistOption option = new PicklistOption();
                option.etiqueta = item.Name;
                option.valor = item.Id;
                option.depende = item.DSALES_Categoria__c;
                option.seleccionado = false;
                option.mostrar = true;
                objetoNuevo.listSubCategorias.add(option);
            }
        }
        for(PicklistOption item: objeto.listSubCategorias){
            for(PicklistOption itemNuevo: objetoNuevo.listSubCategorias){
                if(item.valor == itemNuevo.valor){
                    itemNuevo.seleccionado = item.seleccionado;
                    itemNuevo.mostrar = item.mostrar;
                }
            }
        }
        if (Schema.sObjectType.DSALES_Clase__c.isQueryable()) {
            for(DSALES_Clase__c item: [Select Id, Name,DSALES_SubCategoria__c from DSALES_Clase__c Where DSALES_SubCategoria__c in : listSubCategorias order by Name]){
                PicklistOption option = new PicklistOption();
                option.etiqueta = item.Name;
                option.valor = item.Id;
                option.depende = item.DSALES_SubCategoria__c;
                option.seleccionado = false;
                option.mostrar = true;
                objetoNuevo.listClases.add(option);
            }
        } 
        getPicklistOptionsDependentAuxiliar(objeto, objetoNuevo, listClases);
        return objetoNuevo;
    }
    
    public static void getPicklistOptionsDependentAuxiliar(DSALES_ClasificacionServicioWrapper objeto, DSALES_ClasificacionServicioWrapper objetoNuevo, List<String> listClases){
        for(PicklistOption item: objeto.listClases){
            for(PicklistOption itemNuevo: objetoNuevo.listClases){
                if(item.valor == itemNuevo.valor){
                    itemNuevo.seleccionado = item.seleccionado;
                    itemNuevo.mostrar = item.mostrar;
                }
            }
        }
        if (Schema.sObjectType.DSALES_Familia__c.isQueryable()) {
            for(DSALES_Familia__c item: [Select Id, Name,DSALES_Clase__c from DSALES_Familia__c Where DSALES_Clase__c in : listClases order by Name]){
                PicklistOption option = new PicklistOption();
                option.etiqueta = item.Name;
                option.valor = item.Id;
                option.depende = item.DSALES_Clase__c;
                option.seleccionado = false;
                option.mostrar = true;
                objetoNuevo.listFamilias.add(option);
            }
        }
        getPicklistOptionsDependentFamily(objeto, objetoNuevo);
    }
    public static void getPicklistOptionsDependentFamily(DSALES_ClasificacionServicioWrapper objeto, DSALES_ClasificacionServicioWrapper objetoNuevo){
        for(PicklistOption item: objeto.listFamilias){
            for(PicklistOption itemNuevo: objetoNuevo.listFamilias){
                if(item.valor == itemNuevo.valor){
                    itemNuevo.seleccionado = item.seleccionado;
                    itemNuevo.mostrar = item.mostrar;
                }
            }
        }
    }

    @AuraEnabled
    public static String checkProfileType(string profile)
    {
        Id id1 = UserInfo.getProfileId(); 
        if (Schema.sObjectType.Profile.isQueryable()) {
            Profile perfilSM = [SELECT id From Profile WHERE Name =: profile LIMIT 1];
            Profile perfilAdmi = [SELECT id From Profile WHERE Name = 'Administrador del sistema' LIMIT 1];
            if(perfilAdmi.Id== id1)
            {
                return 'Administrador del sistema';
            }
            else {
            if(id1 == perfilSM.Id)
            {
                return profile;	
            }
            else
            {
                return 'No corresponde';        
            }
            }
        }
        else{
            return 'No corresponde';  
        }
       
    }

    @AuraEnabled
    public static List<PicklistOp> getcategories(string recordName){        
        List<PicklistOp> listcategories = new List<PicklistOp>();
        for(DSALES_Categoria__c item: [Select Id, Name From DSALES_Categoria__c where RecordType.name=: recordName])
    {
        PicklistOp p = new PicklistOp();
        p.label= item.name;
        p.value = item.Id;
        listcategories.add(p);
    }  
        return listcategories;
    }

    @AuraEnabled
    public static List<PicklistOp> getserviciocategorias(String recordName){   
        List<String> categoriasNombres = new List<String>();
        List<String> categoriasIds = new List<String>();
        Http https = new Http();
        HttpRequest request = new HttpRequest();
        Blob credential= Blob.valueOf(DSALES_obtenerToken.getToken());
        String authorizationHeader = 'Bearer ' + '{!$Credential.Tokensss.AccessToken}';

        request.setEndpoint(DSALES_Utility.getEndpoint(NOMBRE_SERVICIO_CAT));
        request.setHeader('Authorization', authorizationHeader);
        //request.setEndpoint('callout:AutorizacionToken2/some_path');
        //request.setEndpoint('callout:DSALES_AutorizacionToken2');
        //request.setHeader('Authorization',  EncodingUtil.base64Decode(authorizationHeader));
        request.setMethod('GET');
        system.debug('request: '+ request);
        HttpResponse response = https.send(request);
        system.debug('response '+response);
        if (response.getStatusCode() == 200) {
            Map<String, Object> respuesta = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> categoriasObj = (List<Object>) respuesta.get('data');
            system.debug('respuesta: ' + respuesta);
            for (Object categoria : categoriasObj) {
                Map<String, Object> categoriaMap = (Map<String, Object>) categoria;
                categoriasNombres.add(String.valueOf(categoriaMap.get('nombre')));
                categoriasIds.add(String.valueOf(categoriaMap.get('id')));
            }
            System.debug('Categorías nombres: ' + categoriasNombres);
            System.debug('Categorías ids: ' + categoriasIds);
        } 
        else {
            System.debug('Error al obtener la respuesta: ' + response.getBody());
            }    
        List<PicklistOp> listcategories = new List<PicklistOp>();
        for(Integer i=0; i<categoriasNombres.size(); i++)
        {
            PicklistOp p = new PicklistOp();
            p.label= categoriasNombres[i];
            p.value = categoriasIds[i];
            listcategories.add(p);
        }  
        return listcategories;
    }

    @AuraEnabled
    public static List<PicklistOp> getserviciosubcategorias(String valueCategoria){   
        List<String> subcategoriasNombres = new List<String>();
        List<String> subcategoriasIds = new List<String>();
        Http https = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(DSALES_Utility.getEndpoint(NOMBRE_SERVICIO_CAT)+'/'+valueCategoria+'/subcategorias');
        request.setHeader('Authorization','Bearer '+DSALES_obtenerToken.getToken());
        request.setMethod('GET');
        HttpResponse response = https.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> respuesta = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> categoriasObj = (List<Object>) respuesta.get('data');
            system.debug('respuesta: ' + respuesta);
            for (Object categoria : categoriasObj) {
                Map<String, Object> categoriaMap = (Map<String, Object>) categoria;
                subcategoriasNombres.add(String.valueOf(categoriaMap.get('nombre')));
                subcategoriasIds.add(String.valueOf(categoriaMap.get('id')));
            }
            System.debug('Categorías nombres: ' + subcategoriasNombres);
            System.debug('Categorías ids: ' + subcategoriasIds);
        } 
        else {
            System.debug('Error al obtener la respuesta: ' + response.getBody());
            }    
        List<PicklistOp> listsubcategories = new List<PicklistOp>();
        for(Integer i=0; i<subcategoriasNombres.size(); i++)
        {
            PicklistOp p = new PicklistOp();
            p.label= subcategoriasNombres[i];
            p.value = subcategoriasIds[i];
            listsubcategories.add(p);
        }  
        return listsubcategories;
    }

    @AuraEnabled
    public static List<PicklistOp> getservicioclase(String valueCategoria, String valueSubcategoria){   
        List<String> clasesNombres = new List<String>();
        List<String> clasesIds = new List<String>();
        Http https = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(DSALES_Utility.getEndpoint(NOMBRE_SERVICIO_CAT)+'/'+valueCategoria+'/subcategorias/'+valueSubcategoria+'/clase');
        request.setHeader('Authorization','Bearer '+DSALES_obtenerToken.getToken());
        request.setMethod('GET');
        HttpResponse response = https.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> respuesta = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> categoriasObj = (List<Object>) respuesta.get('data');
            system.debug('respuesta: ' + respuesta);
            for (Object categoria : categoriasObj) {
                Map<String, Object> categoriaMap = (Map<String, Object>) categoria;
                clasesNombres.add(String.valueOf(categoriaMap.get('nombre')));
                clasesIds.add(String.valueOf(categoriaMap.get('id')));
            }
            System.debug('Categorías nombres: ' + clasesNombres);
            System.debug('Categorías ids: ' + clasesIds);
        } 
        else {
            System.debug('Error al obtener la respuesta: ' + response.getBody());
            }    
        List<PicklistOp> listclases = new List<PicklistOp>();
        for(Integer i=0; i<clasesNombres.size(); i++)
        {
            PicklistOp p = new PicklistOp();
            p.label= clasesNombres[i];
            p.value = clasesIds[i];
            listclases.add(p);
        }  
        return listclases;
    }

    @AuraEnabled
    public static List<PicklistOp> getserviciofamilia(String valueCategoria, String valueSubcategoria, String valueClases){   
        List<String> familiasNombres = new List<String>();
        List<String> familiasIds = new List<String>();
        Http https = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(DSALES_Utility.getEndpoint(NOMBRE_SERVICIO_CAT)+'/'+valueCategoria+'/subcategorias/'+valueSubcategoria+'/clase/'+valueClases+'/familias');
        request.setHeader('Authorization','Bearer '+DSALES_obtenerToken.getToken());
        request.setMethod('GET');
        HttpResponse response = https.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> respuesta = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> categoriasObj = (List<Object>) respuesta.get('data');
            system.debug('respuesta: ' + respuesta);
            for (Object categoria : categoriasObj) {
                Map<String, Object> categoriaMap = (Map<String, Object>) categoria;
                familiasNombres.add(String.valueOf(categoriaMap.get('nombre')));
                familiasIds.add(String.valueOf(categoriaMap.get('id')));
            }
            System.debug('Categorías nombres: ' + familiasNombres);
            System.debug('Categorías ids: ' + familiasIds);
        } 
        else {
            System.debug('Error al obtener la respuesta: ' + response.getBody());
            }    
        List<PicklistOp> listfamilias = new List<PicklistOp>();
        for(Integer i=0; i<familiasNombres.size(); i++)
        {
            PicklistOp p = new PicklistOp();
            p.label= familiasNombres[i];
            p.value = familiasIds[i];
            listfamilias.add(p);
        }  
        return listfamilias;
    }

    @AuraEnabled
    public static List<AsignarProductos> getserviciosku(String valueCategoria, String valueSubcategoria, List<String> valueClasesFamilias){   
        List<String> skus = new List<String>();
        List<String> skusNombres = new List<String>();
        List<String> tiposervicio= new  List<String>();
        List<String> descripcion= new  List<String>();
        String nombreTipoServicio;
        Http https = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(DSALES_Utility.getEndpoint(NOMBRE_SERVICIO_CAT)+'/'+valueCategoria+'/subcategorias/'+valueSubcategoria+'/clase/'+valueClasesFamilias+'/familias/'+valueClasesFamilias+'/codigos');
        request.setHeader('Authorization','Bearer '+DSALES_obtenerToken.getToken());
        request.setMethod('GET');
        HttpResponse response = https.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> respuesta = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> categoriasObj = (List<Object>) respuesta.get('data');
            system.debug('respuesta: ' + respuesta);
            for (Object categoria : categoriasObj) {
                Map<String, Object> categoriaMap = (Map<String, Object>) categoria;
                tiposervicio.add(String.valueOf(categoriaMap.get('codigoServicio')));
                skus.add(String.valueOf(categoriaMap.get('codigo')));
                skusNombres.add(String.valueOf(categoriaMap.get('articulo')));
                descripcion.add(String.valueOf(categoriaMap.get('descripcionCompleta')));

            }
        } 
        else {
            System.debug('Error al obtener la respuesta: ' + response.getBody());
            }    
        List<AsignarProductos> listskus = new List<AsignarProductos>();
        for(Integer i=0; i<skusNombres.size(); i++)
        {
            if(tiposervicio[i]=='0') {
                nombreTipoServicio='No aplica';
            }
            else if (tiposervicio[i]=='1') {
                nombreTipoServicio='Seguros';
            }
            else if (tiposervicio[i]=='2') {
                nombreTipoServicio='Servicios';
            }
            else if (tiposervicio[i]=='3') {
                nombreTipoServicio='Seguros y Servicios';
            }
            AsignarProductos p = new AsignarProductos();
            p.nombre= skusNombres[i];
            p.sku= skus[i];
            p.servicio= nombreTipoServicio;
            p.descripcion=descripcion[i];
            listskus.add(p);
        }  
        return listskus;
    }

    @AuraEnabled
    public static List<PicklistOp> getSubCategories(string valueCategoria){

        List<PicklistOp> listSubCategories = new List<PicklistOp>();
        if (Schema.sObjectType.DSALES_SubCategoria__c.isQueryable()) {
            for(DSALES_SubCategoria__c item: [Select Id, Name,DSALES_Categoria__c from DSALES_SubCategoria__c Where DSALES_Categoria__c =:valueCategoria])
            {
                PicklistOp option = new PicklistOp();
                option.label= item.name;
                option.value = item.Id;
                listSubCategories.add(option);
            }  
        }
        return listSubCategories;
    }

    @AuraEnabled
    public static List<PicklistOp> getClases(string valueCategoria){

        List<PicklistOp> listClases = new List<PicklistOp>();
        System.debug(valueCategoria);
        if (Schema.sObjectType.DSALES_Clase__c.isQueryable()) {
            for(DSALES_Clase__c item: [Select Id, Name from DSALES_Clase__c where DSALES_SubCategoria__c=: valueCategoria])
            {
                PicklistOp option = new PicklistOp();
                option.label= item.name;
                option.value = item.Id;
                listClases.add(option);
            }  
        }
        return listClases;
    }

    @AuraEnabled
    public static List<PicklistOp> getFamilias(string valueClases){

        List<PicklistOp> listFamilias = new List<PicklistOp>();
        if (Schema.sObjectType.DSALES_Familia__c.isQueryable()) {
            for(DSALES_Familia__c item: [Select Id, Name,DSALES_Clase__c from DSALES_Familia__c Where DSALES_Clase__c =:valueClases])
            {
                PicklistOp option = new PicklistOp();
                option.label= item.name;
                option.value = item.Id;
                listFamilias.add(option);
            }  
        }
        return listFamilias;
    }
    
    @AuraEnabled
    public static List<Servicio> getMatriz(){

        List<Servicio>listMatrices = new List<Servicio>();
        if (Schema.sObjectType.DSales_Matriz_GEX__c.isQueryable()) {
            for(DSales_Matriz_GEX__c item: [Select Id, Name, DSALES_Servicio__c, DSALES_Tipo__c from DSales_Matriz_GEX__c where DSALES_Servicio__c= '' and DSALES_Tipo__c = 'Matriz Original'])
            {
                Servicio a = new Servicio();
                a.tipoServicio= item.DSALES_Servicio__c;
                a.tipoMatriz= item.DSALES_Tipo__c;
                a.label= item.name;
                a.value = item.Id;
        
                listMatrices.add(a);
            }  
        }
        return listMatrices;
    }

    @AuraEnabled
    public static void updateMatriz(String allData, String typeServicio){
        List<String> objetoMatrices = (List<String>) JSON.deserialize(allData, List<String>.class);
        List<DSales_Matriz_GEX__c> listMatrizSelected= new List<DSales_Matriz_GEX__c>();
      
        for(Integer i=0; objetoMatrices.size()>i; i++)
        {
            listMatrizSelected.add(new DSales_Matriz_GEX__c(Id = objetoMatrices[i], DSALES_Servicio__c=typeServicio));
        }
        if(Schema.sObjectType.DSales_Matriz_GEX__c.isCreateable() && Schema.sObjectType.DSales_Matriz_GEX__c.isUpdateable()){
            upsert listMatrizSelected;
        }
        
        
    }

    @AuraEnabled
    public static List<Servicio> getCampaings(){
        List<Servicio>listCampaigns = new List<Servicio>();
        if (Schema.sObjectType.Campaign.isQueryable()) {
            for(Campaign item: [Select Id, Name from Campaign where IsActive = true])
            {
                Servicio b = new Servicio();
                b.label= item.Name;
                b.value= item.Id;
                listCampaigns.add(b);
            }   
        }
        return listCampaigns;
    }

    @AuraEnabled
    public static List<Servicio> getTipoUso(){
        List<Servicio>listTipoUso = new List<Servicio>();
        if (Schema.sObjectType.DSALES_TipodeUso__c.isQueryable()) {
            for(DSALES_TipodeUso__c item: [Select Id, Name from DSALES_TipodeUso__c where DSALES_Activo__c = true])
            {
                Servicio b = new Servicio();
                b.label= item.Name;
                b.value= item.Id;
                listTipoUso.add(b);
            }  
        }
        
        return listTipoUso;
    }

    @AuraEnabled
    public static void updateCampaigns(String allData, String idProducto){
        List<String> objetoCampaings = (List<String>) JSON.deserialize(allData, List<String>.class);
        List<String> listCampanasSelected= new List<String>();
        List<Servicio> listCampanasSelectedidvalue= new List<Servicio>();
        List<DSALES_AsociacionCampanias__c> listCampanasSeleccion= new List<DSALES_AsociacionCampanias__c>();
        if (Schema.sObjectType.DSALES_AsociacionCampanias__c.isQueryable()) {
            for(DSALES_AsociacionCampanias__c item: [Select id, DSALES_Campania__c  from DSALES_AsociacionCampanias__c where DSALES_Producto__c= :idProducto ])
            {
                listCampanasSelected.add(item.DSALES_Campania__c);
                Servicio b= new Servicio();
                b.id=item.id;
                b.value=item.DSALES_Campania__c ;
                listCampanasSelectedidvalue.add(b);
            }  
        }
        List<String> newList= new List<String>();
        for (String element : objetoCampaings) { 
            if (!listCampanasSelected.contains(element)) { 
                newList.add(element); 
            } 
        }   
        for(Integer i=0; newList.size()>i; i++)
        {
            listCampanasSeleccion.add(new DSALES_AsociacionCampanias__c(DSALES_Campania__c = newList[i], DSALES_Producto__c=idProducto, DSALES_Activo__c=true));
        }
       for(Servicio item: listCampanasSelectedidvalue){
            if(objetoCampaings.contains(item.value))
            {
                listCampanasSeleccion.add(new DSALES_AsociacionCampanias__c(id=item.id, DSALES_Campania__c = item.value, DSALES_Producto__c=idProducto, DSALES_Activo__c=true));
            }
            else
            {
                listCampanasSeleccion.add(new DSALES_AsociacionCampanias__c(id=item.id, DSALES_Campania__c = item.value, DSALES_Producto__c=idProducto, DSALES_Activo__c=false));
            }
        }
        if(Schema.sObjectType.DSALES_AsociacionCampanias__c.isCreateable() && Schema.sObjectType.DSALES_AsociacionCampanias__c.isUpdateable()){
            upsert listCampanasSeleccion; 
        }
        
    }

    @AuraEnabled
    public static void updateTipoUso(String allData, String idProducto){
        List<String> objetoTipoUso = (List<String>) JSON.deserialize(allData, List<String>.class);
        List<String> listTipoUsoSelected= new List<String>();
        List<Servicio> listTipoUsoSelectedidvalue= new List<Servicio>();
        List<DSALES_AsociacionTiposUso__c> listTipoUsoSeleccion= new List<DSALES_AsociacionTiposUso__c>();
        if (Schema.sObjectType.DSALES_AsociacionTiposUso__c.isQueryable()) {
            for(DSALES_AsociacionTiposUso__c item: [Select id, DSALES_TipodeUso__c from DSALES_AsociacionTiposUso__c where DSALES_Producto__c= :idProducto])
            {
                listTipoUsoSelected.add(item.DSALES_TipodeUso__c);
                Servicio b= new Servicio();
                b.id=item.id;
                b.value=item.DSALES_TipodeUso__c;
                listTipoUsoSelectedidvalue.add(b);
            }  
        }
        List<String> newList= new List<String>();
        for (String element : objetoTipoUso) { 
            if (!listTipoUsoSelected.contains(element)) { 
                newList.add(element); 
            } 
        }   
        for(Integer i=0; newList.size()>i; i++)
        {
            listTipoUsoSeleccion.add(new DSALES_AsociacionTiposUso__c(DSALES_TipodeUso__c = newList[i], DSALES_Producto__c=idProducto, DSALES_Activo__c=true));
        }
       for(Servicio item: listTipoUsoSelectedidvalue){
            if(objetoTipoUso.contains(item.value))
            {
                listTipoUsoSeleccion.add(new DSALES_AsociacionTiposUso__c(id=item.id, DSALES_TipodeUso__c = item.value, DSALES_Producto__c=idProducto, DSALES_Activo__c=true));
            }
            else
            {
                listTipoUsoSeleccion.add(new DSALES_AsociacionTiposUso__c(id=item.id, DSALES_TipodeUso__c = item.value, DSALES_Producto__c=idProducto, DSALES_Activo__c=false));
            }
        }
        if(Schema.sObjectType.DSALES_AsociacionTiposUso__c.isCreateable() && Schema.sObjectType.DSALES_AsociacionTiposUso__c.isUpdateable()){
            upsert listTipoUsoSeleccion; 
        }
    }
 
    @AuraEnabled
    public static List<String> getTiposUsoUsed(String idProducto){

        List<String> listTipoUsoUsed = new List<String>();
        if (Schema.sObjectType.DSALES_AsociacionTiposUso__c.isQueryable()) {
            for(DSALES_AsociacionTiposUso__c item: [Select DSALES_TipodeUso__c from DSALES_AsociacionTiposUso__c where DSALES_Producto__c=:idProducto and DSALES_Activo__c=true])
            {
                listTipoUsoUsed.add(item.DSALES_TipodeUso__c);
            }  
        }
        return listTipoUsoUsed;
    }

    @AuraEnabled
    public static List<String> getCampanasUsed(String idProducto){

        List<String> listCampanasUsed = new List<String>();
        if (Schema.sObjectType.DSALES_AsociacionCampanias__c.isQueryable()) {
            for(DSALES_AsociacionCampanias__c item: [Select DSALES_Campania__c from DSALES_AsociacionCampanias__c where DSALES_Producto__c=:idProducto and DSALES_Activo__c=true])
            {
                listCampanasUsed.add(item.DSALES_Campania__c);
            }  
        }  
        return listCampanasUsed;
    }
 
    @AuraEnabled
    public static void insertListaPrecios(String idproductoservicio, String opcion, String json2){
        system.debug(json2);
        List<Servicio> listaPreciosSelected = (List<Servicio>) JSON.deserialize(json2, List<Servicio>.class);
        List<Pricebook2> idlistaprecios= new List<Pricebook2>(); 
        if (Schema.sObjectType.Pricebook2.isQueryable()) {
            idlistaprecios= [select id, name, IsStandard from Pricebook2 where  name= 'Standard Price Book' limit 1];
        }
        String idprecios= idlistaprecios[0].Id;
        List<PricebookEntry> listPrices= new List<PricebookEntry>();
        if(opcion=='1')
        {
        listPrices.add(new PricebookEntry(Product2Id = idproductoservicio, Pricebook2Id=idprecios, IsActive=true, UnitPrice=1));
        if(Schema.sObjectType.PricebookEntry.isCreateable()) {
            insert listPrices;
        }
        }
        else {
            for(Servicio item:listaPreciosSelected){
                if(item.servicio==true || item.seguro==true){
                    listPrices.add(new PricebookEntry(Product2Id = item.id, Pricebook2Id=idprecios, IsActive=true, UnitPrice=1));
                }
            }
            if(Schema.sObjectType.PricebookEntry.isCreateable()) {
                insert listPrices;
            }
        }   
    }

    @AuraEnabled
    public static List<PicklistOp> getPickListValuesIntoList1(){
        List<PicklistOp> pickListValuesList1= new List<PicklistOp>();
        Schema.DescribeFieldResult fieldResult = Product2.DSALES_ServicioSeguro__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            PicklistOp option = new PicklistOp();
            option.label= pickListVal.getLabel();
            option.value = pickListVal.getValue();
            pickListValuesList1.add(option);
        }
        return pickListValuesList1;
    }

        @AuraEnabled
        public static List<PicklistOp> getPickListValuesIntoList2(){
            List<PicklistOp> pickListValuesList2= new List<PicklistOp>();
            Schema.DescribeFieldResult fieldResult = Product2.DSALES_ServEspecifico__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                PicklistOp option = new PicklistOp();
                option.label= pickListVal.getLabel();
                option.value = pickListVal.getValue();
                pickListValuesList2.add(option);
            }
            return pickListValuesList2;
        }

        @AuraEnabled
        public static List<PicklistOp> getPickListValuesIntoList3(){
            List<PicklistOp> pickListValuesList3= new List<PicklistOp>();
            Schema.DescribeFieldResult fieldResult = Product2.DSALES_Matriz__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                PicklistOp option = new PicklistOp();
                option.label= pickListVal.getLabel();
                option.value = pickListVal.getValue();
                pickListValuesList3.add(option);
            }
            return pickListValuesList3;
        }

        @AuraEnabled
        public static List<PicklistOp> getPickListValuesIntoList4(){
            List<PicklistOp> pickListValuesList4= new List<PicklistOp>();
            Schema.DescribeFieldResult fieldResult = Product2.DSALES_SegEspecifico__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                PicklistOp option = new PicklistOp();
                option.label= pickListVal.getLabel();
                option.value = pickListVal.getValue();
                pickListValuesList4.add(option);
            }
            return pickListValuesList4;
        }
                    
    @AuraEnabled
    public static Product2 createProductIntan(Product2 productIntan, String sku){
        try{
            insert productIntan;
            return productIntan;  
        }
        catch(Exception e){  
        throw new AuraHandledException(e.getMessage());
    }               
    }

    @AuraEnabled
    public static String recordTypeId(String tipoRegistro){
        try{
            String tipoRegistroId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(tipoRegistro).getRecordTypeId();
            return tipoRegistroId;
        }
        catch(Exception e){   
        throw new AuraHandledException(e.getMessage());
    }               
    }

    @AuraEnabled
    public static void insertPocentajeCobro(String idservicio, String jsonp){
       String listPorc= '['+jsonp+ ']';
       List<PorcentajesCobro> listaPorcentajes = (List<PorcentajesCobro>) JSON.deserialize(listPorc, List<PorcentajesCobro>.class);
       system.debug(listPorc);
       system.debug(listaPorcentajes);
       List<DASALES_Porcentajedecobro__c> listInsertPorcentajes= new List <DASALES_Porcentajedecobro__c>();
        for(PorcentajesCobro item: listaPorcentajes)
        {
            if(item.anio1!= 0){
                listInsertPorcentajes.add(new DASALES_Porcentajedecobro__c(DSALES_Anios__c=1, DSALES_Porcentaje__c=item.anio1, DSALES_Product__c= idservicio));
            }

            if(item.anio2!= 0){
                listInsertPorcentajes.add(new DASALES_Porcentajedecobro__c(DSALES_Anios__c=2, DSALES_Porcentaje__c=item.anio2, DSALES_Product__c= idservicio));
            }

            if(item.anio3!=  0){
                listInsertPorcentajes.add(new DASALES_Porcentajedecobro__c(DSALES_Anios__c=3, DSALES_Porcentaje__c=item.anio3, DSALES_Product__c= idservicio));
            }

            if(item.anio4!=  0){
                listInsertPorcentajes.add(new DASALES_Porcentajedecobro__c(DSALES_Anios__c=4, DSALES_Porcentaje__c=item.anio4, DSALES_Product__c= idservicio));
            }

            if(item.anio5!=  0){
                listInsertPorcentajes.add(new DASALES_Porcentajedecobro__c(DSALES_Anios__c=5, DSALES_Porcentaje__c=item.anio5, DSALES_Product__c= idservicio));
            }

            if(item.anio6!=  0){
                listInsertPorcentajes.add(new DASALES_Porcentajedecobro__c(DSALES_Anios__c=6, DSALES_Porcentaje__c=item.anio6, DSALES_Product__c= idservicio));
            }
        }
        if(Schema.sObjectType.DASALES_Porcentajedecobro__c.isCreateable()) {
            insert listInsertPorcentajes;
        }                   
    }     

    @AuraEnabled
    public static DSales_Asignacion_de_Productos__c createVinculacion(DSales_Asignacion_de_Productos__c asignacion){  
        try{
            insert asignacion;
            return asignacion;
        }
        catch(Exception e){
        throw new AuraHandledException(e.getMessage());
    }
                    
    }     

    public class PickListOp{
        @AuraEnabled public String  value;
        @AuraEnabled public String  label;
        @AuraEnabled public String  depende;
        @AuraEnabled public String  seleccionado;
        
    }

    public class DSALES_ClasificacionServicioWrapper{
        @AuraEnabled public List <PickListOption> listCategorias{get;set;}
        @AuraEnabled public List <PickListOption> listSubCategorias{get;set;}
        @AuraEnabled public List <PickListOption> listClases{get;set;}
        @AuraEnabled public List <PickListOption> listFamilias{get;set;}        
        @AuraEnabled public List <Servicio> listServicios{get;set;}  
        @AuraEnabled public String sku;
    }

    public class PickListOption{
        @AuraEnabled public String etiqueta;
        @AuraEnabled public String valor;
        @AuraEnabled public String depende;
        @AuraEnabled public Boolean seleccionado;
        @AuraEnabled public Boolean mostrar;
    }
    
    public class Servicio{
        @AuraEnabled public String id;
        @AuraEnabled public String nombre;
        @AuraEnabled public String sku;
        @AuraEnabled public String categoria;
        @AuraEnabled public String subCategoria;
        @AuraEnabled public String clase;
        @AuraEnabled public String familia;
        @AuraEnabled public Boolean servicio;
        @AuraEnabled public Boolean seguro;
        @AuraEnabled public Boolean noAplica; 
        @AuraEnabled public Boolean noAplicaServicio;
        @AuraEnabled public Boolean noAplicaSeguro;
        @AuraEnabled public String tipoServicio;
        @AuraEnabled public String tipoMatriz;
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String recordId;
        @AuraEnabled public Boolean tipoUso;
        @AuraEnabled public Boolean campanas;
        @AuraEnabled public String idvehiculo;

    }

    public class AsignarProductos{
        @AuraEnabled public String id;
        @AuraEnabled public String nombre;
        @AuraEnabled public String servicio;
        @AuraEnabled public String productoid;
        @AuraEnabled public String sku;
        @AuraEnabled public String departamento;
        @AuraEnabled public String subcategoria;
        @AuraEnabled public String clase;
        @AuraEnabled public String familia;
        @AuraEnabled public String creadoPor;
        @AuraEnabled public String createdDate;
        @AuraEnabled public Boolean estado;
        @AuraEnabled public Boolean seleccionadoSku;
        @AuraEnabled public String idasignacion;  
        @AuraEnabled public String descripcion;  
    }

    public class PorcentajesCobro{
        @AuraEnabled public integer anio1;
        @AuraEnabled public integer anio2;
        @AuraEnabled public integer anio3;
        @AuraEnabled public integer anio4;
        @AuraEnabled public integer anio5;
        @AuraEnabled public integer anio6;      
    }*/
}