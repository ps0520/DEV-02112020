/*
@Author        : Kumar Navneet
@Date Created    : 07/10/2020
@Description    : Batch class for GB and IE Email Invoice Automation
****************************************************************************************/
global class BClsSendSdocInvoiceEmailAllCountry implements Database.Batchable<Sobject> {    
    private List<SDOC__SDJob__c> jobList = new List<SDOC__SDJob__c> {};
        private Map<String, String> mapETemId = new Map<String, String>(); 
    private String country;
    
    global BClsSendSdocInvoiceEmailAllCountry(String country){     
        String recordTypeName ;
        this.country = country;
        if(country == 'CLINICAL'){           
            recordTypeName = 'INTL SDoc Template';
        }    else {
            //Get all the invoice templates that are required for processing
            recordTypeName = String.isNotBlank(country) && String.isNotEmpty(country) ? country + '%' : '';
        }
        String templateQuery = 'Select Id, Name from SDOC__SDTemplate__c Where SDOC__Document_Category__c = \'Invoice\'';
        templateQuery+= String.isNotBlank(recordTypeName) && String.isNotEmpty(recordTypeName) ? (' AND Recordtype.Name LIKE \'' + recordTypeName + '\'') : '';
        system.debug('Template Query is ' + templateQuery);
        for(SDOC__SDTemplate__c Sd : Database.query(templateQuery)){
            this.mapETemId.put(Sd.Name, Sd.Id);
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        //If there is no country filter then query for all Orders that are to be processed for Email Invoicing
        String orderType = String.isNotBlank(country) && String.isNotEmpty(country) ? country + '%' : '';
        String query = 'SELECT Id, Payor__r.RecordType.name, Account.RecordType.Name, Invoice_Number__c, Account.Billingcountry , Payor__r.Billingcountry, Warehouse__c, Account.Preferred_Language__c FROM Order ';
        query+= ' where Invoice_Email_Status__c = \'Pending\'' ;                  
        query+= ' AND Email_Invoice_Opt_In__c = true ' ; 
        query+= String.isNotBlank(orderType) && String.isNotEmpty(orderType) ? (' AND Type LIKE \'' + orderType + '\'') : '';
        system.debug('Start Query is' + query);                
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope){ 
        for(Order objOrder : scope){  
            String strPDFTemplateId ;
            String strHTMLTemplateId ;
            String accRecordType ;
            if(objOrder.Invoice_Number__c != null && objOrder.Invoice_Number__c != ''){ 
                if(country == 'GB' || country == 'IE'){
                    accRecordType = objOrder.Payor__r.RecordType.name == null ? objOrder.Account.RecordType.Name : objOrder.Payor__r.RecordType.name;            
                    strPDFTemplateId = (accRecordType.startsWithIgnoreCase('IE Consumer') || accRecordType.startsWithIgnoreCase('IE Medical Facility')) && mapETemId.containsKey('IE Consumer Invoice') ? mapETemId.get('IE Consumer Invoice') : 
                    accRecordType.startsWithIgnoreCase('IE Payor') && mapETemId.containsKey('IE Payor Invoice') ? mapETemId.get('IE Payor Invoice') :
                    accRecordType.startsWithIgnoreCase('IE Pharmacy') && mapETemId.containsKey('IE Pharmacy Invoice') ? mapETemId.get('IE Pharmacy Invoice') :
                    accRecordType.startsWithIgnoreCase('GB Consumer') && mapETemId.containsKey('UK Consumer Invoice') ? mapETemId.get('UK Consumer Invoice') :
                    (accRecordType.startsWithIgnoreCase('GB Payor') || accRecordType.startsWithIgnoreCase('GB Medical Facility') || accRecordType.startsWithIgnoreCase('GB Pharmacy')) && mapETemId.containsKey('UK Payor Invoice') ? mapETemId.get('UK Payor Invoice') : '';
                    
                    strHTMLTemplateId = (accRecordType.startsWithIgnoreCase('IE Consumer') || accRecordType.startsWithIgnoreCase('IE Medical Facility') || accRecordType.startsWithIgnoreCase('IE Pharmacy')) && mapETemId.containsKey('IE Consumer Email') ? mapETemId.get('IE Consumer Email') : 
                    accRecordType.startsWithIgnoreCase('IE Payor') && mapETemId.containsKey('IE Payor Email') ? mapETemId.get('IE Payor Email') :
                    accRecordType.startsWithIgnoreCase('GB Consumer') && mapETemId.containsKey('UK Consumer Email') ? mapETemId.get('UK Consumer Email') :
                    (accRecordType.startsWithIgnoreCase('GB Payor') || accRecordType.startsWithIgnoreCase('GB Medical Facility') || accRecordType.startsWithIgnoreCase('GB Pharmacy')) && mapETemId.containsKey('UK Payor Email') ? mapETemId.get('UK Payor Email') : '';     
                    
                }else{
                    if(country == 'AT'){
                        accRecordType = objOrder.Account.RecordType.Name;            
                        strPDFTemplateId = accRecordType.startsWithIgnoreCase('AT Consumer')  && mapETemId.containsKey('AT_Invoice-PP_Fusion') ? mapETemId.get('AT_Invoice-PP_Fusion') : '';            
                        strHTMLTemplateId = accRecordType.startsWithIgnoreCase('AT Consumer') && mapETemId.containsKey('AT Consumer Email') ? mapETemId.get('AT Consumer Email') : '';               
                    }else{
                        if(country == 'CLINICAL'){
                            String acccountry ;                
                            String OrderWareHouse ;                            
                            if(objOrder.Payor__r.RecordType.name != null){
                                acccountry = objOrder.Payor__r.Billingcountry ;
                            } else {
                                acccountry = objOrder.Account.Billingcountry ;
                            }                
                            if(objOrder.Warehouse__c != null){
                                OrderWareHouse = objOrder.Warehouse__c ;
                            }
                            strPDFTemplateId = acccountry.startsWithIgnoreCase('Netherlands')  && mapETemId.containsKey('Clinical - EMEA NE Invoice') ? mapETemId.get('Clinical - EMEA NE Invoice') : 
                            (acccountry.startsWithIgnoreCase('Korea') || acccountry.startsWithIgnoreCase('Japan') || acccountry.startsWithIgnoreCase('Australia')) && mapETemId.containsKey('Clinical - APAC Invoice') ? mapETemId.get('Clinical - APAC Invoice') :
                            OrderWareHouse.startsWithIgnoreCase('HLUK') && mapETemId.containsKey('Clinical - EMEA UK specific') ? mapETemId.get('Clinical - EMEA UK specific') :
                            mapETemId.containsKey('Clinical - EMEA Invoice') ? mapETemId.get('Clinical - EMEA Invoice') : ''; 
                            strHTMLTemplateId = mapETemId.get('INTL Clinical Email') ;
                        } else{
                            if(country == 'CA'){
                                accRecordType = objOrder.Payor__r.RecordType.name == null ? objOrder.Account.RecordType.Name : objOrder.Payor__r.RecordType.name;
                                strPDFTemplateId = accRecordType.startsWithIgnoreCase('CA Consumer')  && mapETemId.containsKey('CA Consumer Invoice') ? mapETemId.get('CA Consumer Invoice') :                                      
                                accRecordType.startsWithIgnoreCase('CA Payor')  && mapETemId.containsKey('CA Payor Invoice') ? mapETemId.get('CA Payor Invoice') : '';              
                                strHTMLTemplateId = (accRecordType.startsWithIgnoreCase('CA Consumer') || accRecordType.startsWithIgnoreCase('CA Payor')) && mapETemId.containsKey('CA Consumer Email') ? mapETemId.get('CA Consumer Email') : '';     
                                
                            }else{
                                if(country == 'CH'){
                                    String accPrefLang = objOrder.Account.Preferred_Language__c;        
                                    strPDFTemplateId = accPrefLang.startsWithIgnoreCase('fr')  && mapETemId.containsKey('CH Invoice FRENCH') ? mapETemId.get('CH Invoice FRENCH') : 
                                    accPrefLang.startsWithIgnoreCase('it')  && mapETemId.containsKey('CH Invoice ITALIAN') ? mapETemId.get('CH Invoice ITALIAN') : 
                                    accPrefLang.startsWithIgnoreCase('de')  && mapETemId.containsKey('CH Invoice GERMAN') ? mapETemId.get('CH Invoice GERMAN') : '';                                     
                                    strHTMLTemplateId = mapETemId.containsKey('CH Consumer Email') ? mapETemId.get('CH Consumer Email') : '';     
                                }                                
                            }                           
                        }
                    }
                }                
                List<String> lstTemplateIds = new List<String>();
                if(String.isNotEmpty(strPDFTemplateId) && String.isNotBlank(strPDFTemplateId)) lstTemplateIds.add(strPDFTemplateId);
                if(String.isNotEmpty(strHTMLTemplateId) && String.isNotBlank(strHTMLTemplateId)) lstTemplateIds.add(strHTMLTemplateId);
                if(!lstTemplateIds.isEmpty()){                
                    jobList.add(new SDOC__SDJob__c(SDOC__Start__c = true,  SDOC__Oid__c = objOrder.Id, SDOC__ObjApiName__c = 'Order', SDOC__SendEmail__c = '1', SDOC__Doclist__c = String.join(lstTemplateIds, ','))); 
                }    
                update new Order(Id = objOrder.Id, Invoice_Email_Status__c = 'Sent'); 
            }  
        }        
        if(!jobList.isEmpty())insert jobList;
        update scope;
    }
    global void finish(Database.BatchableContext BC){
        system.debug('Order Finish: ');    }
}