/*----------------------------------------------------------------------- 
File name:      EMTEventCreationWizardController
Author:         Rajan Patil
Company:        Philips
Description:    This class is for Create Event Wizard,
Get Event details, Save Event, 
Test Class:     
Created Date :  26/07/2019
History
<Date>      <Authors Name>     <Brief Description of Change>
26.07.2019  Rajan Patil      
-----------------------------------------------------------------------*/
public with sharing class EMTEventCreationWizardController {
    public static Map<Id, String> recordtypemap {get;set;}
    public class EventException extends Exception {}
    
    @AuraEnabled 
    public static user fetchUser(){
        // query current user information  
        //return EMT_CommonUtility.getUserDetails();
        User oUser = [select id,Name,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled,CurrencyIsoCode
                      FROM User Where id =: userInfo.getUserId()];
        return oUser;
    }
    
    @AuraEnabled
    public static List<Id> getRecordTypeIds() {
        List<Id> recordTypeIds = new List<Id>();
        Id internalEventId = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Internal Event').getRecordTypeId();
        Id externalEventId = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('External Event').getRecordTypeId();
        Id roadshowId = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Roadshow').getRecordTypeId();
        recordTypeIds.add(internalEventId);
        recordTypeIds.add(externalEventId);
        recordTypeIds.add(roadshowId);
        return recordTypeIds;
    }
    
    @AuraEnabled 
    public static Sobject fetchApprovalInstanceRecord(String recId){
        // query current user information  
        List<sObject> lstEvents = new List<sObject>();
        lstEvents = [SELECT Id,Name,CT_Event_Acronym__c,Status__c,Event_Classification_for_Approvals__c,Event_Reach__c from Events__c Where Id=:recId];
        if(lstEvents.size() > 0){
            return lstEvents[0];      
        }
        return null;
    }
    
    @AuraEnabled 
    public static void submitCustomAction(Map<String,String> eventParam){
        try {
            
            if(!String.isEmpty(eventParam.get('EventId')) && !String.isEmpty(eventParam.get('Status'))){
                if(eventParam.get('Status')=='Removed'){     
                    ProcessInstance instance = [SELECT Id
                                                FROM   ProcessInstance
                                                WHERE TargetObjectId=: eventParam.get('EventId') AND Status='Pending' limit 1];
                    
                    // Now that we have our Approval Request instance, lets get the child WorkItem
                    ProcessInstanceWorkitem workItem = [SELECT Id FROM ProcessInstanceWorkitem
                                                        where ProcessInstanceId=:instance.Id limit 1]; 
                    Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
                    
                    
                    req.setWorkItemId(workItem.Id);
                    req.setAction(eventParam.get('Status')); // This means to remove/recall Approval Request
                    req.setComments(eventParam.get('Comment'));
                    Approval.ProcessResult result = Approval.process(req);
                    
                    Events__c evtObj = [SELECT Id,Name,Status__c,Approver__c,CT_Event_Location__c,CT_Location_Country__c,CT_Event_start_date__c,CT_Event_end_date__c,Rejection_Reason__c,Event_Collaborator_Email__c,CT_Owner_email__c,CT_Event_primary_contact_email__c
                                        FROM   Events__c
                                        WHERE Id=: eventParam.get('EventId') limit 1];
                    
                    evtObj.Status__c = 'Draft';
                    evtObj.Is_Submitted__c=false;
                    evtObj.Approver__c = UserInfo.getUserId();
                    evtObj.Rejection_Reason__c = 'Request for edit';
                    update evtObj;
                    //Code added by Souvik for sending email from apex-Start
                    
                    Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
                    List<OrgWideEmailAddress> owea =  [select Id, Address from OrgWideEmailAddress where Address like 'emt%'];
                    System.debug('owea size '+owea.size());
                    if ( owea.size() > 0 ) {
                        message.setOrgWideEmailAddressId(owea[0].Id);
                    } 
                    message.setTargetObjectId(UserInfo.getUserId()); 
                    message.setSaveAsActivity(false);  
                    message.setUseSignature(false); 
                    message.setBccSender(false);
                    EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body,Name from EmailTemplate where name = 'Event brief returned for changes'];
                    if(emailTemplate.Name=='Event brief returned for changes'){
                        
                        string body = emailTemplate.Body;
                        body=body.replace('{!Events__c.Name}', evtObj.Name);
                        body=body.replace('{!Events__c.CT_Event_Location__c}', evtObj.CT_Event_Location__c);
                        body=body.replace('{!Events__c.CT_Location_Country__c}', evtObj.CT_Location_Country__c);    
                        body=body.replace('{!Events__c.CT_Event_start_date__c}', String.valueOf(evtObj.CT_Event_start_date__c));
                        body=body.replace('{!Events__c.CT_Event_end_date__c}', String.valueOf(evtObj.CT_Event_end_date__c));
                        message.setSubject(emailTemplate.subject);        
                        message.setPlainTextBody(body);
                    }
                    else{
                        message.setTemplateID(emailTemplate.Id); 
                    }
                    String[] emailList=new String[]{evtObj.CT_Owner_email__c};
                        if(!(evtObj.Event_Collaborator_Email__c == null) && !(evtObj.Event_Collaborator_Email__c == '')){
                            emailList.add(evtObj.Event_Collaborator_Email__c);
                            
                        }
                    if(!(evtObj.CT_Event_primary_contact_email__c == null) && !(evtObj.CT_Event_primary_contact_email__c == '')){
                        emailList.add(evtObj.CT_Event_primary_contact_email__c);
                        
                    }
                    
                    message.toAddresses=emailList;
                    //message.toAddresses = new String[] { evtObj.CT_Owner_email__c};
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    
                    if (results[0].success) 
                    {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' +  results[0].errors[0].message);
                    }
                    //Code added by Souvik for sending email from apex-End
                    
                }
            }
            
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException('Darn it! Something went wrong: '
                                           + e.getMessage());    
        }          
    }
    
    // Method for geting business data list.
    /*  public static List<Business_Group_Unit__c> fetchBusinessData(String recordId){
// query current user information  
List<Business_Group_Unit__c> oBdata = [select Business__c,Business_Group__c,Business_Unit__c FROM Business_Group_Unit__c Where Parent_Event__c =: recordId];
return oBdata;
} */
    
    @AuraEnabled
    public static List<Business_Group_Unit__c> getClusterData(String recordId){
        
        List<Business_Group_Unit__c> businessList = [select Cluster__c,EmtBusiness__c,Business_Category__c,Function__c from Business_Group_Unit__c where Parent_Event__c =:recordId];
        return businessList;
    }
    
    
    @AuraEnabled
    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId)
    {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    }
    
    @AuraEnabled
    public static sObject getCampaignList(String recordId) {
        return EMT_BaseEditApexController.getDetails(recordId);
    }
    
    
    //Method to call google API and fetch the address recommendations 
    @AuraEnabled
    public static String getAddressSet(String SearchText){
        return EMT_CommonUtility.getAddressSet(SearchText);
    }
    
    //Method to call google API and fetch the address details by addressID 
    @AuraEnabled
    public static String getAddressDetailsByPlaceId(String PlaceID){
        return EMT_CommonUtility.getAddressDetailsByPlaceId(PlaceID);
    }
    
    //Method to call to save event details & return event object
    @AuraEnabled
    public static Events__c saveEventDetails(Events__c eventDetails,List<Business_Group_Unit__c> lstBGU){
        try {
            // EMT_CommonUtility.isRequiredFieldsEntered(eventDetails,lstBGU);
            boolean flag = EMT_CommonUtility.getUserAccess(eventDetails.Id);
            if(flag==true){ 
                MAP<string,string> countryCodeMap = new MAP<string,string>();
                for(EMT_Country_Region__c cCode : EMT_Country_Region__c.getall().values())
                {
                    countryCodeMap.put(cCode.Name,cCode.Country_ISO_Code__c);
                }
                
                if(String.isBlank(eventDetails.EMT_Event_Location_Country_Code__c)) {
                    eventDetails.EMT_Event_Location_Country_Code__c = countryCodeMap.get(eventDetails.CT_Location_Country__c);
                }
                MAP<string,string>countryRegionMap = new MAP<string,string>();
                MAP<string,string>countryMarketMap = new MAP<string,string>();
                system.debug('Custom ->'+EMT_Country_Region__c.getall().values());
                for(EMT_Country_Region__c countryRCode :EMT_Country_Region__c.getall().values()) {
                    if(!String.isBlank(countryRCode.Name) && !String.isBlank(countryRCode.Key_Region__c)){
                        countryRegionMap.put(countryRCode.Name,countryRCode.Key_Region__c);    
                    }
                    if(!String.isBlank(countryRCode.Name) && !String.isBlank(countryRCode.Market__c)){
                        countryMarketMap.put(countryRCode.Name,countryRCode.Market__c);    
                    }
                }
                // Event country should not be blank, Assign Region based on Custom setting mapping
                if(String.isBlank(eventDetails.CT_Location_Country__c)){
                    throw new EventException('Please select event location and event country.');
                }else if(countryRegionMap.containsKey(eventDetails.CT_Location_Country__c)){
                    eventDetails.Region__c = countryRegionMap.get(eventDetails.CT_Location_Country__c);
                }else{
                    eventDetails.Region__c = 'Worldwide';
                }
                
                // Business group is not selected then take business group is as default value from the Busines Group object list
                
                if( lstBGU.size() > 0){
                    if(!String.isBlank(lstBGU[0].EmtBusiness__c))
                    {
                        eventDetails.Business_Group__c = lstBGU[0].EmtBusiness__c;
                    }
                    else
                    {
                        eventDetails.Business_Group__c = lstBGU[0].Function__c;
                    }
                }
                
                if(!String.isBlank(eventDetails.CT_Main_Sponsor__c)){
                    
                    
                    if((eventDetails.CT_Main_Sponsor__c == 'Country') && (!String.isBlank(eventDetails.Market_Country__c))){
                        eventDetails.CT_Market__c = countryMarketMap.get(eventDetails.Market_Country__c);
                        if(String.isEmpty(eventDetails.CT_Market__c)){
                            throw new EventException('Error - Main Sponsor Country is not mapped with Market. Please select another country.');
                        }
                        //system.debug('Market===>'+ eventDetails.CT_Market__c);
                        //system.debug('Market Country==>'+eventDetails.Market_Country__c);
                    }
                }
                EMT_CommonUtility.isRequiredFieldsEntered(eventDetails, lstBGU);
                System.debug('recordtype id '+eventDetails.RecordTypeId);
                List<Events__c> lstEvents = new List<Events__c>();
                lstEvents.add(eventDetails);
                system.debug('---lstEvents'+ lstEvents);
                insert lstEvents;
                
                if(lstEvents.size() > 0){
                    if(lstBGU.size() > 0){
                        List<Business_Group_Unit__c> lstUnitToInsert = new List<Business_Group_Unit__c>();
                        for(Business_Group_Unit__c bGU : lstBGU){
                            bGU.id= null;
                            bGU.Parent_Event__c = lstEvents[0].Id;
                            lstUnitToInsert.add(bGU);
                        }
                        if(lstUnitToInsert.size() > 0){
                            
                            insert lstUnitToInsert;
                        }
                    }
                }
                
            }   
            
        } 
        catch (Exception e) {
            //  "Convert" the exception into an AuraHandledException
            System.debug('error is '+e.getMessage());
            throw new AuraHandledException(e.getMessage());  
            
        } 
        return eventDetails;    
    }
    
    @AuraEnabled
    public static List<String> getPicklistValues( String objectName, String fieldName ) {
        return EMT_CommonUtility.getPicklistValues(objectName,fieldName);
    }
    
    @AuraEnabled
    public static List<EMT_CommonUtility.PicklistEntryWrapper> getCustomMetaDataValues(String recType, String fieldAPIName, String lang){
        return EMT_CommonUtility.getCustomMetaDataValues(recType, fieldAPIName, lang);
    }
    
    @AuraEnabled
    public static List<Events__c> getDuplicateRecords(Events__c eventDetails, Boolean isEdit) {
        
        List<Events__c> eventList;
        
        if(isEdit==true) {
            eventList = [select Id, RecordType.Name, Name,CT_Event_Location__c,CT_Event_Acronym__c from Events__c where ((CT_Event_Location__c =:eventDetails.CT_Event_Location__c AND CT_Event_start_date__c <=: eventDetails.CT_Event_end_date__c AND CT_Event_end_date__c >=: eventDetails.CT_Event_start_date__c) OR (Name =: eventDetails.Name OR CT_Event_Acronym__c =: eventDetails.CT_Event_Acronym__c)) AND Id !=: eventDetails.Id ];
        }
        else {
            eventList = [select Id, RecordType.Name, Name,CT_Event_Location__c,CT_Event_Acronym__c from Events__c where (CT_Event_Location__c =:eventDetails.CT_Event_Location__c AND CT_Event_start_date__c <=: eventDetails.CT_Event_end_date__c AND CT_Event_end_date__c >=: eventDetails.CT_Event_start_date__c) OR (Name =: eventDetails.Name OR CT_Event_Acronym__c =: eventDetails.CT_Event_Acronym__c)];
        }
        return eventList;
    }
    
    @AuraEnabled
    public static boolean checkDuplicate(Events__c eventDetails) {
        List<Events__c> eventList;
        if(eventDetails.CT_Event_Acronym__c!='') {
            eventList = [select Id, RecordType.Name, Name,CT_Event_Location__c,CT_Event_Acronym__c from Events__c where (CT_Event_Location__c =:eventDetails.CT_Event_Location__c AND CT_Event_start_date__c <=: eventDetails.CT_Event_end_date__c AND CT_Event_end_date__c >=: eventDetails.CT_Event_start_date__c) OR (Name =: eventDetails.Name OR CT_Event_Acronym__c =: eventDetails.CT_Event_Acronym__c)];
            if(eventList.size()>0) {
                return true;
            }
            else{
                return false;
            }
        }
        else {
            return false;
        }
    }
    
    @AuraEnabled // Check if the user is available in the public group or not
    public static boolean isUserGlobalTeamMember(){
        return EMT_CommonUtility.isUserGlobalTeamMember();
    }
    
    @AuraEnabled
    public static User getPrimaryContactDetails(Id lookupId) {
        User usr = [select Name,id , Email from User where id =:lookupId];
        return usr; 
    }
    @AuraEnabled 
    public static Map<string,string> getHomePageLinks(){
        return EMT_CommonUtility.getHomePageLinks();
    }
    
    @AuraEnabled
    public static boolean getUserAccess(Id eventId){
        
        return (EMT_CommonUtility.getUserAccess(eventId));
    }
    
    @AuraEnabled
    public static Events__c getEventDetails(Id eventId){
        
        if(eventId != null){
            
            Events__c event = [SELECT Name, Id, Status__c FROM Events__c where Id=:eventId];        
            return event;
        }else
            return null;
    }
    
    @AuraEnabled
    public static string submitEventForApproval(Id eventId){
        try{
            if(eventId != null){
                Events__c eventObj = [SELECT Name, Id,Is_Mandatory_Fields_Valid__c, Is_Submitted__c FROM Events__c where Id=:eventId Limit 1];
                system.debug('mad ->'+eventObj.Is_Mandatory_Fields_Valid__c);
                if(eventObj.Is_Mandatory_Fields_Valid__c == true) {
                    system.debug('event ->'+eventObj);
                    eventObj.Is_Submitted__c=true;
                    update eventObj;
                    system.debug('NEW event ->'+eventObj.Is_Submitted__c);
                    return 'submitted';
                }else if(eventObj.Is_Mandatory_Fields_Valid__c == false) {
                    
                    system.debug('Is_Mandatory_Fields_Valid__c' + eventObj.Is_Mandatory_Fields_Valid__c);
                    return 'submitCriteriaFailed';
                    // throw new AuraHandledException('You can only submit an event for approval. Please fill the required Event brief information.');
                }
            }
            return 'fail';
        }
        catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());    
        }       
        
        
    }
    @AuraEnabled
    public static String getUIThemeDescription() {
        String theme = UserInfo.getUiThemeDisplayed();
        return theme;
    }
    
    @AuraEnabled
    public static String saveEventWithEventClassification(Id recId,String picklistValue) {
        List<Events__c> eventClassificationRecord=[select id,name,Event_Classification_for_Approvals__c,Status__c from Events__c where Id=:recId LIMIT 1];
        String status=null;
        try{
            if(eventClassificationRecord.size() > 0){
                
                Events__c event=eventClassificationRecord[0];
                event.Event_Classification_for_Approvals__c=picklistValue;
                update event;
                status= event.Status__c;
            }
            return status;   
        }
        catch (Exception e) {
            throw new AuraHandledException('Something went wrong Here2: '+ e.getMessage());    
        }
        
        
    }
    
    @AuraEnabled
    public static String getProcessWorkItemId(id recId) {
        try{
            List<ProcessInstance> instance = [SELECT Id
                                              FROM   ProcessInstance
                                              WHERE TargetObjectId=:recId AND Status='Pending' limit 1];
            
            if(instance.size()>0){
                ProcessInstanceWorkitem workItem = [SELECT Id FROM ProcessInstanceWorkitem
                                                    where ProcessInstanceId=:instance[0].Id limit 1]; 
                
                return(workItem.Id); 
            }
            
            
            else{
                return null;
            }
            
        }
        
        catch (Exception e) {
            throw new AuraHandledException('Something went wrong Here: '+ e.getMessage());    
        } 
    }
    
}