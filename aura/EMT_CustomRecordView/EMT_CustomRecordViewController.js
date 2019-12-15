({
	doInit : function(component, event, helper) {
        helper.fetchRecordTypeName(component);
        console.log("==== "+component.get("v.recordId"));
		var action = component.get("c.getProfileCondition");
        action.setParams({recordId:component.get("v.recordId")});
        action.setCallback(this,function(response) {
            var state=response.getState();
            var data= response.getReturnValue();
            if(state=="SUCCESS")
            {
                console.log("data is "+data);
                component.set("v.conditionCheck",data);
            }
            else if(state == "ERROR") 
            {
                console.log("Apex successfully not called"+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
})