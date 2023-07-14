import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPicklistOptionsDependent from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPicklistOptionsDependent';
import getPickListRegiones from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPickListRegiones';
import vinculacionTiendaCampana from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaCampana';
import getPickListTiendas from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPickListTiendas';


export default class DSALES_RegionalizacionSegurosCampanaslwc extends LightningElement {
  @api recordId
  @track data = {};
  show = false;
  checkRegion = false;
  checkCiudad = false;
  checkTienda = false;
  vincular= true;
  desvincular=false;
  listTiendasActivas=[];

  connectedCallback() {
    this.init();
  }

  init() {
    getPickListRegiones()
    .then(result => {
      console.log(this.recordId);
        this.data = result;
        this.showSpinner = false;
        this.showc = true;
    })
    .catch(error => {
        this.showSpinner = false;
        console.log(error);
    });      
    this.getListTiendas();
           
    this.checkRegion = false;
    this.checkCiudad = false;
    this.checkTienda = false;
  }

  selectAllRegion(event) {
    const check = event.target.checked;
    for (const element of this.data.listRegiones) {
        element.seleccionado = check;
    }
    this.checkRegion = check;
    this.mostrarCiudades();
  }

  selectAllCiudad(event) {
    const check = event.target.checked;
    for (const element of this.data.listCiudades) {
        element.seleccionado = check;
    }
    this.checkCiudad = check;
    this.mostrarTienda();
}

selectAllTienda(event) {
  const check = event.target.checked;

  for (const element of this.data.listTiendas) {
      element.seleccionado = check;
  }
  this.checkTienda = check;
  console.log(JSON.parse(JSON.stringify(this.data.listTiendas)));
}

  mostrarCiudades() {
    this.show = true;
    this.cargarPickList();
  }

  mostrarTienda() {
    this.show2 = true;
    this.cargarPickList();
}

  cargarPickList() {
    this.showSpinner = true;
    getPicklistOptionsDependent({ allData: JSON.stringify(this.data) })
        .then(result => {
            this.data = result;
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
        });
  }

  onclickRegion(event) {
    let x = false;
    const valor = event.target.name;
    const check = event.target.checked;
    for (const element of this.data.listRegiones) {
        if (valor == element.valor) {
            element.seleccionado = check;
        }
        if (element.seleccionado) {
            x = true;
        }
    }
    if (x === false) {
        this.checkRegion = false;
    }
    this.mostrarCiudades();
}

onclickCiudad(event) {
  let x = false;
  const valor = event.target.name;
  const check = event.target.checked;
  for (const element of this.data.listCiudades) {
      if (valor == element.valor) {
          element.seleccionado = check;
      }
      if (element.seleccionado) {
          x = true;
      }
  }
  if (x === false) {
      this.checkCiudad = false;
  }
  this.mostrarTienda();
}

onclicklistTiendas(event) {
  let x = false;
  const valor = event.target.name;
  const check = event.target.checked;
  for (const element of this.data.listTiendas) {
      if (valor == element.valor) {
          element.seleccionado = check;
      }
      if (element.seleccionado) {
          x = true;
      }
  }
  if (x === false) {
      this.checkTienda = false;
  }
}

getListTiendas(){
  getPickListTiendas({idCampana: this.recordId})
  .then(result => {
      this.listTiendasActivas = result;
      this.showSpinner = false;
  })
  .catch(error => {
      this.showSpinner = false;
      console.log(error);
  });
}


guardarAsignacion(){
  vinculacionTiendaCampana({ dataJsonTienda: JSON.stringify(this.data.listTiendas), idCampana: this.recordId, vincular: this.vincular})
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
  
opcionVincular(event){
this.vincular=event.target.checked;
if(this.vincular){
    this.desvincular=false;
}
else{
  this.desvincular=true;
}
}

opcionDesvincular(event){
  this.desvincular=event.target.checked;;
  if(this.desvincular)
  {
    this.vincular=false;
  }
  else{
    this.vincular=true;
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
}