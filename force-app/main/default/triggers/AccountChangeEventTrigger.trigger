trigger AccountChangeEventTrigger on AccountChangeEvent (after insert) {
/*******************************************************************************************************
@Description    : Trigger to process  AccountChangeEvent and invokes ClsAccountChangeEventTriggerHandler
********************************************************************************************************/
    // Iterate through each event message.
    List<AccountChangeEvent> accountChanges = Trigger.new;
    Set<String> accountIdsForRelContactUpdates = new Set<String>();
    for (AccountChangeEvent event : accountChanges) {
        // Get all Record Ids for the accounts where the Contact is changed
        if (event.Contact__c != null) {
            List<String> recordIds = event.ChangeEventHeader.getRecordIds();
            accountIdsForRelContactUpdates.addAll(recordIds);
            system.debug('*******ACCCHGEVT - Found Contact Changed for ' + recordIds);
        }   
    	//Process AccountContactRelation Changes
    	if(!accountIdsForRelContactUpdates.isEmpty())
        	ClsAccountChangeEventTriggerHandler.processRelatedContact(accountIdsForRelContactUpdates);
	}
    //Pass Account event changes to create new VR. NS-743
    	if(!accountChanges.isEmpty()){
        	ClsAccountValRequestTriggerHandler.createNewValidationRequest(accountChanges);
		}

}