({
    init: function(component, event, helper) {
        
        var pageReference = component.get("v.pageReference");
        component.set("v.rid", pageReference.state.c__id);
        var action = component.get("c.fetchApprovalInstanceRecord");
        action.setParams({
            recId: component.get("v.rid")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.simpleRecord", response.getReturnValue());
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        var toastEvent = $A.get("e.force:showToast");                        
                        toastEvent.setParams({
                            "title": "Unexpected Error!",
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
        var action=component.get("c.getPicklistValues");
        action.setParams({
            objectName: "Events__c",
            fieldName: "Event_Classification_for_Approvals__c"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.picvalue", response.getReturnValue());
                console.log('here');
                helper.removeEventClassificationBasedOnReach(component,event);
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        var toastEvent = $A.get("e.force:showToast");                        
                        toastEvent.setParams({
                            "title": "Unexpected Error!",
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
        
        
        
        
        var action=component.get("c.getProcessWorkItemId");
        action.setParams({
            recId:  component.get("v.rid")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.processInstanceWorkItemId", response.getReturnValue());
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        var toastEvent = $A.get("e.force:showToast");                        
                        toastEvent.setParams({
                            "title": "Unexpected Error!",
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
        
    },
    handleClick: function(component, event, helper) {
        
        var selectedValue=component.find("select").get("v.value");
        console.log("selectedValue" , selectedValue)
        if(selectedValue === "None"){
            component.set("v.validationHandler",true);
        }
        else{
            component.set('v.simpleRecord.Event_Classification_for_Approvals__c',selectedValue)
            component.set("v.validationHandler",false);
            var eventStatus=component.get("v.simpleRecord.Status__c");
            if(eventStatus === "Closed"){
                component.set("v.errorHandler",true);
            }
            else{
                
                var action=component.get("c.saveEventWithEventClassification");
                action.setParams({
                    recId: component.get("v.rid"),
                    picklistValue: component.find("select").get("v.value")
                    
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var status=response.getReturnValue();
                        console.log('status:',status)
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Success Message",
                            message: "Event Classification saved successfully!",
                            duration: "2000",
                            key: "info_alt",
                            type: "success",
                            mode: "pester"
                        });
                        toastEvent.fire();
                        if(status != "Submitted"){
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": component.get("v.rid"),
                                "slideDevName": "detail"
                            });
                            navEvt.fire();
                        }
                        else if(status	 == "Submitted" )
                        {
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": component.get("v.processInstanceWorkItemId"),
                                "slideDevName": "detail"
                            });
                            navEvt.fire();
                        }
                        $A.get('e.force:refreshView').fire();
                    }
                    else{
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                                var toastEvent = $A.get("e.force:showToast");                        
                                toastEvent.setParams({
                                    "title": "Unexpected Error!",
                                    "message": errors[0].message
                                });
                                toastEvent.fire();
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            }
            
        } 
    },
    handleCancel: function(component, event, helper) {
        var status;
        var eventStatus=component.get("v.simpleRecord.Status__c");
        console.log("The eventStatus is",eventStatus );
        var action=component.get("c.getEventDetails");
        action.setParams({
            eventId: component.get("v.rid")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var Event= response.getReturnValue();
                console.log("The Event is",Event );
                status=Event.Status__c;
                if(status != "Submitted"){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.rid"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                }
                else if(status == "Submitted")
                {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.processInstanceWorkItemId"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                }
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        var toastEvent = $A.get("e.force:showToast");                        
                        toastEvent.setParams({
                            "title": "Unexpected Error!",
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
    openEMTClassificationGuideLink: function(component, event, helper) {
        var link = $A.get("$Label.c.EMT_Events_Classification_guide_link");
        window.open(link);
        
        
    }
    
    
});