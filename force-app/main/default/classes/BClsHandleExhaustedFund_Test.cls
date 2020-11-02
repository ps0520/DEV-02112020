@isTest
public class BClsHandleExhaustedFund_Test {

   @isTest static void TestFundTriggerHandler(){
       List<Account> lstGBAcc = ClsTestDataFactory.createAccountsWithBillingAddress(2, 'GB Consumer', 'United Kingdom');
      Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'GB Payor', 'United Kingdom')[0];
        Recordtype recType=[select id from recordtype where developername='Purchase_Order'];
        Fund__c Fd = new Fund__c();
        Fd.PO_Reference_Number__c ='87666787';
        Fd.Limit_Type__c ='Quantity';        
        Fd.Payor__c = payorAccount.Id;
        Fd.Amount_Limit__c = 100000;
        Fd.Auth_End_Date__c = Date.today().addDays(100);
        Fd.Auth_Start_Date__c = Date.today();
        Fd.Receiver_Qty_Limit__c = 100; 
        Fd.Sensor_Limit__c = 100; 
        Fd.Transmitter_Qty_Limit__c = 100 ;     
        fd.recordtypeid=recType.id;
        insert Fd ;
        
       Fund__c Fd1 = new Fund__c();
       Fd1.PO_Reference_Number__c ='87666711';
       Fd1.Limit_Type__c ='Quantity';        
       Fd1.Payor__c = payorAccount.Id;
       Fd1.Amount_Limit__c = 100000;
       Fd1.Auth_End_Date__c = Date.today().addDays(-1);
       Fd1.Auth_Start_Date__c = Date.today().addDays(-20);
       Fd1.Receiver_Qty_Limit__c = 100; 
       Fd1.Sensor_Limit__c = 100; 
       Fd1.Transmitter_Qty_Limit__c = 100 ;
       fd1.Contingent_Fund__c = fd.Id;
       fd1.recordtypeid=recType.id;        
       insert Fd1 ;
       
        lstGBAcc[0].fund__C=fd.id;
        Account_Fund__c af= new Account_Fund__c(Account__c=lstGBAcc[0].Id, Fund__c=fd.Id, Primary_Flag__c=false);        
        insert af;
        Account_Fund__c af1= new Account_Fund__c(Account__c=lstGBAcc[1].Id, Fund__c=fd.Id, Primary_Flag__c=false);        
        insert af1;
        
       Test.startTest();
       	Database.executeBatch(new BClsHandleExhaustedFund(),1);
       Test.stopTest();
       
    }
}