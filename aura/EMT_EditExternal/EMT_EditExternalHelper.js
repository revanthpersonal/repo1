({
    handleCancel:function(component,event){
        //component.set("v.eventObject",component.get("v.value"));
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "scope": "Events__c"
        });
        navEvent.fire();  
    },
     isEMTGlobalTeamMember:function(component,event){
        var action = component.get("c.isUserGlobalTeamMember");
        action.setCallback(this, function(response) {
           // console.log('-----'+response.getReturnValue());
            component.set("v.isEventReachOptionFilterRequired", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    fetchExistingData:function(component){
        var action = component.get("c.getDetails");
        action.setParams({recordId:component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnData = response.getReturnValue();
            if(state=="SUCCESS" && returnData!=null) {
               
                component.set("v.eventObject",returnData);
                console.log("booth info "+returnData.external_event_subtypes__c)
                if(returnData.external_event_subtypes__c!='Exhibition/tradeshow'){
                    component.set("v.showBoothInfo",false)
                    console.log("booth info 2"+returnData.external_event_subtypes__c)
                }
                if(returnData.Capturing_leads_at_the_event__c==true) {
                    component.set("v.leadValue",'true');
                }
                else {
                    component.set("v.leadValue",'false');
                }
                 if(!$A.util.isEmpty(returnData.Primary_Contact_Lookup__c)) {
                   	this.getPrimaryContactLookup(component);
                   }
                else {
                   // component.set("v.eventObject.CT_Event_primary_contact__c",returnData.CT_Event_primary_contact__c);
                    component.set("v.eventObject.CT_Event_primary_contact_email__c",returnData.CT_Event_primary_contact_email__c);
                    //console.log("Email "+component.get("v.eventObject.CT_Event_primary_contact_email__c"));
                    component.set("v.primaryContactText",returnData.CT_Event_primary_contact__c);
                    
                }
                    
                
                
                component.set("v.eventObject.CT_Function__c",returnData.CT_Function__c);
               // console.log("function is "+returnData.CT_Function__c);
                if(returnData.CT_Reaccuring_event__c==true)
                {
                    component.set("v.recurringEventYes",true);
                    component.set("v.recurringEventNo",false);
                }
                else
                {
                    component.set("v.recurringEventYes",false);
                    component.set("v.recurringEventNo",true);
                }
                
                component.set("v.eventObject.CT_NDA_Customer_meetings__c",returnData.CT_NDA_Customer_meetings__c);
                if(returnData.CT_NDA_Customer_meetings__c == false)
                {
                    component.set("v.disableNDAMeeting",false);
                }
                else
                {
                    component.set("v.disableNDAMeeting",true);
                }
                
                if(returnData.CT_Hands_on_tutorial__c == false)
                {
                    component.set("v.disableHandsOnTutorial",false);
                }
                else
                {
                    component.set("v.disableHandsOnTutorial",true);
                }
                
                if(returnData.CT_Symposia__c==false)
                {
                    component.set("v.disableSymposia",false);
                }
                else
                {
                    component.set("v.disableSymposia",true);
                }
                var step = component.get("v.eventObject.CT_Step__c");
                //console.log("Step in helper is "+step)
                component.set("v.selectedStep",step);
                this.handleStep(component,step);
                
                
                var evtObj = component.get("v.eventObject.Campaign_Focus_Area__c");
                var campaignArray = new Array();
                if(evtObj!=undefined){
                    
                
                campaignArray = evtObj.split(';');
                //console.log("array  "+arry);
                component.set("v.selectedCampaignOptionList",campaignArray); 
                }
                
                if(!$A.util.isEmpty(component.get("v.eventObject.Event_type__c")) && !$A.util.isEmpty(component.get("v.eventObject.CT_External_event_subtype__c")) && !$A.util.isEmpty(component.get("v.eventObject.CT_External_event_subtype__c"))){
                    var childComponent = component.find("childEventType1");
                childComponent.getCallEventTypeMethod(component.get("v.eventObject.Event_type__c"),component.get("v.eventObject.CT_External_event_subtype__c"),component.get("v.eventObject.external_event_subtypes__c"))
                }
                
            }
    
        });
        $A.enqueueAction(action);
        
    },
    
    
    fieldValidationController:function(component,buttonName) {
        component.set("v.invalidField",[]);
        if(buttonName=="StepOneSave") {
            var counter = this.checkFieldValidation(component,'basic_info_field');
            if(counter==0) {
                component.set("v.isValid",false);
                component.set("v.allowSave",true);
            }
        }
        else if(buttonName=="StepTwoSave") {
            var counter1,counter2;
            component.set("v.invalidField",[]);
            
            counter1 = this.checkFieldValidation(component,'basic_info_field');
            counter2 = this.checkFieldValidation(component,'basic_info_field1');
            if((counter1+counter2)==0) {
                component.set("v.isValid",false);
                component.set("v.allowSave",true);
            }
        }
            else if(buttonName=="StepThreeSave") {
                var counter1,counter2,counter3;
                component.set("v.invalidField",[]);
                counter1 = this.checkFieldValidation(component,'basic_info_field');
                counter2 = this.checkFieldValidation(component,'basic_info_field1');
                counter3 = this.checkFieldValidation(component,'basic_info_field2');
                if((counter1+counter2+counter3)==0) {
                    component.set("v.isValid",false);
                    component.set("v.allowSave",true);
                }
            }
                else if(buttonName=="StepFourSave") {
                    var counter1,counter2,counter3,counter4;
                    component.set("v.invalidField",[]);
                    counter1=  this.checkFieldValidation(component,'basic_info_field');
                    counter2  = this.checkFieldValidation(component,'basic_info_field1');
                    counter3 = this.checkFieldValidation(component,'basic_info_field2');
                    counter4 = this.checkFieldValidation(component,'basic_info_field3');
                    if((counter1+counter2+counter3+counter4)==0) {
                        component.set("v.isValid",false);
                        component.set("v.allowSave",true);
                    }
                }
        
                    else if(buttonName=="StepFiveSave") {
                        component.set("v.invalidField",[]);
                        var counter1,counter2,counter3,counter4,counter5;
                        component.set("v.invalidField",[]);
                        counter1 = this.checkFieldValidation(component,'basic_info_field');
                        counter2 = this.checkFieldValidation(component,'basic_info_field1');
                        counter3 = this.checkFieldValidation(component,'basic_info_field2');
                        counter4 = this.checkFieldValidation(component,'basic_info_field3');
                        counter5 = this.checkFieldValidation(component,'basic_info_field4');
                        if((counter1+counter2+counter3+counter4+counter5)==0) {
                            component.set("v.isValid",false);
                            component.set("v.allowSave",true);
                        }
                    }                        
                        else {
                            
                            component.set("v.invalidField",[]);
                            var counter1,counter2,counter3,counter4,counter5,counter6;
                            counter1 = this.checkFieldValidation(component,'basic_info_field');
                            counter2 =  this.checkFieldValidation(component,'basic_info_field1');
                            counter3 = this.checkFieldValidation(component,'basic_info_field2');
                            counter4 = this.checkFieldValidation(component,'basic_info_field3');
                            counter5 = this.checkFieldValidation(component,'basic_info_field4');
                            counter6 = this.checkFieldValidation(component,'basic_info_field5');
                            if((counter1+counter2+counter3+counter4+counter5+counter6)==0) {
                                component.set("v.isValid",false);
                                component.set("v.allowSave",true);
                            }
                        }
    },
    
    checkFieldValidation:function(component,auraId) {
        
        var i=0;
        var j=0;
        var k=0;
        var counter = 0;
        var errorMessage;
        var fieldstoValidate = component.find(auraId);
       // console.log("aura id is "+auraId);
        component.set("v.allowSave",false);
        
         var sectionMap = new Map([["basic_info_field","General"],["basic_info_field1","Type/Size"],["basic_info_field2","Budget"],["basic_info_field3","Event Focus"],["basic_info_field4","Target"],["basic_info_field5","Justification"]]);
        
        if(auraId == 'basic_info_field3') {	
            if(component.get("v.data").length==0) {
                errorMessage = "Please select atleast one cluster in the \'Event Focus\' tab before saving the evnent";
                var invalidFieldList =  component.get("v.invalidField");
                invalidFieldList.push(errorMessage);
                component.set("v.invalidField",invalidFieldList);
                component.set("v.isValid",true);
                counter++;
            }
            else {
               // console.log("else is executed for BGU")
                
                component.set("v.isValid",true);
                component.set("v.allowSave",false);
                
            }
        }
        
        
        var isValid = fieldstoValidate.reduce(function(initialValidCheck,inputElement) {
            if($A.util.isEmpty(inputElement.get("v.value"))  && inputElement.get("v.label")!='Event Collaborator Email') {
               // console.log("the name of the field is "+ inputElement.get("v.label"));
                errorMessage = "Please complete " + "\'" + inputElement.get("v.label") + "\'" +  " in the " + "\'" + sectionMap.get(auraId) + "\'"+ " tab before saving the event ";
                var invalidFieldList =  component.get("v.invalidField");
                invalidFieldList.push(errorMessage);
                component.set("v.invalidField",invalidFieldList);
                component.set("v.isValid",true);
                counter++;
            }
            
            if(inputElement.get("v.label")=='Event primary contact email' && !$A.util.isEmpty(inputElement.get("v.value"))) {
                    if(/@philips.com\s*$/.test(inputElement.get("v.value"))===false) {
                        errorMessage = "The "+inputElement.get("v.label") + " must contain \'@philips.com\'  in the \'General Tab\'";
                        var invalidFieldList =  component.get("v.invalidField");
                        invalidFieldList.push(errorMessage);
                        component.set("v.invalidField",invalidFieldList);
                        component.set("v.isValid",true);
                        counter++;                   
                        
                    }
                }
                if(inputElement.get("v.label")=='Event Collaborator Email' && !$A.util.isEmpty(inputElement.get("v.value"))) {
                    if(/@philips.com\s*$/.test(inputElement.get("v.value"))===false) {
                        errorMessage = "The "+inputElement.get("v.label") + " must contain \'@philips.com\'  in the \'General Tab\'";
                        var invalidFieldList =  component.get("v.invalidField");
                        invalidFieldList.push(errorMessage);
                        component.set("v.invalidField",invalidFieldList);
                        component.set("v.isValid",true);
                        counter++;                   
                        
                    }
                }
            
            if(inputElement.get("v.label")=='Budget in local currency') {
                if(inputElement.get("v.value")==0) {
                    errorMessage = inputElement.get("v.label") + " in the \'Budget\' tab cannot be 0";
                    var invalidFieldList =  component.get("v.invalidField");
                    invalidFieldList.push(errorMessage);
                    component.set("v.invalidField",invalidFieldList);
                    component.set("v.isValid",true);
                    counter++;
                }
            }
            
                 if(auraId=="basic_info_field1" && (component.get("v.eventObject.Event_type__c")=="" ||component.get("v.eventObject.Event_type__c")=="--- None ---") && i==0) {
                errorMessage = "Please complete \'Event type\' in the \'Type/Size\' tab before saving the event";
                var invalidFieldList =  component.get("v.invalidField");
                invalidFieldList.push(errorMessage);
                component.set("v.invalidField",invalidFieldList);
                component.set("v.isValid",true);
                counter++;
                
                i++
                console.log("ext "+component.get("v.eventObject.CT_External_event_subtype__c"))  ; 
            }
            if(auraId=="basic_info_field1" && (component.get("v.eventObject.CT_External_event_subtype__c")=="" ||component.get("v.eventObject.CT_External_event_subtype__c")=="--- None ---") && j==0) {
                errorMessage = "Please complete \'Event Sub type\' in the \'Type/Size\' tab before saving the event";
                var invalidFieldList =  component.get("v.invalidField");
                invalidFieldList.push(errorMessage);
                component.set("v.invalidField",invalidFieldList);
                component.set("v.isValid",true);
                counter++;
                
                j++;
                
                console.log("ext "+component.get("v.eventObject.CT_External_event_subtype__c"))  ; 
            }
           
            if(auraId=="basic_info_field1" && (component.get("v.eventObject.external_event_subtypes__c")=="" ||component.get("v.eventObject.external_event_subtypes__c")=="--- None ---") && k==0 && component.get("v.eventObject.Event_type__c")=='Customer') {
                 
                errorMessage = "Please complete \'External event subtype\' in the \'Type/Size\' tab before saving the event";
                var invalidFieldList =  component.get("v.invalidField");
                invalidFieldList.push(errorMessage);
                component.set("v.invalidField",invalidFieldList);
                component.set("v.isValid",true);
                counter++;
                k++;
            }
            
            
        },true);
        
        
       return counter;
    },
    
    
     checkDuplicate : function(component) {
        var action = component.get("c.checkDuplicate");
        action.setParams({eventDetails:component.get("v.eventObject")});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state== "SUCCESS") {
               // console.log("return Value  " +response.getReturnValue());
                if(response.getReturnValue()==true) {
                    component.set("v.showDuplicateModal",true);
                    
                   // console.log("Duplicate modal is invoked ");
                   
                   
                    
                }
                else
                {
                    component.set("v.showDuplicateModal",false);
                    this.saveEventDetails(component,event); 
                }
            }
            else {
               // console.log("Duplicate Callback Failed");
            }
            
        });
        $A.enqueueAction(action);
        
    },

    
    handleStep:function(component,step) {
        //console.log("Step in handle is "+step);
        switch(step) {
            case 'CT_Basic_event_info':
                
                component.set("v.showBasicData", true);
                component.set("v.showEventTypeAndSize", false); 
                component.set("v.showBudgetInfo", false);
                component.set("v.showEventFocus", false);
                component.set("v.showTarget", false);
                component.set("v.showJustification", false);
                break;
            case 'CT_Event_Size':
                component.set("v.showBasicData", false);
                component.set("v.showEventTypeAndSize", true); 
                component.set("v.showBudgetInfo", false);
                component.set("v.showEventFocus", false);
                component.set("v.showTarget", false);
                component.set("v.showJustification", false);
                break;
            case 'CT_Budget':
                component.set("v.showBasicData", false);
                component.set("v.showEventTypeAndSize", false); 
                component.set("v.showBudgetInfo", true);
                component.set("v.showEventFocus", false);
                component.set("v.showTarget", false);
                component.set("v.showJustification", false);
                break;
            case 'CT_PR':
                component.set("v.showBasicData", false);
                component.set("v.showEventTypeAndSize", false); 
                component.set("v.showBudgetInfo", false);
                component.set("v.showEventFocus", true);
                component.set("v.showTarget", false);
                component.set("v.showJustification", false);
                
                break;
            case 'CT_Leads':
                component.set("v.showBasicData", false);
                component.set("v.showEventTypeAndSize", false); 
                component.set("v.showBudgetInfo", false);
                component.set("v.showEventFocus", false);
                component.set("v.showTarget", true);
                component.set("v.showJustification", false);
                break;
                
            case 'Event justification':
                component.set("v.showBasicData", false);
                component.set("v.showEventTypeAndSize", false); 
                component.set("v.showBudgetInfo", false);
                component.set("v.showEventFocus", false);
                component.set("v.showTarget", false);
                component.set("v.showJustification", true);
                break;
            default:
                component.set("v.showBasicData", true);
                component.set("v.showEventTypeAndSize", false); 
                component.set("v.showBudgetInfo", false);
                component.set("v.showEventFocus", false);
                component.set("v.showTarget", false);
                component.set("v.showJustification", false);
        }
    },
    
    fetchEventTypePicklist: function(component,fieldAPI,recType,lang) {
        var action = component.get("c.getCustomMetaDataValues");
        action.setParams({
            'recType': recType,
            'fieldAPIName': fieldAPI,
            'lang': lang,
        });
        action.setCallback(this, function(response) {
            component.set("v.listEventTypeValues", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    fetchEventSubTypePicklist: function(component,fieldAPI,recType,lang) {
        var action = component.get("c.getCustomMetaDataValues");
        action.setParams({
            'recType': recType,
            'fieldAPIName': fieldAPI,
            'lang': lang,
        });
        action.setCallback(this, function(response) {
            component.set("v.listEventSubTypeValues", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    fetchCollaborator:function(component) {
        
        var action = component.get("c.getCollabrator");
        //onsole.log("recordId is "+component.get("v.recordId"));
        action.setParams({recordId:component.get("v.recordId")});
        action.setCallback(this,function(response) {
            var state = response.getState();
            var data = response.getReturnValue();
            if(data!=undefined) {
                
                if(state=="SUCCESS"){
                    component.set("v.eventCollabratorValue",data);
                    component.set("v.eventCollabratorLookupId",data.Id);
                    component.set("v.selectedObjectDisplayName",data.Name);
                    
                   // console.log("collab is "+data.Name);
                }
                else{
                   // console.log("there is an error in getcollab");
                }
                
            }
            
            
            
        });
        $A.enqueueAction(action);
    },
    
    getPrimaryContactLookup:function(component) {
        var action = component.get("c.getPrimaryContact");
        //onsole.log("recordId is "+component.get("v.recordId"));
        action.setParams({recordId:component.get("v.recordId")});
        action.setCallback(this,function(response) {
            var state = response.getState();
            var data = response.getReturnValue();
            if(data!=undefined) {
                
                if(state=="SUCCESS"){
                    component.set("v.primaryContactValue",data);
                    component.set("v.primaryContactLookupId",data.Id);
                    component.set("v.primaryContactName",data.Name);
                  // console.log("contact id executed");
                }
                else{
                   // console.log("there is an error in contact");
                }
                
            }
            
            
            
        });
        $A.enqueueAction(action);
    },
    
    fetchUser: function(component) {
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
                //component.set('v.eventObject.CT_Event_primary_contact__c',storeResponse.Name);
                //component.set('v.eventObject.CT_Event_primary_contact_email__c',storeResponse.Email);
                component.set("v.eventObject.RecordTypeId",component.get("v.recordTypeId"));
               if($A.util.isUndefinedOrNull(component.get("v.eventObject.CurrencyIsoCode"))){
                component.set("v.eventObject.CurrencyIsoCode",storeResponse.CurrencyIsoCode);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchEventExecutionPicklist : function(component,evtFieldName,elementId) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            'objectName': component.get("v.ObjectName"),
            'fieldName': evtFieldName,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                //component.set("v.TypePicklist", a.getReturnValue());
                var allValues = response.getReturnValue();
               // console.log('======>'+JSON.stringify(response.getReturnValue()))
                var plValues = [];
                if (plValues != undefined && plValues.length > 0) {
                    plValues.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                
                for (var i = 0; i < allValues.length; i++) {
                    plValues.push({
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                
                //component.find(elementId).set("v.options", opts);
                component.set("v.lstCampaignOption",plValues);
               // console.log('====  plValues '+JSON.stringify(plValues));
                
              //  console.log('====get lstCampaignOption'+JSON.stringify(component.get("v.lstCampaignOption")));
            } 
        });
        $A.enqueueAction(action);
    },
    
    saveEventDetails:function(component,event){
       //component.set("v.eventObject.Capturing_leads_at_the_event__c",component.get("v.leadValue"));
        var action = component.get("c.saveEventDetails");
       // console.log("leadvalue "+component.get("v.eventObject.Capturing_leads_at_the_event__c"));
        action.setParams({
            eventDetails:component.get("v.eventObject"),
            lstBGU: component.get("v.data"),
            recordIds: component.get("v.idList")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            //console.log('state is ' + state);
            if(state == 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title:'Success Message',
                    message:'Event details are saved successfully!',
                    duration:'2000',
                    key:'info_alt',
                    type:'success',
                    mode:'pester'
                });
                toastEvent.fire();
                this.handleCancel(component,event);
            } else if (response.getState() === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.showErrors",true);
                        component.set("v.errorMessage", errors[0].message);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title:'Error Message',
                            message:'Error:'+errors[0].message,
                            duration:'2000',
                            key:'info_alt',
                            type:'error',
                            mode:'pester'
                        });
                        toastEvent.fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    getPicklistValuesBasednRecordType : function(component,fieldAPIName) {
        
        var objectAPIName = component.get("v.ObjectName");
        var recordTypeId = component.get('v.recordTypeId');
        
        var action = component.get("c.getRecordPickListValues");
        
        action.setParams({
            objectName : objectAPIName,
            fieldAPIName : fieldAPIName,
            strRecordTypeId : recordTypeId
        });
        
        action.setCallback(this, function(response){
            this.handleResponse(response, component);
        });
        
        $A.enqueueAction(action);
        
    },
    handleResponse : function(response, component){
        //console.log('====>State'+response.getState());
        if (response.getState() === "SUCCESS") {
            if (!$A.util.isEmpty(response.getReturnValue())) {
                var picklistOptions = [];
                var noneValue = {};
                noneValue["value"] = "";
                noneValue["label"] = "--None--";
                picklistOptions.push(noneValue);
                var returnedValues = JSON.parse(response.getReturnValue());
                //var returnedValues = response.getReturnValue();
                //console.log('=====> returnedValues'+ returnedValues);
                if (!$A.util.isEmpty(returnedValues)) {
                    returnedValues.forEach(function(returnedValue){
                        var picklistValue = {};
                        picklistValue["value"] = returnedValue.value;
                        picklistValue["label"] = returnedValue.label;
                        picklistOptions.push(picklistValue);
                    });
                    //console.log('=====>'+ JSON.stringify(picklistOptions));
                    //component.set("v.pickListOptions", picklistOptions);
                }
            }else{
                //console.log("Couldn't find an picklist values.");
            }
        } else if (response.getState() === "ERROR") {
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                  //  console.log(errors[0].message);
                }
            }
        } else{
          //  console.log("Unknow error!");
        }
    },
    clearAddressList : function(component) {
      //  console.log("Clearing the list!");
        component.set('v.searchKey', null)
        component.set('v.AddressList', null);
    }, 
    
    
    //get address details by place Id from google API 
    getAddressDetailsByPlaceId: function(component,event){
        var selectedValue = event.currentTarget.dataset.value;
        var action = component.get("c.getAddressDetailsByPlaceId");
        action.setParams({
            PlaceID:selectedValue 
        });
        action.setCallback(this, function(response){
            var res = response.getState();
            if(res == 'SUCCESS'){
                //console.log(response.getReturnValue());
                var response = JSON.parse(response.getReturnValue());
                var postalCode = '', state = '', country= '', city = '', street = '', street_number = '', route = '', subLocal1 = '', subLocal2 = '';
                
                for(var i=0; i < response.result.address_components.length ; i++){
                    var FieldLabel = response.result.address_components[i].types[0];
                   // console.log("myDesc  "+response.result.address_components[i].long_name);
                    //debugger;
                    if(FieldLabel == 'sublocality_level_2' || FieldLabel == 'sublocality_level_1' || FieldLabel == 'street_number' || FieldLabel == 'route' || FieldLabel == 'locality' || FieldLabel == 'country' || FieldLabel == 'postal_code' || FieldLabel == 'administrative_area_level_1'){
                        switch(FieldLabel){
                            case 'sublocality_level_2':
                                subLocal2 = response.result.address_components[i].long_name;
                                break;
                            case 'sublocality_level_1':
                                subLocal1 = response.result.address_components[i].long_name;
                                break;
                            case 'street_number':
                                street_number = response.result.address_components[i].long_name;
                                break;
                            case 'route':
                                route = response.result.address_components[i].long_name;
                                break;
                            case 'postal_code':
                                postalCode = response.result.address_components[i].long_name;
                                break;
                            case 'administrative_area_level_1':
                                state = response.result.address_components[i].long_name;
                                break;
                            case 'country':
                                country = response.result.address_components[i].long_name;
                                var countryCode = response.result.address_components[i].short_name;
                                break;
                            case 'locality':
                                city = response.result.address_components[i].long_name;
                                break;
                            default:
                                break;
                        }
                    }
                }
                
                street = street_number + ' ' + route;
                if(street == null){
                    street = subLocal2 + ' ' + subLocal1;
                }
                //component.set('v.eventObject.CT_Event_Location__c', street);
                component.set('v.eventObject.EMT_Event_Location_Country_Code__c',countryCode);
                component.set('v.eventObject.CT_Location_Country__c', country);
                var addressLst = component.get("v.AddressList");
                for(var i=0; i <addressLst.length; i++){
                    if(selectedValue == addressLst[i].place_id){
                      //  console.log('========Address'+ addressLst[i].main_text);
                        //component.set('v.eventObject.CT_Event_Location__c', addressLst[i].main_text+', '+state+','+country);
                        component.set('v.eventObject.CT_Event_Location__c', addressLst[i].main_text);
                    }
                }
                //component.set('v.addressDetails.Zip_Postal_Code__c', postalCode);
                component.set('v.eventObject.CT_Event_Location_State__c', state);
                //component.set('v.addressDetails.Country__c', country);
              //  console.log("dhinchak "+countryCode);
                component.set('v.eventObject.CT_Event_Location_City__c	', city);
                component.set("v.searchKey", null);
                component.set("v.showModalBox", false);
            }
        });
        $A.enqueueAction(action);
    },
    getAddressRecommendations: function(component, event){
        var key = component.get("v.searchKey");
        var action = component.get("c.getAddressSet");
        action.setParams({
            "SearchText": key
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = JSON.parse(response.getReturnValue());
                var predictions = response.predictions;
                var addresses = [];
                if (predictions.length > 0) {
                    for (var i = 0; i < predictions.length; i++) {
                        var bc =[];
                        addresses.push(
                            {
                                main_text: predictions[i].structured_formatting.main_text, 
                                secondary_text: predictions[i].structured_formatting.secondary_text,
                                place_id: predictions[i].place_id
                            });
                        
                    }
                }
                for(var i=0; i <addresses.length; i++){
                  //  console.log("hi"+addresses[i].main_text);
                    //console.log(addresses[i].secondary_text);
                   // console.log(addresses[i].place_id);
                }
               // console.log("Address:Address: "+addresses)
                component.set("v.AddressList", addresses);
            }
        });
        $A.enqueueAction(action);
    },
    
    //validations on required fields
    validateFieldsOne : function(component,event,fId) {
        var fieldsToValidate = component.find(fId);
        //console.log("fieldstovalidate=="+fId);
        var counter = 0;
        if(fieldsToValidate.length!=undefined)
        {
            //console.log("length "+fieldsToValidate.length);
            var allValid = fieldsToValidate.reduce(function(validSoFar,inputCmp){
                inputCmp.showHelpMessageIfInvalid();
                var s = inputCmp.checkValidity();
               // console.log("check 111 "+ s);
                return validSoFar && s;
            },true);
            if(!allValid)
            {
                counter++;
            }
        }
        else
        {
            var allValid =  fieldsToValidate;
            if(!allValid.checkValidity())
            {
                counter++;
            }
        }
       // console.log(counter);
        if(counter==0)
        {
            return true;
            
        }
        else
        {
            return false;
        }
    },
    
    
    validateFieldsTwo: function(component,event,id) {
        
        var fieldsToValidate = component.find(id);
        //console.log("fieldstovalidatetwotwo=="+id);
        var counter = 0;
        if(fieldsToValidate.length!=undefined)
        {
           // console.log("length "+fieldsToValidate.length);
            var allValid = fieldsToValidate.reduce(function(validSoFar,inputCmp){
                inputCmp.showHelpMessageIfInvalid();
                var s = inputCmp.checkValidity();
            //    console.log("check 111 "+ s);
                return validSoFar && s;
            },true);
            if(!allValid)
            {
                counter++;
            }
        }
        else
        {
            var allValid =  fieldsToValidate;
            if(!allValid.checkValidity())
            {
                counter++;
            }
        }
       // console.log(counter);
        var checkPageOne = this.validateFieldsOne(component,event,'basic_info_field');
      //  console.log("check page one"+checkPageOne)
        if(counter==0)
        {
            return true;
            
        }
        else
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Validation Error!",
                "message": "You must complete the previous fields as well before saving",
                "type": 'error'
            });
            toastEvent.fire();
        }
        
    },
   /* removeBook: function (component, row) {
        var rows = component.get('v.listBusinessData');
        var rowIndex = rows.indexOf(row);
        var idList = component.get("v.idList");
        idList.push(rows[rowIndex].Id);
        console.log('======== Record Id======='+ rows[rowIndex].Id);
        rows.splice(rowIndex, 1);
        component.set('v.data', rows);
    
    },*/
    
      removeBook: function (component, row) {
        var valCluster = row.Cluster__c;
        var valBusiness = row.EmtBusiness__c;
        var valBusinessCategory = row.Business_Category__c;
        var valFunction = row.Function__c;
        var concatStringforBusiness ='';
       
        var rows = component.get('v.listBusinessData');
        var rowIndex = rows.indexOf(row);
        
        var idList = component.get("v.idList");
        if(!$A.util.isEmpty(rows[rowIndex].Id)){
             idList.push(rows[rowIndex].Id);
        }
       
        rows.splice(rowIndex, 1);
        
        component.set('v.data', rows);
        component.set('v.listBusinessData', component.get("v.data"));
       
        if(valCluster === 'Function'){
            concatStringforBusiness = 	valCluster +'##'+ valFunction;
        }else{
       		concatStringforBusiness = 	valCluster +'##'+ valBusiness +'##'+valBusinessCategory + '##'+ valFunction;
        }
         
        var arrayBusinessData = component.get("v.arrayBusinessData");
        
        var findIndex = arrayBusinessData.indexOf(concatStringforBusiness);
        if(findIndex != -1){
            arrayBusinessData.splice(findIndex, 1);
            component.set("v.arrayBusinessData",arrayBusinessData);
        }
    },
    
    fetchClusterData: function(component){
       var action = component.get("c.getClusterData");
        action.setParams({"recordId":component.get("v.recordId")});
        action.setCallback(this,function(response) {
             var bList = response.getReturnValue();
            var state = response.getState();
            if(state=="SUCCESS") {
                  if(!$A.util.isEmpty(bList)){
                    var arrayBusinessData = component.get("v.arrayBusinessData");
                    var concatString = '';
                    for(var i = 0; i < bList.length; i++){
                        if(bList[i].Cluster__c === 'Function'){
                            concatString = bList[i].Cluster__c +'##'+ bList[i].Function__c;
                            arrayBusinessData.push(concatString);
                        }else{
        					concatString = 	bList[i].Cluster__c +'##'+ bList[i].EmtBusiness__c +'##'+ bList[i].Business_Category__c + '##'+ bList[i].Function__c;
                            arrayBusinessData.push(concatString);
                        }
                    }
                        component.set("v.arrayBusinessData",arrayBusinessData);    
                  }
                   
              
               component.set("v.listBusinessData",bList);
                component.set("v.data",bList);
            }
            else
            {
              //  console.log("Callback failed");
            }
        });
        $A.enqueueAction(action);
    },
})