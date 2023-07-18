declare module "@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPickListRegiones" {
  export default function getPickListRegiones(): Promise<any>;
}
declare module "@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPickListTiendas" {
  export default function getPickListTiendas(param: {idCampana: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPickListTiendasMatriz" {
  export default function getPickListTiendasMatriz(param: {idMatriz: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPickListTiendasSeguro" {
  export default function getPickListTiendasSeguro(param: {idSeguros: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPicklistOptionsDependent" {
  export default function getPicklistOptionsDependent(param: {allData: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.seleccionCampanaMatriz" {
  export default function seleccionCampanaMatriz(param: {idSelected: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaCampana" {
  export default function vinculacionTiendaCampana(param: {dataJsonTienda: any, idCampana: any, vincular: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaMatriz" {
  export default function vinculacionTiendaMatriz(param: {dataJsonTienda: any, idMatriz: any, vincular: any}): Promise<any>;
}
declare module "@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaSeguro" {
  export default function vinculacionTiendaSeguro(param: {dataJsonTienda: any, idSeguros: any, vincular: any}): Promise<any>;
}
