//Naresh Kumar  04/29/2016
global class AccountEngScoreHistoryBatch implements Database.Batchable<sObject>{
    global final String Query;

    global AccountEngScoreHistoryBatch (String q){
        this.query = q; 
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);     
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> accounts = new List<Account>();
        for(SObject eachRecord : scope){
            accounts.add((Account)eachRecord);
        }
        AccountEngScoreHisotryBatchHelper.createHistoryRecord(accounts);
    }

    global void finish(Database.BatchableContext BC){}
}