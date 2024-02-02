public with sharing class DSALES_CertificadosHelper {
  
    
    private static final String TEMPLETE_NAME = 'DSALES_CertificadoGEX';  
    private static final String TEMPLATE_ARMADO='dsalesCertServicioArmado';
    private static final String TEMPLATE_INS='dsalesCertServicioInstalacion';
    private static final String DIRECCION_CORREO = 'coppelsoluciones@int.coppel.com';  
    public static boolean checkArm= false;
    public static boolean checkIns=false;
    
    @Future(callout=true)
    public static void envioCertificado(String jsonString){
        try{
            List<DSALES_Certificado__c> sObjectList = (List<DSALES_Certificado__c>) JSON.deserialize(jsonString, List<DSALES_Certificado__c>.class);
            Map<String, Account> mapaCuenta = new Map<String, Account>();
            for(DSALES_Certificado__c item: sObjectList){
                mapaCuenta.put(item.DSALES_Cliente__c, new Account());
            }
            for(Account item: [Select Id,Name,PersonContactId, PersonEmail from Account where Id in : mapaCuenta.keySet() WITH SECURITY_ENFORCED ]){
                mapaCuenta.put(item.Id, item);
            }
            EmailTemplate templete = [Select Id, HtmlValue, Subject from EmailTemplate Where DeveloperName = :TEMPLETE_NAME WITH SECURITY_ENFORCED];
            EmailTemplate armadoTem= [SELECT Id, HtmlValue,Subject from EmailTemplate WHERE DeveloperName=:TEMPLATE_ARMADO WITH SECURITY_ENFORCED];
            EmailTemplate armadoIns=[SELECT Id, HtmlValue,Subject from EmailTemplate WHERE DeveloperName=:TEMPLATE_INS WITH SECURITY_ENFORCED];
            OrgWideEmailAddress owa = [Select Id,Address From OrgWideEmailAddress Where Address = :DIRECCION_CORREO WITH SECURITY_ENFORCED LIMIT 1 ];
            List<Messaging.SingleEmailMessage> listaMensaje = new List<Messaging.SingleEmailMessage>();
            for(DSALES_Certificado__c item: sObjectList){
                
                Account cuenta = mapaCuenta.get(item.DSALES_Cliente__c);
                item.DSALES_enviado__c = true;
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
               if(!String.isEmpty(item.DSALES_E_mail__c) || item.DSALES_E_mail__c!=null)
               {
                    mail.setToAddresses(new string[] {item.DSALES_E_mail__c});
                    system.debug('item.Dsales_E_mail__c'+item.DSALES_E_mail__c);
               }
                else
                {
                     mail.setToAddresses(new string[] {item.DSALES_Email__c});
                     system.debug('item.DsalesEmail'+item.DSALES_Email__c);
                }
               system.debug('ITEM REcordtype: '+item.RecordTypeId);
                Id certRecId = Schema.SObjectType.DSALES_Certificado__c.getRecordTypeInfosByName().get('Garantía Extendida').getRecordTypeId();
                Id certArmId = Schema.SObjectType.DSALES_Certificado__c.getRecordTypeInfosByName().get('Armado de Muebles').getRecordTypeId();
                Id certInsId = Schema.SObjectType.DSALES_Certificado__c.getRecordTypeInfosByName().get('Instalación').getRecordTypeId();
                if(item.RecordTypeId==certArmId)
                {
                     mail.setTemplateId(armadoTem.Id);
                    checkArm=true;
                    
                }
                else if(item.RecordTypeId==certInsId)  
                {
                   checkIns=true;
                    system.debug('RecordType es INS');
                     mail.setTemplateId(armadoIns.Id);
                    //Id idEvento = DSALES_ServicioCitasRequest.crearCita(certificadoRecord.Id); 
                }
                else
                {
                     mail.setTemplateId(templete.Id);
                }
               
                mail.setTargetObjectId(cuenta.PersonContactId);
                system.debug('Cuenta: '+cuenta.PersonContactId);
                mail.setOrgWideEmailAddressId(owa.Id);
                
                
                Blob b = generarPFD(item.Id); 
                
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setContentType('application/pdf');
                efa.setInline(False);
                if(checkArm)
                {
                     efa.setFileName('Certificado de Armado de Muebles.pdf');
                }
                else if (checkIns)
                {
                    efa.setFileName('Certificado de Servicio de Instalación.pdf');
                }   
                else{
                         efa.setFileName('Certificado de Garantía Extendida.pdf');
                    }

                efa.setBody(b);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                listaMensaje.add(mail);  
            }
            Messaging.sendEmail(listaMensaje, false);
            if(Schema.sObjectType.DSALES_Certificado__c.isUpdateable()) {
                update sObjectList;
                 System.debug('Correo enviado' + sObjectList);
                }
           
           
        }catch(Exception ex){
            System.debug('Error: '+ex.getMessage() + ', Línea: '+ex.getLineNumber());
        }
    }
    
    public static Blob generarPFD(Id certificadoId){
        PageReference pdf = Page.DSALES_CertificadoPDF; 
        pdf.setRedirect(False);
        pdf.getParameters().put('certificadoId',certificadoId);
        Blob b; 
        if(!test.isRunningTest())
        {
            b = pdf.getContent();
        }
        else
        {
            b = blob.valueOF('Test');
        }
        
        return b;
    }
    public static void enviarCorreoActualizado(Map<Id,SObject> certificadoActualizado, List<DSALES_Certificado__c> records){
        try{
            List<DSALES_Certificado__c> listToSend= new List<DSALES_Certificado__c>();
            List<DSALES_Certificado__c> listRecord = (LIst<DSALES_Certificado__c>)records;
            for(DSALES_Certificado__c certi :listRecord){
                DSALES_Certificado__c certificado = (DSALES_Certificado__c)certificadoActualizado.get(certi.Id);
                if(certificado.dsalesEstatusServicioArmado__c !=certi.dsalesEstatusServicioArmado__c){
                    listToSend.add(certi);
                }
            }
            if(listToSend!=null && listToSend.size()>0){
                DSALES_CertificadosHelper.envioCertificado(JSON.serialize(listToSend));
            }
             
        }catch(Exception ex){
            System.debug('Error: '+ex.getMessage() + ', Línea: '+ex.getLineNumber());
        }
    }    
}