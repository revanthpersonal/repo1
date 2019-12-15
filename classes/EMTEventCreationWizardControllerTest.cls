@isTest
private class EMTEventCreationWizardControllerTest {
    
    @isTest public static void fetchUserTest()
    {
        Test.startTest();
        User user = EMTEventCreationWizardController.fetchUser();
        system.assertEquals(UserInfo.getUserName(), user.Username);
        Test.stopTest();
    }
    @isTest static void testGetAddressSet() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());        
        String resp = EMTEventCreationWizardController.getAddressSet('example');       
        String expectedValue = '{"example":"test"}';
        System.assertEquals(expectedValue,resp);
        
    }
    
    @isTest static void testGetAddressDetailsByPlaceId(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());        
        String resp = EMTEventCreationWizardController.getAddressDetailsByPlaceId('example');        
        String expectedValue = '{"example":"test"}';
        System.assertEquals(expectedValue,resp);
    }
    
    @isTest static void testfetchApprovalInstanceRecord() {
        List<Events__c> eventList = EMT_TestDataFactory.createEventRecords(1);
        Test.startTest();
        EMTEventCreationWizardController.fetchApprovalInstanceRecord(eventList[0].id);
        EMTEventCreationWizardController.fetchApprovalInstanceRecord(null);
        Test.stopTest();
        
    }
    
    
    @isTest static void getClusterDataTest() {        
        
        List<Events__c> eventList = EMT_TestDataFactory.createEventRecords(1);
        Business_Group_Unit__c obj = new Business_Group_Unit__c(Cluster__c='Connected care', EmtBusiness__c='Monitoring & Analytics',
                                                                Business_Category__c ='General and Specialty Care', Function__c ='Business Transformation', 
                                                                Parent_Event__c =eventlist[0].Id);
        insert obj;
        Test.startTest();
        List<Business_Group_Unit__c> businessGroupList = EMTEventCreationWizardController.getClusterData(eventList[0].id);
        Test.stopTest();
    }
    
    
    
    @isTest static void testgetRecordTypeIds() {
        
        Test.startTest();
        EMTEventCreationWizardController.getRecordTypeIds();
        Test.stopTest();
    }
    
    @isTest static void testfetchUser() {
        
        Test.startTest();
        EMTEventCreationWizardController.fetchUser();
        Test.stopTest();
    }
    
    @isTest static void testgetRecordTypeNameById() {
        
        Id recTypeId = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Internal Event').getRecordTypeId();
        Test.startTest();
        EMTEventCreationWizardController.getRecordTypeNameById('Events__c', recTypeId);
        Test.stopTest();
    }
    
    @isTest static void testgetCampaignList() {
        List<Events__c> eventList = EMT_TestDataFactory.createEventRecords(1);
        Test.startTest();
        EMTEventCreationWizardController.getCampaignList(eventList[0].id);
        Test.stopTest();
        
    }
    
    @isTest static void testgetPicklistValues() {
        Test.startTest();
        EMTEventCreationWizardController.getPicklistValues('Events__c', 'Business__c');
        Test.stopTest();
        
    }    
    
    @isTest static void testgetDuplicateRecords() {
        List<Events__c> eventList = EMT_TestDataFactory.createEventRecords(2);
        Test.startTest();
        EMTEventCreationWizardController.getDuplicateRecords(eventList[0], true);
        EMTEventCreationWizardController.getDuplicateRecords(eventList[1], false);
        Test.stopTest();
        
    }
    
    @isTest static void testcheckDuplicate() {
        List<Events__c> eventList = EMT_TestDataFactory.createEventRecords(1);
        Events__c eventObj = EMT_TestDataFactory.createEvent('EVENT1', Date.today(), Date.today()+20, '');
        Events__c eventObj1 = EMT_TestDataFactory.createEvent('EVENT2', Date.today()+20, Date.today()-2, 'EV');
        Test.startTest();
        EMTEventCreationWizardController.checkDuplicate(eventList[0]);
        EMTEventCreationWizardController.checkDuplicate(eventObj);
        EMTEventCreationWizardController.checkDuplicate(eventObj1);
        Test.stopTest();
        
    }
    
    @isTest static void testPicklistEntryWrapper() {
        Test.startTest();
        //EMTEventCreationWizardController.PicklistEntryWrapper testWrapper = new EMTEventCreationWizardController.PicklistEntryWrapper('Test','Test');
        Test.stopTest();
        
    } 
    @isTest static void testSubmitCustomAction() {
        
        Events__c evtObj = EMT_TestDataFactory.createEventRecords(1)[0];
        Events__c evtObj2 = EMT_TestDataFactory.createEventRecords(1)[0];
        string evtId = evtObj.Id;
        evtObj.CT_Budget__c=20000.00;
        evtObj.CT_Market__c='Africa';
        evtObj.external_event_subtypes__c='Congress/Seminar';
        evtObj.Status__c='Draft';
        evtObj.Event_Collaborator_Email__c='test@test.com';
        evtObj.CT_Event_primary_contact_email__c='test@test.com';
        
        update evtObj;
        
        MAP<string,string> testMap = new MAP<string,string>();
        MAP<string,string> testMap2 = new MAP<string,string>();
        testMap.put('EventId', evtId );
        testMap.put('Status', 'Removed');
        testMap2.put('EventId', evtObj2.Id );
        testMap2.put('Status', 'Removed');
        Approval.ProcessSubmitRequest EventRequest = new Approval.ProcessSubmitRequest();
        EventRequest.setObjectId(evtObj.ID);
        Approval.ProcessResult EventRequestResult = Approval.Process(EventRequest);
        
        System.assert(EventRequestResult.isSuccess());
        
        Test.startTest();
        try{            
            EMTEventCreationWizardController.submitCustomAction(testMap);    
            EMTEventCreationWizardController.submitCustomAction(testMap2);
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage()); 
        }
        Test.stopTest();
        
    }
    @isTest static void testsaveEventWithEventClassification() {
        
        List<Events__c> event= new List<Events__c>();
        Events__c evtObj = EMT_TestDataFactory.createEventRecords(1)[0];
        string evtId = evtObj.Id;
        evtObj.CT_Budget__c=20000.00;
        update evtObj;
        event.add(evtObj);
        Test.startTest();
        try{            
            EMTEventCreationWizardController.saveEventWithEventClassification(evtObj.Id,'Strategic Event'); 
            
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage()); 
        }
        Test.stopTest();
        
    }
    
    @isTest static void testgetProcessWorkItemId() {
        
        
        Events__c evtObj = EMT_TestDataFactory.createEventRecords(1)[0];
        Events__c evtObj2 = EMT_TestDataFactory.createEventRecords(1)[0];
        string evtId = evtObj.Id;
        evtObj.CT_Budget__c=20000.00;
        evtObj.CT_Market__c='Africa';
        evtObj.external_event_subtypes__c='Congress/Seminar';
        evtObj.Status__c='Draft';
        evtObj.Event_Collaborator_Email__c='test@test.com';
        evtObj.CT_Event_primary_contact_email__c='test@test.com';
        
        update evtObj;
        Approval.ProcessSubmitRequest EventRequest = new Approval.ProcessSubmitRequest();
        EventRequest.setObjectId(evtObj.ID);
        Approval.ProcessResult EventRequestResult = Approval.Process(EventRequest);
        
        System.assert(EventRequestResult.isSuccess());
        
        Test.startTest();
        try{            
            EMTEventCreationWizardController.getProcessWorkItemId(evtObj.Id);         
            EMTEventCreationWizardController.getProcessWorkItemId(evtObj2.Id);   
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage()); 
        }
        Test.stopTest();
        
    }
    @isTest
    public static void getPrimaryContactTest(){
        Test.startTest();
        User user= EMT_TestDataFactory.createUserRecord();
        User userDetails = EMTEventCreationWizardController.getPrimaryContactDetails(user.Id);
        System.assertEquals(userDetails.Id,user.Id);    
        Test.stopTest();
    }
    
    @isTest
    public static void getIsUserGlobalTeamMemberTest(){
        
        Test.startTest();        
        boolean IsGlobalMember;
        IsGlobalMember= EMTEventCreationWizardController.isUserGlobalTeamMember();
        
        User genericUser = EMT_TestdataFactory.createEMTgenericUser();
        Group EMTGlobalTeamgrp = new Group();
        EMTGlobalTeamgrp.name = 'EMT Global Team';
        EMTGlobalTeamgrp.Type = 'Regular'; 
        insert EMTGlobalTeamgrp;
        
        GroupMember grpMem = new GroupMember();
        grpMem.UserOrGroupId = genericUser.Id;
        grpMem.GroupId = EMTGlobalTeamgrp.Id;
        insert grpMem;
        system.RunAs(genericUser){
            IsGlobalMember = EMTEventCreationWizardController.isUserGlobalTeamMember();
            system.assertEquals(true, IsGlobalMember);          
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getHomePageLinksTest(){
        Test.startTest();
        EMT_Home_Page_Links__c obj1 = new EMT_Home_Page_Links__c(Name=' Test Link 1', EMT_Document_URL__c='test1@test.com');
        EMT_Home_Page_Links__c obj2 = new EMT_Home_Page_Links__c(Name=' Test Link 2', EMT_Document_URL__c='test2@test.com');
        insert obj1;
        insert obj2;
        Map<string,string> mapHomePageLinks = EMTEventCreationWizardController.getHomePageLinks();
        Test.stopTest();
    }
    //need to modify
    @IsTest(SeeAllData=true) 
    public static void  getCustomMetaDataValuesTest(){
        Test.StartTest();
        List<EMT_CommonUtility.PicklistEntryWrapper> obj = EMTEventCreationWizardController.getCustomMetaDataValues('Internal Event','Event_type__c','');
        Test.StopTest();
        
    }
    
    @isTest
    public static void getUserAccessTest(){
        Test.startTest();
        EMTEventCreationWizardController.getUserAccess(EMT_TestDataFactory.eventRecords(1)[0].Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testUserAccess(){
        
        Test.startTest();
        User EMTApprover = EMT_TestDataFactory.createEMTApprover();
        User EMTGenericUser = EMT_TestDataFactory.createEMTgenericUser();
        Events__c eventObj;
        
        system.RunAs(EMTGenericUser){            
            eventObj = EMT_TestDataFactory.createEvent('Event Created by Generic user 1', Date.today(), Date.today()+20, 'Event');                             
        }
        
        system.RunAs(EMTApprover){
            try{
                EMTEventCreationWizardController.getUserAccess(eventObj.Id);   
            }
            catch(Exception e){
                system.assertEquals('Script-thrown exception', e.getMessage());  
            }    
        }
        Test.stopTest();
    }
    @isTest
    public static void testGenricUserAccessTest(){
        
        Test.startTest();
        User GenericUser1 = EMT_TestDataFactory.createEMTgenericUser();
        Events__c eventObj;
        Events__c eventObj2 = new Events__c();
        
        system.RunAs(GenericUser1){
            try{
                eventObj = EMT_TestDataFactory.createEvent('Event Created by Generic user 1', Date.today(), Date.today()+20, 'Event1');        
                EMTEventCreationWizardController.getUserAccess(eventObj.Id); 
                EMTEventCreationWizardController.getUserAccess(eventObj2.Id);
                
            }
            catch(Exception e){
                
            }
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testCrossGenricUserAccess(){
        
        Test.startTest();
        User GenericUser1 = EMT_TestDataFactory.createEMTgenericUser();
        User GenericUser2 = EMT_TestDataFactory.createEMTgenericUser();
        Events__c eventObj;
        
        system.RunAs(GenericUser1){
            eventObj = EMT_TestDataFactory.createEvent('Event Created by Generic user 1', Date.today(), Date.today()+20, 'Event1');        
        }
        
        system.RunAs(GenericUser2){
            try{
                EMTEventCreationWizardController.getUserAccess(eventObj.Id);  
            }
            catch(Exception e){
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        Test.stopTest();
    }   
    
    
    @isTest
    public static void getEventDetailsTest(){
        Test.startTest();
        EMTEventCreationWizardController.getEventDetails(EMT_TestDataFactory.eventRecords(1)[0].Id);
        EMTEventCreationWizardController.getEventDetails(null);
        Test.stopTest();
    }
    
    @isTest
    public static void submitEventForApprovalTest(){
        
        Events__c eventData = EMT_TestDataFactory.eventRecords(1)[0];
        Test.startTest();  
        EMTEventCreationWizardController.submitEventForApproval(eventData.Id);
        eventData.Is_Mandatory_Fields_Valid__c=false;
        update eventData;
        EMTEventCreationWizardController.submitEventForApproval(eventData.Id);
        EMTEventCreationWizardController.submitEventForApproval(null);
        Test.stopTest();
    }
    @isTest 
    static void saveRoadShowEventTest() {    
        
        Events__c roadShoweventObj = EMT_TestDataFactory.createRoadShowEvent('Country', 'Exhibition/tradeshow','Custom', 2, true, 900, true, 9, true, 2, true, 2);
        
        List<Business_Group_Unit__c> BusinessEventsList = EMT_TestDataFactory.createBusinessEventRecords(1);     
        
        EMT_Country_Region__c countryRegionObj= new EMT_Country_Region__c(Name = 'Barbados', Market__c = 'Latin America', Key_Region__c = 'Americas', Country_ISO_Code__c = 'BB' );
        
        Test.startTest();
        insert countryRegionObj;               
        try{
            EMTEventCreationWizardController.saveEventDetails(roadShoweventObj, BusinessEventsList);                        
        }
        catch (Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }        
        Test.stopTest();
    }   
    
    
    @isTest 
    static void saveInternalEventTest1() {
        
        Events__c internalEventObj = EMT_TestDataFactory.createInternalEvent('');            
        List<Business_Group_Unit__c> businessEventList = new List<Business_Group_Unit__c>();          
        Business_Group_Unit__c businessGroupObj = new Business_Group_Unit__c(Cluster__c='Image Guided Therapy',  Business_Category__c='General and Specialty Care',
                                                                             Function__c='Business Transformation', Business__c = 'Corporate', Business_Group__c = 'IPNS', 
                                                                             Business_Unit__c = 'IPNS', CurrencyIsoCode = 'EUR');
        businessEventList.add(businessGroupObj);
        EMT_Country_Region__c countryRegionObj= new EMT_Country_Region__c(Name = 'Barbados', Market__c = 'Latin America', Key_Region__c = 'Americas', Country_ISO_Code__c = 'BB' );
        
        Test.startTest();
        insert countryRegionObj;
        
        try{
            EMTEventCreationWizardController.saveEventDetails(internalEventObj, businessEventList);            
        }
        catch (Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }          
        
        Test.stopTest();
    }
    
    @isTest 
    static void saveInternalEventTest2() {
        
        Events__c internalEventObj = EMT_TestDataFactory.createInternalEvent('Test');            
        List<Business_Group_Unit__c> businessEventList = new List<Business_Group_Unit__c>();          
        Business_Group_Unit__c businessGroupObj = new Business_Group_Unit__c(Cluster__c='Image Guided Therapy',  Business_Category__c='General and Specialty Care',
                                                                             Function__c='Business Transformation', Business__c = 'Corporate', Business_Group__c = 'IPNS', 
                                                                             Business_Unit__c = 'IPNS', CurrencyIsoCode = 'EUR');
        businessEventList.add(businessGroupObj);
        EMT_Country_Region__c countryRegionObj= new EMT_Country_Region__c(Name = 'Barbados', Market__c = 'Latin America', Key_Region__c = 'Americas', Country_ISO_Code__c = 'BB' );
        
        Test.startTest();
        insert countryRegionObj;
        
        try{
            EMTEventCreationWizardController.saveEventDetails(internalEventObj, businessEventList);             
        }
        catch (Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }          
        
        Test.stopTest();
    }
    
    @isTest 
    static void IsRequiredFieldsFilledTest() {
        
        Test.startTest();
        
        Events__c roadShoweventObj1 = EMT_TestDataFactory.createRoadShowEvent('Function', 'Exhibition/tradeshow','Custom', 2, true, 9, true, null, false, null, false, null);  
        Events__c roadShoweventObj2 = EMT_TestDataFactory.createRoadShowEvent('Function', 'Exhibition/tradeshow','Custom', 2, true, 9, false, null, false, null, false, null);
        Events__c roadShoweventObj3 = EMT_TestDataFactory.createRoadShowEvent('Function','Exhibition/tradeshow','Custom', 2, true, 9, true, 3, true, null, false, null);
        Events__c roadShoweventObj4 = EMT_TestDataFactory.createRoadShowEvent('Function', 'Exhibition/tradeshow','Custom', 2, true, 9, true, 3, true, 3, false, null);
        Events__c roadShoweventObj5 = EMT_TestDataFactory.createRoadShowEvent('Function', 'Exhibition/tradeshow','', 2, true, 900, true, 9, true, 2, true, 2);    
        Events__c roadShoweventObj6 = EMT_TestDataFactory.createRoadShowEvent('Function', 'Exhibition/tradeshow','Custom', 2, true, 900, true, 9, true, 2, true, 2);    
        Events__c roadShoweventObj7 = EMT_TestDataFactory.createRoadShowEvent('Function', 'Exhibition/tradeshow','Custom', 2, true, null, true, 9, true, 2, true, 2);    
        Events__c roadShoweventObj8 = EMT_TestDataFactory.createRoadShowEvent('Function', 'Exhibition/tradeshow','Custom', 2, true, 89, true, 9, true, 2, true, null);     
        
        List<Business_Group_Unit__c> BusinessEventsList = EMT_TestDataFactory.createBusinessEventRecords(1);
        EMT_Country_Region__c countryRegionObj= new EMT_Country_Region__c(Name = 'Barbados', Market__c = 'Latin America', Key_Region__c = 'Americas', Country_ISO_Code__c = 'BB' );                
        insert countryRegionObj;               
        
        try{                 
            EMT_CommonUtility.isRequiredFieldsEntered(roadShoweventObj1, BusinessEventsList);
            EMT_CommonUtility.isRequiredFieldsEntered(roadShoweventObj2, BusinessEventsList);
            EMT_CommonUtility.isRequiredFieldsEntered(roadShoweventObj3, BusinessEventsList);
            EMT_CommonUtility.isRequiredFieldsEntered(roadShoweventObj4, BusinessEventsList);
            EMT_CommonUtility.isRequiredFieldsEntered(roadShoweventObj5, BusinessEventsList);
            EMT_CommonUtility.isRequiredFieldsEntered(roadShoweventObj6, BusinessEventsList);
            EMT_CommonUtility.isRequiredFieldsEntered(roadShoweventObj7, BusinessEventsList);
            EMT_CommonUtility.isRequiredFieldsEntered(roadShoweventObj8, BusinessEventsList);
        }
        catch (Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
        
        Test.stopTest();        
    }   
}