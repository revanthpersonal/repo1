/*
Ravi V   : 12/10/2013
Naresh K : 05/27/2013

Raghu R  : 1/31/2014: MDM Projct :  Added code to insert and updare Account Address records

Raghu R  : 2/27/2014: MDM Projct :  Updated code as requirement changed for Customer Account

Business Process:
When account is created or updated:

For Prospect:
If prospect then header address gets copied as corporate address.
On update, update existing corporate address 

For partner:
On create, copy header address as sold to 
On create, copy header address as corporate address
On update, only update corporate address

For Customer:
On create, copy header address as corporate address
On update, only update corporate address
Test Class: Account_BeforeTest
*/
trigger Account_Before on Account(before insert, before update, before delete, after insert) {
    if (Util.Bypass_Trigger_Chk) return;

    List < Address__c > addresslist = new List < Address__c > ();
    List < Address__c > addresslistupdate = new List < Address__c > ();
    Global_Setting__c obj1 = new Global_Setting__c();
    Id BusPartnerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();


    if ((trigger.isInsert || Trigger.isupdate) && Trigger.isBefore) {
        for (Account acct: Trigger.new) {

            // When new Account created if Recordtype is Enterprise - Business Partner flag it as isDirect
            if (trigger.isInsert) {

                String acntRecId = acct.Recordtypeid;
                if (acntRecId != '') {
                    if (BusPartnerRecTypeId == acntRecId)
                        acct.isDirect__c = true;
                }
            }
            System.debug('------------------acct.Country__c-----------------' + acct.Country__c);

            System.debug('------------------acct.Subsidary__c-----------------' + acct.Subsidary__c);

            System.debug('------------------obj1--------------' + obj1);

            // Assign subsidary     
            if (acct.Country__c != null && acct.Subsidary__c == null) {
                List<Country__c> tempc = [select name from Country__c where id =: acct.Country__c limit 1];
                if(!tempc.isEmpty()){
                    if (tempc[0].name == 'United States') {
                        acct.Subsidary__c = Global_Setting__c.getInstance('United States').ID__c;
                    } else if (tempc[0].name == 'Canada') {
                        acct.Subsidary__c = Global_Setting__c.getInstance('Canada').ID__c;
                    } else if (tempc[0].name == 'Japan') {
                        acct.Subsidary__c = Global_Setting__c.getInstance('Japan').ID__c;
                    } else {
                        acct.Subsidary__c = Global_Setting__c.getInstance('ROW').ID__c;
                    }
                }
            }
             /* Navaneetha Added */

      if (trigger.isInsert && trigger.isBefore) {
            
      if(acct.RecordType__c != 'Merge Record Type') {
      if(acct.Street1__c != null || acct.Street2__c != null || acct.Street3__c  != null ){

        String customstreet = (String.isBlank(acct.Street1__c)? '' : acct.Street1__c.removeEnd(',') + ',') + (String.isBlank(acct.Street2__c)? '' : acct.Street2__c.removeEnd(',')+ ',') + (String.isBlank(acct.Street3__c)? '' : acct.Street3__c.removeEnd(',')  );
        //String customstreet = (String.isBlank(acct.Street1__c)? '' : acct.Street1__c + '');
                //String customstreet1 = customstreet.removeEnd(',');
                
                if(customstreet != null){
          acct.billingstreet  =  customstreet;                    
        }
      }
      else{
        acct.Street1__c = (string.isBlank(acct.billingstreet)?'':acct.billingstreet) ;
      }
      if(acct.Country__c != null){
        acct.Billingcountry = acct.Country_Name__c;
      }
      else
      {
        list <country__c> county =  [select id, Name from country__c where name =:  acct.Billingcountry];
      if(county != null && !county.isempty()){
        acct.Country__c = county[0].id;
      }
      else {
        acct.Country__c = Null;
      }
      }
      if(acct.City__c != null){
        acct.BillingCity = acct.City__c;
      }
      else 
      {
        acct.City__c = acct.BillingCity;
      }

      if(acct.StateProvince__c != null){
        acct.BillingState = acct.StateProvince__c;
      }
      else{
        acct.StateProvince__c = acct.BillingState;
      }
      if(acct.ZipCode__c != null){
        acct.BillingPostalCode = acct.ZipCode__c;
      }
      else{
        acct.ZipCode__c =  acct.BillingPostalCode;
      }
               
      }
      }
       Boolean addressupdated = false;
      if(trigger.isUpdate && trigger.isBefore){
      if(acct.RecordType__c != 'Merge Record Type'){
      //String customstreet
            if(acct.Street1__c != trigger.oldMap.get(acct.id).Street1__c || acct.Street2__c != trigger.oldMap.get(acct.id).Street2__c || acct.Street3__c  != trigger.oldMap.get(acct.id).Street3__c ){
        String customstreet = (String.isBlank(acct.Street1__c)? '' : acct.Street1__c.removeEnd(',') + ', ') + (String.isBlank(acct.Street2__c)? '' : acct.Street2__c.removeEnd(',') + ', ') + (String.isBlank(acct.Street3__c)? '' : acct.Street3__c.removeEnd(',') );
        acct.billingstreet  =  customstreet;
                addressupdated = true;
      }
      if( trigger.newMap.get(acct.id).billingstreet != trigger.oldMap.get(acct.id).billingstreet && !addressupdated )
      {
                
        acct.Street1__c = (string.isBlank(acct.billingstreet)?'':acct.billingstreet.removeEnd(','));
      }
                
      if(acct.Country__c != trigger.oldMap.get(acct.id).Country__c){
        acct.Billingcountry = acct.Country_Name__c;
      }

      if(trigger.newMap.get(acct.id).Billingcountry != trigger.oldMap.get(acct.id).Billingcountry){
        list <country__c> county =  [select id, Name from country__c where name =:  acct.Billingcountry];
      if(county != null && !county.isempty()){
        acct.Country__c = county[0].id;
      }else {
        acct.Country__c = Null;
      }
      }
      if(acct.City__c != trigger.oldMap.get(acct.id).City__c){
        acct.BillingCity = acct.City__c;
      }
      if( trigger.newMap.get(acct.id).BillingCity != trigger.oldMap.get(acct.id).BillingCity)
      {
        acct.City__c = acct.BillingCity;
      }
      if(acct.StateProvince__c != trigger.oldMap.get(acct.id).StateProvince__c){
        acct.BillingState = acct.StateProvince__c;
      }
      if( trigger.newMap.get(acct.id).BillingState != trigger.oldMap.get(acct.id).BillingState)
      {
        acct.StateProvince__c = acct.BillingState;
      }
      if(acct.ZipCode__c != trigger.oldMap.get(acct.id).ZipCode__c){
        acct.BillingPostalCode = acct.ZipCode__c;
      }
      if( trigger.newMap.get(acct.id).BillingPostalCode != trigger.oldMap.get(acct.id).BillingPostalCode)
      {
        acct.ZipCode__c = acct.BillingPostalCode;
      }
      }

      } 

      /* Navaneetha Added */
        }
    }


    // Insert Address record from header 
    if (Trigger.isInsert && Trigger.isAfter) {
        try {
            for (Account acct: Trigger.new) {
                if (acct.Street1__c == null && acct.ZipCode__c == null && acct.City__c == null && acct.StateProvince__c == null && acct.Country__c == null)
                    continue;
                addresslist.clear();
                List<Country__c> tempc = [select name from Country__c where id =: acct.Country__c limit 1];
                Address__c temp = new Address__c(Account__c = acct.id, Address_Line_1__c = acct.Street1__c, Address_Line_2__c = acct.Street2__c, name = acct.Street1__c, City__c = acct.City__c, State__c = acct.StateProvince__c, Province__c = acct.StateProvince__c, Zipcode__c = acct.ZipCode__c);
                if(!tempc.isEmpty())
                    temp.Country__c = tempc[0].name;

                if (acct.Type == 'Prospect') {
                    temp.Address_Type__c = 'Corporate';
                    temp.Type__C = 'Corporate';
                    addresslist.add(temp);
                } else if (acct.Type == 'Partner') {
                    temp.Address_Type__c = 'Sold To';
                    temp.Type__C = 'Sold To';
                    addresslist.add(temp);
                    Address__c newAdrs = new Address__c(Account__c = acct.id, Address_Line_1__c = acct.Street1__c, Address_Line_2__c = acct.Street2__c, name = acct.Street1__c, City__c = acct.City__c, State__c = acct.StateProvince__c, Province__c = acct.StateProvince__c, Zipcode__c = acct.ZipCode__c);
                    if(!tempc.isEmpty())
                        temp.Country__c = tempc[0].name;
                    newAdrs.Address_Type__c = 'Corporate';
                    newAdrs.Type__C = 'Corporate';
                    addresslist.add(newAdrs);
                } else if (acct.Type == 'Customer') {
                    if (acct.IsDirect__c) {
                        temp.Address_Type__c = 'Sold To';
                        temp.Type__C = 'Sold To';
                    } else {
                        temp.Address_Type__c = 'End User';
                        temp.Type__C = 'End User';
                    }
                    addresslist.add(temp);
                    Address__c newAdrs = new Address__c(Account__c = acct.id, Address_Line_1__c = acct.Street1__c, Address_Line_2__c = acct.Street2__c, name = acct.Street1__c, City__c = acct.City__c, State__c = acct.StateProvince__c, Province__c = acct.StateProvince__c, Zipcode__c = acct.ZipCode__c);
                    if(!tempc.isEmpty())
                        temp.Country__c = tempc[0].name;
                    newAdrs.Address_Type__c = 'Corporate';
                    newAdrs.Type__C = 'Corporate';
                    addresslist.add(newAdrs);
                }
            }
            insert addresslist;
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }


    /* Updated requested for Too many SOQL issue Requested by vikram/liam updated by navaneetha*/
    if (Trigger.isUpdate  && TriggerFlowManager.ACCOUNT_ADDRESS_UPDATE) {
        ValidateAccountUpdate.validateAccountForInactiveStatus(Trigger.newMap, Trigger.oldMap);
        addresslist.clear();
        Map<id, List<Address__c>> adrs = new Map<id, List<Address__c>> ();
        Map<id, Country__c> addcountry = new Map<id, Country__c>([Select id, Name from Country__C]);
        try {
            Set<String> setAccountId = new Set<String>();
            for (Account acct: Trigger.new) {
            if (acct.Street1__c == null && acct.ZipCode__c == null && acct.City__c == null && acct.StateProvince__c == null && acct.Country__c == null)
                    continue;
                setAccountId.add(acct.id); 
                }   
                List<Account> lstacc = new List<Account>();
                lstacc = [Select id, Name,Street1__c,Street2__c,City__c,StateProvince__c,ZipCode__c,Type, Country__C,Country__r.name from account where id =: setAccountId];
                adrs = new Map<id, List<Address__c>> ();
                List<Address__c> lstadd = new List<Address__c>();
                lstadd = [Select id, account__c from address__C where account__C in : lstacc and Address_Type__c = 'Corporate'];
              //  list<Address__C> lstadd1 = new list<Address__C>();
                for(Address__C ads : lstadd  ){
                
                if(adrs.containskey(ads.account__c)){                
               // lstadd1.add(ads);
                  adrs.get(ads.account__c).add(ads);
                }
                else{
                  //lstadd1.add(ads); 
                   list<Address__C> newads = new  list<Address__C> ();   
                    newads.add(ads);
                    adrs.put(ads.account__c , newads);
                   
                }
                }
                 List<Address__c> lstaddq = new List<Address__c>();
                for (string acctq: (Trigger.newmap).keyset()) {
                    if(adrs.containskey(acctq)){                        
                        if(adrs.get(acctq).size()>0){
                           adrs.get(acctq)[0].Address_Line_1__c =  (Trigger.newmap).get(acctq).Street1__c;
                           adrs.get(acctq)[0].Address_Line_2__c = (Trigger.newmap).get(acctq).Street2__c;
                           adrs.get(acctq)[0].name = (Trigger.newmap).get(acctq).Street1__c;
                           adrs.get(acctq)[0].Country__c = addcountry.get((Trigger.newmap).get(acctq).Country__c).Name;
                           adrs.get(acctq)[0].City__c = (Trigger.newmap).get(acctq).City__c;
                           adrs.get(acctq)[0].State__c = (Trigger.newmap).get(acctq).StateProvince__c;
                           adrs.get(acctq)[0].Province__c = (Trigger.newmap).get(acctq).StateProvince__c;
                           adrs.get(acctq)[0].Zipcode__c = (Trigger.newmap).get(acctq).ZipCode__c;
                           adrs.get(acctq)[0].Address_Type__c = 'Corporate';
                           adrs.get(acctq)[0].Type__C = 'Corporate';
                            if ((Trigger.newmap).get(acctq).Type == 'Prospect') {
                                adrs.get(acctq)[0].Is_Primary__c = true;}
                        }                        
                    }
                    else
                    {
                        account acct = (Trigger.newmap).get(acctq);
                        Address__c temp = new Address__c(Account__c = acct.id, Address_Line_1__c = acct.Street1__c, Address_Line_2__c = acct.Street2__c, name = acct.Street1__c, City__c = acct.City__c, State__c = acct.StateProvince__c, Province__c = acct.StateProvince__c, Zipcode__c = acct.ZipCode__c, Address_Type__c = 'Corporate', Is_primary__c = true, Type__C = 'Corporate');
                        if(acct.Country__c != null){
                            temp.Country__c = addcountry.get(acct.Country__c).Name; 
                        } else{
                            temp.Country__c =  'United States'; 
                        }
                         if (acct.Type == 'Prospect') {
                        temp.Address_Type__c = 'Corporate';
                        temp.Type__C = 'Corporate';
                        lstaddq.add(temp);
                    }  
                        else if (acct.Type == 'Partner') {
                        temp.Address_Type__c = 'Sold To';
                        temp.Type__C = 'Sold To';
                        lstaddq.add(temp);
                        Address__c newAdrs = new Address__c(Account__c = acct.id, Address_Line_1__c = acct.Street1__c, Address_Line_2__c = acct.Street2__c, name = acct.Street1__c, City__c = acct.City__c, State__c = acct.StateProvince__c, Province__c = acct.StateProvince__c, Zipcode__c = acct.ZipCode__c);
                         if(acct.Country__c != null)
                            newAdrs.Country__c = addcountry.get(acct.Country__c).Name; 
                        newAdrs.Address_Type__c = 'Corporate';
                        newAdrs.Type__C = 'Corporate';
                        lstaddq.add(newAdrs);
                    }else if (acct.Type == 'Customer') {
                        if (acct.IsDirect__c) {
                            temp.Address_Type__c = 'Sold To';
                            temp.Type__C = 'Sold To';
                        } else {
                            temp.Address_Type__c = 'End User';
                            temp.Type__C = 'End User';
                        }
                        lstaddq.add(temp);
                        Address__c newAdrs = new Address__c(Account__c = acct.id, Address_Line_1__c = acct.Street1__c, Address_Line_2__c = acct.Street2__c, name = acct.Street1__c, City__c = acct.City__c, State__c = acct.StateProvince__c, Province__c = acct.StateProvince__c, Zipcode__c = acct.ZipCode__c);
                        if(acct.Country__c != null)
                            newAdrs.Country__c = addcountry.get(acct.Country__c).Name; 
                        newAdrs.Address_Type__c = 'Corporate';
                        newAdrs.Type__C = 'Corporate';
                        lstaddq.add(newAdrs);
                    }
                    }
                }
                
            for(id acid: adrs.keyset()){
                lstaddq.addall(adrs.get(acid));
            }
               upsert lstaddq;
                
                
                TriggerFlowManager.ACCOUNT_ADDRESS_UPDATE = false;
            
             
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }

    // do not allow delete unless profile is System Administrator
    if (trigger.isDelete) {
        /*List<String> listOfAdminProfiles = Label.Admin_Profiles.split(';');
        Integer admin = [SELECT count() FROM Profile p WHERE ID in
            (SELECT u.ProfileId From User u WHERE ID =: UserInfo.getUserId())
            AND p.name IN :listOfAdminProfiles
        ];

        if (admin == 0) {*/
        //Anju May 11 : Only users or profiles with Delete Account custom permissions can delete Account.
        if(!FeatureManagement.checkPermission('Delete_Account'))
        {
            for (Account acct: Trigger.old) {
                acct.addError('Only Administrator can delete an Account');
            }
        }
    }
    
    /* If Account is converted from Data.com then set RecordType and Type */
    if(Trigger.isInsert && Trigger.isBefore)
    {
       if(trigger.new[0].Jigsaw != null)
       {
          RecordType objRecType = [Select id from RecordType where name =: 'EMG - Prospect Record Type'];
          trigger.new[0].RecordTypeId = objRecType.id;
          trigger.new[0].Type = 'Prospect';
          trigger.new[0].Street1__c = trigger.new[0].BillingStreet;
          trigger.new[0].City__c = trigger.new[0].BillingCity;
          trigger.new[0].StateProvince__c = trigger.new[0].BillingState;
          trigger.new[0].ZipCode__c = trigger.new[0].BillingPostalCode;
          
          List<Country__c> list_Contry = [Select id from Country__c where name =: trigger.new[0].BillingCountry];
          if(list_Contry != null && list_Contry.size() >0)
            trigger.new[0].Country__c = list_Contry[0].id;

       }
    }
    //Merging activity will be allowed for below profiles <start>
    if(Trigger.isUpdate && Trigger.isBefore  && TriggerFlowManager.ACCOUNT_MERGE_CHECK){
        Set<String> profileNamesToCheck = new Set<String>();
        profileNamesToCheck.add('System Administrator');
        profileNamesToCheck.addAll(Profiles_for_Account_Merge_Check__c.getall().KeySet());
        Integer ProfileAccess= [SELECT count() FROM Profile p WHERE ID in
            (SELECT u.ProfileId From User u WHERE ID =: UserInfo.getUserId())
                AND p.name IN :profileNamesToCheck ];
        TriggerFlowManager.ACCOUNT_MERGE_CHECK = false;
            //AND p.name IN('System Administrator','Genesys System Administrator', 'Customer Care Data Admin', 'Regional Sales Ops', 'Regional Sales Ops (Edit all)')];
        for (Account acct: Trigger.new) {
            if(ProfileAccess==0 && acct.IsMerge__c == true )
                acct.addError('Do not have permission to merge account.');
        }
    }
        //Merging activity will be allowed for below profiles <end>
}