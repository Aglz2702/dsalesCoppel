import { LightningElement, api, wire, track } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DSALES_TIPO_DE_ENDOSO__C from '@salesforce/schema/DSALES_Endoso__c.DSALES_Tipodeendoso__c';
import DSALES_TIPO_DE_DOCUMENTOS__C from '@salesforce/schema/DSALES_Endoso__c.DSALES_Tipodedocumento__c';
import endosoDocuments from '@salesforce/apex/endososControllerClass.endosoDocuments';
const MAX_FILE_SIZE = 4500000;

const fields = [DSALES_TIPO_DE_ENDOSO__C, DSALES_TIPO_DE_DOCUMENTOS__C];
//import CLAIMTYPE_FIELD from '@salesforce/schema/Claim.ClaimType';

/* const options = [
     {'label':'MAPFRE','value':'MAPFRE'},
    {'label':'QUALITAS','value':'QUALITAS'},
    {'label':'GNP','value':'GNP'}
    
 ];*/

export default class QuickActionLWC extends LightningElement {

    @api recordId;
    @track error;



    /*  @track selectedValue;
     @track options = options;
     areDetailsVisible= false;
      
     // //for single select picklist
    handleSelectOption(event){
        console.log(event.detail);
          this.selectedValue = event.detail;
      }
      handleChange(event) {
          this.selectedValue = event.target.value;
          this.areDetailsVisible = event.target.value;
     }
     get isGNP() {
         if (this.selectedValue === "GNP") {
             return true;
         }
         console.log(options);
     }
     */




    @wire(getRecord, { recordId: '$recordId', fields })
    DSALES_Endoso__c;
    get endoso() {
        return getFieldValue(this.DSALES_Endoso__c.data, DSALES_TIPO_DE_ENDOSO__C);
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg'];
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.refreshComponent();
    }
    refreshComponent() {
        eval("$A.get('e.force:refreshView').fire();");
    }

    @track dataFile = [];

    uploadFileData(event) {
        console.log(event.target.dataset.item);
        let fl = event.detail.files;// documentId
        console.log(fl[0]);
        if (this.dataFile) {
            for (let i in this.dataFile) {
                if (this.dataFile[i].Id == event.target.dataset.item) {
                    for (let j in fl) {
                        this.dataFile[i].Files.push({ key: this.dataFile[i].Id, Name: fl[j].name, fileId: fl[j].documentId });

                    }
                }
                console.log(this.dataFile);
            }
        }
    }

    removeFile(event) {
        let Key = event.detail.name;
        let Id = event.target.dataset.item;
        for (let i in this.dataFile) {
            if (this.dataFile[i].Key == Key) {
                for (let j in this.dataFile[i].Files) {
                    if (this.dataFile[i].Files[j].fileId == Id) {
                        console.log(this.dataFile[i].Files[j]);
                        this.dataFile[i].Files.splice(j, 1);
                        console.log(this.dataFile[i].Files);
                        deleteRecord(Id)
                            .then((result) => {
                                console.log('Deleted');
                            }).catch((err) => {
                                console.log('Error ' + err);
                            });
                    }
                }
            }
        }
    }

    @wire(endosoDocuments, { TipoDeEndoso: '$endoso' })
    wiredData({ error, data }) {
        if (data) {
            console.log('Data', data);
            this.dataFile = [];
            for (const [key, value] of Object.entries(data)) {
                this.dataFile.push({ Id: key, value: value, Files: [] })
                console.log(this.dataFile);

            }


        } else if (error) {
            console.error('Error:', error);
        }
    }







    //  @wire(getRecord, { recordId: '$recordId', claimFields })
    //  claim;
    //  get claimTypeField() {
    //      return getFieldValue(this.claim.data, CLAIMTYPE_FIELD);
    //  }
    //  get TitleValue() {
    //      if (this.claimTypeField === "Robo Total") {
    //          return true;
    //      }
    //  }
    //  get TypeValue() {
    //      if (this.claimTypeField === "Perdida Total") {
    //          return true;
    //      }
    //  }



}