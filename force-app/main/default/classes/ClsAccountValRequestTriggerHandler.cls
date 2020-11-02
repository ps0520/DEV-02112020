/****************************************************************************************************************
@Author        : Pradeep Sadasivan
@Date Created    : 29/07/2020
@Description    : Account Trigger Controller for Account Change events/Account Trigger for all IQVIA requirements- NS-743
                  - 
****************************************************************************************************************/
public class ClsAccountValRequestTriggerHandler {
    // populate Top Parent Account before insert/update, Param from Account Trigger
    public static void updateTopParentAccount(List<Account> newAccList){ 
        for(Account newAcc : newAccList){
            if(newAcc.Record_Type_Name__c == ClsConstants.ACCOUNT_DE_MEDICAL_FACILITY_RECORDTYPE_NAME || newAcc.Record_Type_Name__c == ClsConstants.ACCOUNT_CA_MEDICAL_FACILITY_RECORDTYPE_NAME) {
                if(newAcc.Id != newAcc.OK_Top_Level_ParentID__c){
                    newAcc.OK_Top_Level_Parent__c = newAcc.OK_Top_Level_ParentID__c;
               }
            }  
        }
    }
    public static void createNewValidationRequest(List<AccountChangeEvent> newAccList){
    Set<String> accountIdsForVRs = new Set<String>();
    Map<String, List<String>> newMap = new Map<String, List<String>>();
    
    LIST<QIDC__Validation_Request_ims__c> newValidationRequest = new LIST<QIDC__Validation_Request_ims__c>();
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
                event.Phone!= null ||
                event.Inactive__c !=null) {
               List<String> recordIds = event.ChangeEventHeader.getRecordIds();
                EventBus.ChangeEventHeader header = event.ChangeEventHeader; 
               accountIdsForVRs.addAll(recordIds);
               newMap.put(header.changetype,recordIds);
            }   
        }
        if(!accountIdsForVRs.isEmpty()){
        List<Account> newAccount =  [SELECT Id,OK_Status__c,Inactive__c,LastName,Gender__c,ShippingCountry,ShippingStateCode,ShippingCountryCode,OK_Ind_Type__c,OK_Main_Category__c,Parent.Name,
                             PersonTitle,RecordTypeID,FirstName,MiddleName,Phone,PersonMobilePhone,PersonEmail,Salutation,Facility_Number__c,Fax,ShippingStreet,Record_Type_Name__c,ShippingCity,ShippingPostalCode,ShippingState,
                             Medical_Facility__r.Name, Name,OK_Specialty_1__c, (SELECT OK_Role_1__c,Child_Account__c FROM Related_Child_Accounts__r LIMIT 1) from Account where ID IN : accountIdsForVRs];
            for(AccountChangeEvent changeAcc: newAccList){ 
                for(Account newAcc: newAccount){
                    System.debug('@@@@@@@@Line-47@@@@@@@@@' + newAcc);
                    EventBus.ChangeEventHeader header = changeAcc.ChangeEventHeader;
                    if ((newAcc.OK_Status__c == 'Invalid' && newAcc.Inactive__c == true )){} //If new account has OneKey Id then skip the process OR if an account without onekey is updated then skip
                    else
                        System.debug('@@@@@@@@Line-50@@@@@@@@@' + newAcc);
                    {
                    if(newAcc.Record_Type_Name__c == ClsConstants.Account_DE_Prescriber_RecordType_Name || newAcc.Record_Type_Name__c == ClsConstants.Account_CA_Prescriber_RecordType_Name) {
                        QIDC__Validation_Request_ims__c newIndividualVR = new QIDC__Validation_Request_ims__c();
                        newIndividualVR.RecordTypeId = ClsConstants.VALIDATION_REQUEST_ACTIVITY_RECORDTYPE_NAME;
                        if (header.changetype == 'CREATE'){
                            newIndividualVR.OK_Request_Type__c =  ClsConstants.REQUEST_TYPE_NEW;
                        }else if(header.changetype == 'UPDATE'){
                            newIndividualVR.OK_Request_Type__c =  ClsConstants.REQUEST_TYPE_UPDATE;
                        }
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
                            newIndividualVR.QIDC__Request_Comments_ims__c = Label.Change_First_Name_For_VR;
                        }else if(changeAcc.LastName != null){
                            newIndividualVR.QIDC__Request_Comments_ims__c = Label.Change_Last_Name_For_VR;     
                        }else if(changeAcc.Medical_Facility__c != null){
                            newIndividualVR.QIDC__Request_Comments_ims__c = Label.Change_Medical_Facility_For_VR;    
                        }else if(changeAcc.ShippingStreet != null || changeAcc.ShippingCity != null || changeAcc.ShippingState != null || changeAcc.ShippingPostalCode != null){
                            newIndividualVR.QIDC__Request_Comments_ims__c = Label.Change_Address_For_VR;     
                        }
                        if(newAcc.Related_Child_Accounts__r.size()>0) {
                            for(Related_Account__c relatedAccountDetails : newAcc.Related_Child_Accounts__r) {
                                newIndividualVR.QIDC__Role_ims__c = relatedAccountDetails.OK_Role_1__c;
                            }
                        }
                        newValidationRequest.add(newIndividualVR); 
                    }else if(newAcc.Record_Type_Name__c == ClsConstants.ACCOUNT_DE_MEDICAL_FACILITY_RECORDTYPE_NAME || newAcc.Record_Type_Name__c == ClsConstants.ACCOUNT_CA_MEDICAL_FACILITY_RECORDTYPE_NAME ) {
                        QIDC__Validation_Request_ims__c newWorkplaceVR = new QIDC__Validation_Request_ims__c();
                        newWorkplaceVR.RecordTypeId = ClsConstants.VALIDATION_REQUEST_WORKPLACE_RECORDTYPE_NAME;
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
                        if (header.changetype == 'CREATE'){
                            newWorkplaceVR.OK_Request_Type__c =  ClsConstants.REQUEST_TYPE_NEW;
                        }else if(header.changetype == 'UPDATE'){
                            newWorkplaceVR.OK_Request_Type__c =  ClsConstants.REQUEST_TYPE_UPDATE;
                        }
                        if(changeAcc.Name != null){
                            newWorkplaceVR.QIDC__Request_Comments_ims__c = Label.Change_Business_Name_For_VR;
                        }else if(changeAcc.Fax != null){
                            newWorkplaceVR.QIDC__Request_Comments_ims__c = Label.Change_Fax_For_VR;     
                        }else if(changeAcc.Phone != null){
                            newWorkplaceVR.QIDC__Request_Comments_ims__c = Label.Change_Phone_For_VR;     
                        }else if(changeAcc.ParentID != null){
                            newWorkplaceVR.QIDC__Request_Comments_ims__c = Label.Change_Parent_Account_For_VR;    
                        }else if(changeAcc.ShippingStreet != null || newAcc.ShippingCity != null || newAcc.ShippingState != null || newAcc.ShippingPostalCode != null){
                            newWorkplaceVR.QIDC__Request_Comments_ims__c = Label.Change_Address_For_VR;     
                        }
                        newValidationRequest.add(newWorkplaceVR);                              
                    }
                }
                }
            }
            try{
                if(!newValidationRequest.isEmpty()){
                    insert newValidationRequest;
                    System.debug('@@@@@@@@Line-133@@@@@@@@@' + newValidationRequest);
                }
            }catch(system.DmlException de){
                System.debug('The following exception has occurred: ' + de.getMessage());
            }
        }
    }
}