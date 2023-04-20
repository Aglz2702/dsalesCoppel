public class DSALES_ControladorCertificadoPDF {
    
    public String html{get;set;}
    private static final String NOMBRE_OBJETO = 'DSALES_Certificado__c';
    private static final String NOMBRE_PLANTILLA = 'Certificado PDF';
    private static final String NOMBRE_DATE = 'DATE';
    private static final String NOMBRE_DOUBLE = 'DOUBLE';
    private static final String MY_FILE_NAME='Cotizacion';
    
    public DSALES_ControladorCertificadoPDF(){
        
        String recordId = ApexPages.currentPage().getParameters().get('certificadoId');
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+MY_FILE_NAME);
        //html = [Select Id, HtmlValue, Subject from EmailTemplate Where DeveloperName = :NOMBRE_PLANTILLA].HtmlValue;
        html = [select Id, DSALES_Plantilla__c  from DSALES_Generador__c Where Name = :NOMBRE_PLANTILLA].DSALES_Plantilla__c;
        html = html.replace('border-color: #ffffff;', 'border-image: initial; border: 1px solid blue;');
        html=html.replace('p style="text-align:center"', 'p style="text-align:center; font-size:10px; color:rgb(0, 101, 173);"');
        html=html.replace('<div><hr /><p>&nbsp;</p></div>', '<div style="page-break-after: always"><span style="display:none">&nbsp;</span></div>');
        Map<String, String> mapCampos = getField(NOMBRE_OBJETO);
        Tienda__c tienda= new Tienda__c();
        DSALES_Certificado__c certificado= new DSALES_Certificado__c();
        String query = 'Select ';
        for(String item: mapCampos.keySet()){
            query += item+',';
        }
        query = query.substring(0, query.length() -1);
        query += ' From DSALES_Certificado__c Where Id = :recordId';
        if (Schema.sObjectType.DSALES_Certificado__c.isQueryable()) {
            certificado = DataBase.query(String.escapeSingleQuotes(query));
        }  
        if (Schema.sObjectType.Tienda__c.isQueryable()) {
            tienda=[SELECT name FROM Tienda__c WHERE DSales_TiendaID__c=:certificado.DSALES_Tienda__c LIMIT 1];
        }
        html=html.replace('DSALES_Tienda__c', tienda.Name);
        html = html.replace('certificado.', '');
        for(String item: mapCampos.keySet()){
            if(html.contains(item)){
                String replace = '';
                if(certificado.get(item)!= null){
                    if(mapCampos.get(item) == NOMBRE_DATE){
                        replace = String.valueOf(Date.valueOf(certificado.get(item)).format());
                    }else if (mapCampos.get(item) == NOMBRE_DOUBLE ){
                        replace = String.valueOf(Decimal.valueOf( String.valueOf(certificado.get(item)) ).format());
                    }else{
                        replace = String.valueOf(certificado.get(item));
                    }
                }
                html = html.replace(item, replace);
            }
        }
    }
    
    
    private static Map<String, String> getField(String objName){
        Map<String, String> mapCampos = new Map<String, String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(ObjName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult field = sfield.getDescribe();
            mapCampos.put(field.getName(), String.valueOf(field.getType())); 
        }
        return mapCampos;
    }


}