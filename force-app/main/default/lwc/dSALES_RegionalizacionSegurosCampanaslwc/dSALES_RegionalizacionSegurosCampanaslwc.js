import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPicklistOptionsDependent from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPicklistOptionsDependent';
import getPicklistOptionsDependentSM from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPicklistOptionsDependentSM';
import getPickListRegiones from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPickListRegiones';
import vinculacionTiendaCampana from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaCampana';
import getPickListTiendas from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPickListTiendas';
import seleccionCampanaMatriz from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.seleccionCampanaMatriz';
import vinculacionTiendaMatriz from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.vinculacionTiendaMatriz';
import getPickListTiendasMatriz from '@salesforce/apex/DSALES_RegionalizacionSegurosCampanas.getPickListTiendasMatriz';

export default class DSALES_RegionalizacionSegurosCampanaslwc extends LightningElement {
  @api recordId
  @track data = {};
  show = false;
  checkRegion = false;
  checkCiudad = false;
  checkGerente=false;
  checkTienda = false;
  vincular= true;
  desvincular=false;
  listTiendasActivas=[];
  seleccionCampMat='';
  gerenteActivado=true;
  connectedCallback() {
    this.init();
  }

  init() {
    seleccionCampanaMatriz({ idSelected: this.recordId})
    .then(result => {
      console.log(result);
        this.seleccionCampMat = result;
        if(this.seleccionCampMat=='campana'){
          this.getListTiendas();
          this.gerenteActivado=false;
        }else if(this.seleccionCampMat=='matriz'){  
          this.getListTiendasMatriz();
        }      
    })
    .catch(error => {
        console.log(error);
    });  
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
 
    this.checkRegion = false;
    this.checkCiudad = false;
    this.checkGerente= false;
    this.checkTienda = false;
  }

  selectAllRegion(event) {
    const check = event.target.checked;
    for (const element of this.data.listRegiones) {
        element.seleccionado = check;
        for (const element2 of this.data.listCiudades) {
          if (element.valor == element2.depende) {
              element2.seleccionado = check;
          } 
          for (const element3 of this.data.listGerentes) {
              if (element2.valor == element3.depende) {
                  element3.seleccionado = check;
              } 
          }
      }
    }
    this.checkRegion = check;
    this.mostrarCiudades();
  }

  selectAllCiudad(event) {
    const check = event.target.checked;
    for (const element of this.data.listCiudades) {
        element.seleccionado = check;
        for (const element2 of this.data.listGerentes) {
          if (element.valor == element2.depende) {
              element2.seleccionado = check;
          } 
      }
    }
    this.checkCiudad = check;
    this.mostrarGerentes();
    console.log(JSON.parse(JSON.stringify(this.data.listGerentes)));
}

selectAllGerente(event) {
  const check = event.target.checked;
  for (const element of this.data.listGerentes) {
      element.seleccionado = check;
  }
  this.checkGerente = check;
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
    this.cargarPickList();
  }

  mostrarGerentes() {
    if(this.seleccionCampMat=='campana'){
      this.cargarPickListSM();
    }
    else{
      this.cargarPickList();
    }
}

  mostrarTienda() {
    this.cargarPickList();
}

  cargarPickList() {
    this.showSpinner = true;
    console.log(JSON.parse(JSON.stringify(this.data)));
    getPicklistOptionsDependent({ allData: JSON.stringify(this.data) })
        .then(result => {
            this.data = result;
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
        });
  }

  cargarPickListSM() {
    this.showSpinner = true;
    console.log(JSON.parse(JSON.stringify(this.data)));
    getPicklistOptionsDependentSM({ allData: JSON.stringify(this.data) })
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
    const depende = valor;
    let depende2='';
    for (const element of this.data.listRegiones) {
        if (valor == element.valor) {
            element.seleccionado = check;
        }
    }
    for (const element of this.data.listCiudades) {
      if (depende == element.depende) {
          element.seleccionado = check;
          depende2=element.valor;
      }
    }
    for (const element of this.data.listGerentes) {
        if (depende2 == element.depende) {
            element.seleccionado = check;
        }
    }
    this.mostrarCiudades();
}

onclickCiudad(event) {
  let x = false;
  const valor = event.target.name;
  const check = event.target.checked;
  const depende = valor;
  for (const element of this.data.listCiudades) {
      if (valor == element.valor) {
          element.seleccionado = check;
      }
  }
  for (const element of this.data.listGerentes) {
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
  for (const element of this.data.listGerentes) {
      if (valor == element.valor) {
          element.seleccionado = check;
      }
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

getListTiendasMatriz(){
  getPickListTiendasMatriz({idMatriz: this.recordId})
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
  console.log( this.seleccionCampMat);
  console.log( 'hola');
  if(this.seleccionCampMat== 'campana'){
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
  else if(this.seleccionCampMat== 'matriz'){
    vinculacionTiendaMatriz({ dataJsonTienda: JSON.stringify(this.data.listTiendas), idMatriz: this.recordId, vincular: this.vincular})
    .then(result => {
        console.log(result);
        this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente.');
        this.getListTiendasMatriz();
    }).catch(error => {
        console.log(error);
        this.showSpinner = false;
        this.pushMessage('Error', 'error', 'Ha ocurrido un error al actualizar los registros.');
    });
  }
  else{
    this.pushMessage('Error', 'error', 'Ha ocurrido un error al actualizar los registros.');
  }
 
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