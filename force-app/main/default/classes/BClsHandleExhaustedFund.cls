global class BClsHandleExhaustedFund implements database.Batchable<SObject>,Database.stateful {
    global List<Fund__c> lstupdateFund = new List<Fund__c>();
    global Database.QueryLocator start(Database.BatchableContext bc){
       
        String fundQuery = 'SELECT Id, payor__c,Succeeding_Fund__c,Auth_End_Date__c,Contingent_Fund__c from fund__c ' ;
        fundQuery += ' where Auth_End_Date__c = Yesterday AND Contingent_Fund__c != null';
        System.debug('fundQuery--'+fundQuery);
        return Database.getQueryLocator(fundQuery);
    }
    global void execute(Database.BatchableContext bc, List<fund__c> scope){       
        System.debug('**Scope--'+scope.size()+'**Record--'+scope[0].Id);
        Map<Id,Fund__c> mapOfFund = new Map<Id,Fund__c>();
        for(fund__c fund : scope){
            mapOfFund.put(fund.Id,fund);
        }
        
        for(Id fundId : mapOfFund.keySet()){
            Fund__c fd = new Fund__c();
            fd.Id = fundId;
            fd.Succeeding_Fund__c = mapOfFund.get(fundId).Contingent_Fund__c;
            lstupdateFund.add(fd);
        }            
        
    }
    global void finish(Database.BatchableContext bc){       
        try{update lstupdateFund;}catch(Exception ex){System.debug('ErrLine--'+ex.getLineNumber());System.debug('Err--'+ex);}
       System.debug('Batch Execution Finished--');
    }
}