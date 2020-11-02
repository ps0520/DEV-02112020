global class PEClsHandleBatchOCEEvent implements Database.batchable<Sobject>, Database.AllowsCallouts {
	
    private List<OCE_Account_Event__e> lstOCEAccEvent;
    global PEClsHandleBatchOCEEvent(List<OCE_Account_Event__e> lstOCEEvent){
        this.lstOCEAccEvent = lstOCEEvent;
    }
    
    global Iterable<Sobject> start(Database.BatchableContext BC){
        return new ObjectIterator(lstOCEAccEvent);
    }
    
    global void execute(Database.BatchableContext BC, List<OCE_Account_Event__e> lstOCEOEvent){
        OCE_Account_Event__e OCEevt= lstOCEOEvent[0];
        Map<String,String> sampleOrderResultedMap = new Map<String,String>();
        Boolean eventMandateFieldFlag = validateEventMandate(OCEevt);
        if(!eventMandateFieldFlag) return;
        if(eventMandateFieldFlag){
            Map<Id, Address__c> accntIdToBillToAddressMap = new Map<Id, Address__c>();
            Map<Id, Address__c> accntIdToShipToAddressMap = new Map<Id, Address__c>();
            Account accountOneKey = [Select id,IQVIA_OneKeyId__c from Account where IQVIA_OneKeyId__c =: OCEevt.AccountOnekeyId__c];
            // Check Mandate fields
            //if not found then create account
            // 1 - Address - If one of then copy on other 
            // 2 - Address - if not then create both
            // Address - If Shipt to Found and bill to not then copy ship to in to BillTo
            // Address - If Bikll to Found and Ship to not then copy Bill to in to Shipto
            // address - if both addres not found then create both address based on Event
            // Account & address - Validation method Split
            
            
            Address__c ShipToAddrs = null;
            Address__c BillToAddrs = null;
            if(accountOneKey != null){
                
                for(Address__c addr : [Select id,Account__c,Account__r.IQVIA_OneKeyId__c,IQVIA_OneKeyId__c,Type__c,Primary_Flag__c
                                       from Address__c where  Primary_Flag__c = TRUE AND Account__r.IQVIA_OneKeyId__c =: OCEevt.AccountOnekeyId__c AND IQVIA_OneKeyId__c =: OCEevt.AddressOneKeyId__c]){
                                           if(addr.Type__c == 'Bill To')
                                               accntIdToBillToAddressMap.put(addr.Account__r.IQVIA_OneKeyId__c, addr);
                                           else if(addr.Type__c == 'Ship To')
                                               accntIdToShipToAddressMap.put(addr.Account__r.IQVIA_OneKeyId__c, addr);
                                       }
                
                if(accntIdToShipToAddressMap.get(OCEevt.AccountOnekeyId__c) == null && accntIdToBillToAddressMap.get(OCEevt.AccountOnekeyId__c) != null  ){
                    BillToAddrs = accntIdToBillToAddressMap.get(OCEevt.AccountOnekeyId__c);
                    Address__c ShipToAddressCreate = new Address__c();
                    ShipToAddressCreate.Account__c = BillToAddrs.Account__c;
                    ShipToAddressCreate.Address_Line_1__c = BillToAddrs.Address_Line_1__c;
                    ShipToAddressCreate.Address_Line_2__c = BillToAddrs.Address_Line_2__c;
                    ShipToAddressCreate.Address_Line_3__c = BillToAddrs.Address_Line_3__c;
                    ShipToAddressCreate.Type__c = 'Ship To';
                    ShipToAddressCreate.City__c = BillToAddrs.City__c;
                    ShipToAddressCreate.Postal_Code__c = BillToAddrs.Postal_Code__c;
                    ShipToAddressCreate.State__c = BillToAddrs.State__c;
                    insert ShipToAddressCreate;
                    
                }
                if(accntIdToShipToAddressMap.get(OCEevt.AccountOnekeyId__c) != null && accntIdToBillToAddressMap.get(OCEevt.AccountOnekeyId__c) == null  ){
                    ShipToAddrs = accntIdToShipToAddressMap.get(OCEevt.AccountOnekeyId__c);
                    Address__c billToAddressCreate = new Address__c();
                    billToAddressCreate.Account__c = ShipToAddrs.Account__c;
                    billToAddressCreate.Address_Line_1__c = ShipToAddrs.Address_Line_1__c;
                    billToAddressCreate.Address_Line_2__c = ShipToAddrs.Address_Line_2__c;
                    billToAddressCreate.Address_Line_3__c = ShipToAddrs.Address_Line_3__c;
                    billToAddressCreate.Type__c = 'Bill To';
                    billToAddressCreate.City__c = ShipToAddrs.City__c;
                    billToAddressCreate.Postal_Code__c = ShipToAddrs.Postal_Code__c;
                    billToAddressCreate.State__c = ShipToAddrs.State__c;
                    insert billToAddressCreate;
                }
                
                if(accntIdToShipToAddressMap.get(OCEevt.AccountOnekeyId__c) == null && accntIdToBillToAddressMap.get(OCEevt.AccountOnekeyId__c) == null ){
                    Boolean  addressCreateFlag = validateAddressReqField(OCEevt);
                    if(addressCreateFlag)  ShipToAddrs = createBothToAddress(accountOneKey.Id,OCEevt,'Ship To');
                    if(addressCreateFlag)  BillToAddrs = createBothToAddress(accountOneKey.Id,OCEevt,'Bill To');
                }
                // Captur map & write Err               
                sampleOrderResultedMap = ClsSampleProgramHandler.createOrder(accountOneKey.Id,OCEevt.ProgramType__c, ShipToAddrs.Id);
                if(sampleOrderResultedMap.containsKey('Failed')){
                    ErrorUtility.LogErrorWithEvent('Consume', 'ClsSampleProgramHandler', String.valueOf(sampleOrderResultedMap.get('Failed')), 'Order', OCEevt.AccountOnekeyId__c, 'Failed to Create Order', OCEevt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(OCEevt));
            	}
                
            }else{
                Account accTofrmOCE = new Account();
                Boolean  accCreateFlag = validateAccountReqField(OCEevt);
                if(accCreateFlag){
                    accTofrmOCE.RecordTypeId = getAccountRecordType(OCEevt.AccCountryCode__c); // Based on Country - Need to find the Record Type // ask Vijay How the Country value will be receving ex. CA/Canada
                    accTofrmOCE.Country__c = OCEevt.AccCountryCode__c;
                    accTofrmOCE.PersonEmail = OCEevt.Email__c;
                    accTofrmOCE.LastName = OCEevt.LastName__c;
                    accTofrmOCE.Preferred_Language__c = OCEevt.Preferred_Language__c;
                    accTofrmOCE.Phone = OCEevt.WorkPhone__c;
                    accTofrmOCE.PersonMobilePhone =OCEevt.Mobile__c;
                    accTofrmOCE.PersonHomePhone =OCEevt.HomePhone__c;
                    accTofrmOCE.PersonOtherPhone =OCEevt.OtherPhone__c;
                    accTofrmOCE.IQVIA_OneKeyId__c =  OCEevt.AccountOnekeyId__c;
                    insert accTofrmOCE;
                    
                    // Address Insertion
                    Boolean  addressNewCreateFlag = validateAddressReqField(OCEevt);
                    if(addressNewCreateFlag)  ShipToAddrs = createBothToAddress(accTofrmOCE.Id,OCEevt,'Ship To');
                    if(addressNewCreateFlag)  BillToAddrs = createBothToAddress(accTofrmOCE.Id,OCEevt,'Bill To');
                                        
                   sampleOrderResultedMap =  ClsSampleProgramHandler.createOrder(accTofrmOCE.Id,OCEevt.ProgramType__c, ShipToAddrs.Id); 
                    if(sampleOrderResultedMap.containsKey('Failed')){
                        ErrorUtility.LogErrorWithEvent('Consume', 'ClsSampleProgramHandler', String.valueOf(sampleOrderResultedMap.get('Failed')), 'Order', OCEevt.AccountOnekeyId__c, 'Failed to Create Order', OCEevt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(OCEevt));
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    global static Address__c createBothToAddress(String accId,OCE_Account_Event__e OCEevt,String addrsType){
        Address__c SBAddrs = new Address__c();
        SBAddrs.Account__c = accId;
        SBAddrs.Address_Line_1__c = OCEevt.AddressLine1__c;
        SBAddrs.Address_Line_2__c = OCEevt.AddressLine2__c;
        SBAddrs.Address_Line_3__c = OCEevt.AddressLine3__c;
        SBAddrs.Type__c = addrsType;
        SBAddrs.City__c = OCEevt.City__c;
        SBAddrs.Postal_Code__c = OCEevt.PostalCode__c;
        SBAddrs.State__c = OCEevt.StateProvince__c;
        insert SBAddrs;
        return SBAddrs;
    }  
    global static boolean validateEventMandate(OCE_Account_Event__e oceEvnt){
        Boolean evtflag = true;
        if(oceEvnt.AccountOnekeyId__c == ''){
            evtflag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Account OneKey Id', 'Account', oceEvnt.AccountOnekeyId__c, 'Account Field  IQVIA_OneKeyId__c required for Account Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return evtflag;
        }else if(oceEvnt.AddressOneKeyId__c == '' ){
            evtflag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Address OneKey Id', 'Order', oceEvnt.AccountOnekeyId__c, 'Address Field IQVIA_OneKeyId__c is required for Order Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return evtflag;
        }else if(oceEvnt.ProgramType__c == ''){
            evtflag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Program Type', 'Account', oceEvnt.AccountOnekeyId__c, 'Program Type is required for Account & Address Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return evtflag; 
        }else if(oceEvnt.OCEOrderReference__c == ''){
            evtflag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing OrderReference', 'Order', oceEvnt.AccountOnekeyId__c, 'Order Field OrderReference is required for Order Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return evtflag; 
        }
        
        return evtflag;
    }
    global static boolean validateAddressReqField(OCE_Account_Event__e oceEvnt){
        Boolean addrsFlag = true;
        if(oceEvnt.AddressLine1__c == '' || oceEvnt.AddressLine2__c == '' || oceEvnt.AddressLine3__c == ''){
            addrsFlag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Address Lines', 'Account', oceEvnt.AccountOnekeyId__c, 'Address Line is required for Account & Address Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return addrsFlag;
        }else if(oceEvnt.Address_Phone_Number__c == ''){
            addrsFlag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Address Phone', 'Address__c', oceEvnt.AccountOnekeyId__c, 'Address Line is required for Account & Address Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return addrsFlag; 
        }else if(oceEvnt.CareOf_AddressFirstName__c == ''){
            addrsFlag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Address FirstName', 'Address__c', oceEvnt.AccountOnekeyId__c, 'Address CareoOf FirstName is required for Account & Address Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return addrsFlag; 
        }else if(oceEvnt.CareOf_AddressLastName__c == ''){
            addrsFlag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Address LastName', 'Address__c', oceEvnt.AccountOnekeyId__c, 'Address CareoOf LastName is required for Account & Address Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return addrsFlag; 
        }else if(oceEvnt.PostalCode__c == ''){
            addrsFlag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Address PostalCode', 'Address__c', oceEvnt.AccountOnekeyId__c, 'Address Postal Code is required for Account & Address Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return addrsFlag; 
        }else if(oceEvnt.City__c == ''){
            addrsFlag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Address City', 'Address__c', oceEvnt.AccountOnekeyId__c, 'Address City is required for Account & Address Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return addrsFlag; 
        }else if(oceEvnt.StateProvince__c == ''){
            addrsFlag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing StateProvince', 'Address__c', oceEvnt.AccountOnekeyId__c, 'Address StateProvince is required for Account & Address Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return addrsFlag; 
        }
        return addrsFlag;
    } 
    global static boolean validateAccountReqField(OCE_Account_Event__e oceEvnt){
        Boolean accflag = true;
        if(oceEvnt.AccCountryCode__c == ''){
            accflag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Account country code', 'Account', oceEvnt.AccountOnekeyId__c, 'Account Field country code required for Account Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return accflag;
        }else if(oceEvnt.Email__c == '' || oceEvnt.Email__c == null){
            accflag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Account Email', 'Account', oceEvnt.AccountOnekeyId__c, 'Account Field Email is required for Account Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return accflag;
        }else if(oceEvnt.LastName__c == ''){
            accflag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Account Last Name', 'Account', oceEvnt.AccountOnekeyId__c, 'Account Field LastName is required for Account Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return accflag;
        }else if(oceEvnt.Preferred_Language__c == ''){
            accflag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Account Preferred Language', 'Account', oceEvnt.AccountOnekeyId__c, 'Account Field Preferred Language is required for Account Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return accflag;
        }else if(oceEvnt.WorkPhone__c == '' || oceEvnt.Mobile__c == '' || oceEvnt.HomePhone__c == '' || oceEvnt.OtherPhone__c == ''){
            accflag = false;
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleBatchOCEEvent', 'Missing Account Phone', 'Account', oceEvnt.AccountOnekeyId__c, 'Account Field Preferred Language is required for Account Creation', oceEvnt.AccountOnekeyId__c, 'Fatal Error - Bailing out', String.valueOf(oceEvnt));
            return accflag;
        }
        return accflag;
    }
    
    //Ask Vijay About - Aalways need to check PersonAccount Record type?? or Account Record type we need to check
    global static String getAccountRecordType(String countryCode){
        String accRecTypeId = '';
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        List<RecordType> rtypes = [Select Name, Id From RecordType 
                                   where sObjectType='PersonAccount' and isActive=true ];
        for(RecordType rt: rtypes)
            mapRecordTypes.put(rt.Name,rt.Id);	
        
        for(String recName : mapRecordTypes.KeySet()){
            if(recName.startsWith('CA Consumer')){
                accRecTypeId = mapRecordTypes.get('CA Consumer');
            }else if(recName.startsWith('DE Consumer')){
                accRecTypeId = mapRecordTypes.get('DE Consumer');
            }else if(recName.startsWith('AT Consumer')){
                accRecTypeId = mapRecordTypes.get('AT Consumer');
            }else if(recName.startsWith('CH Consumer')){
                accRecTypeId = mapRecordTypes.get('CH Consumer');
            }else if(recName.startsWith('GB Consumer')){
                accRecTypeId = mapRecordTypes.get('GB Consumer');
            }else if(recName.startsWith('IE Consumer')){
                accRecTypeId = mapRecordTypes.get('IE Consumer');
            }else if(recName.startsWith('INTL Consumer')){
                accRecTypeId = mapRecordTypes.get('INTL Consumer');
            }else if(recName.startsWith('SI Consumer')){
                accRecTypeId = mapRecordTypes.get('SI Consumer');
            }
        }
        return accRecTypeId;
    }
    
     global class ObjectIterator implements Iterator<Sobject>, Iterable<Sobject>{
        global List<Sobject> lstObject; Integer i = 0;
        global ObjectIterator(List<Sobject> lstObject){  this.lstObject = lstObject; i = 0; }  
        global Boolean hasNext(){ return (i >= lstObject.size()) ? false : true; } 
        global Sobject next(){ if(i < lstObject.size()){ i++; return lstObject[i-1]; } return null;}  
        global Iterator<Sobject> iterator() { return this;  } 
    }
}