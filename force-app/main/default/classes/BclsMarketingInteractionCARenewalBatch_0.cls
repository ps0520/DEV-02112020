global class BclsMarketingInteractionCARenewalBatch_0 implements database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext bc){
        Date CANoRuleRenwlNxt60Date = date.today().adddays(60);
        Date CANoRuleRenwlNxt85Date = date.today().adddays(85);
        Date CANoRuleRenwlNxt95Date = date.today().adddays(95);
        
        String SSIPQuery = 'SELECT Id, Account__c, Account__r.Id, Renewal_Date__c, ' ;
        SSIPQuery += ' Product__c, Product__r.Name, Account__r.RecordType.DeveloperName,Price_Book__r.Name ';
        SSIPQuery += ' from SSIP_Rule__c' ;
        SSIPQuery += ' WHERE Status__c=\'Active\' AND (Account__r.RecordType.DeveloperName =\'CA_Consumer\')';
        SSIPQuery += ' AND (Product__r.Name =\'MTRNTCAGS-12MOS\') AND (Renewal_Date__c>=:CANoRuleRenwlNxt85Date AND Renewal_Date__c<=:CANoRuleRenwlNxt95Date)';
        SSIPQuery += ' AND (Price_Book__r.Name =\'CAN G6 SUBSCRIPTION 12MOS Auto Renewal\')';
        
        System.debug('--SSIPQuery--'+SSIPQuery);
        return Database.getQueryLocator(SSIPQuery);
    }
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        System.debug('--scope--'+scope.size());
        List<SSIP_Rule__c> lstGBIESSIPRule = new List<SSIP_Rule__c>();
        List<SSIP_Rule__c> lstCASSIPRule = new List<SSIP_Rule__c>();
        for(SSIP_Rule__c ssipRule : (List<SSIP_Rule__c>)scope){			
            lstCASSIPRule.add(ssipRule);
        }
        
        if(lstCASSIPRule.size()>0) executeCAFunction(lstCASSIPRule);
    }
    public static void executeCAFunction(List<SSIP_Rule__c> lstCASSIPRule){
        System.debug('--executeCAFunction Of Renewal Batch---');
        Map<String,String> mapOfSSIPAcc = new Map<String,String>();
        Map<Id,marketing_interaction__c> MapOfMI = new Map<Id,marketing_interaction__c>();
        List<marketing_interaction__c> lstMI = new List<marketing_interaction__c>();
        List<marketing_interaction__c> lstMItoInsert = new List<marketing_interaction__c>();
        Set<Id> setOfAccIds = new Set<Id>();
        Set<String> setOfCommType = new Set<String>();
        setOfCommType.add('CA - Subscription Renewal - Auto');
        for(SSIP_Rule__c CASSIP : lstCASSIPRule){
            setOfAccIds.add(CASSIP.Account__c);
            mapOfSSIPAcc.put(CASSIP.Id,CASSIP.Account__c);
        }
        
        lstMI = [SELECT id, Account__c, CreatedDate FROM marketing_interaction__c WHERE account__c in :setOfAccIds AND 
                 Communication_Type__c IN:setOfCommType AND Country__c= 'Canada' AND CreatedDate > LAST_N_MONTHS:6];
        if(lstMI.size()>0){
            for(SSIP_Rule__c ssipRule : lstCASSIPRule){	
                Marketing_interaction__c miRec = new Marketing_interaction__c();
                miRec.Account__c = mapOfSSIPAcc.get(ssipRule.Id);
                if(SSIPRule.Price_Book__r.name == 'CAN G6 SUBSCRIPTION 12MOS Auto Renewal'){
                    miRec.Communication_Type__c = 'CA - Subscription Renewal - Auto';
                }
                miRec.Country__c = 'Canada';
                miRec.CurrencyIsoCode = 'CAD';
                miRec.Source_Record_Id__c = ssipRule.Id;
                miRec.Related_Information__c = String.valueOf(ssipRule.Renewal_Date__c);
                lstMItoInsert.add(miRec);
            }			
        }
        System.debug('--lstMItoInsert--'+lstMItoInsert);
        if(lstMItoInsert.size()>0) insert lstMItoInsert;
        
    }
    global void finish(Database.BatchableContext bc){
        System.debug('BclsMarketingInteractionRenewalBatch Execution Finished!!!');				
    }
}