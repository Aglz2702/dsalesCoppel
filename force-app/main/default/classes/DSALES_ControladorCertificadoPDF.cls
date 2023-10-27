public without sharing class DSALES_ControladorCertificadoPDF {
    
    public String html{get;set;}
    private static final String NOMBRE_OBJETO = 'DSALES_Certificado__c'; 
    private static final String NOMBRE_PLANTILLA = 'Certificado PDF';
    private static final String NOMBRE_PLANTILLA2 ='Armado PDF';
    private static final String NOMBRE_DATE = 'DATE';
    private static final String NOMBRE_DOUBLE = 'DOUBLE';
    private static final String MY_FILE_NAME='Cotizacion';
    
    public DSALES_ControladorCertificadoPDF(){
        String recordId = ApexPages.currentPage().getParameters().get('certificadoId');
        DSALES_Certificado__c certi= [SELECT Id,recordType.name,DSalesNombreServicio__c FROM DSALES_Certificado__c WHERE ID=:recordId];
       
        String def='';
        for(DSALES_Generador__c htmlWeb:[SELECT Id,DSALES_Plantilla__c,Name  from DSALES_Generador__c ])
           {
               if(htmlWeb.name.ContainsIgnoreCase('Garantía Extendida'))
               {
                   def=htmlWeb.DSALES_Plantilla__c;
               }
               if(certi.DSalesNombreServicio__c!=null && certi.DSalesNombreServicio__c.EqualsIgnoreCase(htmlWeb.Name))
               {
                   html=htmlWeb.Dsales_Plantilla__c;
                   system.debug('Existe Plantilla: '+htmlWeb.Name);
                   system.debug('HTML: '+html);
                   break;
               }
               else{
                   system.debug('No EXISTE Plantilla: ');
                   html=def;
               }
           }
       /* if(certi.recordType.name.containsIgnoreCase('Armado'))
        {
            System.debug('Certificado RecordType: Armado');
            html = [select Id, DSALES_Plantilla__c  from DSALES_Generador__c Where Name = :NOMBRE_PLANTILLA2].DSALES_Plantilla__c;
        }
        else if (certi.recordType.name.containsIgnoreCase('Garantía') || certi.recordType.name.containsIgnoreCase('Garantia'))
        {
            System.debug('Certificado RecordType: GEX');
            html = [select Id, DSALES_Plantilla__c  from DSALES_Generador__c Where Name = :NOMBRE_PLANTILLA].DSALES_Plantilla__c;
        }
*/
       
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

        tienda=[SELECT name,DSales_TiendaID__c FROM Tienda__c WHERE DSales_TiendaID__c=:certificado.DSALES_Tienda__c  WITH SECURITY_ENFORCED LIMIT 1];
        html=html.replace('DSALES_Tienda__c', tienda.DSales_TiendaID__c+' '+tienda.Name);
        html = html.replace('certificado.', '');
        for(String item: mapCampos.keySet()){
            if(html.contains(item)){
                String replace = '';
                //replace=haha(certificado, item, mapCampos);
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
        conCertificadoFor(mapCampos, certificado, html);
    }


    public static void conCertificadoFor(Map<String, String> mapCampos, DSALES_Certificado__c certificado, String html) {
        for(String item: mapCampos.keySet()){
            if(html.contains(item)){
                String replace = '';
                //replace=haha(certificado, item, mapCampos);
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

   /* public static String haha(DSALES_Certificado__c certificado, String item, Map<String, String> mapCampos){
        String replace='';
        if(certificado.get(item)!= null){
            if(mapCampos.get(item) == NOMBRE_DATE){
                replace = String.valueOf(Date.valueOf(certificado.get(item)).format());
            }else if (mapCampos.get(item) == NOMBRE_DOUBLE ){
                replace = String.valueOf(Decimal.valueOf( String.valueOf(certificado.get(item)) ).format());
            }else{
                replace = String.valueOf(certificado.get(item));
            }
        }
        return replace;
    }
*/

}