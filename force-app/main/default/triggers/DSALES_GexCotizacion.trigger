trigger DSALES_GexCotizacion on Quote (after insert, after update) {
    //If(trigger.isAfter && (trigger.isInsert ||trigger.isUpdate)) {
      //if(!System.isFuture() && !System.isBatch()){
        fflib_SObjectDomain.triggerHandler(DSALES_GexCotizaciones.class);
   //}
   // }
}