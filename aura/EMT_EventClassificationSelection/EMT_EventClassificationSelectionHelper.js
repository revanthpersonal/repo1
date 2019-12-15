({
    removeEventClassificationBasedOnReach : function(component,event) {
        console.log('here2');
        var cusEvent=component.get('v.simpleRecord');
        console.log('here3',cusEvent);
        
        
        console.log('here5',cusEvent.Event_Reach__c);
        if(cusEvent.Event_Reach__c != 'Global'){
            console.log('here6');
            var i;
            console.log('here7');
            var picVal=component.get('v.picvalue');
            console.log('here4',picVal);
            for(i=0;i<picVal.length;i++){
                
                if(picVal[i] === 'Strategic Event')
                {
                    console.log(picVal[i]);                   
                    picVal.splice(i,1);
                }
            }
            component.set("v.picvalue", picVal); 
        }
    }
})