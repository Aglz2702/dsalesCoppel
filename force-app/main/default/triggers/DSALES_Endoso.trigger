trigger DSALES_Endoso on DSALES_Endoso__c (after update) {
	//fflib_SObjectDomain.triggerHandler(DSALES_Endosos.class);
	DSALES_Endosos.onAfterUpdate(trigger.oldMap,trigger.newMap);

}