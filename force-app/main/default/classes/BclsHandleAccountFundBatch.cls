//NS-1394->batch will run when succeeding fund added to any fund
global class BclsHandleAccountFundBatch implements Database.Batchable<sObject>{
    public Map<id,id> mapFund;
    global BclsHandleAccountFundBatch(Map<id,id> mapOfFunToSuccFund){
        this.mapFund=mapOfFunToSuccFund;
    }
    
    global List<Account_Fund__c> start(Database.BatchableContext bc){   
        System.debug('--Satrt--');
        List<Account_Fund__c> newAccountFundInsert=new List<Account_Fund__c>();
        if(mapFund.keyset().size()>0){
            Map<id,Set<Id>> mapFundToActs=new Map<id,Set<Id>>();          
            for(Account_Fund__c actFund:[select id,Account__c,Fund__c from Account_Fund__c where Fund__c IN : mapFund.keyset()]){
                if(!mapFundToActs.containskey(actFund.Fund__c)){
                    mapFundToActs.put(actFund.Fund__c,new set<id>{actFund.Account__c});
                }else{
                    mapFundToActs.get(actFund.Fund__c).add(actFund.Account__c);
                }
            }
            for(Id fundId: mapFund.keyset()){
                if(mapFundToActs.containskey(fundId)){
                    Id succedingFund=mapFund.get(fundId);
                    for(Id actIds:mapFundToActs.get(fundId)){
                        //new AccountFund creation
                        Account_Fund__c actFundNew= new Account_Fund__c();
                        actFundNew.Account__c=actIds;
                        actFundNew.Fund__c=succedingFund;
                        newAccountFundInsert.add(actFundNew);                             
                    }
                }
            }            
        }  
        System.debug('newAccountFundInsert--'+newAccountFundInsert.size());
        return newAccountFundInsert;
    }
    
    global void execute(Database.BatchableContext bc, List<Account_Fund__c> scope){
        Database.SaveResult[] srList=database.insert(scope,false);
        for(Integer i = 0; i < srList.size(); i++){            
            if(srList[i].isSuccess()){  
                System.debug('Id--'+srList[i]);
            }
            else {
                String error = '';
                for(Database.Error err : srList[i].getErrors()) {
                    error += error == '' ? 'Fund ' + err.getMessage() : ', ' + err.getMessage();
                }
                ErrorUtility.LogError('Batch', 'BclsHandleAccountFundBatch', error, 'BclsHandleAccountFundBatch', 'crm', '', 'Account ID: ' + scope[i].Account__C+' Fund ID: ' + scope[i].Fund__C,'Fatal Error - Bailing out');
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        system.debug('Batch excecution ends ');       
    }
    
}