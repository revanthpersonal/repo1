({
    fetchRecordTypeName : function(component) {
		var action = component.get("c.getRecordTypeName");
        action.setParams({recordId:component.get("v.recordId")});
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state=="SUCCESS"){
                component.set("v.eventRecordType",response.getReturnValue());
                console.log("name is "+response.getReturnValue());
                //if(response.getReturnValue(=-=))
            }
        });
        $A.enqueueAction(action);
	},
    
})