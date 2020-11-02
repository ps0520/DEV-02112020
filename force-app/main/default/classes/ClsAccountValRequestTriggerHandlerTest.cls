@isTest
private class ClsAccountValRequestTriggerHandlerTest{
   @isTest
    Static void creativeActivityValidationRequestActivity(){
         Profile prof = [Select Id from Profile where name = 'DE Salesforce Admin'];
		User u = new User(
        ProfileId = prof.Id,
        Username = 'test123@dexcomtest.com',
        Alias = 'batmans',
        Email='test123@dexcomtest.com',
        EmailEncodingKey='UTF-8',
        Firstname='Bruces',
        Lastname='Wayne',
		LanguageLocaleKey='en_US',	
        LocaleSidKey='de_DE_EURO',
		TimeZoneSidKey='Europe/Berlin');
       // QIDC__OK_Available_Countries_ims__c = 'DE',
       // QIDC__OK_Preferred_Country_ims__c ='DE');
        insert u;
      
         Account parentAccount = new Account(Name  = 'parentAccount-s',
                                                 ShippingStreet = 'Street12',
                                                 ShippingCity ='Petersburger',
                                                 ShippingPostalCode = '10248',
                                                 ShippingState = 'Berlin',
                                                 ShippingCountry = 'Germany',
                                                 BillingStreet = 'Street1',
                                                 BillingCity ='Petersburger',
                                                 BillingPostalCode = '10248',
                                                 BillingState = 'Berlin',
                                                 BillingCountry = 'Germany',
                                                 RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('DE Medical Facility').getRecordTypeId());
    insert parentAccount;
   
    Account medicalFacilityAccount = new Account(Name  = 'Medical facility',
                                                 ShippingStreet = 'Street1',
                                                 ShippingCity ='Petersburger',
                                                 ShippingPostalCode = '10247',
                                                 ShippingState = 'Berlin',
                                                 ShippingCountry = 'Germany',
                                                 BillingStreet = 'Street1',
                                                 BillingCity ='Petersburger',
                                                 BillingPostalCode = '10247',
                                                 BillingState = 'Berlin',
                                                 BillingCountry = 'Germany',
                                                 ParentID = parentAccount.id,
                                                 RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('DE Medical Facility').getRecordTypeId());
    insert medicalFacilityAccount;
          Account prescriberAccount = new Account(FirstName = 'Joe',
                                       LastName  = 'Prescriber',
                                       Gender__c =  'Male',
                                       Prescriber_Id__c = '23333333',
                                       ShippingStreet = 'Street1',
                                       ShippingCity ='Petersburger',
                                       ShippingPostalCode = '10247',
                                       ShippingState = 'Berlin',
                                       ShippingCountry = 'Germany',
                                       BillingStreet = 'Street1',
                                       BillingCity ='Petersburger',
                                       BillingPostalCode = '10247',
                                       BillingState = 'Berlin',
                                       BillingCountry = 'Germany',
                                       RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('DE Prescriber').getRecordTypeId());
    insert prescriberAccount ;
    Related_Account__c childAccount = new Related_Account__c(Parent_Account__c = medicalFacilityAccount.Id,
                                       Child_Account__c = prescriberAccount.Id
                                      );
    insert childAccount;
    Address__c  addressShip = new Address__c (Address_Line_1__c  = 'Line1',
                                       Address_Line_2__c = 'Line2',
                                       Address_Line_3__c =  'Line3',
                                       City__c= 'Petersburger',
                                       Country__c = 'Germany',
                                       Postal_Code__c = '10247',
                                       Type__c ='Ship To',
                                       RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('DE Address').getRecordTypeId(),
                                       Account__c = prescriberAccount.Id );
    insert addressShip;
    Address__c  addressBill = new Address__c (Address_Line_1__c  = 'Line1',
                                       Address_Line_2__c = 'Line2',
                                       Address_Line_3__c =  'Line3',
                                       City__c= 'Petersburger',
                                       Country__c = 'Germany',
                                       Postal_Code__c = '10247',
                                       Type__c ='Bill To',
                                       RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('DE Address').getRecordTypeId(),
                                       Account__c = prescriberAccount.Id);
    insert addressBill; 

   
        
      Test.enableChangeDataCapture();
        prescriberAccount.LastName ='Test change';
    prescriberAccount.ShippingPostalCode = '46236';
        system.runAs(u){
    Test.startTest();
    update prescriberAccount;
    Test.stopTest();
    Account ac=[select id,LastName,ShippingPostalCode from account where id=:prescriberAccount.id];
	System.assertEquals(ac.LastName, 'Test change');
    System.assertEquals(ac.ShippingPostalCode, '46236');  
   }
    }
    @isTest
    Static void creativeActivityValidationRequestWorkplace(){
    Profile prof = [Select Id from Profile where name = 'DE Inside Sales User'];
		User u = new User(
        ProfileId = prof.Id,
        Username = 'test123@dexcomtest.com',
        Alias = 'batmans',
        Email='test123@dexcomtest.com',
        EmailEncodingKey='UTF-8',
        Firstname='Bruces',
        Lastname='Wayne',
		LanguageLocaleKey='en_US',	
        LocaleSidKey='de_DE_EURO',
		TimeZoneSidKey='Europe/Berlin',
        QIDC__OK_Available_Countries_ims__c = 'DE',
        QIDC__OK_Preferred_Country_ims__c ='DE');
        insert u;
       
         Account acc =  [SELECT Id,Name,ShippingPostalCode,Phone FROM Account WHERE Name = 'Medical facility' LIMIT 1];
    
    Test.enableChangeDataCapture();
    acc.Name ='Facility level2';
    acc.ShippingPostalCode = '46237';
    acc.phone ='0112233333';
    system.runAs(u){
    Test.startTest();
    update acc;
    Test.stopTest();
    Account ac1=[select id,Name,ShippingPostalCode,phone from account where id=:acc.id];
	System.assertEquals(ac1.Name, 'Facility level2');
    System.assertEquals(ac1.ShippingPostalCode, '46237');
    System.assertEquals(ac1.phone, '0112233333'); 
    }
    }

}