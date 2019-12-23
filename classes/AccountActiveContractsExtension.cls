//Naresh Kumar  09/08/2015
public without sharing class AccountActiveContractsExtension {
    public List<wrapperContracts> contracts {get;set;}
    public Id accountId = null;
    public AccountActiveContractsExtension(ApexPages.StandardController sc){
         accountId = sc.getId();
         init(accountId);
    }
    public String strAttachmentId {get; set;}
    public String strContractId {get; set;}
    
    public void init(Id accountId){
        contracts = new List<wrapperContracts>();
        strContractId = '';
        strAttachmentId = '';
        
        List<GCR_Content_Document_Detail__c> contracts1 = [SELECT id, Name, Document_Name__c,GCR__r.Name,GCR__r.id,GCR__r.Status__c,CreatedBy.Name, Effective_Date__c, Expiration_Renewal_Date__c, Public_URL__c            
            FROM GCR_Content_Document_Detail__c WHERE Account_Name__c =: accountId
            AND (Expiration_Renewal_Date__c = NULL OR Expiration_Renewal_Date__c >: System.today())];
        Set<Id> setOfDocumentIds = new Set<Id>();
        
        for(GCR_Content_Document_Detail__c eachContact : contracts1){
            setOfDocumentIds.add(eachContact.id);
        }
        
        Map<Id, dsfs__DocuSign_Status__c> mapIdVsDocusignStatus = new Map<Id, dsfs__DocuSign_Status__c>([SELECT id, GCR_Content_Document__c FROM dsfs__DocuSign_Status__c 
            WHERE GCR_Content_Document__c =: setOfDocumentIds]);    
        Set<Id> setOfStatusIds = new Set<Id>();
        
        Map<Id, List<Id>> mapOfDocumentVsStatusIds = new Map<Id, List<Id>>();
        for(Id documentId : mapIdVsDocusignStatus.keyset()){
            System.debug('NKC debug documentId [' + documentId + ']');
            Id gcrId = mapIdVsDocusignStatus.get(documentId).GCR_Content_Document__c;
            System.debug('NKC debug gcrId [' + gcrId + ']');
            setOfStatusIds.add(documentId);
            if(mapOfDocumentVsStatusIds.get(gcrId) == null){
                List<Id> newList = new List<Id>();              
                newList.add(documentId);
                mapOfDocumentVsStatusIds.put(gcrId, newList);
            }
            else{
                mapOfDocumentVsStatusIds.get(gcrId).add(documentId);    
            }
            System.debug('NKC debug mapOfDocumentVsStatusIds [' + mapOfDocumentVsStatusIds + ']');
        }
       
       
        Map<Id, List<Attachment>> mapOfParentIdVsAttachment = new Map<Id, List<Attachment>>(); 
        List<Attachment> atts = [SELECT Name, CreatedBy.Name, CreatedDate, parentId FROM Attachment 
            WHERE parentId IN : setOfStatusIds OR parentId IN : setOfDocumentIds order by id asc];
        
        for(Attachment eachAtt : atts){
            System.debug('NKC debug eachAtt.Name [' + eachAtt.Name + ']');
             
            if(mapOfParentIdVsAttachment.get(eachAtt.parentId) == null){
                List<Attachment> newList = new List<Attachment>();
                newList.add(eachAtt);
                mapOfParentIdVsAttachment.put(eachAtt.parentId, newList);
            }
            else{
                mapOfParentIdVsAttachment.get(eachAtt.parentId).add(eachAtt);
            }
        }
        
        
        for(GCR_Content_Document_Detail__c eachContact : contracts1){
            wrapperContracts newContract = new wrapperContracts();
            newContract.contract = eachContact;
            newContract.dtEffectiveDate = eachContact.Effective_Date__c;
            newContract.dtExpiryDate = eachContact.Expiration_Renewal_Date__c;
            newContract.strDocumentName = eachContact.Document_Name__c;
            newContract.strCreatedBy = eachContact.CreatedBy.Name;
            List<Attachment> atts1 ;
            List<Attachment> listOfAtts = new List<Attachment>();       
            List<Id> parentIds = mapOfDocumentVsStatusIds.get(eachContact.id);
            if(parentIds == null)
                parentIds = new List<Id>();
            parentIds.add(eachContact.id);
            for(Id eachParentId : parentIds){
                if(mapOfDocumentVsStatusIds.get(eachContact.id) == null) {
                  atts1 = mapOfParentIdVsAttachment.get(eachContact.id);
                   if(atts1 != null && !atts1.isEmpty()){
                        listOfAtts.addAll(atts1);
                    }   
                } 
                else {                  
                for(Id eachStatusId : mapOfDocumentVsStatusIds.get(eachContact.id)){
                     atts1 = mapOfParentIdVsAttachment.get(eachStatusId);
                    if(atts1 != null && !atts1.isEmpty()){
                        listOfAtts.addAll(atts1);
                    }   
                }                   
              }
            }
            
            
            if(listOfAtts.isEmpty())
                continue;
            newContract.att = listOfAtts[0];
            newContract.strRecordType = 'GCR';
            contracts.add(newContract);
        }
        System.debug('contracts1'+contracts);
        
        //Fetching Closed Won Opportunities
        Map<Id, Opportunity> mapOfIdVsOpportunity = new Map<Id, Opportunity>();
        List<Opportunity> listOfOpps = [SELECT id, CloseDate, Term_Commitment__c 
                                                    FROM Opportunity WHERE AccountId =: accountId AND StageName = '6.Closed' 
                                                    AND Win_Loss_Status__c = 'Won'];
        for(Opportunity eachOpp : listOfOpps){
            if(eachOpp.CloseDate == null || (eachOpp.CloseDate != null && 
                                             eachOpp.CloseDate.addMonths(Integer.ValueOf(Label.Account_Active_Contract_Expiry_Months)) < System.today())){
                continue;
            }
            mapOfIdVsOpportunity.put(eachOpp.id, eachOpp);
        }
        mapIdVsDocusignStatus = new Map<Id, dsfs__DocuSign_Status__c>([SELECT id, dsfs__Opportunity__c, GCR_Content_Document__c FROM dsfs__DocuSign_Status__c 
            WHERE dsfs__Opportunity__c =: mapOfIdVsOpportunity.keyset()]);        
        
        mapOfParentIdVsAttachment = new Map<Id, List<Attachment>>(); 
        atts = [SELECT Name, CreatedBy.Name, CreatedDate, parentId FROM Attachment 
            WHERE parentId IN : mapIdVsDocusignStatus.keyset() ORDER BY Id asc];
        
        for(Attachment eachAtt : atts){
            System.debug('NKC debug eachAtt.Name [' + eachAtt.Name + ']');             
            if(mapOfParentIdVsAttachment.get(eachAtt.parentId) == null){
                List<Attachment> newList = new List<Attachment>();
                newList.add(eachAtt);
                mapOfParentIdVsAttachment.put(eachAtt.parentId, newList);
            }
            else{
                mapOfParentIdVsAttachment.get(eachAtt.parentId).add(eachAtt);
            }
        }
        
        //Looping over each Docusign Status
        for(dsfs__DocuSign_Status__c eachStatus : mapIdVsDocusignStatus.values()){
            List<Attachment> listOfAttachments = mapOfParentIdVsAttachment.get(eachStatus.id);
            if(listOfAttachments == null)
                continue;
            for(Attachment eachAtt : listOfAttachments){
                wrapperContracts newContract = new wrapperContracts();
                newContract.att = eachAtt;
                Opportunity objOpp = mapOfIdVsOpportunity.get(eachStatus.dsfs__Opportunity__c);                 
                newContract.strDocumentName = eachAtt.Name;
                newContract.dtEffectiveDate = objOpp.CloseDate;
                newContract.strCreatedBy = eachAtt.CreatedBy.Name;
                if(objOpp.Term_Commitment__c != null){
                    String strYears = objOpp.Term_Commitment__c.replace('Years', '').replace('Year','').replace(' ','');
                    try{
                        Integer intYears = Integer.valueOf(strYears);
                        newContract.dtExpiryDate = newContract.dtEffectiveDate.addYears(intYears).addDays(-1);
                    }catch(Exception e){}
                }                
                newContract.strRecordType = 'Opportunity';
                contracts.add(newContract);
            }
            
        }
    }
    
    public class wrapperContracts{
        public Attachment att {get;set;}        
        public GCR_Content_Document_Detail__c contract {get;set;} 
        public String strDocumentName {get; set;}
        public String strRecordType {get;set;}    
        public Date dtEffectiveDate {get;set;}
        public Date dtExpiryDate {get;set;}
        public String strCreatedBy {get;set;}
    }
    
    //Added By Ranjith on Jun 23, 2016 -- Starts
    //*** Method to create contents
    public void createContent() {
        if(strContractId == null)
            return;
        System.debug('contractId: '+strContractId );
        System.debug('attachmentId: '+strAttachmentId );
        String strObjType = 'ContentVersion';
        String strRecType = 'Contract Document';
        Attachment objSelectedAttachment = [SELECT Id, Name, ParentId, Body, ContentType 
                                            FROM Attachment 
                                            WHERE Id =: strAttachmentId LIMIT 1];
        GCR_Content_Document_Detail__c objSelectedContract = [SELECT Id, Name, Account_Name__r.Name
                                                              FROM GCR_Content_Document_Detail__c 
                                                              WHERE Id =: strContractId LIMIT 1];

        // Uploading attachment to Content
        ContentVersion objCV = new ContentVersion();
        String strContentTitle = objSelectedContract.Account_Name__r.Name + '-' + objSelectedContract.Name + '-' + objSelectedAttachment.Name;
        if(strContentTitle.length() > 75) {
            strContentTitle = strContentTitle.substring(0, 75);    
        }   
        objCV.Title = strContentTitle; 
        objCV.Description = objCV.Title;
        objCV.VersionData = objSelectedAttachment.Body;
        // Path on Client ensures Preview is generated when the link is viewed/clicked
        objCV.PathOnClient = objSelectedAttachment.Name+'.pdf';//+objSelectedAttachment.ContentType;
        objCV.Contract__c = strContractId;
        objCV.IsMajorVersion = true;
        //objCV.FirstPublishLocationId = '058n00000009p13';// [SELECT Id FROM ContentWorkspace WHERE Name = 'Contract Documents'].Id;
        //objCV.RecordTypeId = QuoteUtil.getRecordTypes('ContentVersion').get('Contract Document').Id;
        objCV.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SobjectType =: strObjType AND Name =: strRecType].Id;
        insert objCV;
        System.debug('objCV: '+objCV.Id);
        
        // Setting up of the attachment file in Content for distribution
        ContentDistribution objCD = new ContentDistribution();
        objCD.Name = strContentTitle;
        objCD.ContentVersionId = objCV.Id;
        objCD.PreferencesAllowOriginalDownload = true;
        objCD.PreferencesAllowPDFDownload = true;
        objCD.PreferencesAllowViewInBrowser = true;
        objCD.PreferencesNotifyOnVisit = false;
        insert objCD;         
        
        objCD = [SELECT ContentDocumentId, DistributionPublicUrl FROM ContentDistribution WHERE Id = :objCD.Id];
        System.debug('objNewCV: '+objCD.Id);        
        
        objSelectedContract.Public_URL__c = objCD.DistributionPublicUrl;
        update objSelectedContract;
        
        init(accountId);        
    }
    //Added By Ranjith on Jun 23, 2016 -- Ends
}