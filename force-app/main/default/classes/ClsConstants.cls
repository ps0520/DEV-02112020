public class ClsConstants {

    //Account Record Types
    public static final string ACCOUNT_DE_PRESCRIBER_RECORDTYPE_NAME = Label.Account_DE_Prescriber_RecordType_Name;
    public static final string ACCOUNT_CA_PRESCRIBER_RECORDTYPE_NAME = Label.Account_CA_Prescriber_RecordType_Name;
    public static final string ACCOUNT_DE_MEDICAL_FACILITY_RECORDTYPE_NAME = Label.Account_DE_Medical_Facility_RecordType_Name;
    public static final string ACCOUNT_CA_MEDICAL_FACILITY_RECORDTYPE_NAME = Label.Account_CA_Medical_Facility_RecordType_Name;
   
    public static final string ACCOUNT_DE_PRESCRIBER_RECORDTYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Account_DE_Prescriber_RecordType_Name).getRecordTypeId();
    public static final string ACCOUNT_DE_MEDICAL_FACILITY_RECORDTYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Account_DE_Medical_Facility_RecordType_Name).getRecordTypeId(); 
    
    //Validation Request Record Types
    public static final string VALIDATION_REQUEST_ACTIVITY_RECORDTYPE_NAME = Schema.SObjectType.QIDC__Validation_Request_ims__c.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
    public static final string VALIDATION_REQUEST_WORKPLACE_RECORDTYPE_NAME = Schema.SObjectType.QIDC__Validation_Request_ims__c.getRecordTypeInfosByName().get('Workplace').getRecordTypeId();  
    
    //Country codes
    public static final string GERMANY_COUNTRY_CODE = Label.Germany_Country_Code;
    public static final string CANADA_COUNTRY_CODE = Label.Canada_Country_Code;
    
    //VR Request Types
    public static final string REQUEST_TYPE_NEW = Label.New;
    public static final string REQUEST_TYPE_UPDATE = Label.Update;
    
    //VR Comment field
    public static final string NAMECHANGE = Label.Change_Business_Name_For_VR;
    public static final string FAXCHANGE = Label.Change_Fax_For_VR;
    public static final string FIRSTNAMECHANGE = Label.Change_First_Name_For_VR;
	public static final string LASTNAMECHANGE = Label.Change_Last_Name_For_VR;
	public static final string MEDICALFACILITYCHANGE = Label.Change_Medical_Facility_For_VR;
	public static final string PARENTCHANGE = Label.Change_Parent_Account_For_VR;
    public static final string PHONECHANGE = Label.Change_Phone_For_VR; 
    public static final string ADDRESSCHANGE = Label.Change_Address_For_VR; 
        
        
        
        	
        
        	
}