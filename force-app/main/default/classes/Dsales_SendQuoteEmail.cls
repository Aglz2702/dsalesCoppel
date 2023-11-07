@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class Dsales_SendQuoteEmail implements Schedulable{
    global void execute(SchedulableContext sc){
        envioCotizacion();
    }
    public static void envioCotizacion(){
        try{
            EmailTemplate templeteSc = [Select Id, HtmlValue, Subject, DeveloperName from EmailTemplate Where DeveloperName = 'Envi_de_cotizaci_n_SC_1695315752491' WITH SECURITY_ENFORCED];
            system.debug('Template name------->' +templeteSc.DeveloperName);
            OrgWideEmailAddress owa = [Select Id,Address From OrgWideEmailAddress Where Address = 'coppelsoluciones@int.coppel.com' WITH SECURITY_ENFORCED LIMIT 1];
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            Date fourDaysAgo = Date.TODAY().addDays(-4);
            List<Quote> quoteList = [SELECT Id, Name,DSALES_Contado__c,DSALES_EmailNew__c,Email, dsalesFechaEnvioCotizacion__c,DSALES_Fechadecreacionpresupuesto__c,DSALES_Enviarcotizacion__c, RecordType.Name FROM Quote 
                                     WHERE DSALES_Enviarcotizacion__c= true AND RecordType.Name='Venta de Seguro de Celulares' 
                                     AND DSALES_Fechadecreacionpresupuesto__c =:fourDaysAgo WITH SECURITY_ENFORCED LIMIT 50];
            System.debug('QuoteList===>'+quoteList);       
            for(Quote item: quoteList){
                if(item.dsalesFechaEnvioCotizacion__c== null){
                    item.dsalesFechaEnvioCotizacion__c = item.DSALES_Fechadecreacionpresupuesto__c + 4;
                    String correo = item.DSALES_Contado__c ? item.DSALES_EmailNew__c : item.Email ;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    mail.setToAddresses(new string[] {correo});
                    mail.setOrgWideEmailAddressId(owa.Id);
                    system.debug('Email: '+correo);
                    efa.setInline(False);
                    mail.setHtmlBody(templeteSc.HtmlValue);
                    mail.setSubject(templeteSc.Subject);
                    Blob body = DSALES_GexCotizacionesHelper.generarSmPdf(item.Id);
                    efa.setContentType('application/pdf');
                    efa.setFileName('Cotizacion_Coppel.pdf');
                    efa.setBody(body);
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    messageList.add(mail);
                }
            }
            if (Quote.SObjectType.getDescribe().isUpdateable()) {
                update quoteList;
            } 
            else {
                System.debug('Permisos insuficientes para actualizar');
            }
            
            System.debug('QuoteList1===>'+quoteList);   
            if(messageList.Size()!=0){
                    Messaging.sendEmail(messageList, false);
                    System.debug('Correo enviado');
                }
        }catch(Exception ex){
            System.debug('Error: '+ex.getMessage() + ', Línea: '+ex.getLineNumber());
        } 
    }
}