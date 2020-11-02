global class BClsSSIPRuleDeactivate implements Database.Batchable<Sobject>{
    private final Date sdt;
    private final Date edt;
    private final Date todaysDt;
    public BClsSSIPRuleDeactivate(){
        this.sdt = Date.today();
        this.edt = Date.today();
        this.todaysDt = Date.today();
    }
    public BClsSSIPRuleDeactivate(Date sdt, Date edt){
        this.sdt = sdt;
        this.edt = edt == null ? sdt : edt;
        this.todaysDt = Date.today();
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String soqlQuery = 'SELECT Id, Status__c,Account__r.Recordtype.Name,Account__r.RecordType.DeveloperName,RecordType.DeveloperName,';
        soqlQuery += ' Price_Book__r.Name,Product_Name__c,Renewal_date__c,Last_Renewed_Date__c, Rule_End_Date__c FROM SSIP_Rule__c ';
        soqlQuery += ' WHERE Status__c = \'Active\' AND ((Rule_End_Date__c >=:sdt AND Rule_End_Date__c <=: edt) or ( renewal_date__c >= :sdt AND Renewal_Date__c <= :edt))';
        //return Database.getQueryLocator('SELECT Id, Status__c,Account__r.Recordtype.Name,Account__r.RecordType.DeveloperName, Renewal_date__c,Last_Renewed_Date__c, Rule_End_Date__c FROM SSIP_Rule__c WHERE Status__c = \'Active\' AND ((Rule_End_Date__c >=:sdt AND Rule_End_Date__c <=: edt) or ( renewal_date__c >= :sdt AND Renewal_Date__c <= :edt))');
        return Database.getQueryLocator(soqlQuery);
    }
    global void execute(Database.BatchableContext BC, List<SSIP_Rule__c> scope){
        
        try{
            System.debug('**scope---'+scope.size());
            List<Marketing_Interaction__c> lstofMI = new List<Marketing_Interaction__c>();
            Date ruleEndNxtDay = Date.today().addDays(-1);
            List<SSIP_Rule__c> lstToUpdateSSIP = new List<SSIP_Rule__c>();
            for(SSIP_Rule__c ssipRule : scope){
                String accRecName = ssipRule.Account__r.Recordtype.Name;
                String PBName = ssipRule.Price_Book__r.Name;
                String PrdName = ssipRule.Product_Name__c;
                String ssipRecType = ssipRule.RecordType.DeveloperName;
                if((ssipRule.Rule_End_Date__c >= sdt && ssipRule.Rule_End_Date__c <= edt)){
                    ssipRule.Status__c = 'Inactive';
                    System.debug('**Making Inactive--');
                    lstToUpdateSSIP.add(ssipRule);
                }
                System.debug('**RenewalDate---'+ssipRule.Renewal_date__c);
                if(ssipRule.Renewal_date__c != null && ssipRule.Renewal_date__c == Date.today() && accRecName.equalsIgnoreCase('CA Consumer') && PBName.equalsIgnoreCase('CAN G6 SUBSCRIPTION 12MOS Auto Renewal') && PrdName.equalsIgnoreCase('MTRNTCAGS-12MOS')){
                    
                    Marketing_Interaction__c mi = new Marketing_Interaction__c();
                    mi.Account__c=ssipRule.Account__r.Id;
                    mi.Communication_Type__c=' CA - Subscription Renewal - Renewed';
                    mi.Source_Record_Id__c=ssipRule.id;
                    mi.Related_Information__c=ssipRule.Renewal_Date__c.format();
                    mi.Country__c='Canada';                
                    lstofMI.add(MI);                
                }
                
                if(ssipRule.Renewal_date__c >= sdt && ssipRule.Renewal_date__c <= edt){ 
                    System.debug('**Adding Renewal Date--');
                    ssipRule.Renewal_date__c = ssipRule.Renewal_date__c + 360; 
                    lstToUpdateSSIP.add(ssipRule);
                }
            }
            insert lstofMI;
            if(lstToUpdateSSIP.size()>0) update lstToUpdateSSIP;
            //update scope;
            // Add The Erros in  platfrom Error
        }catch(Exception ex){
            System.debug('**BClsSSIPRuleDeactivate--Err--'+ex);
            System.debug('**BClsSSIPRuleDeactivate--ErrLine--'+ex.getLineNumber());            
        }        
    }
    global void finish(Database.BatchableContext BC){
        
    }
}