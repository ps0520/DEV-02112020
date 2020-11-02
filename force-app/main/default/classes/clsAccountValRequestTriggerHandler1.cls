/****************************************************************************************************************
@Author        : Pradeep Sadasivan
@Date Created    : 29/07/2020
@Description    : Account Trigger Controller class to create new Validation Request for Prescriber or Medical Facility
****************************************************************************************************************/
public class clsAccountValRequestTriggerHandler1{
	public static void createNewValidationRequest1(List<AccountChangeEvent> newAccList){
        Set<String> accountIdsForVRs = new Set<String>();
    	for (AccountChangeEvent event : newAccList) {
    		if( event.FirstName != null ||
            	event.LastName != null  ||
             	event.Medical_Facility__c != null ||
             	event.ShippingStreet!= null ||
             	event.ShippingCity != null ||
             	event.ShippingState!= null||
             	event.ShippingPostalCode!= null ||
             	event.Name != null ||
             	event.Fax!= null ||
             	event.ParentID!= null||
             	event.Phone!= null) {
               List<String> recordIds = event.ChangeEventHeader.getRecordIds();
             accountIdsForVRs.addAll(recordIds);
   			}
		}
        if(!accountIdsForVRs.isEmpty()){
     	List<Account> newAccount =  [SELECT Id,LastName,Gender__c,ShippingCountry,ShippingStateCode,ShippingCountryCode,OK_Ind_Type__c,OK_Main_Category__c,Parent.Name,
                             PersonTitle,RecordTypeID,CreatedBy.Profile.Name,FirstName,MiddleName,Phone,PersonMobilePhone,PersonEmail,Salutation,Facility_Number__c,Fax,ShippingStreet,Record_Type_Name__c,ShippingCity,ShippingPostalCode,ShippingState,
                             Medical_Facility__r.Name, Name,OK_Specialty_1__c, (SELECT OK_Role_1__c,Child_Account__c FROM Related_Child_Accounts__r LIMIT 1) from Account where ID IN : accountIdsForVRs];
            LIST<QIDC__Validation_Request_ims__c> newValidationRequest = new LIST<QIDC__Validation_Request_ims__c>();
         for(Account newAcc: newAccount){
             AccountChangeEvent changeAcc = newAccList[0];
            if(newAcc.Record_Type_Name__c == Constants.Account_DE_Prescriber_RecordType_Name || newAcc.Record_Type_Name__c == Constants.Account_CA_Prescriber_RecordType_Name) {
                QIDC__Validation_Request_ims__c newIndividualVR = new QIDC__Validation_Request_ims__c();
                newIndividualVR.RecordTypeId = Constants.VALIDATION_REQUEST_ACTIVITY_RECORDTYPE_NAME;
                newIndividualVR.QIDC__Individual_ims__c = newAcc.id;
                newIndividualVR.QIDC__First_Name_ims__c = newAcc.FirstName;
                newIndividualVR.QIDC__Middle_Name_ims__c = newAcc.MiddleName;
                newIndividualVR.QIDC__Last_Name_ims__c = newAcc.LastName;
                newIndividualVR.QIDC__Courtesy_Title_ims__c = newAcc.Salutation;
                newIndividualVR.QIDC__Individual_Title_ims__c=newAcc.PersonTitle;
                newIndividualVR.QIDC__Gender_ims__c = newAcc.Gender__c;
                newIndividualVR.QIDC__Individual_Type_ims__c = newAcc.OK_Ind_Type__c;
                newIndividualVR.QIDC__Primary_Specialty_ims__c= newAcc.OK_Specialty_1__c;
                newIndividualVR.QIDC__Name_ims__c = newAcc.Medical_Facility__r.Name;
                newIndividualVR.QIDC__Organization_Name_ims__c = newAcc.Medical_Facility__r.Name;
                newIndividualVR.QIDC__Workplace_Type_ims__c= newAcc.OK_Ind_Type__c;
                newIndividualVR.QIDC__Category_ims__c = newAcc.OK_Main_Category__c;
                newIndividualVR.QIDC__Address_Line_1_ims__c = newAcc.ShippingStreet;
                newIndividualVR.QIDC__City_ims__c = newAcc.ShippingCity;
                newIndividualVR.QIDC__Postal_Code_ims__c = newAcc.ShippingPostalCode;
                newIndividualVR.QIDC__County_ims__c = newAcc.ShippingState;
                if(changeAcc.FirstName != null){
                   newIndividualVR.QIDC__Request_Comments_ims__c = 'Change of First Name, please refer Account history for details';
                }else if(changeAcc.LastName != null){
                   newIndividualVR.QIDC__Request_Comments_ims__c = 'Change of Last Name, please refer Account history for details';     
                }else if(changeAcc.LastName != null){
                   newIndividualVR.QIDC__Request_Comments_ims__c = 'Change of Last Name, please refer Account history for details';     
                }else if(changeAcc.Medical_Facility__c != null){
                   newIndividualVR.QIDC__Request_Comments_ims__c = 'Change of Medical Facility, please refer Account history for details';     
                }else if(changeAcc.ShippingStreet != null || changeAcc.ShippingCity != null || changeAcc.ShippingState != null || changeAcc.ShippingPostalCode != null){
                   newIndividualVR.QIDC__Request_Comments_ims__c = 'Change of Address, please refer Account history for details';     
                }
                if(newAcc.Related_Child_Accounts__r.size()>0) {
                    for(Related_Account__c relatedAccountDetails : newAcc.Related_Child_Accounts__r) {
                    	newIndividualVR.QIDC__Role_ims__c = relatedAccountDetails.OK_Role_1__c;
                    }
                }
                newValidationRequest.add(newIndividualVR); 
            }else if(newAcc.Record_Type_Name__c == Constants.ACCOUNT_DE_MEDICAL_FACILITY_RECORDTYPE_NAME || newAcc.Record_Type_Name__c == Constants.ACCOUNT_CA_MEDICAL_FACILITY_RECORDTYPE_NAME ) {
                QIDC__Validation_Request_ims__c newWorkplaceVR = new QIDC__Validation_Request_ims__c();
                newWorkplaceVR.RecordTypeId = Constants.VALIDATION_REQUEST_WORKPLACE_RECORDTYPE_NAME;
                newWorkplaceVR.QIDC__Workplace_ims__c = newAcc.Id;
                newWorkplaceVR.QIDC__Name_ims__c = newAcc.Name;
                newWorkplaceVR.QIDC__Organization_Name_ims__c = newAcc.Name;
                newWorkplaceVR.QIDC__Address_Line_1_ims__c = newAcc.ShippingStreet;
                newWorkplaceVR.QIDC__City_ims__c = newAcc.ShippingCity;
                newWorkplaceVR.QIDC__Postal_Code_ims__c = newAcc.ShippingPostalCode;
                newWorkplaceVR.QIDC__Workplace_Parent_EID_ims__c = newAcc.Parent.Name;
                newWorkplaceVR.QIDC__County_ims__c = newAcc.ShippingState;
                newWorkplaceVR.QIDC__Workplace_Type_ims__c= newAcc.OK_Main_Category__c;
                newWorkplaceVR.QIDC__Category_ims__c = newAcc.OK_Main_Category__c;
                newWorkplaceVR.OK_Fax__c = newAcc.Fax;
                newWorkplaceVR.OK_Work_Phone__c = newAcc.Phone;
                newWorkplaceVR.OK_Facility_Number__c = newAcc.Facility_Number__c;
                if(changeAcc.Name != null){
                   newWorkplaceVR.QIDC__Request_Comments_ims__c = 'Change of Business Name, please refer Account history for details';
                }else if(changeAcc.Fax != null){
                   newWorkplaceVR.QIDC__Request_Comments_ims__c = 'Change of Fax, please refer Account history for details';     
                }else if(changeAcc.Phone != null){
                   newWorkplaceVR.QIDC__Request_Comments_ims__c = 'Change of Phone number, please refer Account history for details';     
                }else if(changeAcc.ParentID != null){
                   newWorkplaceVR.QIDC__Request_Comments_ims__c = 'Change of Parent Account, please refer Account history for details';     
                }else if(changeAcc.ShippingStreet != null || newAcc.ShippingCity != null || newAcc.ShippingState != null || newAcc.ShippingPostalCode != null){
                   newWorkplaceVR.QIDC__Request_Comments_ims__c = 'Change of Address, please refer Account history for details';     
                }
                newValidationRequest.add(newWorkplaceVR);                              
            }
        
        }
        try{
            if(!newValidationRequest.isEmpty()){
                insert newValidationRequest;
                System.debug('LINE-81 controller ClsAccountValRequestTriggerHandler' +newValidationRequest);
            }
        }catch(system.DmlException de){
            System.debug('The following exception has occurred: ' + de.getMessage());
        }
        
    }
    }
}
//}
/*    private List<Account> newAccList;
     private List<Account> oldAccList;      
     public ClsAccountValRequestTriggerHandler1 (List<Account> newAccounts,List<Account> oldAccounts) {
                            this.newAccList= newAccounts;
                            this.oldAccList= oldAccounts;
    }
      
      public void execute(QueueableContext queCont){
      
       LIST<QIDC__Validation_Request_ims__c> newValidationRequest = new LIST<QIDC__Validation_Request_ims__c>();
       LIST<Account> accountDataList = [SELECT Id,LastName,Gender__c,ShippingCountry,ShippingStateCode,ShippingCountryCode,OK_Ind_Type__c,OK_Main_Category__c,Parent.Name,
                             PersonTitle,RecordTypeID,FirstName,MiddleName,Phone,PersonMobilePhone,PersonEmail,Salutation,Facility_Number__c,Fax,ShippingStreet,Record_Type_Name__c,ShippingCity,ShippingPostalCode,ShippingState,
                             Medical_Facility__r.Name, Name,OK_Specialty_1__c, (SELECT OK_Role_1__c,Child_Account__c FROM Related_Child_Accounts__r LIMIT 1) from ACCOUNT WHERE ID IN : newAccList];     
      
       if(!accountDataList.isEmpty()) {
            for(Account newAcc: accountDataList ) {
                Account oldAcc = oldAccList[0];
                if( ClsCheckRecursive.runOnce()) {
                    if(newAcc.Record_Type_Name__c == 'DE Prescriber') {
                        if( newAcc.FirstName != oldAcc.FirstName ||
                            newAcc.LastName != oldAcc.LastName ||
                            newAcc.Medical_Facility__r.ID != oldAcc.Medical_Facility__r.ID ||
                            newAcc.ShippingStreet!= oldAcc.ShippingStreet ||
                            newAcc.ShippingCity != oldAcc.ShippingCity ||
                            newAcc.ShippingState!= oldAcc.ShippingState||
                            newAcc.ShippingPostalCode!= oldAcc.ShippingPostalCode ||
                            newAcc.Phone!= oldAcc.Phone) { 
                            QIDC__Validation_Request_ims__c newIndividualVR = new QIDC__Validation_Request_ims__c();
                            newIndividualVR.RecordTypeId = Constants.VALIDATION_REQUEST_ACTIVITY_RECORDTYPE_NAME;
                            newIndividualVR.QIDC__Individual_ims__c = newAcc.id;
                            newIndividualVR.QIDC__Country_ISO_Code_ims__c= Constants.GERMANY_COUNTRY_CODE;
                            newIndividualVR.QIDC__First_Name_ims__c = newAcc.FirstName;
                            newIndividualVR.QIDC__Middle_Name_ims__c = newAcc.MiddleName;
                            newIndividualVR.QIDC__Last_Name_ims__c = newAcc.LastName;
                            newIndividualVR.QIDC__Courtesy_Title_ims__c = newAcc.Salutation;
                            newIndividualVR.QIDC__Individual_Title_ims__c=newAcc.PersonTitle;
                            newIndividualVR.QIDC__Gender_ims__c = newAcc.Gender__c;
                            newIndividualVR.QIDC__Individual_Type_ims__c = newAcc.OK_Ind_Type__c;
                            newIndividualVR.QIDC__Primary_Specialty_ims__c= newAcc.OK_Specialty_1__c;
                            newIndividualVR.QIDC__Name_ims__c = newAcc.Medical_Facility__r.Name;
                            newIndividualVR.QIDC__Organization_Name_ims__c = newAcc.Medical_Facility__r.Name;
                            newIndividualVR.QIDC__Workplace_Type_ims__c= newAcc.OK_Ind_Type__c;
                            newIndividualVR.QIDC__Category_ims__c = newAcc.OK_Main_Category__c;
                            newIndividualVR.QIDC__Address_Line_1_ims__c = newAcc.ShippingStreet;
                            newIndividualVR.QIDC__City_ims__c = newAcc.ShippingCity;
                            newIndividualVR.QIDC__Postal_Code_ims__c = newAcc.ShippingPostalCode;
                            newIndividualVR.QIDC__County_ims__c = newAcc.ShippingState;
                            newIndividualVR.QIDC__Request_Comments_ims__c = 'New Validation Request Submitted';
                                if(newAcc.Related_Child_Accounts__r.size()>0) {
                                    for(Related_Account__c relatedAccountDetails : newAcc.Related_Child_Accounts__r) {
                                        newIndividualVR.QIDC__Role_ims__c = relatedAccountDetails.OK_Role_1__c;
                                    }
                                }else {
                                    newIndividualVR.QIDC__Role_ims__c = 'NO VALUE AVAILABLE';
                                } 
                                newValidationRequest.add(newIndividualVR);      
                        }
                    }              
                    else if(newAcc.Record_Type_Name__c == Constants.ACCOUNT_DE_MEDICAL_FACILITY_RECORDTYPE_NAME ) {
                        if( newAcc.ShippingStreet!= oldAcc.ShippingStreet ||
                            newAcc.ShippingCity != oldAcc.ShippingCity ||
                            newAcc.ShippingState!= oldAcc.ShippingState||
                            newAcc.ShippingPostalCode!= oldAcc.ShippingPostalCode ||
                            newAcc.Phone!= oldAcc.Phone||
                            newAcc.Name != oldAcc.Name ||
                            newAcc.Facility_Number__c != oldAcc.Facility_Number__c ||
                            newAcc.Fax!= oldAcc.Fax ||
                            newAcc.Parent.ID!= oldAcc.Parent.ID ) {
                            QIDC__Validation_Request_ims__c newWorkplaceVR = new QIDC__Validation_Request_ims__c();
                            newWorkplaceVR.RecordTypeId = Constants.VALIDATION_REQUEST_WORKPLACE_RECORDTYPE_NAME;
                            newWorkplaceVR.QIDC__Workplace_ims__c = newAcc.Id;
                            newWorkplaceVR.QIDC__Name_ims__c = newAcc.Name;
                            newWorkplaceVR.QIDC__Organization_Name_ims__c = newAcc.Name;
                            newWorkplaceVR.QIDC__Address_Line_1_ims__c = newAcc.ShippingStreet;
                            newWorkplaceVR.QIDC__City_ims__c = newAcc.ShippingCity;
                            newWorkplaceVR.QIDC__Postal_Code_ims__c = newAcc.ShippingPostalCode;
                            newWorkplaceVR.QIDC__Workplace_Parent_EID_ims__c = newAcc.Parent.Name;
                            newWorkplaceVR.QIDC__County_ims__c = newAcc.ShippingState;
                            newWorkplaceVR.QIDC__Country_ISO_Code_ims__c= Constants.GERMANY_COUNTRY_CODE;
                            newWorkplaceVR.QIDC__Workplace_Type_ims__c= newAcc.OK_Main_Category__c;
                            newWorkplaceVR.QIDC__Category_ims__c = newAcc.OK_Main_Category__c;
                            newWorkplaceVR.OK_Fax__c = newAcc.Fax;
                            newWorkplaceVR.OK_Work_Phone__c = newAcc.Phone;
                            newWorkplaceVR.OK_Facility_Number__c = newAcc.Facility_Number__c;
                            newValidationRequest.add(newWorkplaceVR);                                     
                        }
                    }
                }
            }
            try{
                if(!newValidationRequest.isEmpty()){
                  insert newValidationRequest;
                }
            }catch(system.DmlException de){
                System.debug('The following exception has occurred: ' + de.getMessage());
            }
        }
      }        
           public static void createNewValidationRequest(List<Account> newAccList, List<Account> oldAccList) {
    
        LIST<QIDC__Validation_Request_ims__c> newValidationRequest = new LIST<QIDC__Validation_Request_ims__c>();
        LIST<Account> accountDataList = [SELECT Id,LastName,Gender__c,ShippingCountry,ShippingStateCode,ShippingCountryCode,OK_Ind_Type__c,OK_Main_Category__c,Parent.Name,
                             PersonTitle,RecordTypeID,FirstName,MiddleName,Phone,PersonMobilePhone,PersonEmail,Salutation,Facility_Number__c,Fax,ShippingStreet,Record_Type_Name__c,ShippingCity,ShippingPostalCode,ShippingState,
                             Medical_Facility__r.Name, Name,OK_Specialty_1__c, (SELECT OK_Role_1__c,Child_Account__c FROM Related_Child_Accounts__r LIMIT 1) from ACCOUNT WHERE ID IN : newAccList];              
        if(!accountDataList.isEmpty()) {
            for(Account newAcc: accountDataList ) {
                Account oldAcc = oldAccList[0];
                if( ClsCheckRecursive.runOnce()) {
                    if(newAcc.Record_Type_Name__c == 'DE Prescriber') {
                        if( newAcc.FirstName != oldAcc.FirstName ||
                            newAcc.LastName != oldAcc.LastName ||
                            newAcc.Medical_Facility__r.ID != oldAcc.Medical_Facility__r.ID ||
                            newAcc.ShippingStreet!= oldAcc.ShippingStreet ||
                            newAcc.ShippingCity != oldAcc.ShippingCity ||
                            newAcc.ShippingState!= oldAcc.ShippingState||
                            newAcc.ShippingPostalCode!= oldAcc.ShippingPostalCode ||
                            newAcc.Phone!= oldAcc.Phone) { 
                            QIDC__Validation_Request_ims__c newIndividualVR = new QIDC__Validation_Request_ims__c();
                            newIndividualVR.RecordTypeId = Constants.VALIDATION_REQUEST_ACTIVITY_RECORDTYPE_NAME;
                            newIndividualVR.QIDC__Individual_ims__c = newAcc.id;
                            newIndividualVR.QIDC__Country_ISO_Code_ims__c= Constants.GERMANY_COUNTRY_CODE;
                            newIndividualVR.QIDC__First_Name_ims__c = newAcc.FirstName;
                            newIndividualVR.QIDC__Middle_Name_ims__c = newAcc.MiddleName;
                            newIndividualVR.QIDC__Last_Name_ims__c = newAcc.LastName;
                            newIndividualVR.QIDC__Courtesy_Title_ims__c = newAcc.Salutation;
                            newIndividualVR.QIDC__Individual_Title_ims__c=newAcc.PersonTitle;
                            newIndividualVR.QIDC__Gender_ims__c = newAcc.Gender__c;
                            newIndividualVR.QIDC__Individual_Type_ims__c = newAcc.OK_Ind_Type__c;
                            newIndividualVR.QIDC__Primary_Specialty_ims__c= newAcc.OK_Specialty_1__c;
                            newIndividualVR.QIDC__Name_ims__c = newAcc.Medical_Facility__r.Name;
                            newIndividualVR.QIDC__Organization_Name_ims__c = newAcc.Medical_Facility__r.Name;
                            newIndividualVR.QIDC__Workplace_Type_ims__c= newAcc.OK_Ind_Type__c;
                            newIndividualVR.QIDC__Category_ims__c = newAcc.OK_Main_Category__c;
                            newIndividualVR.QIDC__Address_Line_1_ims__c = newAcc.ShippingStreet;
                            newIndividualVR.QIDC__City_ims__c = newAcc.ShippingCity;
                            newIndividualVR.QIDC__Postal_Code_ims__c = newAcc.ShippingPostalCode;
                            newIndividualVR.QIDC__County_ims__c = newAcc.ShippingState;
                            newIndividualVR.QIDC__Request_Comments_ims__c = 'New Validation Request Submitted';
                                if(newAcc.Related_Child_Accounts__r.size()>0) {
                                    for(Related_Account__c relatedAccountDetails : newAcc.Related_Child_Accounts__r) {
                                        newIndividualVR.QIDC__Role_ims__c = relatedAccountDetails.OK_Role_1__c;
                                    }
                                }else {
                                    newIndividualVR.QIDC__Role_ims__c = 'NO VALUE AVAILABLE';
                                } 
                                newValidationRequest.add(newIndividualVR);      
                        }
                    }              
                    else if(newAcc.Record_Type_Name__c == Constants.ACCOUNT_DE_MEDICAL_FACILITY_RECORDTYPE_NAME ) {
                        if( newAcc.ShippingStreet!= oldAcc.ShippingStreet ||
                            newAcc.ShippingCity != oldAcc.ShippingCity ||
                            newAcc.ShippingState!= oldAcc.ShippingState||
                            newAcc.ShippingPostalCode!= oldAcc.ShippingPostalCode ||
                            newAcc.Phone!= oldAcc.Phone||
                            newAcc.Name != oldAcc.Name ||
                            newAcc.Facility_Number__c != oldAcc.Facility_Number__c ||
                            newAcc.Fax!= oldAcc.Fax ||
                            newAcc.Parent.ID!= oldAcc.Parent.ID ) {
                            QIDC__Validation_Request_ims__c newWorkplaceVR = new QIDC__Validation_Request_ims__c();
                            newWorkplaceVR.RecordTypeId = Constants.VALIDATION_REQUEST_WORKPLACE_RECORDTYPE_NAME;
                            newWorkplaceVR.QIDC__Workplace_ims__c = newAcc.Id;
                            newWorkplaceVR.QIDC__Name_ims__c = newAcc.Name;
                            newWorkplaceVR.QIDC__Organization_Name_ims__c = newAcc.Name;
                            newWorkplaceVR.QIDC__Address_Line_1_ims__c = newAcc.ShippingStreet;
                            newWorkplaceVR.QIDC__City_ims__c = newAcc.ShippingCity;
                            newWorkplaceVR.QIDC__Postal_Code_ims__c = newAcc.ShippingPostalCode;
                            newWorkplaceVR.QIDC__Workplace_Parent_EID_ims__c = newAcc.Parent.Name;
                            newWorkplaceVR.QIDC__County_ims__c = newAcc.ShippingState;
                            newWorkplaceVR.QIDC__Country_ISO_Code_ims__c= Constants.GERMANY_COUNTRY_CODE;
                            newWorkplaceVR.QIDC__Workplace_Type_ims__c= newAcc.OK_Main_Category__c;
                            newWorkplaceVR.QIDC__Category_ims__c = newAcc.OK_Main_Category__c;
                            newWorkplaceVR.OK_Fax__c = newAcc.Fax;
                            newWorkplaceVR.OK_Work_Phone__c = newAcc.Phone;
                            newWorkplaceVR.OK_Facility_Number__c = newAcc.Facility_Number__c;
                            newValidationRequest.add(newWorkplaceVR);                                     
                        }
                    }
                }
            }
            try{
                if(!newValidationRequest.isEmpty()){
                  insert newValidationRequest;
                }
            }catch(system.DmlException de){
                System.debug('The following exception has occurred: ' + de.getMessage());
            }
        }
    }

   
    
    
    //method to create new Validation Request for Prescriber or Medical Facility Param from change event
  /*  public static void createNewValidationRequest(List<Account> newAccList){
    LIST<QIDC__Validation_Request_ims__c> newValidationRequest = new LIST<QIDC__Validation_Request_ims__c>();
        for(Account newAcc: newAccList){
            if(newAcc.Record_Type_Name__c == Constants.Account_DE_Prescriber_RecordType_Name || newAcc.Record_Type_Name__c == Constants.Account_CA_Prescriber_RecordType_Name) {
                QIDC__Validation_Request_ims__c newIndividualVR = new QIDC__Validation_Request_ims__c();
                newIndividualVR.RecordTypeId = Constants.VALIDATION_REQUEST_ACTIVITY_RECORDTYPE_NAME;
                newIndividualVR.QIDC__Individual_ims__c = newAcc.id;
                newIndividualVR.QIDC__First_Name_ims__c = newAcc.FirstName;
                newIndividualVR.QIDC__Middle_Name_ims__c = newAcc.MiddleName;
                newIndividualVR.QIDC__Last_Name_ims__c = newAcc.LastName;
                newIndividualVR.QIDC__Courtesy_Title_ims__c = newAcc.Salutation;
                newIndividualVR.QIDC__Individual_Title_ims__c=newAcc.PersonTitle;
                newIndividualVR.QIDC__Gender_ims__c = newAcc.Gender__c;
                newIndividualVR.QIDC__Individual_Type_ims__c = newAcc.OK_Ind_Type__c;
                newIndividualVR.QIDC__Primary_Specialty_ims__c= newAcc.OK_Specialty_1__c;
                newIndividualVR.QIDC__Name_ims__c = newAcc.Medical_Facility__r.Name;
                newIndividualVR.QIDC__Organization_Name_ims__c = newAcc.Medical_Facility__r.Name;
                newIndividualVR.QIDC__Workplace_Type_ims__c= newAcc.OK_Ind_Type__c;
                newIndividualVR.QIDC__Category_ims__c = newAcc.OK_Main_Category__c;
                newIndividualVR.QIDC__Address_Line_1_ims__c = newAcc.ShippingStreet;
                newIndividualVR.QIDC__City_ims__c = newAcc.ShippingCity;
                newIndividualVR.QIDC__Postal_Code_ims__c = newAcc.ShippingPostalCode;
                newIndividualVR.QIDC__County_ims__c = newAcc.ShippingState;
                if(newAcc.FirstName != null){
                   newIndividualVR.QIDC__Request_Comments_ims__c = 'Change of First Name, please refer Account history for details';
                }else if(newAcc.LastName != null){
                   newIndividualVR.QIDC__Request_Comments_ims__c = 'Change of Last Name, please refer Account history for details';     
                }else if(newAcc.LastName != null){
                   newIndividualVR.QIDC__Request_Comments_ims__c = 'Change of Last Name, please refer Account history for details';     
                }else if(newAcc.Medical_Facility__c != null){
                   newIndividualVR.QIDC__Request_Comments_ims__c = 'Change of Medical Facility, please refer Account history for details';     
                }else if(newAcc.ShippingStreet != null || newAcc.ShippingCity != null || newAcc.ShippingState != null || newAcc.ShippingPostalCode != null){
                   newIndividualVR.QIDC__Request_Comments_ims__c = 'Change of Address, please refer Account history for details';     
                }
                if(newAcc.Related_Child_Accounts__r.size()>0) {
                    for(Related_Account__c relatedAccountDetails : newAcc.Related_Child_Accounts__r) {
                    	newIndividualVR.QIDC__Role_ims__c = relatedAccountDetails.OK_Role_1__c;
                    }
                }
                newValidationRequest.add(newIndividualVR); 
            }else if(newAcc.Record_Type_Name__c == Constants.ACCOUNT_DE_MEDICAL_FACILITY_RECORDTYPE_NAME || newAcc.Record_Type_Name__c == Constants.ACCOUNT_CA_MEDICAL_FACILITY_RECORDTYPE_NAME ) {
                QIDC__Validation_Request_ims__c newWorkplaceVR = new QIDC__Validation_Request_ims__c();
                newWorkplaceVR.RecordTypeId = Constants.VALIDATION_REQUEST_WORKPLACE_RECORDTYPE_NAME;
                newWorkplaceVR.QIDC__Workplace_ims__c = newAcc.Id;
                newWorkplaceVR.QIDC__Name_ims__c = newAcc.Name;
                newWorkplaceVR.QIDC__Organization_Name_ims__c = newAcc.Name;
                newWorkplaceVR.QIDC__Address_Line_1_ims__c = newAcc.ShippingStreet;
                newWorkplaceVR.QIDC__City_ims__c = newAcc.ShippingCity;
                newWorkplaceVR.QIDC__Postal_Code_ims__c = newAcc.ShippingPostalCode;
                newWorkplaceVR.QIDC__Workplace_Parent_EID_ims__c = newAcc.Parent.Name;
                newWorkplaceVR.QIDC__County_ims__c = newAcc.ShippingState;
                newWorkplaceVR.QIDC__Workplace_Type_ims__c= newAcc.OK_Main_Category__c;
                newWorkplaceVR.QIDC__Category_ims__c = newAcc.OK_Main_Category__c;
                newWorkplaceVR.OK_Fax__c = newAcc.Fax;
                newWorkplaceVR.OK_Work_Phone__c = newAcc.Phone;
                newWorkplaceVR.OK_Facility_Number__c = newAcc.Facility_Number__c;
                if(newAcc.Name != null){
                   newWorkplaceVR.QIDC__Request_Comments_ims__c = 'Change of Business Name, please refer Account history for details';
                }else if(newAcc.Fax != null){
                   newWorkplaceVR.QIDC__Request_Comments_ims__c = 'Change of Fax, please refer Account history for details';     
                }else if(newAcc.Phone != null){
                   newWorkplaceVR.QIDC__Request_Comments_ims__c = 'Change of Phone number, please refer Account history for details';     
                }else if(newAcc.Parent.Name != null){
                   newWorkplaceVR.QIDC__Request_Comments_ims__c = 'Change of Parent Account, please refer Account history for details';     
                }else if(newAcc.ShippingStreet != null || newAcc.ShippingCity != null || newAcc.ShippingState != null || newAcc.ShippingPostalCode != null){
                   newWorkplaceVR.QIDC__Request_Comments_ims__c = 'Change of Address, please refer Account history for details';     
                }
                newValidationRequest.add(newWorkplaceVR);                              
            }
        }
        try{
            if(!newValidationRequest.isEmpty()){
                insert newValidationRequest;
                System.debug('LINE-81 controller ClsAccountValRequestTriggerHandler' +newValidationRequest);
            }
        }catch(system.DmlException de){
            System.debug('The following exception has occurred: ' + de.getMessage());
        }
    } */