/*
Raghu R : 2/3/2014 : MDM Project : Trigger which copies order addresses to account addresses when status changed to approved

Business Process : Setting primary flag = true

Step 1: Most recent sold to address would be set as isprimary= true.
Step 2: if no sold to address then most recent end user address would be set as isprimary= true.
Step 3: if no sold to/end user address then most recent bill to address would be set as isprimary= true.
Step 4: if no sold to/end user/ bill to address then most recent ship to address would be set as isprimary= true.
Step 5: if np sold to/end user/ bill to / ship tp  address then most recent Corporate address would be set as isprimary= true.

*/
trigger AccountAddress_Trigger on Address__c (Before insert,Before Update) {

  if(!OrderTrigger_Utils_Class.isAcntAdrInsertFlag())
  {
  	 OrderTrigger_Utils_Class.setAcntAddrInsertFlag(true);
  	 if(Trigger.isInsert)
     {
     //  if(OrderTrigger_Utils_Class.ACCOUNT_ORDER_UPDATE)
     //  {
        AcntAdrs_Trigger_Class.onAfterInsert(Trigger.new);  
    //    OrderTrigger_Utils_Class.ACCOUNT_ORDER_UPDATE = false;
    //   }
     } 
     OrderTrigger_Utils_Class.setAcntAddrInsertFlag(false);    
   }  
}