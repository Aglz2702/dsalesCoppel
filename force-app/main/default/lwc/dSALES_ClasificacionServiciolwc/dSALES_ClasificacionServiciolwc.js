import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCategoria from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListCategoria';
import getToken from '@salesforce/apex/DSALES_ClasificacionServicio.getToken';
import SendCat from '@salesforce/apex/DSALES_ClasificacionServicio.getPicklistOptionsDependent';
import getRecords from '@salesforce/apex/DSALES_ClasificacionServicio.getRecords';
import upsertRecord from '@salesforce/apex/DSALES_ClasificacionServicio.upsertRecord';
import getSku from '@salesforce/apex/DSALES_ClasificacionServicio.getBuscarSKU';
import getProfileType from '@salesforce/apex/DSALES_ClasificacionServicio.checkProfileType';
import getCategories from '@salesforce/apex/DSALES_ClasificacionServicio.getcategories';
import getSubCategories from '@salesforce/apex/DSALES_ClasificacionServicio.getSubCategories';
import getClases from '@salesforce/apex/DSALES_ClasificacionServicio.getClases';
import getFamilias from '@salesforce/apex/DSALES_ClasificacionServicio.getFamilias';
import getPickListTipoProducto from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList1';
import getPickListTipoServicio from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList2';
import getPickListTipoSeguro from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList4';
import getPickListMatriz from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList3';
import getPickListPago from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList5';
import getPickListFormaPago from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList6';
import getPickListProveedores from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListProveedores';
import getPickListEncuesta from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListEncuesta';
import getMatrices from '@salesforce/apex/DSALES_ClasificacionServicio.getMatriz';
import getBuscarVinculacion from '@salesforce/apex/DSALES_ClasificacionServicio.getBuscarVinculacion';
import createProductIntan from '@salesforce/apex/DSALES_ClasificacionServicio.createProductIntan';
import upsertVinculacion from '@salesforce/apex/DSALES_ClasificacionServicio.upsertVinculacion';
import getBuscarProducto from '@salesforce/apex/DSALES_ClasificacionServicio.getBuscarProducto';
import getidservicio from '@salesforce/apex/DSALES_ClasificacionServicio.getidservicio';
import insertVinculacion from '@salesforce/apex/DSALES_ClasificacionServicio.insertVinculacion';
import updateMatriz from '@salesforce/apex/DSALES_ClasificacionServicio.updateMatriz';
import insertListaPrecios from '@salesforce/apex/DSALES_ClasificacionServicio.insertListaPrecios';
import insertProveedores from '@salesforce/apex/DSALES_ClasificacionServicio.insertProveedores';
import asignacionProveedores from '@salesforce/apex/DSALES_ClasificacionServicio.asignacionProveedores';
import asignacionEncuesta from '@salesforce/apex/DSALES_ClasificacionServicio.asignacionEncuesta';
import insertPocentajeCobro from '@salesforce/apex/DSALES_ClasificacionServicio.insertPocentajeCobro';
import recordTypeId from '@salesforce/apex/DSALES_ClasificacionServicio.recordTypeId';
import getCampaings from '@salesforce/apex/DSALES_ClasificacionServicio.getCampaings';
import updateCampaigns from '@salesforce/apex/DSALES_ClasificacionServicio.updateCampaigns';
import getTipoUso from '@salesforce/apex/DSALES_ClasificacionServicio.getTipoUso';
import updateTipoUso from '@salesforce/apex/DSALES_ClasificacionServicio.updateTipoUso';
import getTiposUsoUsed from '@salesforce/apex/DSALES_ClasificacionServicio.getTiposUsoUsed';
import getCampanasUsed from '@salesforce/apex/DSALES_ClasificacionServicio.getCampanasUsed';
import getserviciocategorias from '@salesforce/apex/DSALES_ClasificacionServicio.getserviciocategorias';
import getserviciosubcategorias from '@salesforce/apex/DSALES_ClasificacionServicio.getserviciosubcategorias';
import getservicioclase from '@salesforce/apex/DSALES_ClasificacionServicio.getservicioclase';
import getserviciofamilia from '@salesforce/apex/DSALES_ClasificacionServicio.getserviciofamilia';
import getserviciosku from '@salesforce/apex/DSALES_ClasificacionServicio.getserviciosku';
import getRecordsFromServer from '@salesforce/apex/DSALES_ClasificacionServicio.getRecordsFromServer';
import getRecordsFromServer2 from '@salesforce/apex/DSALES_ClasificacionServicio.getRecordsFromServer2';
import getRecordsFromServer21 from '@salesforce/apex/DSALES_ClasificacionServicio.getRecordsFromServer21';
import getRecordsFromServer3 from '@salesforce/apex/DSALES_ClasificacionServicio.getRecordsFromServer3';
import getRecordsFromServer31 from '@salesforce/apex/DSALES_ClasificacionServicio.getRecordsFromServer31';
import getPicklistOptionsDependent from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPicklistOptionsDependent';
import seleccionSegurosServicios from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.seleccionSegurosServicios';
import getPicklistOptionsDependentSM from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPicklistOptionsDependentSM';
import getPickListRegiones from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPickListRegiones';
import vinculacionTiendaSeguro from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaSeguro';
import getPickListTiendasSeguro from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPickListTiendasSeguro';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';




const columns = [
    { label: 'Nombre', fieldName: 'etiqueta' }

];

