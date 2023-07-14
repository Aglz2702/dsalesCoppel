trigger DSALES_Product2 on Product2 (before insert,after insert, before update, after update) {
    fflib_SObjectDomain.triggerHandler(DSALES_Product2Handler.class);
}