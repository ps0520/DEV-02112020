@isTest
private class ClsTestAccountContactRelationObject {
/****************************************************************
@Description    : Test class for AccountContactRelation logic
*****************************************************************/
    @isTest static void testRelatedAccountInsUpd(){
        //Insert 10 account records
        List<Account> accts = ClsTestDataFactory.createAccountsWithBillingAddress(10, 'DE Medical Facility', 'Germany');
        Test.startTest();
        //Get the first account, which was inserted
        Account a = accts[0];
        //Insert Contact
        Id deContactRecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('DE Contact').getRecordTypeId();
        List<Contact> conList = new List<Contact>();
        for(Integer i=0; i<10 ; i++){
            Contact con = new Contact();
            con.RecordtypeId = deContactRecordtypeId;
            con.AccountId = a.Id;
            con.FirstName = 'DE FirstName ' + i;
            con.LastName = 'DE LastName ' + i;
            conList.add(con);
        }
        insert conList;
        //Insert AccountContactRelation
        ClsAccountRelatedContactTriggerHandler.executeRelatedContactTrigger = true;
        List<AccountContactRelation> relContactList = new List<AccountContactRelation>();
        for(Integer i=1; i < 10 ; i++)
        {
            AccountContactRelation newRel = new AccountContactRelation();
            newRel.AccountId = accts[i].Id;
            newRel.ContactId = conList[2].Id;
            newRel.Primary__c = true;
            relContactList.add(newRel);
            system.debug('***INFO ADDED ' + newRel);
        }
        insert relContactList;
        //Change the primary relation for the first account
        ClsAccountRelatedContactTriggerHandler.executeRelatedContactTrigger = true;
        AccountContactRelation newRel = new AccountContactRelation();
        newRel.AccountId = accts[2].Id;
        newRel.ContactId = conList[5].Id;
        newRel.Primary__c = true;
        insert newRel;
        Test.stopTest();
    }
}