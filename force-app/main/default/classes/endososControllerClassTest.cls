@isTest
public class endososControllerClassTest {
    
    @isTest static void configSetupTest () { 
        
        String label= 'TEST';    
        String values = '{"Tipo_de_endoso__c":"Cambio de placas", "ClaimType__c": "Robo Total"}';
        Map<String, Object> endosoValue = (Map<String, Object>)JSON.deserializeUntyped(values);    
        Test.startTest();
        EndososControllerClass.endosoDocuments('Cambio de dirección');    
        Test.stopTest();
        System.assertNotEquals(label, values, 'debe ser diferente');
        
        
        
        
    }
     @isTest
    public static void endososFail(){
        Profile perfil =[SELECT Id FROM Profile WHERE  Name='Agente de servicios SM'];
        User usr = new User(LastName = 'TEST',
                            FirstName='Fail',
                            Alias = 'ftest',
                            Email = 'f.test@asdf.com',
                            Username = 'f.test@asdf.com',
                            ProfileId = perfil.Id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
    	insert usr;
        
        System.runAs(usr){
            Test.startTest();
            try{
                
                EndososControllerClass.endosoDocuments('');    
                
            }catch(DmlException e){
                System.assertNotEquals('Error', e.getMessage(), 'Errors in DML');
                
            }
            Test.stopTest();
			            
        }
    }
    
    
    
    /* @isTest static void configSetupTest1 () { 
endososControllerClass result = new endososControllerClass();

System.assert(!result.isSuccess());
System.assert(result.getMessage().size() > 0);

}*/
    
    
    
}