export default class DSALES_ClasificacionServiciolwc extends LightningElement {
    filterObject = {
        DSales_Producto__r: {
            RecordTypeId: this.recordType
        }
    };
    @track data = {};
    @track currentPage = 1;
    @track itemsPerPage = 50;
    @track dataSeguros = {};
    @track pickList = {};
    @track asignacion = {};
    @track label = {};
    @track matrizPorcentaje = {};
    columns = columns;
    totalPages = 0;
    checkCategoria = false;
    checkSubCategoria = false;
    checkSku = false;
    checkSkus = false;
    checkClase = false;
    checkFamilia = false;
    checkRegion = false;
    checkCiudad = false;
    checkGerente = false;
    gerenteActivado=false;
    checkTienda = false;
    listTiendasActivas = [];
    showSpinner = true;
    popServicios = false;
    show = false;
    show2 = false;
    showc = false;
    showbyfilter = false;
    showVincuProduct = false;
    showCrearIntangible = false;
    showasignarSubCategorias = false;
    showasignarClases = false;
    showasignarFamilias = false;
    showAdmiGex = false;
    showAdmiSM = false;
    showAdmiSC = false;
    showSeguro = false;
    buscarCategoria = '';
    buscarSCat = '';
    buscarClase = '';
    buscarFami = '';
    buscarSkuString = '';
    buscarPers = '';
    buscarServicio = '';
    recordType = '';
    showPorcentajeCobro = false;
    openTablaResultado = false;
    openTableVincProduct = false;
    showConfirmarDesvincular = false
    showConfirmarVincular = false;
    openFormAsignarTiendas = false;
    ValueCategoriaSelected = '';
    ValueSubCategoriaSelected = '';
    resultPerfil = false;
    vincular = true;
    desvincular = false;
    campanasSelected = [];
    tiposUsoSelected = [];
    listaClaseFamiliaToken = [];
    listaClaseToken = [];
    connectedCallback() {
        this.init();
        this.resultPerfil = false;
        this.showAdmiSM = false;
        this.showAdmiGex = false;
        this.data.showServicio = true;
        this.showSeguro= false;
        getProfileType()
            .then(result => {
                console.log(result);
                this.data.confirmarProfileType = result;
                if (this.data.confirmaProfileType == 'Administrador SM' || this.data.confirmaProfileType == 'Administrador SC') {
                    this.resultPerfil = false;
                    this.showSeguro=true;
                    this.showAdmiSM = false;
                    this.showAdmiSC = false;
                    this.showAdmiGex = false;
                    this.data.showServicio = false;
                    this.pickList.valueSelectedtipoProducto = 'Seguro';
                    this.pickList.DSales_Tipo_de_Producto__c = 'Seguro';
                    this.getPickList4();
                }
                else if (this.data.confirmarProfileType == 'Administrador GEX' || this.data.confirmarProfileType == 'Administrador Armado'|| this.data.confirmarProfileType == 'Administrador de Instalación') {
                    this.resultPerfil = false;
                    this.showAdmiSM = false;
                    this.showAdmiGex = true;
                    this.showSeguro=false;
                    this.data.showServicio = true;
                    this.pickList.valueSelectedtipoProducto = 'Servicio';
                    this.pickList.DSales_Tipo_de_Producto__c = 'Servicio';
                    this.getPickList2();
                }
                else if (this.data.confirmarProfileType == 'Administrador del sistema'|| this.data.confirmarProfileType == 'System Administrator') {
                    this.resultPerfil = true;
                    this.showAdmiSM = false;
                    this.showAdmiGex = false;
                    this.showSeguro=false;
                    this.data.showServicio = true;
                    this.pickList.valueSelectedtipoProducto = 'Servicio';
                    this.pickList.DSales_Tipo_de_Producto__c = 'Servicio';
                    this.getPickList2();
                }
                this.searchAllRecords();
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    init() {

        getCategoria()
            .then(result => {
                this.data = result;
                this.showSpinner = false;
                this.showc = false;
                console.log('hi');

            })
            .catch(error => {
                this.showSpinner = false;
            });
        this.show = false;
        this.show2 = false;
        this.show3 = false;
        this.checkCategoria = false;
        this.checkSubCategoria = false;
        this.checkClase = false;
        this.checkFamilia = false;

    }

    changeSku(event) {
        this.buscarSkuString = event.target.value;
        this.currentPage = 1;
        this.totalPages = 1;
    }

    changebusqueda(event) {
        this.buscarPers = event.target.value;
        this.currentPage = 1;
        this.totalPages = 1;
    }

    buscarSku() {
        this.showbyfilter = true;
        this.showSpinner = true;
        getSku({ sku: this.buscarSkuString })
            .then(result => {
                this.ProfileChecker();
                this.data.listServicios = result;
                this.fetchData2();
                if (this.data.listServicios.length > 0) {
                    this.popServicios = true;
                    this.recordServicio();
                } else {
                    this.pushMessage('Advertencia', 'warning', 'No se han encontrado productos.');
                }
            }).catch(error => {
                this.showSpinner = false;
            });
    }

    buscadorC(event) {
        this.buscarCategoria = event.target.value;
        this.buscarCategoria = this.quitaAcento(this.buscarCategoria);
        if (this.buscarCategoria.length > 2) {
            for (const element of this.data.listCategorias) {
                let etiqueta = this.quitaAcento(element.etiqueta);
                element.mostrar = etiqueta.includes(this.buscarCategoria);
            }
        } else {
            for (const element of this.data.listCategorias) {
                element.mostrar = true;
            }
        }
    }

    buscadorSubC(event) {
        this.buscarSCat = event.target.value;
        this.buscarSCat = this.quitaAcento(this.buscarSCat);
        if (this.buscarSCat.length > 2) {
            for (const element of this.data.listSubCategorias) {
                let etiqueta = this.quitaAcento(element.etiqueta);
                element.mostrar = etiqueta.includes(this.buscarSCat);
            }
        } else {
            for (const element of this.data.listSubCategorias) {
                element.mostrar = true;
            }
        }
    }

    buscadorCla(event) {
        this.buscarClase = event.target.value;
        this.buscarClase = this.quitaAcento(this.buscarClase);
        if (this.buscarClase.length > 2) {
            for (const element of this.data.listClases) {
                let etiqueta = this.quitaAcento(element.etiqueta);
                element.mostrar = etiqueta.includes(this.buscarClase);
            }
        } else {
            for (const element of this.data.listClases) {
                element.mostrar = true;
            }
        }
    }

    buscadorFami(event) {
        this.buscarFami = event.target.value;
        this.buscarFami = this.quitaAcento(this.buscarFami);
        if (this.buscarFami.length > 2) {
            for (const element of this.data.listFamilias) {
                let etiqueta = this.quitaAcento(element.etiqueta);
                element.mostrar = etiqueta.includes(this.buscarFami);
            }
        } else {
            for (const element of this.data.listFamilias) {
                element.mostrar = true;
            }
        }
    }

    quitaAcento(cadena) {
        cadena = cadena.toUpperCase();
        cadena = cadena.replace('Á', 'A');
        cadena = cadena.replace('É', 'E');
        cadena = cadena.replace('Í', 'I');
        cadena = cadena.replace('Ó', 'O');
        cadena = cadena.replace('Ú', 'U');
        return cadena;
    }
    mostrarSubcategoria() {
        this.show = true;
        this.cargarPickList2();
    }

    mostrarClase() {
        this.show2 = true;
        this.cargarPickList2();
    }

    mostrarFamilia() {
        this.show3 = true;
        this.cargarPickList2();
    }

    cargarPickList2() {
        this.buscarSkuString = '';
        this.currentPage = 1;
        this.totalPages = 1;
        console.log(JSON.parse(JSON.stringify(this.data)));
        SendCat({ allData: JSON.stringify(this.data) })
            .then(result => {
                console.log(JSON.parse(JSON.stringify(result)));
                this.data = result;
            }).catch(error => {
                console.log(error);
            });
    }

    onclickCategoria(event) {
        console.log(event.target.name + 'hola');
        let x = false;
        const valor = event.target.name;
        const check = event.target.checked;
        const depende = valor;
        let depende2 = '';
        for (const element of this.data.listCategorias) {
            if (valor == element.valor) {
                element.seleccionado = check;
            }
        }
        for (const element of this.data.listSubCategorias) {
            if (depende == element.depende) {
                element.seleccionado = check;
                depende2 = element.valor;
            }
        }
        for (const element of this.data.listClases) {
            if (depende2 == element.depende) {
                element.seleccionado = check;
            }
        }

        this.mostrarSubcategoria();
    }

    onclickSubCategoria(event) {
        let x = false;
        const valor = event.target.name;
        const check = event.target.checked;
        const depende = valor;
        for (const element of this.data.listSubCategorias) {
            if (valor == element.valor) {
                element.seleccionado = check;
            }
        }
        for (const element of this.data.listClases) {
            if (depende == element.depende) {
                element.seleccionado = check;
            }
        }
        this.mostrarClase();
    }

    onclickListFamilias(event) {
        let x = false;
        const valor = event.target.name;
        const check = event.target.checked;
        for (const element of this.data.listFamilias) {
            if (valor == element.valor) {
                element.seleccionado = check;
            }
        }
    }

    onclicklistClases(event) {
        let x = false;
        const valor = event.target.name;
        const check = event.target.checked;
        for (const element of this.data.listClases) {
            if (valor == element.valor) {
                element.seleccionado = check;
            }
        }
        this.mostrarFamilia();
    }

    selectAllCategoria(event) {
        const check = event.target.checked;
        for (const element of this.data.listCategorias) {
            element.seleccionado = check;
            for (const element2 of this.data.listSubCategorias) {
                if (element.valor == element2.depende) {
                    element2.seleccionado = check;
                }
                for (const element3 of this.data.listClases) {
                    if (element2.valor == element3.depende) {
                        element3.seleccionado = check;
                    }
                }
            }

        }
        this.checkCategoria = check;
        this.mostrarSubcategoria();
    }

    borrarSelection() {
        console.log(JSON.parse(JSON.stringify(this.data)));
        const check = false;
        for (const element of this.data.listCategorias) {
            element.seleccionado = check;
        }
        for (const element2 of this.data.listSubCategorias) {
            element2.seleccionado = check;
            element2.mostrar = check;
        }
        for (const element3 of this.data.listClases) {
            element3.seleccionado = check;
            element3.mostrar = check;
        }
        for (const element4 of this.data.listFamilias) {
            element4.seleccionado = check;
            element4.mostrar = check;
        }
        this.checkCategoria = check;
        this.checkSubCategoria = check;
        this.checkFamilia = check;
        this.checkClase = check;
    }
    selectAllSubCategoria(event) {
        const check = event.target.checked;
        for (const element of this.data.listSubCategorias) {
            element.seleccionado = check;
            for (const element2 of this.data.listClases) {
                if (element.valor == element2.depende) {
                    element2.seleccionado = check;
                }
            }
        }
        this.checkSubCategoria = check;
        this.mostrarClase();
    }

    selectAllFamilia(event) {
        const check = event.target.checked;
        for (const element of this.data.listFamilias) {
            element.seleccionado = check;
        }
        this.checkFamilia = check;
    }

    selectAllClase(event) {
        const check = event.target.checked;
        for (const element of this.data.listClases) {
            element.seleccionado = check;
        }
        this.checkClase = check;
        this.mostrarFamilia();
    }

    search() {

        if (this.buscarSkuString == '') {
            this.showSpinner = true;
            this.getNameRecordTypeId();
            getRecords({ allData: JSON.stringify(this.data), perfilUsuario: this.data.nameRecordType, opcion: 'RecordType' })
                .then(result => {
                    this.ProfileChecker();
                    this.data = result;
                    this.data.registroSeguro = false;
                    this.data.registroServicio = false;
                    this.fetchData2();
                    if (this.data.listServicios.length > 0) {
                        this.popServicios = true;
                        this.recordServicio();
                    } else {
                        this.pushMessage('Advertencia', 'warning', 'No se han encontrado productos.');
                    }
                    this.showbyfilter = true;
                })
                .catch(error => {
                    this.showSpinner = false;
                    console.log(error);
                    this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte su administrador.');
                });
        }
        else {
            this.buscarSku();
        }

    }

    searchAllRecords() {
        this.currentPage = 1;
        this.showSpinner = true;
        this.getNameRecordTypeId();
        getRecords({ allData: JSON.stringify(this.data), perfilUsuario: this.data.nameRecordType, opcion: 'AllRecords' })
            .then(result => {
                this.data = result;
                this.data.registroSeguro = false;
                this.data.registroServicio = false;
                this.fetchData2();
                if (this.data.listServicios.length > 0) {
                    this.popServicios = true;
                } else {
                    this.pushMessage('Advertencia', 'warning', 'No se han encontrado productos.');
                }
                this.showbyfilter = true;
                this.showCrearIntangible = false;
                this.showc = false;
                this.showVincuProduct = false;
            })
            .catch(error => {
                this.showSpinner = false;
                this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte su administrador.');
            });
    }

    guardar() {
        this.showSpinner = true;
        this.popServicios = false;
        upsertRecord({ allData: JSON.stringify(this.data.listapaginada2) })
            .then(result => {
                if (result[1] == '200') {
                    this.cancelar();
                    if (result[0] == 'sin errores') {
                        this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente.');
                    }
                    else {
                        this.pushMessage('Advertencia', 'Warning', 'Operacion exitosa con los siguientes errores: ' + result[0]);
                    }
                    insertListaPrecios({ idproductoservicio: 'opcion2', opcion: '2', json2: JSON.stringify(this.data.listapaginada2) })
                        .then(result2 => {
                            console.log(result2);
                        }).catch(error => {
                            console.log(error);
                        });
                }
                else if (result[1] == '400') {
                    this.pushMessage('Advertencia', 'warning', 'Error: ' + result + ' Recurso no encontrado');
                    this.showSpinner = false;
                }
                else if (result[1] == '404') {
                    this.pushMessage('Advertencia', 'warning', 'Error: ' + result + 'No se encontró el recurso solicitado');
                    this.showSpinner = false;
                }
                else if (result[1] == '416') {
                    this.pushMessage('Advertencia', 'warning', 'Error: ' + result + 'Rango no satisfactorio');
                    this.showSpinner = false;
                }
                else if (result[1] == '422') {
                    this.pushMessage('Advertencia', 'warning', 'Error: ' + result + 'Entidad no procesable');
                    this.showSpinner = false;
                }
                else if (result[1] == '429') {
                    this.pushMessage('Advertencia', 'warning', 'Error: ' + result + 'Demasiadas peticiones');
                    this.showSpinner = false;
                }
                else if (result[1] == '500') {
                    this.pushMessage('Advertencia', 'warning', 'Error: ' + result + 'Problemas en la comunicación');
                    this.showSpinner = false;
                }
                this.showSpinner = false;
                this.ProfileCheckerBusqueda();
            }).catch(error => {
                this.showSpinner = false;
                this.pushMessage('Error', 'error', 'Ha ocurrido un error al actualizar los registros.');
            });
    }

    cancelar() {
        this.popServicios = false;
        this.showSpinner = false;
        this.showVincuProduct = false;
        this.openTablaResultado = false;
        this.ValueCategoriaSelected = '';
        this.pickList.ValueClasesSelected = '';
        this.pickList.ValuefamiliasSelected = '';
        this.pickList.aplicaCobro = false;
        this.pickList.porcentajeCobro = 0;
        this.pickList.valueSelectedMatriz = '';
        this.pickList.Description = '';
        this.pickList.Name = '';
        this.pickList.StockKeepingUnit = '';
        this.pickList.valueSelectedtipoSeguroServicio = '';
        this.pickList.matrizSelected = '';
        this.data.listasignacion = '';
        this.data.showcompras = false;
        this.data.showcomprascat = false;
    }

    limpiarCampos() {
        this.ValueCategoriaSelected = '';
        this.pickList.ValueClasesSelected = '';
        this.pickList.ValuefamiliasSelected = '';
        this.pickList.aplicaCobro = false;
        this.pickList.porcentajeCobro = 0;
        this.pickList.valueSelectedMatriz = '';
        this.pickList.Description = '';
        this.pickList.Name = '';
        this.pickList.StockKeepingUnit = '';
        this.pickList.valueSelectedtipoSeguroServicio = '';
        this.pickList.matrizSelected = '';
        this.pickList.dsalesOpcionPago__c = '';
        this.pickList.DSales_Aplicaporcentajecobro__c = false;
        this.pickList.dsalesProveedor__c='';
        this.pickList.dsalesEncuestaPISyS__c='';
        this.pickList.formaCobro='';
        this.pickList.proveedores='';
        this.showPorcentajeCobro = false;
        this.data.showPrecioUnico = false;
        this.aplicaMotoEx = false;
        this.pickList.DSALES_Aplicaparamotoexterna__c = false;
        this.checkSku = false;
        this.checkSkus = false;
        this.pickList.listMatrices = '';
        this.pickList.DSales_PorcentajeCobro__c = 0;
        this.pickList.IsActive = false;
        this.pickList.subCategoriaSelected = '';
        this.matrizPorcentaje.anio1 = 0;
        this.matrizPorcentaje.anio2 = 0;
        this.matrizPorcentaje.anio3 = 0;
        this.matrizPorcentaje.anio4 = 0;
        this.matrizPorcentaje.anio5 = 0;
        this.matrizPorcentaje.anio6 = 0;
        this.data.busqueda=false;
    }

    onchangeSeguro(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (let i = 0; i < this.data.listapaginada2.length; i++) {
            if (this.data.listapaginada2[i].id == name) {
                this.data.listapaginada2[i].seguro = check;
                this.data.listapaginada2[i].noAplica = false;
                this.data.listapaginada2[i].noAplicaSeguro = false;
                this.asignarTipoServicio(i);
            }
        }
    }
    onchangeNoAplica(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (const element of this.data.listapaginada2) {
            if (element.id == name) {
                element.noAplica = check;
                element.noAplicaSeguro = check;
                element.noAplicaServicio = check;
                element.servicio = false;
                element.seguro = false;
            }
        }
    }
    onchangeNoAplicaServicio(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (const element of this.data.listapaginada2) {
            if (element.id == name) {
                element.noAplicaServicio = check;
                element.servicio = false;
                element.seguro = false;
            }
        }
    }
    onchangeNoAplicaSeguro(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (const element of this.data.listapaginada2) {
            if (element.id == name) {
                element.noAplicaSeguro = check;
                element.servicio = false;
                element.seguro = false;
            }
        }
    }
    onchangeAllSeguro(event) {
        this.data.registroSeguro = event.target.checked;
        for (let i = 0; i < this.data.listapaginada2.length; i++) {
            this.data.listapaginada2[i].seguro = this.data.registroSeguro;
            this.data.listapaginada2[i].servicio = false;
            this.data.listapaginada2[i].noAplica = false;
            this.asignarTipoServicio(i);
        }
        this.recordServicio();
    }

    onchangeAllNoAplica(event) {
        this.data.noAplica = event.target.checked;
        for (const element of this.data.listapaginada2) {
            element.noAplica = this.data.noAplica;
            element.seguro = false;
            element.servicio = false;
        }
        this.recordServicio();
    }

    onchangeAllNoAplicaServicio(event) {
        this.data.noAplica = event.target.checked;
        for (const element of this.data.listapaginada2) {
            element.noAplicaServicio = this.data.noAplica;
            element.seguro = false;
            element.servicio = false;
        }
        this.recordServicio();
    }

    onchangeAllNoAplicaSeguro(event) {
        this.data.noAplica = event.target.checked;
        for (const element of this.data.listapaginada2) {
            element.noAplicaSeguro = this.data.noAplica;
            element.seguro = false;
            element.servicio = false;
        }
        this.recordServicio();
    }
    onchangeAllTiposuso(event) {
        this.data.registroTiposUso = event.target.checked;
        for (const element of this.data.listapaginada2) {
            element.tipoUso = this.data.registroTiposUso;
        }
    }

    onchangeAllCampanas(event) {
        this.data.registroCampanas = event.target.checked;
        for (const element of this.data.listapaginada2) {
            element.campanas = this.data.registroCampanas;
        }
    }

    onchangeServicio(event) {
        const name = event.target.name;
        const check = event.target.checked;
        console.log(JSON.parse(JSON.stringify(this.data.listapaginada2)));
        for (let i = 0; i < this.data.listapaginada2.length; i++) {
            if (this.data.listapaginada2[i].id == name) {
                this.data.listapaginada2[i].servicio = check;
                this.data.listapaginada2[i].noAplica = false;
                this.data.listapaginada2[i].noAplicaServicio = false;
                this.asignarTipoServicio(i);
            }
        }
    }

    onchangeAllServicio(event) {
        this.data.registroServicio = event.target.checked;
        for (let i = 0; i < this.data.listapaginada2.length; i++) {
            this.data.listapaginada2[i].servicio = this.data.registroServicio;
            this.data.listapaginada2[i].noAplica = false;
            this.data.listapaginada2[i].seguro = false;
            this.asignarTipoServicio(i);
        }
        this.recordServicio();
    }

    asignarTipoServicio(index) {
        if (this.data.listapaginada2[index].servicio && this.data.listapaginada2[index].seguro) {
            this.data.listapaginada2[index].tipoServicio = "3";
        } else if (this.data.listapaginada2[index].servicio) {
            this.data.listapaginada2[index].tipoServicio = "2";
        } else if (this.data.listapaginada2[index].seguro) {
            this.data.listapaginada2[index].tipoServicio = "1";
        } else {
            this.data.listapaginada2[index].tipoServicio = "0";
        }
    }

    recordServicio() {
        this.data.registroSeguro = false;
        this.data.registroServicio = false;
        this.data.noAplica = false;
        for (const element of this.data.listServicios) {
            if (element.seguro) {
                this.data.registroSeguro = true;
            }
            if (element.servicio) {
                this.data.registroServicio = true;
            }
            if (element.noAplica) {
                this.data.noAplica = true;
            }
        }
    }
    pushMessage(title, variant, msj) {
        const message = new ShowToastEvent({
            "title": title,
            "variant": variant,
            "message": msj
        });
        this.dispatchEvent(message);
    }

    openVincuProduct() {
        this.showVincuProduct = true;
        this.showc = false;
        this.showbyfilter = false;
        this.showCrearIntangible = false;
        this.currentPage = 1;
        recordTypeId({ tipoRegistro: 'Garantía Extendida' })
            .then(result => {
                this.recordType = result;
            });

    }

    openFormIntangible(event) {
        this.showc = false;
        this.data.showServicio = true;
        this.showbyfilter = false;
        this.showVincuProduct = false;
        this.limpiarCampos();
        this.showCrearIntangible = true;
        this.buscarServicio = '';
        this.SelectSeguroServicio();
        this.getPickList1();
    }

    getPickList1() {
        getPickListTipoProducto()
            .then(result => {
                this.pickList.tipoProducto = result;
            });
    }

    getPickList2(event) {
        this.label.labelTipoServicio = 'Tipo de servicio';
        this.label.labelSku = 'SKU del servicio';
        this.label.labelDescripcion = 'Descripción';
        this.label.labelName = 'Nombre del servicio';
        this.label.labelOpcionPago = 'Forma de cobro';
        this.label.labelPrecioUnico = 'Costo fijo';
        getPickListTipoServicio()
            .then(result => {
                this.pickList.tipoSeguroServicio = result;
            });
    }

    getPickList3() {
        getPickListMatriz()
            .then(result => {
                this.pickList.Matriz = result;
            });
    }

    getPickList4() {
        this.label.labelTipoServicio = 'Tipo de seguro';
        this.label.labelSku = 'SKU del seguro';
        this.label.labelDescripcion = 'Descripción';
        this.label.labelName = 'Nombre del seguro';
        this.label.labelOpcionPago = 'Forma de cobro';
        this.label.labelPrecioUnico = 'Costo fijo';
        getPickListTipoSeguro()
            .then(result => {
                this.pickList.tipoSeguroServicio = result;
            });
    }

    SelectSeguroServicio(event) {
        this.data.showEncuesta=false;
        this.data.showProveedores=false;
        this.ProfileChecker();
        getPickListFormaPago()
            .then(result => {
                this.pickList.listCobro = result;
            });
    }

    SelectSeguroServicioAdmi(event) {
        this.pickList.valueSelectedtipoProducto = event.target.value;
        this.pickList.DSales_Tipo_de_Producto__c = event.target.value;
        if (event.target.value == 'Servicio') {
            this.data.showServicio = true;
            this.showAdmiSM=false;
            this.getPickList2();
        }
        else if (event.target.value == 'Seguro') {
            this.data.showServicio = false;
            this.showAdmiSM=false;
            this.getPickList4();
        }
    }
    asignarCategoria(event) {
        this.showSpinner = true;
        this.data.showEncuesta=false;
        this.data.showProveedores=false;
        this.pickList.valueSelectedtipoSeguroServicio = event.target.value;
        if( this.pickList.valueSelectedtipoSeguroServicio=='Seguro de Motos'){
            this.showAdmiSC=false;
            this.showAdmiSM=true;
        }
        else if ( this.pickList.valueSelectedtipoSeguroServicio=='Seguro de Celulares'){
            this.showAdmiSC=true;
            this.showAdmiSM=false;
            this.data.showProveedores=true;
            getPickListProveedores()
            .then(result => {
                this.pickList.listProveedores = result;
            });
        }
        else if ( this.pickList.valueSelectedtipoSeguroServicio=='Instalaciones'){
            this.data.showProveedores=true;
            this.data.showEncuesta=true;
            getPickListProveedores()
            .then(result => {
                this.pickList.listProveedores = result;
            });
            getPickListEncuesta()
            .then(result => {
                this.pickList.listEncuestas = result;
            });
        }
        else{
            this.data.showProveedores=false;
            this.data.showEncuesta=false;
        }
        console.log(this.pickList.valueSelectedtipoProducto + 'holaa');
        recordTypeId({ tipoRegistro: this.pickList.valueSelectedtipoSeguroServicio })
            .then(result => {
                this.pickList.RecordTypeId = result;
                if (this.pickList.valueSelectedtipoProducto == 'Servicio') {
                    this.pickList.DSALES_ServEspecifico__c = event.target.value;
                    this.pickList.recordTypeSeguroServicio = 'Servicios';
                }
                else if (this.pickList.valueSelectedtipoProducto == 'Seguro') {
                    this.pickList.DSALES_SegEspecifico__c = event.target.value;
                    this.pickList.recordTypeSeguroServicio = 'Seguro de Motos';
                    getPickListPago()
                        .then(result7 => {
                            this.pickList.listOpcionesPago = result7;
                        });
                }
                getCategories({ recordName: this.pickList.recordTypeSeguroServicio })
                    .then(result2 => {
                        this.pickList.listCategorias = result2;
                        this.showSpinner = false;
                    });
            });
        console.log(this.pickList.recordTypeSeguroServicio);
        console.log(this.pickList.DSALES_ServEspecifico__c + this.pickList.DSALES_SegEspecifico__c);

    }
    asignarSubCategorias(event) {
        this.ValueCategoriaSelected = event.target.value;
        this.pickList.DSALES_Categoria__c = event.target.value;
        this.showasignarSubCategorias = true;
        getSubCategories({ valueCategoria: this.ValueCategoriaSelected })
            .then(result => {
                this.pickList.listSubCategorias = result;
            });
    }

    asignarClase(event) {
        this.pickList.subCategoriaSelected = event.target.value;
        this.pickList.DSALES_SubCategoria__c = event.target.value;
        this.showasignarClases = true;
        this.pickList.IsActive = true;
        getClases({ valueCategoria: this.pickList.subCategoriaSelected })
            .then(result => {
                this.pickList.listClases = result;
            });
    }

    asignarFamilas(event) {
        this.pickList.ValueClasesSelected = event.target.value;
        this.pickList.DSALES_Clase__c = event.target.value;
        this.showasignarFamilias = true;
        getFamilias({ valueClases: this.pickList.ValueClasesSelected })
            .then(result => {
                this.pickList.listFamilias = result;
            });
    }

    asignarMatriz(event) {
        this.showSpinner = true;
        this.pickList.Valuefamilias = event.target.value;
        this.pickList.DSALES_Familia__c = event.target.value;
        getMatrices()
            .then(result => {
                this.pickList.listMatrices = result;
                this.showSpinner = false;
            });
    }



    ProfileChecker(event) {
        this.resultPerfil = false;
        this.showAdmiSM = false;
        this.showAdmiGex = false;
        getProfileType()
            .then(result => {
                console.log(result);
                this.data.confirmarProfileType = result;
                if (this.data.confirmarProfileType == 'Administrador SM' || this.data.confirmarProfileType == 'Administrador SC') {
                    this.resultPerfil = false;
                    this.showAdmiSM = false;
                    this.showAdmiGex = false;
                    this.showAdmiSC = false;
                    this.showSeguro=true;
                    this.data.showServicio = false;
                    this.pickList.valueSelectedtipoProducto = 'Seguro';
                    this.pickList.DSales_Tipo_de_Producto__c = 'Seguro';
                    this.getPickList4();
                }
                else if (this.data.confirmarProfileType == 'Administrador GEX' || this.data.confirmarProfileType == 'Administrador Armado' || this.data.confirmarProfileType == 'Administrador de Instalación') {
                    this.resultPerfil = false;
                    this.showAdmiSM = false;
                    this.showAdmiSC = false;
                    this.showSeguro=false;
                    this.showAdmiGex = true;
                    this.data.showServicio = true;
                    this.pickList.valueSelectedtipoProducto = 'Servicio';
                    this.pickList.DSales_Tipo_de_Producto__c = 'Servicio';
                    this.getPickList2();
                }
                else if (this.data.confirmarProfileType == 'Administrador del sistema' || this.data.confirmarProfileType == 'System Administrator') {
                    this.resultPerfil = true;
                    this.showAdmiSM = false;
                    this.showAdmiGex = false;
                    this.showAdmiSC = false;
                    this.showSeguro=false;
                    this.data.showServicio = true;
                    this.pickList.valueSelectedtipoProducto = 'Servicio';
                    this.pickList.DSales_Tipo_de_Producto__c = 'Servicio';
                    this.getPickList2();
                }
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }


    ProfileCheckerBusqueda(event) {
        this.resultPerfil = false;
        this.showAdmiSM = false;
        this.showSeguro=false;
        this.showAdmiSC=false;
        this.showAdmiGex = false;
        this.show = false;
        this.show2 = false;
        this.show3 = false;
        this.checkCategoria = false;
        this.checkSubCategoria = false;
        this.checkClase = false;
        this.checkFamilia = false;
        getCategoria()
            .then(result => {
                this.data = result;
                this.showSpinner = false;
                this.showc = false;
                console.log('hi');
                getProfileType()
                    .then(result => {
                        console.log(result);
                        console.log('hola2');
                        this.data.confirmarProfileType = result;
                        if (this.data.confirmarProfileType == 'Administrador SM' || this.data.confirmarProfileType == 'Administrador SC') {
                            this.resultPerfil = false;
                            this.showAdmiSM = false;
                            this.showAdmiSC= false;
                            this.showSeguro=true;
                            this.showAdmiGex = false;
                            this.data.showServicio = false;
                            this.pickList.valueSelectedtipoProducto = 'Seguro';
                            this.pickList.DSales_Tipo_de_Producto__c = 'Seguro';
                            this.getPickList4();
                        }
                        else if (this.data.confirmarProfileType == 'Administrador GEX' || this.data.confirmarProfileType == 'Administrador Armado' || this.data.confirmarProfileType == 'Administrador de Instalación') {
                            this.resultPerfil = false;
                            this.showAdmiSM = false;
                            this.showAdmiGex = true;
                            this.showAdmiSC= false;
                            this.showSeguro=false;
                            this.data.showServicio = true;
                            this.pickList.valueSelectedtipoProducto = 'Servicio';
                            this.pickList.DSales_Tipo_de_Producto__c = 'Servicio';
                            this.getPickList2();
                        }
                        else if (this.data.confirmarProfileType == 'Administrador del sistema' || this.data.confirmarProfileType == 'System Administrator') {
                            this.resultPerfil = true;
                            this.showAdmiSM = false;
                            this.showAdmiGex = false;
                            this.showAdmiSC= false;
                            this.showSeguro=false;
                            this.data.showServicio = true;
                            this.pickList.valueSelectedtipoProducto = 'Servicio';
                            this.pickList.DSales_Tipo_de_Producto__c = 'Servicio';
                            this.getPickList2();
                        }
                        this.searchAllRecords();
                    })
                    .catch(error => {
                        this.showSpinner = false;
                    });

            })
            .catch(error => {
                this.showSpinner = false;
            });


    }

    buscarAsignacionVinculacion(event) {
        this.data.asignacion = event.target.value;
    }

    handleInputChangeSku(event) {
        this.pickList.StockKeepingUnit = event.detail.value;
    }

    handleInputChangePrecioUnico(event) {
        this.pickList.dsalesPrecioUnico__c = event.detail.value;
    }

    handleInputChangeNameSS(event) {
        this.pickList.Name = event.detail.value;
    }

    handleInputChangeDescription(event) {
        this.pickList.Description = event.detail.value;
    }

    openPorcentajeCobro(event) {
        this.pickList.matrizSelected = '';
        this.pickList.DSales_PorcentajeCobro__c = 0;
        this.data.aniosporcentaje = 0;
        this.data.dos = 0;
        this.data.tres = 0;
        this.data.cuatro = 0;
        this.data.cinco = 0;
        this.data.seis = 0;
        this.showPorcentajeCobro = true;
        this.pickList.DSales_Aplicaporcentajecobro__c = true;
        this.pickList.aplicaCobro = true;
        console.log(this.showPorcentajeCobro);
    }

    limpiarPorcentajeCobro() {
        this.pickList.matrizSelected = '';
        this.pickList.DSales_PorcentajeCobro__c = 0;
        this.data.aniosporcentaje = 0;
        this.data.dos = 0;
        this.data.tres = 0;
        this.data.cuatro = 0;
        this.data.cinco = 0;
        this.data.seis = 0;
        this.showPorcentajeCobro = false;
        this.pickList.DSales_Aplicaporcentajecobro__c = false;
        this.pickList.aplicaCobro = false;
    }

    motoExternaSelected(event) {
        const checkpc = event.target.checked;
        this.pickList.aplicaMotoEx = checkpc;
        this.pickList.DSALES_Aplicaparamotoexterna__c = checkpc;
    }

    opcionpagoselected(event) {
        this.pickList.dsalesOpcionPago__c = event.target.value;
        console.log(JSON.parse(JSON.stringify(this.pickList.dsalesOpcionPago__c)));
    }

    onChangePorcentajeCobro(event) {
        this.data.DSALES_Anios__c = 1;
        this.matrizPorcentaje.anio1 = event.target.value;
    }

    onChangePorcentajeCobro2(event) {
        this.data.DSALES_Anios__c = 2;
        this.matrizPorcentaje.anio2 = event.target.value;
    }

    onChangePorcentajeCobro3(event) {
        this.data.DSALES_Anios__c = 3;
        this.matrizPorcentaje.anio3 = event.target.value;
    }

    onChangePorcentajeCobro4(event) {
        this.data.DSALES_Anios__c = 4;
        this.matrizPorcentaje.anio4 = event.target.value;
    }

    onChangePorcentajeCobro5(event) {
        this.data.DSALES_Anios__c = 5;
        this.matrizPorcentaje.anio5 = event.target.value;
    }

    onChangePorcentajeCobro6(event) {
        this.data.DSALES_Anios__c = 6;
        this.matrizPorcentaje.anio6 = event.target.value;
    }

    onchangeValueMatriz(event) {
        this.pickList.matrizSelected = event.detail.value;
    }
    onchangeCampana(event) {
        this.data.campanasSelected = event.detail.value;
    }

    onchangeTiposuso(event) {
        this.data.tiposUsoSelected = event.detail.value;
    }

    onchangeTypesChecked(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (const element of this.data.listapaginada2) {
            if (element.id == name) {
                element.tipoUso = check;
            }
        }
    }

    onchangeCampaignsChecked(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (const element of this.data.listapaginada2) {
            if (element.id == name) {
                element.campanas = check;
            }
        }
    }

    camposVacios() {
        if (this.data.aniosporcentaje == 0 && this.matrizPorcentaje.anio1 != 0) {
            this.data.camposCompletos = true;
        }
        else if (this.data.aniosporcentaje == 1 && this.matrizPorcentaje.anio1 != 0 && this.matrizPorcentaje.anio2 != 0) {
            this.data.camposCompletos = true;
        }
        else if (this.data.aniosporcentaje == 2 && this.matrizPorcentaje.anio1 != 0 && this.matrizPorcentaje.anio2 != 0 && this.matrizPorcentaje.anio3 != 0) {
            this.data.camposCompletos = true;
        }
        else if (this.data.aniosporcentaje == 3 && this.matrizPorcentaje.anio1 != 0 && this.matrizPorcentaje.anio2 != 0 && this.matrizPorcentaje.anio3 != 0 &&
            this.matrizPorcentaje.anio4 != 0) {
            this.data.camposCompletos = true;
        }
        else if (this.data.aniosporcentaje == 4 && this.matrizPorcentaje.anio1 != 0 && this.matrizPorcentaje.anio2 != 0 && this.matrizPorcentaje.anio3 != 0 &&
            this.matrizPorcentaje.anio4 != 0 && this.matrizPorcentaje.anio5 != 0) {
            this.data.camposCompletos = true;
        }
        else if (this.data.aniosporcentaje == 5 && this.matrizPorcentaje.anio1 != 0 && this.matrizPorcentaje.anio2 != 0 && this.matrizPorcentaje.anio3 != 0 &&
            this.matrizPorcentaje.anio4 != 0 && this.matrizPorcentaje.anio5 != 0 && this.matrizPorcentaje.anio6 != 0) {
            this.data.camposCompletos = true;
        }
        else this.data.camposCompletos = false;
    }


    confirmarGuardar() {
        console.log('holaaaa');
        console.log(this.pickList.valueSelectedtipoSeguroServicio);
        if (this.pickList.valueSelectedtipoProducto == 'Servicio') {
            this.validacionCampos();
            console.log(this.data.confirmarCampos);
            this.data.confirmarGuardar = false;
            if (this.ValueCategoriaSelected == '' ||
                this.pickList.ValueClasesSelected == '' ||
                this.pickList.Description == '' ||
                this.pickList.Name == '' ||
                this.pickList.StockKeepingUnit == '' ||
                this.data.confirmarCampos === false
            ) {
                this.pushMessage('Advertencia', 'warning', 'Existen campos vacios o no seleccionados');
            }
            else {
                this.guardarProductIntan();
            }
        } else {
            this.confirmarGuardarAux();
        }
    }

    confirmarGuardarAux() {
        this.data.confirmarGuardar = false;
        if (this.ValueCategoriaSelected == '' ||
            this.pickList.ValueClasesSelected == '' ||
            this.pickList.Description == '' ||
            this.pickList.Name == '' ||
            this.pickList.StockKeepingUnit == ''
        ) {
            this.pushMessage('Advertencia', 'warning', 'Existen campos vacios o no seleccionados');
        }
        else {
            this.guardarProductIntan();
            if( this.pickList.valueSelectedtipoSeguroServicio=='Seguro de Motos'){
            }
            else if ( this.pickList.valueSelectedtipoSeguroServicio=='Seguro de Celulares'){
            }
        }
    }

    validacionCampos() {
        this.data.confirmarCampos = true;
        if (this.pickList.formaCobro != '') {
            if (this.pickList.formaCobro == 'Porcentaje de Cobro') {
                this.camposVacios();
                if (this.data.camposCompletos === false) {
                    this.data.confirmarCampos = false;
                }
            }
            else if (this.pickList.formaCobro == 'Matriz de Precios') {
                if (this.pickList.matrizSelected == '') {
                    this.data.confirmarCampos = false;
                }
            }
            else if (this.pickList.formaCobro == 'Costo Fijo') {
                if (this.pickList.dsalesPrecioUnico__c == '') {
                    this.data.confirmarCampos = false;
                }
            }
            else if (this.pickList.formaCobro == 'Proveedor') {
                console.log('en proceso...')
            }
        }
        if(this.pickList.valueSelectedtipoSeguroServicio=='Instalaciones'){
            if(this.pickList.dsalesProveedor__c==''){
                this.data.confirmarCampos=false;
            }
        }
    }


    guardarProductIntan() {
        if (this.pickList.valueSelectedtipoProducto == 'Servicio') {
            this.pickList.DSALES_ServEspecifico__c = this.pickList.valueSelectedtipoSeguroServicio;
        }
        else {
            this.pickList.DSALES_SegEspecifico__c = this.pickList.valueSelectedtipoSeguroServicio;
        }
        createProductIntan({ productIntan: this.pickList, sku: this.pickList.StockKeepingUnit }
        ).then(result => {
            this.message = result.message;
            this.error = undefined;
            if (this.message !== undefined) {
                this.pushMessage('Error al crear Servicio', 'Warning', 'Error al crear registro')
            }
            this.pushMessage('Guardado', 'success', 'Producto guardado exitosamente.')
            this.showCrearIntangible = false;
            if (this.pickList.valueSelectedtipoProducto == 'Servicio') {
                this.data.confirmarGuardar = true;
                getidservicio({ sku: this.pickList.StockKeepingUnit })
                    .then(result2 => {
                        this.data.idservicio = result2;
                        this.showSpinner = false;
                        if (this.pickList.formaCobro == 'Matriz de Precios') {
                            updateMatriz({ allData: JSON.stringify(this.pickList.matrizSelected), typeServicio: result2 })
                                .then(result3 => {
                                    console.log(result3);
                                }).catch(error => {
                                    this.showSpinner = false;
                                    console.log(error);
                                });
                        }
                        else if(this.pickList.formaCobro == 'Porcentaje de Cobro') {
                            insertPocentajeCobro({ idservicio: result2, jsonp: JSON.stringify(this.matrizPorcentaje) })
                                .then(result4 => {
                                    console.log(result4);
                                }).catch(error => {
                                    console.log(error);
                                    this.showSpinner = false;
                                });
                        }
                        if(this.pickList.valueSelectedtipoSeguroServicio=='Instalaciones'){
                                asignacionProveedores({ idProveedor: this.pickList.dsalesProveedor__c, idServicio: result2 })
                                .then(result5 => {
                                    console.log(result5);
                                }).catch(error => {
                                    console.log(error);
                                    this.showSpinner = false;
                                });

                                asignacionEncuesta({ idEncuesta: this.pickList.dsalesEncuestaPISyS__c, idServicio: result2 })
                                .then(result6 => {
                                    console.log(result6);
                                }).catch(error => {
                                    console.log(error);
                                    this.showSpinner = false;
                                });   
                        }
                    }).catch(error => {
                        console.log(error);
                        this.showSpinner = false;
                    });


            }
            getidservicio({ sku: this.pickList.StockKeepingUnit })
                .then(result11 => {
                    this.data.idservicio = result11;
                    this.showSpinner = false;
                    insertListaPrecios({ idproductoservicio: result11, opcion: '1', json2: JSON.stringify(this.data.listapaginada2) })
                        .then(result22 => {
                            console.log(result22);
                        }).catch(error22 => {
                            console.log(error22);
                        });
                        if( this.pickList.valueSelectedtipoSeguroServicio=='Seguro de Motos'){
                            insertProveedores({ idSeguroServicio: result11, opcion: 'Inter' })
                            .then(result222 => {
                                console.log(result222);
                            }).catch(error222 => {
                                console.log(error222);
                            });
                        }
                        else if ( this.pickList.valueSelectedtipoSeguroServicio=='Seguro de Celulares'){
                            insertProveedores({ idSeguroServicio: result11, opcion: 'Cardiff' })
                            .then(result223 => {
                                console.log(result223);
                            }).catch(error223 => {
                                console.log(error223);
                            });
                        }
                }).catch(error => {
                    console.log(error);
                    this.showSpinner = false;
                });

        })
            .catch(error => {
                this.message = undefined;
                this.error = error;
                this.pushMessage('Error al guardar, SKU ya existente', 'Warning', 'Error al crear registro')
            });



    }

    guardarAsignacion() {
        console.log(JSON.parse(JSON.stringify(this.data.listapaginada)));
        console.log('id: ' + this.data.idservicio)
        insertVinculacion({ dataJSON: JSON.stringify(this.data.listapaginada), idservicio: this.data.idservicio })
            .then(result => {
                if (result) {
                    this.pushMessage('Advertencia', 'warning', '¡Cuidado¡, Alguno(s) de los producto(s) vinculados,  ya tienen un servicio dado de alta.');
                }
                else {
                    this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente.');
                }
                this.onClickBuscarIntanProduct();
            }).catch(error => {
                console.log(error);
                this.showSpinner = false;
                this.pushMessage('Error', 'error', 'Ha ocurrido un error al actualizar los registros.');
            });
        this.showConfirmarVincular = false;
        this.openTableVincProduct = false;
        this.data.listapaginada=[];
    }

    onClickBuscarIntanProduct() {
        this.limpiarCampos();
        this.showSpinner = true;
        this.currentPage = 1;
        if (this.buscarServicio === '') {
            this.buscarServicio = this.data.idservicio;
        }
        this.data.idservicio = this.buscarServicio;
        this.showSpinner = true;
        getBuscarVinculacion({ servicio: this.buscarServicio })
            .then(result => {
                this.data.listasignacion = result;
                this.error = undefined;
                if (this.data.listasignacion > 0) {
                    this.openTablaResultado = true;
                } else if (this.data.listasignacion< 1) {
                    this.pushMessage('Advertencia', 'warning', 'No se han encontrado Asignaciones, Crea una.');
                    this.openTablaResultado = true;
                    this.showSpinner=false;
                }
                this.fetchData3();
            }).catch(error => {
                console.log(error);
                this.pushMessage('Advertencia', 'warning', 'Este Servicio no existe.');
                this.showSpinner = false;
                this.openTablaResultado = false;
            });

    }

    onClickBuscarIntanProduct2() {
        this.limpiarCampos();
        this.data.busqueda=true;
        this.showSpinner = true;
        this.currentPage = 1;
        if (this.buscarServicio === '') {
            this.buscarServicio = this.data.idservicio;
        }
        this.data.idservicio = this.buscarServicio;
        this.showSpinner = true;
        getBuscarVinculacion({ servicio: this.buscarServicio })
            .then(result => {
                this.data.listasignacion = result;
                this.error = undefined;
                if (this.data.listasignacion > 0) {
                    this.openTablaResultado = true;
                } else if (this.data.listasignacion< 1) {
                    this.pushMessage('Advertencia', 'warning', 'No se han encontrado Asignaciones, Crea una.');
                    this.openTablaResultado = true;
                    this.showSpinner=false;
                }
                this.fetchData31();
            }).catch(error => {
                console.log(error);
                this.pushMessage('Advertencia', 'warning', 'Este Servicio no existe.');
                this.showSpinner = false;
                this.openTablaResultado = false;
            });

    }

    getidserviciostring() {
        getidservicio({ sku: this.buscarServicio })
            .then(result => {
                this.data.idservicio = result;
                this.showSpinner = false;
            }).catch(error => {
                console.log(error);
                this.showSpinner = false;
            });
    }
    onChangeInputBuscarServicio(event) {
        this.buscarServicio = event.target.value;
    }

    cancelar2() {
        this.openTablaResultado = false;

    }

    selectAllSku(event) {
        const check = event.target.checked;
        for (const element of this.data.listapaginada3) {
            element.seleccionadoSubcategoria = check;
            element.seleccionadoSku = check;
            element.seleccionadoDept = check;
            element.seleccionadoClase = check;
            element.seleccionadoFamilia = check;
        }
        this.checkSku = check;
    }

    updateVinculacion() {
        upsertVinculacion({ dataJSON: JSON.stringify(this.data.listapaginada3) })
            .then(resultid => {
                console.log(resultid);
                this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente.');
                this.onClickBuscarIntanProduct();
            }).catch(errorc => {
                console.log(errorc);
                this.showSpinner = false;
                this.pushMessage('Error', 'error', 'Ha ocurrido un error al actualizar los registros.');
            });


        this.showConfirmarDesvincular = false;
    }

    selectAllSkuSelected(event) {
        this.data.checkDepartamento = false;
        const check1 = event.target.checked;
        const checkDept = event.target.label;
        for (const element of this.data.listapaginada3) {
            if (element.sku === checkDept) {
                element.seleccionadoSku = check1;
            }

        }
        this.checkDepartamento = check1;
    }

    selectAllDepartamentos(event) {
        this.data.checkDepartamento = false;


        const check1 = event.target.checked;
        const checkDept = event.target.label;
        for (const element of this.data.listapaginada3) {
            if (element.departamento === checkDept) {
                element.seleccionadoDept = check1;
                element.seleccionadoSku = check1;
            }
        }
        this.checkDepartamento = check1;
    }

    selectAllSubcategoria(event) {

        const check1 = event.target.checked;
        const checkDept = event.target.label;
        for (const element of this.data.listapaginada3) {
            if (element.subcategoria === checkDept) {
                element.seleccionadoSubcategoria = check1;
                element.seleccionadoDept = check1;
                element.seleccionadoSku = check1;
            }
        }
    }

    selectAllClases(event) {
        this.data.checkClase = false;

        const check2 = event.target.checked;
        const checkClass = event.target.label;
        for (const element of this.data.listapaginada3) {
            if (element.clase === checkClass) {
                element.seleccionadoClase = check2;
                element.seleccionadoDept = check2;
                element.seleccionadoSku = check2;
                element.seleccionadoSubcategoria = check2;

            }
        }
        this.checkClase = check2;
    }

    selectAllFamilias(event) {
        this.data.checkfamilia = false;
        const check3 = event.target.checked;
        const checkFam = event.target.label;
        for (const element of this.data.listapaginada3) {
            if (element.familia === checkFam) {
                element.seleccionadoClase = check3;
                element.seleccionadoDept = check3;
                element.seleccionadoSku = check3;
                element.seleccionadoFamilia = check3;
                element.seleccionadoSubcategoria = check3;
            }
        }
        this.data.checkFamilia = check3;
    }

    selectAllSkusProducto(event) {
        const checkP = event.target.checked;
        for (const element of this.data.listapaginada) {
            element.seleccionadoSku = checkP;
            element.seleccionadoSubcategoria = checkP;
            element.seleccionadoClase = checkP;
            element.seleccionadoDept = checkP;
            element.seleccionadoFamilia = checkP;
        }
        this.checkSkus = checkP;
    }

    selectAllSkuProducto(event) {
        this.data.checkSku = false;
        this.data.listSku = event.target.label;
        const check1 = event.target.checked;
        for (const element of this.data.listapaginada) {
            if (element.sku === this.data.listSku) {
                element.seleccionadoSku = check1;
            }
        }
        this.checkDepartamento = check1;
    }


    selectAllDepartamentosProducto(event) {
        this.data.checkDepartamento = false;
        this.data.DSALES_Departamento__c = event.target.label;
        const check1 = event.target.checked;
        for (const element of this.data.listapaginada) {
            if (element.departamento === this.data.DSALES_Departamento__c) {
                element.seleccionadoDept = check1;
                element.seleccionadoSku = check1;
            }
        }
        this.checkDepartamento = check1;
    }

    selectAllSubcategoriaProducto(event) {
        this.data.checkSubcategoria = false;
        this.data.DSALES_Subcategoria__c = event.target.label;
        const check1 = event.target.checked;
        for (const element of this.data.listapaginada) {
            if (element.subcategoria === this.data.DSALES_Subcategoria__c) {
                element.seleccionadoSubcategoria = check1;
                element.seleccionadoDept = check1;
                element.seleccionadoSku = check1;
            }
        }
    }

    selectAllClasesProducto(event) {
        this.data.checkClase = false;
        const check2 = event.target.checked;
        this.data.DSALES_Clase__c = event.target.label;
        for (const element of this.data.listapaginada) {
            if (element.clase === this.data.DSALES_Clase__c) {
                element.seleccionadoClase = check2;
                element.seleccionadoDept = check2;
                element.seleccionadoSku = check2;
                element.seleccionadoSubcategoria = check2;
            }
        }
        this.checkClase = check2;
    }

    selectAllFamiliasProducto(event) {
        this.data.checkfamilia = false;
        const check3 = event.target.checked;
        this.data.DSALES_Familia__c = event.target.label;
        for (const element of this.data.listapaginada) {
            if (element.familia === this.data.DSALES_Familia__c) {
                element.seleccionadoClase = check3;
                element.seleccionadoDept = check3;
                element.seleccionadoSku = check3;
                element.seleccionadoFamilia = check3;
                element.seleccionadoSubcategoria = check3;
                this.data.DSALES_Departamento__c = element.departamento;
                this.data.DSALES_Clase__c = element.clase;
                this.data.DSALES_SKU__c = element.sku;
                this.data.DSALES_Servicio_Seguro__c = element.id;
            }
        }
        this.data.checkFamilia = check3;
    }

    skuSelected(event) {
        this.data.checkfamilia = false;
        const check3 = event.target.checked;
        for (const element of this.data.listapaginada3) {
            if (element.seleccionadoSku === true) {
                this.data.listSkuSelected = element.sku;

            }
        }
        this.data.checkFamilia = check3;
    }

    vincularNuevoServicio() {
        getidservicio({ sku: this.pickList.StockKeepingUnit })
            .then(result => {
                this.data.idservicio = result;
                this.buscarProductsNoVinc();
            }).catch(error => {
                this.showSpinner = false;
            });
        this.data.confirmarGuardar = false;
        this.showVincuProduct = true;
        this.openTablaResultado = true;

    }
    buscarProductsNoVinc() {
        this.currentPage = 1;
        this.showSpinner=true;
        this.busquedaPers='';
        this.data.busqueda=false;
        getBuscarProducto({ servicio: this.data.idservicio })
            .then(result => {
                this.data.listaproductos = result;
                this.fetchData();
                if (this.data.listaproductos > 0) {
                    this.openTableVincProduct = true;
                } else {
                    this.pushMessage('Advertencia', 'warning', 'No se han encontrado productos.');
                    this.onClickBuscarIntanProduct();
                }
            }).catch(error => {
                this.showSpinner = false;
            });


    }

    buscarProductsNoVinc2() {
        this.currentPage = 1;
        this.showSpinner=true;
        getBuscarProducto({ servicio: this.data.idservicio })
            .then(result => {
                this.data.listaproductos = result;
                this.fetchData11();
                if (this.data.listaproductos > 0) {
                    this.openTableVincProduct = true;
                } else {
                    this.pushMessage('Advertencia', 'warning', 'No se han encontrado productos.');
                    this.onClickBuscarIntanProduct();
                }
            }).catch(error => {
                this.showSpinner = false;
            });
    }

    agregarAnioPorcentaje() {
        if (this.data.aniosporcentaje < 5) {
            this.data.aniosporcentaje = this.data.aniosporcentaje + 1;
            if (this.data.aniosporcentaje == 1) {
                this.data.dos = true;
                this.data.tres = false;
                this.data.cuatro = false;
                this.data.cinco = false;
                this.data.seis = false;
            }
            else if (this.data.aniosporcentaje == 2) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = false;
                this.data.cinco = false;
                this.data.seis = false;
            }
            else if (this.data.aniosporcentaje == 3) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = true;
                this.data.cinco = false;
                this.data.seis = false;
            }
            else if (this.data.aniosporcentaje == 4) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = true;
                this.data.cinco = true;
                this.data.seis = false;
            }
            else if (this.data.aniosporcentaje == 5) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = true;
                this.data.cinco = true;
                this.data.seis = true;
            }
        }

    }
    quitarAnioPorcentaje() {
        if (this.data.aniosporcentaje > 0) {
            this.data.aniosporcentaje = this.data.aniosporcentaje - 1;
            if (this.data.aniosporcentaje == 0) {
                this.data.dos = false;
                this.data.tres = false;
                this.data.cuatro = false;
                this.data.cinco = false;
                this.data.seis = false;
                this.matrizPorcentaje.anio2 = 0;
            }
            else if (this.data.aniosporcentaje == 1) {
                this.data.dos = true;
                this.data.tres = false;
                this.data.cuatro = false;
                this.data.cinco = false;
                this.data.seis = false;
                this.matrizPorcentaje.anio3 = 0;
            }
            else if (this.data.aniosporcentaje == 2) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = false;
                this.data.cinco = false;
                this.data.seis = false;
                this.matrizPorcentaje.anio4 = 0;
            }
            else if (this.data.aniosporcentaje == 3) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = true;
                this.data.cinco = false;
                this.data.seis = false;
                this.matrizPorcentaje.anio5 = 0;
            }
            else if (this.data.aniosporcentaje == 4) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = true;
                this.data.cinco = true;
                this.data.seis = false;
                this.matrizPorcentaje.anio6 = 0;
            }
        }
    }

    openFormCampaigns(event) {
        this.data.sku = event.currentTarget.dataset.id;
        getidservicio({ sku: this.data.sku })
            .then(result => {
                this.data.idProducto = result;
                this.getCampanas();
            }).catch(error => {
                console.log(error);
            });
    }

    openFormTypes(event) {
        this.data.sku = event.currentTarget.dataset.id;
        getidservicio({ sku: this.data.sku })
            .then(result => {
                this.data.idProducto = result;
                this.getTiposUso();
            }).catch(error => {
                console.log(error);
            });
    }

    closeformCampaignsTypes() {
        this.data.showCampaigns = false;
        this.data.showTypes = false;
        this.tiposUsoSelected = [];
        this.campanasSelected = [];
    }
    cancelar3() {
        this.openTableVincProduct = false;
        this.limpiarCampos();
        this.onClickBuscarIntanProduct();
    }
    cancelar31() {
        this.openFormAsignarTiendas = false;
        this.limpiarcamposTiendaSeguro();
    }
    openEmergenteDesvincular() {
        for (const element of this.data.listapaginada3) {
            if (element.seleccionadoSku === true) {
                this.showConfirmarDesvincular = true;
            }
        }
    }

    cancelar4() {
        this.showConfirmarDesvincular = false;
        this.data.confirmarGuardar = false;
        this.limpiarCampos();
        this.openFormIntangible();
    }

    openEmergenteVincular() {
        for (const element of this.data.listapaginada) {
            if (element.seleccionadoSku === true) {

                this.showConfirmarVincular = true;
            }
        }
    }

    cancelar5() {
        this.showConfirmarVincular = false;
    }

    getCampanas() {
        getCampaings()
            .then(campanas => {
                this.data.listaCampanas = campanas;
                this.getCampanasUsadas();
            })
    }

    getTiposUso() {
        getTipoUso()
            .then(tipos => {
                this.data.listaTiposuso = tipos;
                this.getTiposUsoUsadas();
            })
    }

    getTiposUsoUsadas() {
        getTiposUsoUsed({ idProducto: this.data.idProducto })
            .then(tipos => {
                this.data.tiposUsoSelected = tipos;
                this.tiposUsoSelected.push(...this.data.tiposUsoSelected);
                this.data.showTypes = true;
            })
    }

    getCampanasUsadas() {
        getCampanasUsed({ idProducto: this.data.idProducto })
            .then(tipos => {
                this.data.campanasSelected = tipos;
                this.campanasSelected.push(... this.data.campanasSelected);
                this.data.showCampaigns = true;
            })
    }

    getSkuforCampaings() {
        updateCampaigns({ allData: JSON.stringify(this.data.campanasSelected), idProducto: this.data.idProducto })
            .then(result => {
                console.log(result);
                this.pushMessage('Exitoso', 'success', 'Campañas actualizadas exitosamente.');
            }).catch(error => {
                console.log(error);
            });
        this.closeformCampaignsTypes();
    }

    getSkuforTypes() {
        updateTipoUso({ allData: JSON.stringify(this.data.tiposUsoSelected), idProducto: this.data.idProducto })
            .then(result => {
                console.log(result);
                this.pushMessage('Exitoso', 'success', 'Tipos de usos actualizados exitosamente.');
            }).catch(error => {
                console.log(error);
            });
        this.closeformCampaignsTypes();
    }

    openTypesVincuMasiva() {
        getTipoUso()
            .then(tipos => {
                this.data.listaTiposuso = tipos;
                this.data.showTypes = true;
            })
        this.data.idProducto = null;
    }

    handleInputChangeVehicleID(event) {
        const name = event.target.name;
        this.data.idvehiculo = event.detail.value;
        for (const element of this.data.listapaginada2) {
            if (element.id == name) {
                element.idvehiculo = this.data.idvehiculo;

            }
        }
    }

    getNameRecordTypeId() {
        if (this.data.confirmarProfileType == 'Administrador SM') {
            this.data.nameRecordType = 'Administrador SM';
        }
        else if (this.data.confirmarProfileType == 'Administrador del sistema' || this.data.confirmarProfileType == 'System Administrator') {
            this.data.nameRecordType = 'Administrador del sistema';
        }
        else if (this.data.confirmarProfileType == 'Administrador GEX') {
            this.data.nameRecordType = 'Administrador GEX';
        }
        else if (this.data.confirmarProfileType == 'Administrador Armado') {
            this.data.nameRecordType = 'Administrador Armado';
        }
        else if (this.data.confirmarProfileType == 'Administrador SC') {
            this.data.nameRecordType = 'Administrador SC';
        }
        else if (this.data.confirmarProfileType == 'Administrador Instalaciones') {
            this.data.nameRecordType = 'Administrador Instalaciones';
        }
    }

    openSearchFilter() {
        this.showbyfilter = false;
        this.showCrearIntangible = false;
        this.showVincuProduct = false;
        this.currentPage = 1;
        getCategoria()
            .then(result => {
                this.data = result;
                this.showSpinner = false;
                this.showc = true;

            })
            .catch(error => {
                this.showSpinner = false;
            });
        this.show = false;
        this.show2 = false;
        this.show3 = false;
        this.checkCategoria = false;
        this.checkSubCategoria = false;
        this.checkClase = false;
        this.checkFamilia = false;

    }

    getservicecategories() {
        this.data.showcompras = true;
        this.data.valueCategoryService = '';
        this.data.valueSubcategoryService = '';
        this.data.valueClassService = '';
        this.data.valueFamilyService = '';
        getToken()
            .then(result => {
                this.data.tokenAccess = result;
                console.log(result);
                getserviciocategorias({ recordName: 'empty', token: this.data.tokenAccess })
                    .then(result2 => {
                        this.data.servicioCategoria = result2;
                    }).catch(error2 => {
                        console.log(error2);
                    });
            }).catch(error => {
                console.log(error);
            });
    }

    getcategoriespage() {
        this.data.showcomprascat = true;
        this.data.valueCategoryService = '';
        this.data.valueSubcategoryService = '';
        this.data.valueClassService = '';
        this.data.valueFamilyService = '';
        getToken()
            .then(result => {
                this.data.tokenAccess = result;
                console.log(result);
                getserviciocategorias({ recordName: 'empty', token: this.data.tokenAccess })
                    .then(result2 => {
                        this.data.servicioCategoria = result2;
                    }).catch(error2 => {
                        console.log(error2);
                    });
            }).catch(error => {
                console.log(error);
            });
    }

    getservicesubcategories(event) {
        this.data.valueCategoryService = event.target.value;
        getserviciosubcategorias({ valueCategoria: this.data.valueCategoryService, token: this.data.tokenAccess })
            .then(result => {
                this.data.servicioSubcategoria = result;
            }).catch(error => {
                console.log(error);
            });
    }

    getserviceclass(event) {
        this.data.valueSubcategoryService = event.target.value;
        getservicioclase({ valueCategoria: this.data.valueCategoryService, valueSubcategoria: this.data.valueSubcategoryService, token: this.data.tokenAccess })
            .then(result => {
                this.data.servicioClases = result;
            }).catch(error => {
                console.log(error);
            });
    }

    getservicefamily(event) {
        this.data.valueClassService = event.target.value;
        this.listaClaseToken.push(this.data.valueClassService);
        this.listaClaseToken.push(this.data.tokenAccess);
        getserviciofamilia({ valueCategoria: this.data.valueCategoryService, valueSubcategoria: this.data.valueSubcategoryService, valueClases: this.listaClaseToken })
            .then(result => {
                this.data.servicioFamilias = result;
            }).catch(error => {
                console.log(error);
            });
    }

    getValueFamily(event) {
        this.data.valueFamilyService = event.target.value;
    }

    getservicesku() {
        if (this.data.valueCategoryService == '' || this.data.valueSubcategoryService == '' || this.data.valueClassService == '' || this.data.valueFamilyService == '') {
            this.pushMessage('Advertencia', 'warning', 'Existen campos vacios o no seleccionados');
        }
        else {
            this.listaClaseFamiliaToken.push(this.data.valueClassService);
            this.listaClaseFamiliaToken.push(this.data.valueFamilyService);
            this.listaClaseFamiliaToken.push(this.data.tokenAccess);
            getserviciosku({ valueCategoria: this.data.valueCategoryService, valueSubcategoria: this.data.valueSubcategoryService, valueClasesFamiliasToken: this.listaClaseFamiliaToken })
                .then(result => {
                    this.data.servicioSku = result;
                }).catch(error => {
                    console.log(error);
                });
        }

    }

    handleKeyDownSearch(event) {
        if (event.key === 'Enter') {
            this.search();
            console.log('Enter presionado');
        }
    }

    handleKeyDownSearch2(event) {
        if (event.key === 'Enter') {
            this.buscarProductsNoVinc2();
            console.log('Enter presionado');
        }
    }

    handleKeyDownSearch3(event) {
        if (event.key === 'Enter') {
            this.onClickBuscarIntanProduct2();
            console.log('Enter presionado');
        }
    }

    openAsignarTiendas() {
        this.openFormAsignarTiendas = true;
        this.showSpinner = true;
        getPickListRegiones()
            .then(result => {
                console.log(this.recordId);
                this.dataSeguros = result;
                seleccionSegurosServicios({idSeguros: this.buscarServicio })
                    .then(result => {
                        this.data.seleccion = result;
                        if(result=='Seguros'){
                            this.gerenteActivado=false;
                        }
                        else if(result=='Servicios'){
                            this.gerenteActivado=true;
                        }
                        this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
        });
            })
            .catch(error => {
                this.showSpinner = false;
                console.log(error);
            });
        this.getListTiendas();
        this.checkRegion = false;
        this.checkCiudad = false;
        this.checkGerente = false;
        this.checkTienda = false;
    }

    selectAllRegion(event) {
        const check = event.target.checked;
        for (const element of this.dataSeguros.listRegiones) {
            element.seleccionado = check;
            for (const element2 of this.dataSeguros.listCiudades) {
              if (element.valor == element2.depende) {
                  element2.seleccionado = check;
              } 
              for (const element3 of this.dataSeguros.listGerentes) {
                  if (element2.valor == element3.depende) {
                      element3.seleccionado = check;
                  } 
              }
          }
        }
        this.checkRegion = check;
        this.mostrarGerentes();
    }

    selectAllCiudad(event) {
        const check = event.target.checked;
        for (const element of this.dataSeguros.listCiudades) {
            element.seleccionado = check;
            for (const element2 of this.dataSeguros.listGerentes) {
              if (element.valor == element2.depende) {
                  element2.seleccionado = check;
              } 
          }
        }
        this.checkCiudad = check;
        this.mostrarGerentes();
    }

    selectAllGerente(event) {
        const check = event.target.checked;
        for (const element of this.dataSeguros.listGerentes) {
            element.seleccionado = check;
        }
        this.checkGerente = check;
        this.mostrarGerentes();
    }

    selectAllTienda(event) {
        const check = event.target.checked;

        for (const element of this.dataSeguros.listTiendas) {
            element.seleccionado = check;
        }
        this.checkTienda = check;
        console.log(JSON.parse(JSON.stringify(this.dataSeguros.listTiendas)));
    }

    mostrarCiudades() {
        this.cargarPickList();
    }

    mostrarGerentes() {
        if(this.data.seleccion=='Seguros'){
            this.cargarPickList();
        }
        else if(this.data.seleccion=='Servicios'){
           this.cargarPickListServ();
        }
    }

    mostrarTienda() {
        this.cargarPickList();
    }

    cargarPickList() {
        this.showSpinner = true;
        getPicklistOptionsDependentSM({ allData: JSON.stringify(this.dataSeguros) })
        .then(result => {
            this.dataSeguros = result;
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
        });
       
    }

    cargarPickListServ() {
        this.showSpinner = true;
        getPicklistOptionsDependent({ allData: JSON.stringify(this.dataSeguros) })
        .then(result => {
            this.dataSeguros = result;
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
        });
       
    }

    onclickRegion(event) {
        let x = false;
        const valor = event.target.name;
        const check = event.target.checked;
        const depende = valor;
        let depende2='';
        for (const element of this.dataSeguros.listRegiones) {
            if (valor == element.valor) {
                element.seleccionado = check;
            }
        }
        for (const element of this.dataSeguros.listCiudades) {
            if (depende == element.depende) {
                element.seleccionado = check;
                depende2=element.valor;
            }
          }
          for (const element of this.dataSeguros.listGerentes) {
              if (depende2 == element.depende) {
                  element.seleccionado = check;
              }
          }
        this.mostrarGerentes();
    }

    onclickCiudad(event) {
        let x = false;
        const valor = event.target.name;
        const check = event.target.checked;
        const depende = valor;
        for (const element of this.dataSeguros.listCiudades) {
            if (valor == element.valor) {
                element.seleccionado = check;
            }     
        }
        for (const element of this.dataSeguros.listGerentes) {
            if (depende == element.depende) {
                element.seleccionado = check;
            }
        }
        this.mostrarGerentes();
    }

    onclickGerente(event) {
        let x = false;
        const valor = event.target.name;
        const check = event.target.checked;
        for (const element of this.dataSeguros.listGerentes) {
            if (valor == element.valor) {
                element.seleccionado = check;
            }
        }
        this.mostrarGerentes();
      }

    onclicklistTiendas(event) {
        let x = false;
        const valor = event.target.name;
        const check = event.target.checked;
        for (const element of this.dataSeguros.listTiendas) {
            if (valor == element.valor) {
                element.seleccionado = check;
            }
        }
    }

    getListTiendas() {
        getPickListTiendasSeguro({ idSeguros: this.buscarServicio })
            .then(result => {
                this.listTiendasActivas = result;
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                console.log(error);
            });
    }


    guardarAsignacionVinculacion() {
        console.log(this.buscarServicio);
        vinculacionTiendaSeguro({ dataJsonTienda: JSON.stringify(this.dataSeguros.listTiendas), idSeguros: this.buscarServicio, vincular: this.vincular })
            .then(result => {
                console.log(result);
                this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente.');
                this.getListTiendas();
            }).catch(error => {
                console.log(error);
                this.showSpinner = false;
                this.pushMessage('Error', 'error', 'Ha ocurrido un error al actualizar los registros.');
            });
    }


    opcionVincular(event) {
        this.vincular = event.target.checked;
        if (this.vincular) {
            this.desvincular = false;
        }
        else {
            this.desvincular = true;
        }
    }

    opcionDesvincular(event) {
        this.desvincular = event.target.checked;;
        if (this.desvincular) {
            this.vincular = false;
        }
        else {
            this.vincular = true;
        }

    }

    limpiarcamposTiendaSeguro() {
        this.dataSeguros.listTiendas = [];
        this.dataSeguros.listCiudades = [];
        this.dataSeguros.listRegiones = [];
        this.dataSeguros.listGerentes = [];

    }

    handleFirst() {
        this.showSpinner = true;
        this.currentPage = 1;
        if (this.data.opcionPaginado == 1) {
            this.fetchData();
        }
        else if (this.data.opcionPaginado == 2) {
            this.fetchData2();
        }
        else {
            this.fetchData3();
        }
    }

    handleFinal() {
        this.showSpinner = true;
        this.currentPage = this.totalPages;
        if (this.data.opcionPaginado == 1) {
            this.fetchData();
        }
        else if (this.data.opcionPaginado == 2) {
            this.fetchData2();
        }
        else {
            this.fetchData3();
        }
    }

    handlePrevious() {
        this.showSpinner = true;
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            if (this.data.opcionPaginado == 1) {
                this.fetchData();
            }
            else if (this.data.opcionPaginado == 2) {
                this.fetchData2();
            }
            else {
                this.fetchData3();
            }
        }
    }

    handleNext() {
        this.showSpinner = true;
        console.log(this.showSpinner);
        if (this.currentPage < this.totalPages)
            this.currentPage += 1;
        if (this.data.opcionPaginado == 1) {
            this.fetchData();
        }
        else if (this.data.opcionPaginado == 2) {
            this.fetchData2();
        }
        else {
            this.fetchData3();
        }
    }

    fetchData() {
        getRecordsFromServer2({ servicio: this.data.idservicio, pageNumber: this.currentPage, pageSize: this.itemsPerPage })
            .then(result => {
                this.data.listapaginada = result;
                this.totalPages = Math.ceil(this.data.listaproductos/ this.itemsPerPage);
                this.data.opcionPaginado = 1;
                this.showSpinner = false;
            })
            .catch(error => {
                // Manejo de errores si es necesario
            });
    }

    fetchData11() {
        this.data.listapaginada='';
        getRecordsFromServer21({ servicio: this.data.idservicio, busquedaPers: this.buscarPers })
            .then(result => {
                this.data.listapaginada = result;
                this.totalPages = Math.ceil(this.data.listaproductos/ this.itemsPerPage);
                this.data.opcionPaginado = 1;
                this.showSpinner = false;
            })
            .catch(error => {
                // Manejo de errores si es necesario
            });
    }

    fetchData2() {
        console.log(JSON.parse(JSON.stringify(this.data.listServicios)));
        getRecordsFromServer({ pageNumber: this.currentPage, pageSize: this.itemsPerPage, pageData: JSON.stringify(this.data.listServicios) })
            .then(result => {
                this.data.listapaginada2 = result;
                this.totalPages = Math.ceil(Object.keys(this.data.listServicios).length / this.itemsPerPage);
                this.data.opcionPaginado = 2;
                this.showSpinner = false;
            })
            .catch(error => {
                // Manejo de errores si es necesario
            });
    }

    fetchData3() {
        getRecordsFromServer3({ servicio: this.buscarServicio, pageNumber: this.currentPage, pageSize: this.itemsPerPage })
            .then(result => {
                this.data.listapaginada3 = result;
                this.data.lastRecord=this.data.listapaginada3[this.data.previousRecord];
                this.totalPages = Math.ceil(this.data.listasignacion / this.itemsPerPage);
                this.data.opcionPaginado = 3;
                this.showSpinner = false;
            })
            .catch(error => {
                // Manejo de errores si es necesario
            });
    }

    fetchData31() {
        getRecordsFromServer31({ servicio: this.buscarServicio, busquedaPers: this.buscarPers })
            .then(result => {
                this.data.listapaginada3 = result;
                this.data.lastRecord=this.data.listapaginada3[this.data.previousRecord];
                this.totalPages = Math.ceil(this.data.listasignacion / this.itemsPerPage);
                this.data.opcionPaginado = 3;
                this.showSpinner = false;
            })
            .catch(error => {
                // Manejo de errores si es necesario
            });
    }

    opcionPago(event) {
        console.log('holaa');
        console.log(event.target.value);
        this.pickList.formaCobro = event.target.value;
        this.pickList.dsalesFormasCobro__c=event.target.value;
        console.log(this.pickList.formaCobro);
        if (this.pickList.formaCobro == 'Porcentaje de Cobro') {
            this.openPorcentajeCobro();
            this.pickList.matrizSelected = '';
            this.pickList.dsalesPrecioUnico__c = '';
            this.data.showMatrices = false;
            this.data.showPrecioUnico = false;
        }
        else if (this.pickList.formaCobro == 'Matriz de Precios') {
            this.limpiarPorcentajeCobro();
            this.pickList.dsalesPrecioUnico__c = '';
            this.data.showMatrices = true;
            this.data.showPrecioUnico = false;
        }
        else if (this.pickList.formaCobro == 'Costo Fijo') {
            this.limpiarPorcentajeCobro();
            this.pickList.matrizSelected = '';
            this.pickList.dsalesPrecioUnico__c = '';
            this.data.showMatrices = false;
            this.data.showPrecioUnico = true;
        }
        else if (this.pickList.formaCobro == 'Proveedor') {
            this.limpiarPorcentajeCobro();
            this.pickList.matrizSelected = '';
            this.pickList.dsalesPrecioUnico__c = '';
            this.data.showMatrices = false;
            this.data.showPrecioUnico = false;
        }
    }

    opcionProveedor(event) {
        this.pickList.proveedores=event.target.etiqueta;
        this.pickList.dsalesProveedor__c=event.target.value;
    }

    opcionEncuesta(event) {
        this.pickList.encuesta=event.target.etiqueta;
        this.pickList.dsalesEncuestaPISyS__c=event.target.value;
    }
    busquedaPersonalizada(event){
        const busqueda= event.target.checked;
        if(busqueda)
        {
            this.data.busqueda=true;
            this.buscarPers='';
        }
        else{
            this.data.busqueda=false;
            this.buscarPers='';
            this.buscarProductsNoVinc();
        }
        console.log(this.data.busqueda);
    }

    busquedaPersonalizada2(event){
        const busqueda= event.target.checked;
        if(busqueda)
        {
            this.data.busqueda=true;
        }
        else{
            this.data.busqueda=false;
            this.buscarPers='';
            this.onClickBuscarIntanProduct();
        }
        console.log(this.data.busqueda);
    }

}