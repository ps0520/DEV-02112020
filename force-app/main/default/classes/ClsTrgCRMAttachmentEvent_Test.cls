@isTest
public class ClsTrgCRMAttachmentEvent_Test{
	
    @isTest
    public static void onafterUpdateTest(){ 
                
        string before = 'Testing base 64 encode';            
        Blob beforeblob = Blob.valueOf(before);
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger1';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;
        
        
        CRM_Attachment_Event__e crmAttachObj = new CRM_Attachment_Event__e();
        
        crmAttachObj.name__c = cv.Title;
        crmAttachObj.eventSource__c = 'OMS';
        crmAttachObj.referenceNumberValue__c = '1234555';
        crmAttachObj.eventSourceID__c = 'UK20000614';
        Test.startTest();
        	//ClsOrderHandlerStatic.executeOrderEventTriggerv11 = true;
        	EventBus.publish(crmAttachObj);
        Test.stopTest();
        
       /*  
          
           Test.setMock(HttpCalloutMock.class, new ClsMockHttpResponseGenCCAuthorize());
		 System.enqueueJob(new SSIPScheduleJobUtiltiy.AuthorizeAndSettlePaymentQueueable(objOrder.Id,'CH',
                                                                          (Integer) objOrder.Count_of_Order_Line_Items__c,
                                                                          (Integer) objOrder.Account.Subscription_Pending_Payments__c,
                                                                          objOrder.AccountId, true));
         
         test.stopTest();  
        */
       
    }
}