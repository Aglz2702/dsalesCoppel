public with sharing class DSALES_GexCotizacionesHelper {

private static final String TEMPLETE_NAME = 'Envi_de_cotizaci_n_1660589806562';
private static final String GEX_TEMPLETE = 'DSALES_Cotizacion';            
private static final String DIRECCION_CORREO = 'atencion@coppel.com';  

@Future(callout=true)
public static void envioCotizacionGex(String jsonString, String quoteOld){
        try{
        System.debug('>>> response ' + jsonString);
        List<Quote> sObjectList = (List<Quote>) JSON.deserialize(jsonString, List<Quote>.class);
        Map<Id,Quote> mapQuote= (Map<Id,Quote>) JSON.deserialize(quoteOld, Map<Id,Quote>.class);
        Map<String, Account> mapAccount = new Map<String, Account>();
        List<String> recordId = new List<String>();
        for(Quote item: sObjectList){
            mapAccount.put(item.AccountId, new Account());
            recordId.add(item.RecordTypeId);
            
        }
        for(Account item: [Select Id,Name,PersonContactId, PersonEmail from Account where Id in : mapAccount.keySet() WITH SECURITY_ENFORCED LIMIT 1]){
            mapAccount.put(item.Id, item);
        }
        List<RECORDTYPE> motos= [SELECT Id, Name FROM RECORDTYPE WHERE Id=:recordId[0] WITH SECURITY_ENFORCED LIMIT 1];
        EmailTemplate templete = [Select Id, HtmlValue, Subject, DeveloperName from EmailTemplate Where DeveloperName = :TEMPLETE_NAME WITH SECURITY_ENFORCED];
        system.debug('Template name------->' +templete.DeveloperName);
        EmailTemplate templeteGEX = [Select Id, HtmlValue, Subject, DeveloperName from EmailTemplate Where DeveloperName = :GEX_TEMPLETE WITH SECURITY_ENFORCED];     
        system.debug('Template name------->'  +templeteGEX.DeveloperName);
        OrgWideEmailAddress owa = [Select Id,Address From OrgWideEmailAddress Where Address = :DIRECCION_CORREO WITH SECURITY_ENFORCED LIMIT 1];
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        
        for(Quote item: sObjectList){
            // if(item.DSALES_Enviarcotizacion__c==true && mapQuote.get(item.Id).DSALES_Enviarcotizacion__c==false){
                String correo = item.DSALES_Contado__c ? item.DSALES_EmailNew__c : item.Email ;
                Account acc = mapAccount.get(item.AccountId); 
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                mail.setToAddresses(new string[] {correo});
                mail.setOrgWideEmailAddressId(owa.Id);
                system.debug('Email: '+correo);
                efa.setInline(False);
                
            if(motos.size()>0)
            {
            if(motos[0].Name=='Venta de Seguro de Motos' &&(item.DSALES_Enviarcotizacion__c==true && mapQuote.get(item.Id).DSALES_Enviarcotizacion__c==false)){
                    mail.setHtmlBody(templete.HtmlValue);
                    mail.setSubject(templete.Subject);
                    Blob body = generarSmPdf(item.Id);
                    efa.setContentType('application/pdf');
                    efa.setFileName('DSALES_CotizationSm.pdf');
                    efa.setBody(body);
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    messageList.add(mail);
                    
                }
                else if(motos[0].Name=='Venta de Garantía Extendida' && (item.DSALES_Enviarcotizacion__c==true && mapQuote.get(item.Id).DSALES_Enviarcotizacion__c==false)){
                    mail.setHtmlBody(templeteGEX.HtmlValue);
                    mail.setSubject(templeteGEX.Subject);
                    Blob b = generarPFD(item.Id); 
                    efa.setContentType('application/pdf');
                    efa.setFileName('Cotización.pdf');
                    efa.setBody(b);
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    messageList.add(mail);
                    
                }
             }
            
        }
        if(messageList.Size()!=0){
            Messaging.sendEmail(messageList, false);
            System.debug('Correo enviado');
        }
        
    }catch(Exception ex){
        System.debug('Error: '+ex.getMessage() + ', Línea: '+ex.getLineNumber());
    }
}

public static Blob generarPFD(Id quoteId){
    PageReference pdf = Page.Cotizacion; 
    pdf.setRedirect(False);
    pdf.getParameters().put('quoteID',quoteId);
    if (Schema.sObjectType.Quote.isQueryable()&&Schema.sObjectType.Quote.isDeletable()) {
        List<Quote> dupQuote = [SELECT Id, Name,OpportunityId, DSALES_EmailNew__c, Pricebook2Id, RecordTypeId, Status, DSALES_Enviarcotizacion__c, DSales_Tienda__c, DSales_Vendedor__c,
                                DSALES_Fechadecreacionpresupuesto__c, ExpirationDate, DSALES_esClon__c FROM Quote where DSALES_esClon__c= true WITH SECURITY_ENFORCED LIMIT 1]; 
        delete dupQuote;
    }
    Blob b; 
    if(!test.isRunningTest()){
        b = pdf.getContent();
    }
    else{
        b = blob.valueOF('Test');
    }
    return b;
}


public static Blob generarSmPdf(Id quoteId){
    PageReference pdf = Page.DSALES_CotizationSm; 
    pdf.setRedirect(True);
    pdf.getParameters().put('id',quoteId);
    
    Blob b; 
    if(!test.isRunningTest()){
        b = pdf.getContent();
    }
    else{
        b = blob.valueOF('Test');
    }
    return b;
}

}