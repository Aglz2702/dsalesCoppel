public with sharing class DSALES_CrearParticipantesPoliza {
    public static final String NOMBRE_CONTRATANTE =DSALES_Utility.getNombreContratante('dsalesNombre');
    public static void crearConductor(String idClienteConductor,String idPoliza){
        InsurancePolicyParticipant nuevoParticipante = new InsurancePolicyParticipant();
        nuevoParticipante.InsurancePolicyId=idPoliza;
        nuevoParticipante.PrimaryParticipantAccountId=idClienteConductor;
        nuevoParticipante.Role=DSALES_Utility.FIGURA_CONDUCTOR;

        if(Schema.sObjectType.InsurancePolicyParticipant.isCreateable()) {
            insert nuevoParticipante;
        }else{
            System.debug('Permisos insuficientes para insertar');
        }
    }

    public static void crearOtrosParticipantes(List<DSALES_VentaSM.DatosParticipante> participantes,DSALES_CreateInsurancePolicy.DatosParaParticipantes datos){
        List<InsurancePolicyParticipant> listaParticipantes = new List<InsurancePolicyParticipant>();
        DatosConductor datosCliente = new DatosConductor();
        Decimal numeroCliente ;
        String recortypeOpp= datos.oportunidad.RecordType.DeveloperName;
        if(participantes!=null){
           for(DSALES_VentaSM.DatosParticipante item:participantes){
                InsurancePolicyParticipant participante= new InsurancePolicyParticipant();    
                participante.InsurancePolicyId=datos.poliza.Id;
                participante.dsalesNombre__c=item.nombre;
                participante.dsalesPrimerApellido__c=item.apellidoPaterno;
                participante.dsalesSegundoApellido__c=item.apellidoMaterno;
                participante.dsalesGenero__c=asignarGenero(item.genero);
                participante.Role=item.figura;
                participante.dsalesNumeroTelefono__c=item.telefono;
                participante.dsalesCorreoElectronico__c=item.correoElectronico;
                participante.dsalesFechaNacimiento__c=item.fechaNacimiento;
                participante.dsalesRfc__c=item.rfc;
                participante.dsalesCodigoPostal__c=item.codigoPostal;
                participante.dsalesClaveEstado__c=item.codigoEstado;
                participante.dsalesCalle__c=item.calle;
                participante.dsalesNumeroExterior__c=item.numeroExterior;
                participante.RelationshipToInsured=item.relacionConParticipante;
                participante.BeneficiarySharePercentage=Decimal.valueOf(item.porcentaje);
                System.debug('tipo de registro en oportunidad_____--'+recortypeOpp);
                if((item.figura==DSALES_Utility.FIGURA_CONDUCTOR && recortypeOpp=='Seguro_de_Moto') || (datos.enviaContratante==true && item.figura==DSALES_Utility.FIGURA_CONTRATANTE &&  recortypeOpp== 'dsalesSeguroCelulares')){
                    participante.PrimaryParticipantAccountId=datos.poliza.NameInsuredId;
                }

                listaParticipantes.add(participante);
                
            }
            if(Schema.sObjectType.InsurancePolicyParticipant.isCreateable()) {
                insert listaParticipantes;
            }else{
                System.debug('Permisos insuficientes para insertar');
            }
            
        }

    }
    private static String asignarGenero(String genero){
        if(genero=='F'){
            genero='Femenino';
        }
        else if(genero=='M'){
            genero='Masculino';
        } else if(genero=='Femenino' || genero=='Masculino'){
            genero=genero;
        }
        return genero;
    }
    public static void crearContratante(String idPoliza){
        Account contratante =[SELECT Id FROM Account WHERE FirstName=:NOMBRE_CONTRATANTE WITH SECURITY_ENFORCED LIMIT 1];
        InsurancePolicyParticipant participante = new InsurancePolicyParticipant(
            InsurancePolicyId=idPoliza,
            RelatedParticipantAccountId=contratante.Id,
            Role=DSALES_Utility.FIGURA_CONTRATANTE
        );
        if(Schema.sObjectType.InsurancePolicyParticipant.isCreateable()) {
            insert participante;
        }else{
            System.debug('Permisos insuficientes para insertar');
        }  
    }
    public  class DatosConductor{
        public String nombre{get;set;}
        public String apellidoPaterno {get;set;}
        public String apellidoMaterno {get;set;}
        public String correo{get;set;}
        public Decimal numeroCliente{get;set;}
    }

}