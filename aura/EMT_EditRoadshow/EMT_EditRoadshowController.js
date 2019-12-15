({
    
    doInit : function(component, event, helper) {
		console.log("On rodshow edit");        
        helper.fetchUser(component);
        helper.fetchRoadshowData(component);
        helper.fetchEventExecutionPicklist(component,'Campaign_Focus_Area__c');
      //  helper.isEMTGlobalTeamMember(component,event);
          var actions = [
            { label: 'Delete', name: 'delete' }
        ], 
        fetchData = {
                Cluster__c : '',
                EmtBusiness__c: '',
                Business_Category__c : '',
                Function__c : ''
            };
        
        
       component.set('v.columns', [
            { label: 'Cluster', fieldName: 'Cluster__c', type: 'text' },
            { label: 'Business', fieldName: 'EmtBusiness__c', type: 'text' },
            { label: 'Business Category', fieldName: 'Business_Category__c', type: 'text' },
            { label: 'Function', fieldName: 'Function__c', type: 'text' },
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);
        
        helper.fetchCollaborator(component);
        helper.fetchClusterData(component);
        
    },
    
    handleCloseError:function(component) {
        component.set("v.isValid",false);
        component.set("v.invalidField",[]);
    },
    
    handleHandsOnTutorial : function(component)
    {
        component.set("v.eventObject.CT_Number_of_hands_on_tutorials__c",'');
        if(component.get("v.eventObject.CT_Hands_on_tutorial__c")==false)
        {
            component.set("v.disableHandsOnTutorial",false);
        }
        else
        {
            component.set("v.disableHandsOnTutorial",true);
            
        }

    },
    handleSymposia : function(component) {
        component.set("v.eventObject.CT_Number_of_symposia__c",'');
    	if(component.get("v.eventObject.CT_Symposia__c")==false)
        {
            component.set("v.disableSymposia",false);
        }
        else
        {
            component.set("v.disableSymposia",true);
            
        }
},
    
     handleShowButtons: function(component, event, helper) {
        component.set("v.disableButtons", true); 
    },
    
    //Call by aura:doneWaiting event 
    handleHideButtons : function(component,event,helper){
        component.set("v.disableButtons", false);
    },
    
    validateDate:function(component) {
        var startDate = component.get("v.eventObject.CT_Event_start_date__c");
        var endDate = component.get("v.eventObject.CT_Event_end_date__c");
        if(endDate < startDate)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title:'Warning',
                message:'You are trying to enter a past date as end date',
                duration:'2000',
                key:'info_alt',
                type:'warning',
                mode:'pester'
            });
            toastEvent.fire();
            
            var callDateMethod = component.get("c.handleDate");
            $A.enqueueAction(callDateMethod);
        }
    },
    
    handleDate:function(component)
    {
      //  v.eventObject.CT_Event_end_date__c
      	var eventDays = $A.get("$Label.c.event_days");
        var startDate = component.get("v.eventObject.CT_Event_start_date__c");
        var result = new Date(startDate);
        var endDate = new Date(result.setDate(result.getDate()+parseInt(eventDays)));
        component.set("v.eventObject.CT_Event_end_date__c",$A.localizationService.formatDate(endDate,"yyyy-MM-dd"));
  
    },
    
    handleEvent : function(component, event, helper) {
        if(event.getParam('uniqueLookupIdentifier') == component.get("v.recurringBtnIdentifier")){
            component.set("v.recurringBtnDisplayFlag",false);
        }
         if(event.getParam('uniqueLookupIdentifier') == "eventCollaborator")
        {
            if(event.getParam('populateEmail')==true){
                component.set("v.eventObject.Event_Collaborator_Email__c",event.getParam('selectedObject').Email);
            }
            else{
               component.set("v.eventObject.Event_Collaborator_Email__c",'');
            }
            
        }
    },
    handleRemoveEvent : function(component, event, helper) {
        if(event.getParam('uniqueLookupIdentifier') == component.get("v.recurringBtnIdentifier")){
            component.set("v.recurringBtnDisplayFlag",true);
        }
    },
    
    handleCloneEventClick : function(component, event, helper) {
        component.set("v.eventObject",component.get("v.value"));
        var objEvt = component.get("v.eventObject");
        delete objEvt.Id;
        component.set("v.eventObject.CT_Reaccuring_event__c",true);
        if($A.util.isEmpty(component.get("v.eventObject.Region__c"))){
            component.set("v.eventObject.Region__c",'Worldwide');
        }
        if(!$A.util.isEmpty(component.get("v.eventObject.CT_Expected_number_of_attendees__c"))){
        component.set("v.eventObject.CT_Number_of_attendees__c",component.get("v.value.CT_Expected_number_of_attendees__c"));
        }
        if(!$A.util.isEmpty(component.get("v.eventObject.CT_Expected_number_of_leads__c"))){
        component.set("v.eventObject.CT_Number_of_leads__c",component.get("v.value.CT_Expected_number_of_leads__c"));
        }
        var childComponent = component.find("childEventType");
        childComponent.getCallEventTypeMethod(component.get("v.eventObject.Event_type__c"),component.get("v.eventObject.CT_External_event_subtype__c"),component.get("v.eventObject.external_event_subtypes__c"));
    },
    handleCancelClick : function(component, event, helper) {
        helper.handleCancel(component,event);
    },
    handleChangeEventSearchBoxN:function(component, event, helper) {
        var recurringEventN = component.find('recurringEventN');
        if(recurringEventN.get("v.checked")){
            component.set("v.recurringEventYes",false);
            component.set("v.recurringEventNo",true);
        }
    },
    handleChangeEventSearchBox:function(component, event, helper) {
        var recurringEventY = component.find('recurringEventY');
        
        if(recurringEventY.get("v.checked")){
            component.set("v.eventObject.CT_Reaccuring_event__c",true);
            component.set("v.recurringEventYes",true);
            component.set("v.recurringEventNo",false);
        }
        var changeValue = event.getParam("value");
        if(changeValue=='Yes'){
            component.set("v.recurringEventValue",true);
        }
        if(changeValue=='No'){
            component.set("v.recurringEventValue",false);
        }
    },
    
	handlePrimaryContactEmail : function(component, event, helper) {
        //console.log("i am in "+ JSON.stringify(event.getParam('selectedObject').Email) );
       if(event.getParam('PrimaryContactEmailpopulate') == true)
        {
            component.set("v.eventObject.CT_Event_primary_contact_email__c",event.getParam('selectedObject').Email);
        }
        else
        {
            component.set("v.eventObject.CT_Event_primary_contact_email__c",'');
        }
    },
     handleShowModalforCluster: function(component, evt, helper) {
        var modalBody;
        $A.createComponent("c:EMT_BuisnessClusterPicklist", {"businessComponentEvent": component.getReference("c.handleBusinessDataEvent"),"listBusinessData":component.get("v.listBusinessData"),"arrayBusinessData":component.get("v.arrayBusinessData")}, 
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   component.set('v.body', content);
                                   modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       header: "Select Business Cluster & Business",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       cssClass: "mymodal",
                                       closeCallback: function() {
                                           console.log('popup closed')
                                       }
                                   })
                               }                               
                           });
    },

    
    saveRecord : function(component, event, helper) {
        
         if(component.get("v.leadValue")=='Yes') {
            component.set("v.eventObject.Capturing_leads_at_the_event__c",true);
        }  
        else {
            component.set("v.eventObject.Capturing_leads_at_the_event__c",false);
        }
        if(!$A.util.isEmpty(component.get("v.primaryContactLookupId")))
        {
            component.set("v.eventObject.Primary_Contact_Lookup__c",component.get("v.primaryContactLookupId"));
            component.set("v.eventObject.CT_Event_primary_contact__c",component.get("v.primaryContactValue.Name"));
           // component.set("v.eventObject.CT_Event_primary_contact_email__c",component.get("v.primaryContactValue.Email"));
            
        }
        else
        {
            component.set("v.eventObject.CT_Event_primary_contact__c",component.get("v.primaryContactText"));
        }
        
        var validBasicData="false";
        var validBudgetData="false";
        var buttonName = event.getSource().get("v.name");
        
        var showBasicData = component.get("v.showBasicData");
        var showEventTypeAndSize = component.get("v.showEventTypeAndSize");
        var showBudgetInfo = component.get("v.showBudgetInfo");
        var showEventFocus = component.get("v.showEventFocus");
        var showTarget = component.get("v.showTarget");
        var showJustification = component.get("v.showJustification");
        if(!$A.util.isEmpty(component.get("v.eventCollabratorLookupId"))){
        	component.set("v.eventObject.CT_Event_Collaborator__c",component.get("v.eventCollabratorLookupId"));
        }
        if(showBasicData == true){
                component.set("v.eventObject.CT_Step__c",'CT_Basic_event_info');
                 helper.fieldValidationController(component,buttonName);       
            if(component.get("v.allowSave")==true) {
                helper.checkDuplicate(component);
            }
        }
        if(showEventTypeAndSize == true){
            component.set("v.eventObject.CT_Step__c",'CT_Event_Size');
             helper.fieldValidationController(component,buttonName);       
            if(component.get("v.allowSave")==true) {
                helper.checkDuplicate(component);
            }
        }
       
        if(showBudgetInfo == true){
                component.set("v.eventObject.CT_Step__c",'CT_Budget');
                 helper.fieldValidationController(component,buttonName);    
              if(component.get("v.allowSave")==true) {
                helper.checkDuplicate(component);
            }
        }
      
        if(showEventFocus == true){
            component.set("v.eventObject.CT_Step__c",'CT_PR');
             helper.fieldValidationController(component,buttonName);       
            if(component.get("v.allowSave")==true) {
                helper.checkDuplicate(component);
            }
        }
        if(showTarget == true){
            component.set("v.eventObject.CT_Step__c",'CT_Leads');
              helper.fieldValidationController(component,buttonName);       
            if(component.get("v.allowSave")==true) {
                helper.checkDuplicate(component);
            }
        }
        if(showJustification == true && buttonName != 'StepSixSubmit'){
            component.set("v.eventObject.CT_Step__c",'Event justification');
             helper.fieldValidationController(component,buttonName);       
            if(component.get("v.allowSave")==true) {
                helper.checkDuplicate(component);
            }
        }
        if(showJustification == true && buttonName === 'StepSixSubmit'){
           
            helper.fieldValidationController(component,buttonName);       
            if(component.get("v.allowSave")==true) {
                component.set("v.eventObject.Status__c",'Draft');
                component.set("v.eventObject.Is_Submitted__c",'true');
                component.set("v.eventObject.CT_Step__c",'Submit for approval');
                component.set("v.isSubmit",true);
                helper.checkDuplicate(component);
            }
        }
        
        
    },
    nextTab : function(component, event, helper) {
        component.set("v.showGuidance",false);
        //for progress indicator
         var getselectedStep = component.get("v.selectedStep");
        if(getselectedStep == "CT_Basic_event_info"){
            component.set("v.selectedStep", "CT_Event_Size");
        }
        else if(getselectedStep == "CT_Event_Size"){
            component.set("v.selectedStep", "CT_Budget");
        }
            else if(getselectedStep == "CT_Budget"){
                component.set("v.selectedStep", "CT_PR");
            }
                else if(getselectedStep == "CT_PR"){
                    component.set("v.selectedStep", "CT_Leads");
                }
                    else if(getselectedStep == "CT_Leads"){
                        component.set("v.selectedStep", "Event justification");
                    }
        
        
        //progress indicator ends
        
        var showBasicData = component.get("v.showBasicData");
        var showEventTypeAndSize = component.get("v.showEventTypeAndSize");
        var showBudgetInfo = component.get("v.showBudgetInfo");
        var showEventFocus = component.get("v.showEventFocus");
        var showTarget = component.get("v.showTarget");
        var showJustification = component.get("v.showJustification");
        
        //var showSubmitInternalEventInfo = component.get("v.showSubmitInternalEventInfo");
        var eventRecordType = component.get("v.eventRecordType");
        
        //console.log('======='+JSON.stringify(component.get("v.eventObject")));
        if(showBasicData == true){
            component.set("v.showBasicData", false);
            component.set("v.showEventTypeAndSize", true); 
            component.set("v.showBudgetInfo", false);
            component.set("v.showEventFocus", false);
            component.set("v.showTarget", false);
            component.set("v.showJustification", false);
        }   
        
        if(component.get("v.eventRecordTypeCheckRoadShow") && (showEventTypeAndSize == true)){
            component.set("v.showBasicData", false);
            component.set("v.showEventTypeAndSize", false); 
            component.set("v.showBudgetInfo", true);
            component.set("v.showEventFocus", false);
            component.set("v.showTarget", false);
            component.set("v.showJustification", false);
        }
        
        
        if(showBudgetInfo == true){
             component.set("v.showBasicData", false);
            component.set("v.showEventTypeAndSize", false); 
            component.set("v.showBudgetInfo", false);
            component.set("v.showEventFocus", true);
            component.set("v.showTarget", false);
            component.set("v.showJustification", false);
        }   
        if(showEventFocus == true){
			component.set("v.showBasicData", false);
            component.set("v.showEventTypeAndSize", false); 
            component.set("v.showBudgetInfo", false);
            component.set("v.showEventFocus", false);
            component.set("v.showTarget", true);
            component.set("v.showJustification", false);
        }   
        if(showTarget == true){
        	component.set("v.showBasicData", false);
            component.set("v.showEventTypeAndSize", false); 
            component.set("v.showBudgetInfo", false);
            component.set("v.showEventFocus", false);
            component.set("v.showTarget", false);
            component.set("v.showJustification", true);
        }
    },
    prevTab : function(component, event, helper) {
        //for progress indicator
         var getselectedStep = component.get("v.selectedStep");
        if(getselectedStep == "CT_Event_Size"){
            component.set("v.selectedStep", "CT_Basic_event_info");
        }
        else if(getselectedStep == "CT_Budget"){
            component.set("v.selectedStep", "CT_Event_Size");
        }
            else if(getselectedStep == "CT_PR"){
                component.set("v.selectedStep", "CT_Budget");
            }
                else if(getselectedStep == "CT_Leads"){
                    component.set("v.selectedStep", "CT_PR");
                }
                    else if(getselectedStep == "Event justification"){
                        component.set("v.selectedStep", "CT_Leads");
                    }
        
        //progress indicator ends
        var showBasicData = component.get("v.showBasicData");
        var showEventTypeAndSize = component.get("v.showEventTypeAndSize");
        var showBudgetInfo = component.get("v.showBudgetInfo");
        var showEventFocus = component.get("v.showEventFocus");
        var showTarget = component.get("v.showTarget");
        var showJustification = component.get("v.showJustification");
        var eventRecordType = component.get("v.eventRecordType");
        
        if(showEventTypeAndSize == true){
            component.set("v.showBasicData", true);
            component.set("v.showEventTypeAndSize", false); 
            component.set("v.showBudgetInfo", false);
            component.set("v.showEventFocus", false);
            component.set("v.showTarget", false);
            component.set("v.showJustification", false);
        }  
        
        if(showBudgetInfo == true){
            component.set("v.showBasicData", false);
            component.set("v.showEventTypeAndSize", true); 
            component.set("v.showBudgetInfo", false);
            component.set("v.showEventFocus", false);
            component.set("v.showTarget", false);
            component.set("v.showJustification", false);
        }  
        if(showEventFocus == true){
           component.set("v.showBasicData", false);
            component.set("v.showEventTypeAndSize", false); 
            component.set("v.showBudgetInfo", true);
            component.set("v.showEventFocus", false);
            component.set("v.showTarget", false);
            component.set("v.showJustification", false);
        } 
        if(showTarget == true){
            component.set("v.showBasicData", false);
            component.set("v.showEventTypeAndSize", false); 
            component.set("v.showBudgetInfo", false);
            component.set("v.showEventFocus", true);
            component.set("v.showTarget", false);
            component.set("v.showJustification", false);
        }
        if(showJustification == true){
             component.set("v.showBasicData", false);
            component.set("v.showEventTypeAndSize", false); 
            component.set("v.showBudgetInfo", false);
            component.set("v.showEventFocus", false);
            component.set("v.showTarget", true);
            component.set("v.showJustification", false);
        }  
        
        
    },
    //Show the modal window on click in the input field
    OpenModal : function(component, event, helper) {
        component.set('v.AddressList', null);
        component.set("v.showModalBox", true);
    }, 
    //close the modal window on click of cancel button
    closeModal: function(component, event, helper) {
        component.set("v.showModalBox", false);
    }, 
    //Clear the address list on the user interface
    clear: function(component, event, helper) {
        helper.clearAddressList(component, event);
    }, 
    //Save address when user click on save button in the component
    saveAdress: function(component, event, helper){
      //  console.log("On click of save button!");
        helper.saveAddressDetails(component);
    },
    //Get city, state, country and other details from selected address
    selectOption:function(component, event, helper) {
        helper.getAddressDetailsByPlaceId(component, event);
    }, 
    //On search of address get address list from the API
    keyPressController: function(component, event, helper) {
        helper.getAddressRecommendations(component,event);
    }, 
    handleDualPicklistChange: function (component, event) {
        
        //Get the Selected values   
        var selectedValues = event.getParam("value");
        
        //Update the Selected Values  
        component.set("v.selectedCampaignOptionList", selectedValues);
        component.set("v.eventObject.Campaign_Focus_Area__c", selectedValues);
    },
    
     selectStep1 : function(component,event,helper){
         component.set("v.showGuidance",false);
        component.set("v.selectedStep", "CT_Basic_event_info");
        component.set("v.showBasicData", true);
        component.set("v.showEventTypeAndSize", false); 
        component.set("v.showBudgetInfo", false);
        component.set("v.showEventFocus", false);
        component.set("v.showTarget", false);
        component.set("v.showJustification", false);
    },
    selectStep2 : function(component,event,helper){
    component.set("v.showGuidance",false);
        component.set("v.selectedStep", "CT_Event_Size");
        component.set("v.showBasicData", false);
        component.set("v.showEventTypeAndSize", true); 
        component.set("v.showBudgetInfo", false);
        component.set("v.showEventFocus", false);
        component.set("v.showTarget", false);
        component.set("v.showJustification", false);
        
    },
    selectStep3 : function(component,event,helper){
        component.set("v.showGuidance",false);
        component.set("v.selectedStep", "CT_Budget");
        component.set("v.showBasicData", false);
        component.set("v.showEventTypeAndSize", false); 
        component.set("v.showBudgetInfo", true);
        component.set("v.showEventFocus", false);
        component.set("v.showTarget", false);
        component.set("v.showJustification", false);
    },

    selectStep4 : function(component,event,helper){
        component.set("v.showGuidance",false);
        component.set("v.selectedStep", "CT_PR");
        component.set("v.showBasicData", false);
        component.set("v.showEventTypeAndSize", false); 
        component.set("v.showBudgetInfo", false);
        component.set("v.showEventFocus", true);
        component.set("v.showTarget", false);
        component.set("v.showJustification", false);
    },
    selectStep5 : function(component,event,helper){
        component.set("v.showGuidance",false);
        component.set("v.selectedStep", "CT_Leads");
        component.set("v.showBasicData", false);
        component.set("v.showEventTypeAndSize", false); 
        component.set("v.showBudgetInfo", false);
        component.set("v.showEventFocus", false);
        component.set("v.showTarget", true);
        component.set("v.showJustification", false);
    },
    selectStep6 : function(component,event,helper){
        component.set("v.showGuidance",false);
        component.set("v.selectedStep", "Event justification");
        component.set("v.showBasicData", false);
        component.set("v.showEventTypeAndSize", false); 
        component.set("v.showBudgetInfo", false);
        component.set("v.showEventFocus", false);
        component.set("v.showTarget", false);
        component.set("v.showJustification", true);
    },
    handleShowModal: function(component, evt, helper) {
        
        var modalBody;
        $A.createComponent("c:EMT_DependentDualPicklist", {"businessComponentEvent": component.getReference("c.handleBusinessDataEvent"),"listBusinessData":component.get("v.listBusinessData"),"arrayBusinessData":component.get("v.arrayBusinessData")},
           function(content, status) {
               if (status === "SUCCESS") {
                   component.set('v.body', content);
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({
                       header: "Select Business Group & Unit",
                       body: modalBody, 
                       showCloseButton: true,
                       cssClass: "mymodal",
                       closeCallback: function() {
                         //  console.log('popup closed')
                          // alert('You closed the alert!');
                       }
                   })
               }                               
           });
    },
    handleBusinessDataEvent : function(component, event) {
        var listBusinessData =  event.getParam('listBusinessData');
         var arrayBusinessData =  event.getParam('arrayBusinessData');
        
      
            component.set("v.listBusinessData",event.getParam('listBusinessData'));
        component.set("v.arrayBusinessData",event.getParam('arrayBusinessData'));
        component.set("v.data",listBusinessData);
       // console.log('=======',JSON.stringify(listBusinessData));
        //console.log('=======',arrayBusinessData);
 
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        switch (action.name) {
            case 'delete':
                helper.removeBook(cmp, row)
                break;
        }
    },
    
        hideDuplicateModal:function(component) {
        component.set("v.showDuplicateModal",false);
        component.set("v.showDuplicateList",false);
        console.log("hide is called");
             component.set("v.isSubmit",false);
    },
    handleHref:function(component) {
        console.log("onclick worked");
        component.set("v.showDuplicateList",true);
        component.set("v.showDuplicateModal",false);
       
    },
    handleSaveModal:function(component,event,helper) {
        console.log("save anyway called");
    helper.saveEventDetails(component,event);
    
    component.set("v.showDuplicateModal",false);
        component.set("v.showDuplicateList",false);
        
},
     toggleSection : function(component, event, helper) {

         if(component.get("v.showGuidance")==true) {
            component.set("v.showGuidance",false);
        }
        else {
            component.set("v.showGuidance",true);
        }
        
    },
     handleNDAMeeting : function(component)
    {
        component.set("v.eventObject.CT_Number_of_NDA_Customer_meetings__c",'');    
        if(component.get("v.eventObject.CT_NDA_Customer_meetings__c")==false)
        {
            component.set("v.disableNDAMeeting",false);
        }
        else
        {
            
            component.set("v.disableNDAMeeting",true);
        }
        
    },
   handleLeadOption : function(component,event)
    {
        var changeValue = event.getParam("value");
       
        if(changeValue == 'true'){
            component.set("v.leadValue",changeValue);
        }
        if(changeValue == 'false'){
           component.set("v.eventObject.CT_Expected_number_of_leads__c",'');
           component.set("v.leadValue",changeValue);          
        }
    },
    
        handleSponserChange:function(component,event,helper) {
        var sponserSelected = event.getSource().get("v.value");
        console.log('Sponser Selected '+sponserSelected);
        if(sponserSelected='Market') {
            component.set("v.eventObject.Cluster__c",null);
            component.set("v.eventObject.CT_Function__c",null);
            component.set("v.eventObject.Market_Country__c",null);
            component.set("v.eventObject.CT_Market__c",null);
            
        }
        else if(sponserSelected='Function') {
            component.set("v.eventObject.Cluster__c",null);
            component.set("v.eventObject.CT_Function__c",null);
            component.set("v.eventObject.Market_Country__c",null);
            component.set("v.eventObject.CT_Market__c",null);
            
        }
        else if(sponserSelected='Country') {
            component.set("v.eventObject.Cluster__c",null);
            component.set("v.eventObject.CT_Function__c",null);
            component.set("v.eventObject.Market_Country__c",null);
            component.set("v.eventObject.CT_Market__c",null);   
        }
        else if(sponserSelected='Cluster') {
            component.set("v.eventObject.Cluster__c",null);
            component.set("v.eventObject.CT_Function__c",null);
            component.set("v.eventObject.Market_Country__c",null);
            component.set("v.eventObject.CT_Market__c",null);
                    
        }
        else {
            component.set("v.eventObject.Cluster__c",null);
            component.set("v.eventObject.CT_Function__c",null);
            component.set("v.eventObject.Market_Country__c",null);
            component.set("v.eventObject.CT_Market__c",null);
                        
        }
        
    },
    handleAlternatives:function(component,event,helper){
        var alternative = event.getSource().get("v.value");
        if(alternative!='Other') {
            component.set("v.eventObject.CT_Alternative_Explained__c",'');
        }
    },
    handleOwningMarket :function(component,event,helper) {
        var marketValue = event.getSource().get("v.value");
        if(marketValue === 'Global') {
            component.set("v.eventObject.Event_Reach__c",'Global');
            
        }
        else {
            component.set("v.eventObject.Event_Reach__c",'');
        }
    }
    
})