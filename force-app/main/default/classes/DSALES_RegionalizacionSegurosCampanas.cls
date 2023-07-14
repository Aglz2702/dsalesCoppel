public without sharing class DSALES_RegionalizacionSegurosCampanas {

    @AuraEnabled
    public static DSALES_ClasificacionServicioWrapper getPickListRegiones(){
        DSALES_ClasificacionServicioWrapper respuesta = new DSALES_ClasificacionServicioWrapper();
        respuesta.listRegiones = new List <PickListOption>();
        respuesta.listCiudades = new List <PickListOption>();
        respuesta.listTiendas = new List <PickListOption>();
        if (Schema.sObjectType.dsalesRegion__c.isQueryable()) {
            for(dsalesRegion__c item: [Select Id, name From dsalesRegion__c where dsalesActivo__c= true order by Name Asc]){
                PicklistOption option = new PicklistOption();
                option.etiqueta = item.name;
                option.valor = item.Id;
                option.seleccionado = false;
                option.mostrar = true;
                respuesta.listRegiones.add(option);
            }
        }
        
        return respuesta;
    }

    @AuraEnabled
    public static  List<PickListOption>  getPickListTiendas(string idCampana){
        List<PickListOption>  respuesta = new  List<PickListOption> ();
        for(dsalesAsignacionDeTienda__c item: [Select Id, dsalesTienda__r.name, dsalesTienda__c,LastModifiedBy.Name, dsalesActivo__c, dsalesCampana__c from dsalesAsignacionDeTienda__c Where dsalesCampana__c =:idCampana and dsalesActivo__c=true WITH SECURITY_ENFORCED order by Name asc]){
            PicklistOption option = new PicklistOption();
            option.etiqueta = item.dsalesTienda__r.name;
            option.valor = item.LastModifiedBy.Name;
            if(item.dsalesActivo__c)
            {
                option.depende = 'Activo';
            }
            option.mostrar = true;
            respuesta.add(option);
        }
        return respuesta;
    }

    @AuraEnabled
    public static  List<PickListOption>  getPickListTiendasSeguro(string idSeguros){
        List<PickListOption>  respuesta = new  List<PickListOption> ();
        for(dsalesAsignacionDeTienda__c item: [Select Id, dsalesTienda__r.name, dsalesTienda__c,LastModifiedBy.Name, dsalesActivo__c, Producto__c from dsalesAsignacionDeTienda__c Where Producto__c =:idSeguros and dsalesActivo__c=true WITH SECURITY_ENFORCED order by Name asc]){
            PicklistOption option = new PicklistOption();
            option.etiqueta = item.dsalesTienda__r.name;
            option.valor = item.LastModifiedBy.Name;
            if(item.dsalesActivo__c)
            {
                option.depende = 'Activo';
            }
            option.mostrar = true;
            respuesta.add(option);
        }
        return respuesta;
    }

    @AuraEnabled
    public static DSALES_ClasificacionServicioWrapper getPicklistOptionsDependent(String allData){
        system.debug('x'+allData);
        DSALES_ClasificacionServicioWrapper objeto = (DSALES_ClasificacionServicioWrapper) JSON.deserialize(allData, DSALES_ClasificacionServicioWrapper.class);
        DSALES_ClasificacionServicioWrapper objetoNuevo = (DSALES_ClasificacionServicioWrapper) JSON.deserialize(allData, DSALES_ClasificacionServicioWrapper.class);
        List<String> campos = new List<String>();
        objetoNuevo.listCiudades = new List <PickListOption>();
        objetoNuevo.listTiendas = new List <PickListOption>();
        
        List<String> listRegiones = itemSeleccionados(objeto.listRegiones);
        List<String> listCiudades = itemSeleccionados(objeto.listCiudades);
        List<String> listTiendas = itemSeleccionados(objeto.listTiendas);
        for(dsalesCiudad__c item: [Select Id, name,dsalesRegion__c from dsalesCiudad__c Where dsalesRegion__c in : listRegiones and dsalesActivo__c=true WITH SECURITY_ENFORCED order by Name]){
            PicklistOption option = new PicklistOption();
            option.etiqueta = item.name;
            option.valor = item.Id;
            option.depende = item.dsalesRegion__c;
            option.seleccionado = false;
            option.mostrar = true;
            objetoNuevo.listCiudades.add(option);
        }
        
        for(PicklistOption item: objeto.listCiudades){
            for(PicklistOption itemNuevo: objetoNuevo.listCiudades){
                if(item.valor == itemNuevo.valor){
                    itemNuevo.seleccionado = item.seleccionado;
                    itemNuevo.mostrar = item.mostrar;
                }
            }
        }
        if (Schema.sObjectType.Tienda__c.isQueryable()) {
            for(Tienda__c item: [Select Id, Name,dsalesCiudad__c from Tienda__c Where dsalesCiudad__c in : listCiudades and Activa__c= true order by Name]){
                PicklistOption option = new PicklistOption();
                option.etiqueta = item.Name;
                option.valor = item.Id;
                option.depende = item.dsalesCiudad__c;
                option.seleccionado = false;
                option.mostrar = true;
                objetoNuevo.listTiendas.add(option);
            }
        } 
        getPicklistOptionsDependentAuxiliar(objeto, objetoNuevo, listTiendas);
        return objetoNuevo;
    }
    
    private static List<String> itemSeleccionados(List<PicklistOption> listPickList){
        List<String> listItems = new List <String>();
        for(PicklistOption item: listPickList){
            if(item.seleccionado){
                listItems.add(item.valor);
            }
        }
        return listItems;
    }

    private static void getPicklistOptionsDependentAuxiliar(DSALES_ClasificacionServicioWrapper objeto, DSALES_ClasificacionServicioWrapper objetoNuevo, List<String> listTiendas){
        for(PicklistOption item: objeto.listTiendas){
            for(PicklistOption itemNuevo: objetoNuevo.listTiendas){
                if(item.valor == itemNuevo.valor){
                    itemNuevo.seleccionado = item.seleccionado;
                    itemNuevo.mostrar = item.mostrar;
                }
            }
        }
    }

    @AuraEnabled
    public static void vinculacionTiendaCampana(string dataJsonTienda,  string idCampana, Boolean vincular){
        system.debug('xx'+dataJsonTienda);
        List<PickListOption> listIdTiendas= (List<PickListOption>) JSON.deserialize(dataJsonTienda, List<PickListOption>.class);
        List<dsalesAsignacionDeTienda__c> listInsertVinculacion = new List<dsalesAsignacionDeTienda__c>(); 
        List<dsalesAsignacionDeTienda__c> listSelected=[Select Id, Name, dsalesTienda__c, dsalesActivo__c, dsalesCampana__c from dsalesAsignacionDeTienda__c Where dsalesCampana__c =:idcampana WITH SECURITY_ENFORCED order by Name asc ];   
        List<dsalesAsignacionDeTienda__c> listInsertVinculacionCorrecta = new List<dsalesAsignacionDeTienda__c>(); 
       system.debug(listSelected);
       String tipoRegistroId = Schema.SObjectType.dsalesAsignacionDeTienda__c.getRecordTypeInfosByDeveloperName().get('dsalesAsignacionDeCampanas').getRecordTypeId();
       system.debug(tipoRegistroId);
       for (PickListOption item : listIdTiendas) {
        Boolean encontrado = false;
        String idAsignacion = '';
      
        for (dsalesAsignacionDeTienda__c insertItem : listSelected) {
            if (insertItem.dsalesTienda__c == item.valor) {
                encontrado = true;
                idAsignacion = insertItem.id;
                break;
            }
        }
        Boolean isActive = item.seleccionado;
        if (encontrado && isActive) {
            listInsertVinculacion.add(new dsalesAsignacionDeTienda__c(
                id = idAsignacion,
                dsalesTienda__c = item.valor,
                dsalesActivo__c = vincular,
                dsalesCampana__c = idCampana,
                RecordTypeId= tipoRegistroId
            ));
        } else if(isActive){
            listInsertVinculacion.add(new dsalesAsignacionDeTienda__c(
                dsalesTienda__c = item.valor,
                dsalesActivo__c = isActive,
                dsalesCampana__c = idCampana,
                RecordTypeId= tipoRegistroId

            ));
        }
    }
        system.debug(listInsertVinculacion);
        if(Schema.sObjectType.dsalesAsignacionDeTienda__c.isCreateable() && Schema.sObjectType.dsalesAsignacionDeTienda__c.isUpdateable()){
            upsert listInsertVinculacion;
        }
    }

    @AuraEnabled
    public static void vinculacionTiendaSeguro(string dataJsonTienda,  string idSeguros, Boolean vincular){
        system.debug('prueba say:'+ dataJsonTienda);
        List<PickListOption> listIdTiendas= (List<PickListOption>) JSON.deserialize(dataJsonTienda, List<PickListOption>.class);
        List<dsalesAsignacionDeTienda__c> listInsertVinculacion = new List<dsalesAsignacionDeTienda__c>(); 
        List<dsalesAsignacionDeTienda__c> listSelected=[Select Id, Name, dsalesTienda__c, dsalesActivo__c, Producto__c from dsalesAsignacionDeTienda__c Where Producto__c =:idSeguros WITH SECURITY_ENFORCED order by Name asc ];   
        List<dsalesAsignacionDeTienda__c> listInsertVinculacionCorrecta = new List<dsalesAsignacionDeTienda__c>(); 
       system.debug(listSelected);
       String tipoRegistroId = Schema.SObjectType.dsalesAsignacionDeTienda__c.getRecordTypeInfosByDeveloperName().get('dsalesAsignacionDeSeguros').getRecordTypeId();
       system.debug(tipoRegistroId);
       for (PickListOption item : listIdTiendas) {
        Boolean encontrado = false;
        String idAsignacion = '';
        System.debug(idSeguros);
        for (dsalesAsignacionDeTienda__c insertItem : listSelected) {
            if (insertItem.dsalesTienda__c == item.valor) {
                encontrado = true;
                idAsignacion = insertItem.id;
                break;
            }
        }
        Boolean isActive = item.seleccionado;
        if (encontrado&& isActive) {
            listInsertVinculacion.add(new dsalesAsignacionDeTienda__c(
                id = idAsignacion,
                dsalesTienda__c = item.valor,
                dsalesActivo__c = vincular,
                Producto__c = idSeguros,
                RecordTypeId= tipoRegistroId
            ));
        } else if(isActive) {
            listInsertVinculacion.add(new dsalesAsignacionDeTienda__c(
                dsalesTienda__c = item.valor,
                dsalesActivo__c = isActive,
                Producto__c = idSeguros,
                RecordTypeId= tipoRegistroId

            ));
        }
    }
        system.debug(listInsertVinculacion);
        if(Schema.sObjectType.dsalesAsignacionDeTienda__c.isCreateable() && Schema.sObjectType.dsalesAsignacionDeTienda__c.isUpdateable()){
            upsert listInsertVinculacion;
        }
    }

    public class AsignarTiendas{
        @AuraEnabled public String id;
        @AuraEnabled public String nombre;
        @AuraEnabled public String idCampana;
        @AuraEnabled public String idTienda;
        @AuraEnabled public Boolean estado;
        @AuraEnabled public Boolean seleccionadoSku; 
        @AuraEnabled public String descripcion;  
    }

    public class DSALES_ClasificacionServicioWrapper{
        @AuraEnabled public List <PickListOption> listRegiones{get;set;}
        @AuraEnabled public List <PickListOption> listCiudades{get;set;}
        @AuraEnabled public List <PickListOption> listTiendas{get;set;}        
        @AuraEnabled public String sku;
    }

    public class PickListOption{
        @AuraEnabled public String etiqueta;
        @AuraEnabled public String valor;
        @AuraEnabled public String depende;
        @AuraEnabled public Boolean seleccionado;
        @AuraEnabled public Boolean mostrar;
    }


}