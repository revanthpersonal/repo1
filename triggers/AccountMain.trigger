/*
Modified By:         Swastika Rajkhowa(Rsystems)
Modified Date:       04/04/2016
Function   :         Added a function UpdateCustomAddress to update Address, Country and state custom field by Billing Address 

Modification History:
22-MAR-2018 - Mukunthan Koothan - called UserUpdateUtil.updateGenieFieldsOnAccountUpd method to update Genie fields on Portal Users
*/
trigger AccountMain on Account (after insert, after update, before update) {
    if(Util.Bypass_Trigger_Chk)return;   
    if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){
        if(TriggerFlowManager.ACCOUNT_INITIALIZE_SML){
          SMLHelperWTS.initializeSML(trigger.newMap.keyset(), trigger.oldMap, trigger.isInsert);
            TriggerFlowManager.ACCOUNT_INITIALIZE_SML = false;
        }
        if(trigger.isUpdate){
            OpportunityFieldPopulationHelper.shareQuoteAccess(trigger.new, trigger.oldMap);
            AccountHelper.onAfterUpdate(trigger.new, trigger.oldMap); 
            
            //Mukunthan K on 22-MAR-2018 - added below lines to update genie fields on Portal Users of Account
            //string partnerAccountRT = Object_Record_Type__c.getInstance('EMGBusinessPartnerRecordType').Record_Type_Label_Name__c;
            List<Id> accountIDS = new List<Id>();
            List<Id> geniedisableIds = new List<Id>();
            for(Account accNew:Trigger.New){
                for(Account accOld:Trigger.Old){
                    if(accNew.Id == accOld.Id && accNew.RecordType__c == 'Enterprise - Business Partner' && accNew.Status__c != 'Merged'){
                        
                        if(accNew.PM_Control__c == false && (accNew.Partner_Tier__c != accOld.Partner_Tier__c || accNew.PartnerType__c != accOld.PartnerType__c || accNew.Region__c != accOld.Region__c)){
                            System.Debug('accNewId--->'+accNew.Id);
                            accountIDS.add(accNew.Id);
                        }
                        if(accNew.PM_Control__c != accOld.PM_Control__c && accNew.PM_Control__c == true){
                             geniedisableIds.add(accNew.Id);
                        }
                    }
                }
            }
            if(accountIDS.size()>0){
                UserUpdateUtil.updateGenieFieldsOnAccountUpd(accountIDS);
            }
            if(geniedisableIds.size()>0){
                UserUpdateUtil.enableDisableGenieAccess(geniedisableIds);
            }
        }
        
    }
    if(trigger.isBefore && trigger.isUpdate){
        Accounthelper.onBeforeUpdate(trigger.new, trigger.oldMap);
    }
    //Naresh Kumar, 04/29/2016. Commenting out below part of the trigger. Need to deploy it to production.
    /*
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate))
        AccountHelper.UpdateCustomAddress(trigger.new);
    */
    if(trigger.isAfter && trigger.isUpdate && trigger.new[0].Type == 'Customer' && TriggerFlowManager.CHECK_SC_AND_CLOUD_DEPLOYMENT){
        TriggerFlowManager.CHECK_SC_AND_CLOUD_DEPLOYMENT = false;
        //Account objA = [Select id,name,IsCustomerPortal,Account_ID__c,Status__c,Date_of_Offboard__c,IsOffboarding__c,IsErrorOffboarding__c from Account where id =: trigger.new[0].id];
        Account objA = new Account(id=trigger.new[0].id);
        CheckServiceContractAndCloudDeploy.ServiceContractAndCd(objA);        
    }
    
    // Amit Singh, 06/27/2018.
    // Calling helper method to update the Offering type on related contact
    if(trigger.isAfter && trigger.isUpdate){
        CheckServiceContractAndCloudDeploy.updateContactOfferingType(trigger.new, trigger.oldMap);
    }
    
    // Added by Priyank
    // Calling helper method to Send a notification to Sub Regional Lead of the DSR if the associated Account "owner" is updated. 
    if(trigger.isAfter && trigger.isUpdate){
        DSRUtility.fetchOppIdFromAccount(trigger.new, trigger.oldMap);
    }
}