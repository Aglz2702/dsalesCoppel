@isTest
public class DSALES_EndorsementWrapper_Test {
    @isTest
    static void objecto(){
        //DSALES_EndorsementWrapper.endorsementRequest objpost= new DSALES_EndorsementWrapper.endorsementRequest();
        DSALES_EndorsementWrapper.EndorsementRequest objpost= new DSALES_EndorsementWrapper.EndorsementRequest();
        objpost.uid = 'gg';
        objpost.tipoEndoso = 'gg';
        objpost.numeroPoliza = 'gg';
        objpost.fechaEndoso = date.newInstance(1991, 2, 15);
        objpost.estatus = 'gg';
        objpost.salesforceId = 'gg';
       
        //objpost.Documentos = new DSALES_EndorsementWrapper.documento();
        //objpost.tipoDocumento = new DSALES_EndorsementWrapper.Documento();
        //objpost.tipoDocumento.tipoDocumento = 'gg';
        //objpost.tipoDocumento.documento = 'gg';
        //objpost.tipoDocumento.idDocumento='gg';
        
        objpost.datos = new DSALES_EndorsementWrapper.Dato();
        objpost.Datos.tipoDato = 'gg';
        objpost.Datos.valor = 'gg';
        objpost.Datos.idDato = 'gg';
        
        //DSALES_EndorsementWrapper.endorsementResponse obj= new DSALES_EndorsementWrapper.endorsementResponse();
        DSALES_EndorsementWrapper.EndorsementResponse obj= new DSALES_EndorsementWrapper.EndorsementResponse();
        //obj.ok = 'ok';
        //obj.response = 'ok';
        obj.mensaje = 'ok';
        //obj.Endoso = new DSALES_EndorsementWrapper.Endoso();
        //obj.Endoso.uid='ssff';
        
        //DSALES_EndorsementWrapper.getResponse obj2= new DSALES_EndorsementWrapper.getResponse();
        DSALES_EndorsementWrapper.EndorsementRequest obj2= new DSALES_EndorsementWrapper.EndorsementRequest();
        obj2.uid = 'gg';
        obj2.tipoEndoso = 'gg';
        obj2.numeroPoliza = 'gg';
        obj2.fechaEndoso = date.newInstance(1991, 2, 15);
        //obj2.FechaAplicacionEndoso = '12/12/23';
        obj2.estatus = 'gg';
        obj2.estatusComentario = 'gg';
        //
        obj2.salesforceid = 'gg';
        //obj2.datos = new List<DSALES_EndorsementWrapper.Dato>();

        DSALES_EndorsementWrapper.Dato datoAux = new DSALES_EndorsementWrapper.Dato();
        datoAux.tipoDato = 'gg';
        datoAux.valor = 'gg';
        datoAux.idDato = 'gg';
        //obj2.datos.add(datoAux);
        //obj2.tipoDocumento = new List<DSALES_EndorsementWrapper.Documento>();
        DSALES_EndorsementWrapper.Documento docuAux = new DSALES_EndorsementWrapper.Documento();
        docuAux.tipoDocumento = 'gg';
        docuAux.documento = 'gg';
        docuAux.idDocumento='gg';
        //obj2.tipoDocumento.add(docuAux); 
    }

}