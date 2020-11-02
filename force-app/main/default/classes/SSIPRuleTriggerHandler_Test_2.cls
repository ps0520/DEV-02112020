@isTest
public class SSIPRuleTriggerHandler_Test_2 {
    
    @isTest static void TestOrderCreationAndUpdateCA(){
        
        //Insert 1 consumer account record
        List<Account> consumerAccts = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CA Consumer', 'Canada');
        System.debug('**consumerAccts--'+consumerAccts);
        //Create Pricebook
        Map<String, Id> customPricebookMap = ClsTestDataFactory.createCustomPricebook(new List <String>{'CA Cash'});
        String customPricebookId = customPricebookMap.get('CA Cash');
        
        //Create Products
        Map<String, Id> products = ClsTestDataFactory.createProducts(new List<String> {'MTLYCHARGE', 'STT-GF-004', 'DEX-SHIP-01','FREIGHT CHARGE'});
        
        //Update the virtual sku productIdToPbeId
        Product2 virtualProd = [SELECT Id, Is_Virtual_Product__c FROM Product2 WHERE NAME = 'MTLYCHARGE'];
        virtualProd.Is_Virtual_Product__c = true;
        update virtualProd;
        
        //Create Pricebook EntryPair
        Map<Id, Decimal> productIdToPriceMap = new Map<Id, Decimal>();
        for(String productName : products.keySet()){
            productIdToPriceMap.put(products.get(productName), 125.00);
            
        }
        Map<Id, Id> productIdToPbeId = ClsTestDataFactory.createCustomPricebookEntriesCA(productIdToPriceMap, customPricebookId);
        Id caOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CA_Sales_Order').getRecordTypeId();
        Id caSSIPRecdTypeId = Schema.SObjectType.SSIP_Rule__c.getRecordTypeInfosByDeveloperName().get('CA_SSIP_Rule').getRecordTypeId();
        List<Address__c> lstAddress = new List<Address__c>{
            new Address__c(Account__c = consumerAccts[0].Id,Type__c = 'Bill To', Country__c = 'Canada', City__c = 'Victoria', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = 'V5Z 2M9', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                new Address__c(Account__c = consumerAccts[0].Id,Type__c = 'Ship To',Country__c = 'Canada', City__c = 'Victoria', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = 'V5Z 2M9', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
                // new Address__c(Account__c = payorAccount.Id,Type__c = 'Bill To', Country__c = 'Canada', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                //new Address__c(Account__c = payorAccount.Id,Type__c = 'Ship To',Country__c = 'Canada', City__c = 'Rosemont', Address_Line_1__c = ' W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
                };
                    insert lstAddress;
        
        List<PricebookEntry> lstPBE = [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'CA Cash'];
        System.debug('**lstPBE--'+lstPBE.size());
        //Create Order record
        ClsOrderTriggerStaticClass.isExecuting = false;
        Order newOrder = new Order();
        newOrder.AccountId = consumerAccts[0].Id;
        newOrder.RecordtypeId = caOrderRecdTypeId;
        newOrder.Type = 'CA STANDARD';
        newOrder.EffectiveDate = System.today();
        newOrder.Price_Book__c = customPricebookId;
        newOrder.Pricebook2Id = customPricebookId; 
        newOrder.Status = 'Draft';
        newOrder.CurrencyISOCode = 'CAD';
        insert newOrder;
        System.debug('**newOrder--'+newOrder);
        //newOrder.Pricebook2Id = customPricebookId; 
      
        
        
        //List order line items
        List<OrderItem> orderItemList = new List<OrderItem>();
        for(Id pbeId : productIdToPbeId.values()){
            OrderItem oi = new OrderItem();
            oi.OrderId = newOrder.Id;
            oi.PricebookEntryId = pbeId;
            oi.Quantity = 1;
            oi.UnitPrice = 125.00;
            oi.Tracking_Number__c = '12345';
            oi.Product_Name__c = 'MTLYCHARGE' ;
            orderItemList.add(oi);
        }
        Test.startTest();
        insert orderItemList;
        newOrder.Status = 'Activated';
        update newOrder;
        
        List<SSIP_Rule__c> lstSSIPRule = new List<SSIP_Rule__c>();
        
        Date firstDayOfMonth = System.today().toStartOfMonth();
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
        Integer counter = 0;
        for(PricebookEntry pbe : lstPBE){
            
            lstSSIPRule.add(new SSIP_Rule__c(Account__c = consumerAccts[0].Id, First_Order__c = newOrder.Id, Schedule_Count__c = 3, Frequency_In_Days__c = 30,
                                             First_Repeat_Order_Lead_Days__c = 7, Price_Book__c = pbe.Pricebook2Id, PriceBookEntryId__c = pbe.Id,
                                             First_Shipment_Date__c =lastDayOfMonth,Rule_Re_schedule_Date__c =Date.today()+1 ,RecordTypeId=caSSIPRecdTypeId,
                                             Country__c = 'Canada',
                                             Product__c = pbe.Product2Id, Quantity__c = 1, Shipping_Address__c = null, Status__c = 'Active'));
            
        }
        
        insert lstSSIPRule;
        System.debug('**lstSSIPRule--'+lstSSIPRule.size());
        for(SSIP_Rule__c ssipRule : lstSSIPRule){
            ssipRule.First_Shipment_Date__c = Date.today();
            ssipRule.Rule_Re_schedule_Date__c =lastDayOfMonth-2;
            ssipRule.Rule_End_Date__c = Date.today()+400;
        }
        update lstSSIPRule;
        
        
        
        List<SSIP_Schedule__c> lstSSIPSchedule = [SELECT Id,Account__c FROM SSIP_Schedule__c where Account__c=:consumerAccts[0].Id];
        for(SSIP_Schedule__c ssipSchedule : lstSSIPSchedule){
            ssipSchedule.Rescheduled_Shipment_Date__c = Date.today()+3;
            ssipSchedule.Status__c = 'Open';
            //ssipSchedule.SSIP_Rule__c = lstSSIPRule[0].Id; 
        }
        System.debug('====lstSSIPSchedule===='+lstSSIPSchedule.size());
        update lstSSIPSchedule;
        
        newOrder.Status = 'Shipped';
        update newOrder;
        
        DataBase.executeBatch(new BClsSSIPSchedule());
        test.stopTest();
    }
    
}