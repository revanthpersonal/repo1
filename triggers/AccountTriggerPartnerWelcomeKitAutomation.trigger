trigger AccountTriggerPartnerWelcomeKitAutomation on Account (after update) {
    if(Util.Bypass_Trigger_Chk || Bypass_Triggers__c.getInstance(UserInfo.getUserId()).All__c)
      return;
    EmailTemplate internalTemplate;
    EmailTemplate externalTemplate;
    integer count = 0;
    for(Account a : Trigger.NEW){
        if (PartnerWelcomeKitUtil.firstRun && a.Type == 'Partner' && (Trigger.oldMap.get(a.Id).Type == 'Prospective Partner' || Trigger.oldMap.get(a.Id).Type == 'Prospect')){
            if(count ==0) {
             internalTemplate = [Select id FROM EmailTemplate where name= 'Partner Welcome-Kit Internal Email' Limit 1];
              externalTemplate = [Select id FROM EmailTemplate where name= 'Partner Welcome-Kit External Email' Limit 1];
             }
            count = count + 1;
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            Contact dummyContact = new Contact(FirstName = 'Portal', LastName='User', AccountId = a.Id, Email = 'PartnerWelcomeNotification@genesys.com');
            insert dummyContact;
            
            Set<String> CCEmailsSet = new Set<String>();
            // Add Channel Manager and Regional Channel Manager to CC List if they are not part of the PartnerWelcomeNotificationEMailMembers
            Set<String> PartnerWelcomeNotificationEMailMembers = PartnerWelcomeNotificationEMailMembers__c.getAll().KeySet() != NULL ? PartnerWelcomeNotificationEMailMembers__c.getAll().KeySet() : new Set<String>();
            if(a.Channel_Manager__c != NULL){
                User channelManager = [SELECT id, Email, Manager.Email from User WHERE Id = : a.Channel_Manager__c LIMIT 1];
                if(channelManager.EMail != NULL && !PartnerWelcomeNotificationEMailMembers.contains(channelManager.EMail)){
                    CCEmailsSet.add(channelManager.EMail);
                }
                if(channelManager.Manager.Email != NULL && !PartnerWelcomeNotificationEMailMembers.contains(channelManager.Manager.Email)){
                    CCEmailsSet.add(channelManager.Manager.Email);
                }
            }            
            // Add Regional Channel Lead  to CC List if they are not part of the PartnerWelcomeNotificationEMailMembers
            if(a.Country__c != NULL){
                List<Country__c> countries = [SELECT Region__c FROM Country__c WHERE Id = :a.Country__c];
                if(!countries.isEmpty() && Partner_Rebate_Regional_Channel_Lead__c.getInstance(countries[0].Region__c) != NULL ){
                    List<User> regionalChannelLeads = [SELECT id, Email from User WHERE Id = : Partner_Rebate_Regional_Channel_Lead__c.getInstance(countries[0].Region__c).User_Name__c];
                    if(!regionalChannelLeads.isEmpty() && regionalChannelLeads[0].Email != NULL && !PartnerWelcomeNotificationEMailMembers.contains(regionalChannelLeads[0].Email)){
                        CCEmailsSet.add(regionalChannelLeads[0].Email);
                    }
                }                
            }
            
            for(String s : Partner_WelcomeKit_Internal_Email_Distro__c.getAll().KeySet()){
                if(!PartnerWelcomeNotificationEMailMembers.contains(s)){
                    CCEmailsSet.add(s);
                }
            }

            String[] CCEmails = new List<String>();
            for(String s: CCEmailsSet){
               CCEmails.add(s); 
            }
            // Build mail object for internal Email 
            Messaging.SingleEmailMessage internalMail = new Messaging.SingleEmailMessage(); 
            internalMail.setTemplateId(internalTemplate.id);
            internalMail.setSaveAsActivity(false);
            if(CCEmails.size() > 0)
                internalMail.setCCAddresses(CCEmails);
            internalMail.setreplyto('partners@genesys.com');
            internalMail.setSenderDisplayName('partners@genesys.com');
            internalMail.setWhatId(a.Id);//Object Id
            internalMail.setTargetObjectId(dummyContact.Id); //contactid Lead or Userid
            emailList.add(internalMail);
            
            // Build mail object for external Email 
            List<Contact> contacts = [SELECT id, Name, accountId FROM Contact WHERE accountId =:a.Id and FirstName != 'Portal'];
            for(Contact eachContact : contacts){
                Messaging.SingleEmailMessage externalMail = new Messaging.SingleEmailMessage(); 
                externalMail.setTemplateId(externalTemplate.id);
                externalMail.setSaveAsActivity(false);
                externalMail.setreplyto('partners@genesys.com');
                externalMail.setSenderDisplayName('partners@genesys.com');
                externalMail.setWhatId(a.Id);//Object Id
                externalMail.setTargetObjectId(eachContact.Id);//contactid Lead or Userid
                emailList.add(externalMail);                
            }
            
            if(emailList.size() > 0 && !Test.isRunningTest()){
                Messaging.sendEmail(emailList);
            }
            delete dummyContact;
            PartnerWelcomeKitUtil.firstRun=false;
        } 
    }
}