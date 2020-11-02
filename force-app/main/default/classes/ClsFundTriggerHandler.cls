public class ClsFundTriggerHandler {
    public void onBeforeInsert(List<Fund__c> lstFund){
        Set<Id> setAccountId = new Set<Id>();
        for(Fund__c fund : lstFund) setAccountId.add(fund.Payor__c);
        Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT Id, RecordType.DeveloperName FROM Account WHERE Id IN: setAccountId]);
        for(Fund__c fund : lstFund){
            String recordTypeDName = mapAccount.get(fund.Payor__c).RecordType.DeveloperName;
            String currencyCode = recordTypeDName.startsWithIgnoreCase('CA_') ? 'CAD' : recordTypeDName.startsWithIgnoreCase('CH_') ? 'CHF' : 
                                  recordTypeDName.startsWithIgnoreCase('GB_') ? 'GBP' : recordTypeDName.startsWithIgnoreCase('IE_') ? 'EUR' : 'EUR';
            if(String.isNotBlank(currencyCode) && String.isNotEmpty(currencyCode)) fund.CurrencyIsoCode = currencyCode;
        }
    }
    
    public void onAfterUpdate(List<Fund__C> newList,Map<id,Fund__C> oldMap){
    
     //1391 update fund on account and create AccountFund when Succesding fund populated
        Recordtype recType=[select id from recordtype where developername='Purchase_Order' limit 1];
        Map<id,id> mapOfFunToSuccFund=new Map<id,id>();
        for(Fund__C fund:newList){
             if(fund.Succeeding_Fund__c !=null && fund.recordtypeid==recType.id && fund.Succeeding_Fund__c != oldMap.get(fund.id).Succeeding_Fund__c){
                mapOfFunToSuccFund.put(fund.id,fund.Succeeding_Fund__c);
             }
        }
        
       if(mapOfFunToSuccFund.keyset().size()>0){
       
           database.executeBatch(new BclsHandleAccountFundBatch(mapOfFunToSuccFund),10);
        
       
     
       }
       //1391 --END--
      
    }
}