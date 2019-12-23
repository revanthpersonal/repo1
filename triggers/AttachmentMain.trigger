//Naresh Kumar	01/15/2015
trigger AttachmentMain on Attachment (after insert) {
	try{
		DocuSignMainTriggerHelper.updateGCRContentDocument(trigger.new[0]);
	}
	catch(Exception ex){}	
}