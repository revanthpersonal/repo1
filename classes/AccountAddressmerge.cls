//batchclass for account address update. 
// Created by Navaneetha
global class AccountAddressmerge implements Database.Batchable<sObject>{
    
    global string accrecid;
   // global string accrecid = '001U0000007OnBj';  
    global AccountAddressmerge(string accrecid) {
this.accrecid = accrecid; }
    
    global AccountAddressmerge() {
        this.accrecid = null;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
    
        
     String query = 'select id, name, Street1__c, Street2__c, Street3__c,billingstreet,Addressbatch__c  ,Billingcountry, Country__c,Country_Name__c,City__c,BillingCity,BillingState,StateProvince__c,RecordType__c, '
   // + ' BillingPostalCode,ZipCode__c,lastmodifieddate from  account where Addressbatch__c = false '; 
           + ' BillingPostalCode,ZipCode__c,lastmodifieddate from  account where LastModifiedDate = TODAY'; // + system.today()  ;
   system.debug('query'+ query);     
   Set<String> cntry= new Set<String>();
   Map<string,Id> nameIdmap=new Map<String,Id>();
      
     
        System.debug(query);
        if(Test.isRunningTest()){
           query = query + ' LIMIT 100';   
        }
     return Database.getQueryLocator(query);   
     }
 
    global void execute(Database.BatchableContext bc, List<Account> scope){
   Set<String> cntry= new Set<String>();
Map<string,Id> nameIdmap=new Map<String,Id>();
for(Account acc : scope){
       cntry.add(acc.Billingcountry); 
    } 
list <country__c> county =  [select id, Name from country__c where name =:  cntry];
for(Country__c con:county){
    nameIdmap.put(con.Name,con.Id);
}


            for(Account acc : scope)
        { 
                        
            if(acc.RecordType__c != 'Merge Record Type')
            {
                system.debug('test1');
               String customstreet = (String.isBlank(acc.Street1__c)? '' : acc.Street1__c.removeEnd(',') + ', ') + (String.isBlank(acc.Street2__c)? '' : acc.Street2__c.removeEnd(',')  + ', ') + (String.isBlank(acc.Street3__c)? '' : acc.Street3__c );
                if(customstreet != null && String.isNotBlank(customstreet) && customstreet.Length() < 250 ){
                    acc.billingstreet  =  customstreet;
                    system.debug('customstreet'+ customstreet); 
                }
                else{
                    acc.Street1__c = (string.isBlank(acc.billingstreet)?'':acc.billingstreet) ;
                }
                if(acc.Country__c != null && String.isNotBlank(acc.Country__c)){
                acc.Billingcountry = acc.Country_Name__c;
                    system.debug('acc.Billingcountry'+ acc.Billingcountry.removeEnd(','));
                }
                else{
                    System.debug('acc.Billingcountry' +acc.Billingcountry);
                    // if(acc.Billingcountry != 'Republic of Korea'){
              //    list <country__c> county =  [select id, Name from country__c where name =:  acc.Billingcountry];
                  //  string countryid = county.id;
                    //acc.Country__c = String.isBlank(countryid)? 'Null' : countryid ; 
                    if(nameIdmap.containskey(acc.Billingcountry)){
                        acc.Country__c = nameIdmap.get(acc.Billingcountry);
                    }
                    else
                    {
                         acc.Country__c = Null;
                    }
                   // }
                }
                if(acc.City__c != null && String.isNotBlank(acc.City__c) && acc.City__c.Length() <40){
                acc.BillingCity = acc.City__c;
                }
                else {
                    acc.City__c = acc.BillingCity;
                }
                if(acc.StateProvince__c != null && String.isNotBlank(acc.StateProvince__c) && acc.StateProvince__c.Length() <50){
                    acc.BillingState = acc.StateProvince__c;
                }
                else{
                    acc.StateProvince__c = acc.BillingState;
                }
                if(acc.ZipCode__c != null && String.isNotBlank(acc.ZipCode__c) && acc.ZipCode__c.Length() <20){
                acc.BillingPostalCode = acc.ZipCode__c;
                }
                else{
                    acc.ZipCode__c =  acc.BillingPostalCode;
                } 
                
                acc.Addressbatch__c =true;
               }
            
       
        }
        update scope;

    }      
    global void finish(Database.BatchableContext bc){
        }
    
}