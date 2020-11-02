public class ClsAccountChangeEventTriggerHandler
{
    //Method will make the chosen Contact on the account as Primary on the AccountContactRelation object
    public static void processRelatedContact(Set<String> accountIdsForRelContactUpdates)
    {
        system.debug('*******ACCCHGEVT - Entered the method processRelatedContact');
        Map<Id, Id> accountIdToContactIdMap = new Map<Id, Id>();//Holds list of account to contact to process
        List<AccountContactRelation> createRelatedContactList = new List<AccountContactRelation>();//List used to create the related contacts
        List<AccountContactRelation> updateRelatedContactList = new List<AccountContactRelation>();//List used to update the related contacts        
        //Prepare the account contact map that need to be worked on
        for(Account acc : [SELECT Id, Contact__c FROM Account WHERE Id IN : accountIdsForRelContactUpdates])
            accountIdToContactIdMap.put(acc.Id, acc.Contact__c);
        if(!accountIdToContactIdMap.isEmpty())
        {
            system.debug('*******ACCCHGEVT - accountIdToContactIdMap found  ' + accountIdToContactIdMap);
            Map<String, String> existingAccIdToContactIdMap = new Map<String, String>();//Map stores the account id to contact id combination
            //Get all existing Account Contact Relations that exist already  
            for(AccountContactRelation relContact : [SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE AccountId IN : accountIdToContactIdMap.keySet()])
            {
                String accToConId = relContact.AccountId + '-' + relContact.ContactId;
                existingAccIdToContactIdMap.put(accToConId, relContact.Id);
                system.debug('*******ACCCHGEVT - existingAccIdToContactIdMap found  ' + existingAccIdToContactIdMap);
            }
            for(Id accId : accountIdToContactIdMap.keySet())
            {
                String accToConId = accId + '-' + accountIdToContactIdMap.get(accId);
                system.debug('*******ACCCHGEVT - Processing Account Contact Id ' + accToConId);
                //Find if there is existing relation and if so, make it as Primary else create a new record
                if(existingAccIdToContactIdMap != null && existingAccIdToContactIdMap.containsKey(accToConId))
                {
                    system.debug('*******ACCCHGEVT - Found existing relation ' + existingAccIdToContactIdMap.containsKey(accToConId));
                    AccountContactRelation relContact = new AccountContactRelation (Id = existingAccIdToContactIdMap.get(accToConId));
                    relContact.Primary__c = true;
                    updateRelatedContactList.add(relContact);
                }else{
                    system.debug('*******ACCCHGEVT - New relation added');
                    AccountContactRelation relContact = new AccountContactRelation ();
                    relContact.AccountId = accId;
                    relContact.ContactId = accountIdToContactIdMap.get(accId);
                    relContact.Primary__c = true;
                    createRelatedContactList.add(relContact);
                }
            }
        }
        if(!updateRelatedContactList.isEmpty())
        {
            update updateRelatedContactList;
            system.debug('*******ACCCHGEVT - Update Relation');
        }
        if(!createRelatedContactList.isEmpty())
        {
            insert createRelatedContactList;
            system.debug('*******ACCCHGEVT - Insert Relation');
        }
    }
}