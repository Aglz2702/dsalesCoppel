declare module "@salesforce/apex/DSALES_ClasificacionServicio.getPickListCategoria" {
  export default function getPickListCategoria(): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getRecords" {
  export default function getRecords(param: {allData: any, perfilUsuario: any, opcion: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getBuscarSKU" {
  export default function getBuscarSKU(param: {sku: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getBuscarVinculacion" {
  export default function getBuscarVinculacion(param: {servicio: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getidservicio" {
  export default function getidservicio(param: {sku: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getBuscarProducto" {
  export default function getBuscarProducto(param: {servicio: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.upsertVinculacion" {
  export default function upsertVinculacion(param: {dataJSON: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.insertVinculacion" {
  export default function insertVinculacion(param: {dataJSON: any, idservicio: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.upsertRecord" {
  export default function upsertRecord(param: {allData: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getPicklistOptionsDependent" {
  export default function getPicklistOptionsDependent(param: {allData: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.checkProfileType" {
  export default function checkProfileType(param: {profile: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getcategories" {
  export default function getcategories(param: {recordName: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getserviciocategorias" {
  export default function getserviciocategorias(param: {recordName: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getserviciosubcategorias" {
  export default function getserviciosubcategorias(param: {valueCategoria: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getservicioclase" {
  export default function getservicioclase(param: {valueCategoria: any, valueSubcategoria: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getserviciofamilia" {
  export default function getserviciofamilia(param: {valueCategoria: any, valueSubcategoria: any, valueClases: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getserviciosku" {
  export default function getserviciosku(param: {valueCategoria: any, valueSubcategoria: any, valueClasesFamilias: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getSubCategories" {
  export default function getSubCategories(param: {valueCategoria: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getClases" {
  export default function getClases(param: {valueCategoria: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getFamilias" {
  export default function getFamilias(param: {valueClases: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getMatriz" {
  export default function getMatriz(): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.updateMatriz" {
  export default function updateMatriz(param: {allData: any, typeServicio: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getCampaings" {
  export default function getCampaings(): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getTipoUso" {
  export default function getTipoUso(): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.updateCampaigns" {
  export default function updateCampaigns(param: {allData: any, idProducto: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.updateTipoUso" {
  export default function updateTipoUso(param: {allData: any, idProducto: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getTiposUsoUsed" {
  export default function getTiposUsoUsed(param: {idProducto: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getCampanasUsed" {
  export default function getCampanasUsed(param: {idProducto: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.insertListaPrecios" {
  export default function insertListaPrecios(param: {idproductoservicio: any, opcion: any, json2: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList1" {
  export default function getPickListValuesIntoList1(): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList2" {
  export default function getPickListValuesIntoList2(): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList3" {
  export default function getPickListValuesIntoList3(): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList4" {
  export default function getPickListValuesIntoList4(): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList5" {
  export default function getPickListValuesIntoList5(): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.createProductIntan" {
  export default function createProductIntan(param: {productIntan: any, sku: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.recordTypeId" {
  export default function recordTypeId(param: {tipoRegistro: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.insertPocentajeCobro" {
  export default function insertPocentajeCobro(param: {idservicio: any, jsonp: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_ClasificacionServicio.createVinculacion" {
  export default function createVinculacion(param: {asignacion: any}): Promise<any>;
}
