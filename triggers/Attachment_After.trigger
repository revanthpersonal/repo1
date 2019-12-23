trigger Attachment_After on Attachment (after insert, after update) {

		if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){ // If new attachment is added to Order__c, update PM Approval Flag to true			
			List <id> orderIdList =  new List<Id>();					  
				for(Attachment att: trigger.new){
					if(att.ParentId.getSobjectType() == Order__c.SobjectType){
						orderIdList.add( att.ParentId);	
					}																				
				}
				if(orderIdList.size()>0){
					Order__c [] orders = [select id, Approved_By_Manager__c from Order__c where id IN : orderIdList and Approved_By_Manager__c = false and recordtypeid = '012U0000000M2Tw'];				
					OrderUtil.updatePMApprovalStatus(orders);
				}
		}
}