//Naresh Kumar	04/29/2016
public without sharing class AccountEngScoreHisotryBatchHelper {

	public static void createHistoryRecord(List<Account> accounts){
		List<Id> accountIds = new List<Id>();
		//Looping over each account
		for(Account eachAccount : accounts){
			accountIds.add(eachAccount.id);
		}
		
		List<SML_Account_Engagement_Score__c> engagementScores = [SELECT id,
			(SELECT id, New_Score__c, Old_Score__c, SML_Account_Engagement_Score__c,
			History_Date__c, CreatedDate FROM SML_Account_Engagement_Score_History__r ORDER BY SML_Account_Engagement_Score__c, CreatedDate ASC)
			 FROM SML_Account_Engagement_Score__c WHERE Account__c IN : accountIds]; 
		List<SML_Account_Engagement_Score_History__c> scoreHistoryToBeInserted = new List<SML_Account_Engagement_Score_History__c>();
		Integer counter = 0;
		for(SML_Account_Engagement_Score__c eachScore : engagementScores){			
			List<SML_Account_Engagement_Score_History__c> eachHistory = eachScore.SML_Account_Engagement_Score_History__r;
			//Initializing start date - Year, Month, Day
			Date startDate = Date.newInstance(2015, 12, 1);			
			Set<String> setOfDates = new Set<String>();
			for(SML_Account_Engagement_Score_History__c eachRecord : eachHistory){
				counter ++;
				System.debug(LoggingLevel.INFO, 'NKC debug counter ['+counter+']');
				System.debug(LoggingLevel.INFO, 'NKC debug eachHistory.size() ['+eachHistory.size()+']');
				if(eachHistory.size() > counter)
					System.debug(LoggingLevel.INFO, 'NKC debug eachHistory[counter].History_Date__c ['+eachHistory[counter].History_Date__c+']');
				DateTime currentEndDate = (eachHistory.size() > counter) ? eachHistory[counter].History_Date__c : System.today();
				System.debug(LoggingLevel.INFO, 'NKC debug startDate ['+startDate+']');
				System.debug(LoggingLevel.INFO, 'NKC debug currentEndDate ['+currentEndDate+']');	
				if(currentEndDate <= startDate){
					System.debug(LoggingLevel.INFO, 'NKC debug currentEndDate ['+currentEndDate+']');
					continue;
				}							
				while(startDate < currentEndDate){
					Date endDate = startDate.addDays(14);
					System.debug(LoggingLevel.INFO, 'NKC debug startDate ['+startDate+']');
					System.debug(LoggingLevel.INFO, 'NKC debug endDate ['+endDate+']');
					System.debug(LoggingLevel.INFO, 'NKC debug eachRecord.History_Date__c ['+eachRecord.History_Date__c+']');
					if((eachRecord.History_Date__c >= startDate && eachRecord.History_Date__c <= endDate)){
						startDate = endDate;
						break;
					}
					else{
						System.debug(LoggingLevel.INFO, 'NKC debug setOfDates ['+setOfDates+']');
						if(setOfDates.contains(String.valueOf(startDate))){
							startDate = endDate;
							continue;
						}
						SML_Account_Engagement_Score_History__c newRecord = eachRecord.clone(false, false);
						newRecord.Created_Date__c = startDate;
						scoreHistoryToBeInserted.add(newRecord);
						setOfDates.add(String.valueOf(startDate));	
					}
					startDate = endDate;
				}		
			}					
		}
		if(!scoreHistoryToBeInserted.isEmpty())
			insert scoreHistoryToBeInserted;
	}	
}