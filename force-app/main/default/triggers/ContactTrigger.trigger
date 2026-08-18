trigger ContactTrigger on Contact (after insert, after update, after delete) {
    //Creamos un maping para asociar Id's con total de Accounts
    Map<String,Integer> contactAccountCounter = new Map<String,Integer>();

    switch on Trigger.operationType {
        when AFTER_INSERT{
            for (Contact contact : Trigger.new) {
                if(contact.Active__c == true && contact.AccountId != null){
                    if(contactAccountCounter.containsKey(contact.AccountId)){
                        contactAccountCounter.put(contact.AccountId, contactAccountCounter.get(contact.AccountId)+1);
                    }else{
                        contactAccountCounter.put(contact.AccountId, 1);
                    }
                }
            }
            //Creamos una List para poder insertarlo en Base de datos
            List<Account> updateAccount = new List<Account>();
            
            for (String accountid : contactAccountCounter.keyset()){
                Account acc = new Account(
                    Id = accountid,
                    Active_Contacts__c = contactAccountCounter.get(accountid)
                );
                updateAccount.add(acc);
            }
            update updateAccount;

        }
        when AFTER_UPDATE{
            // Account Id -> net change in active contacts for this transaction
            Map<Id, Integer> accountChangeMap = new Map<Id, Integer>();

            for (Contact contact : Trigger.new) {
                Contact oldContact = Trigger.oldMap.get(contact.Id);
                Boolean wasCounted = oldContact.Active__c == true && oldContact.AccountId != null;
                Boolean isCounted = contact.Active__c == true && contact.AccountId != null;

                if(wasCounted && !isCounted){
                    // se desactivó, o se le quitó el AccountId, o ambas cosas
                    Integer change = accountChangeMap.containsKey(oldContact.AccountId) ? accountChangeMap.get(oldContact.AccountId) : 0;
                    accountChangeMap.put(oldContact.AccountId, change - 1);
                }else if(!wasCounted && isCounted){
                    // se activó, o se le añadió un AccountId
                    Integer change = accountChangeMap.containsKey(contact.AccountId) ? accountChangeMap.get(contact.AccountId) : 0;
                    accountChangeMap.put(contact.AccountId, change + 1);
                }else if(wasCounted && isCounted && oldContact.AccountId != contact.AccountId){
                    // seguía activo pero se movió de una cuenta a otra
                    Integer oldChange = accountChangeMap.containsKey(oldContact.AccountId) ? accountChangeMap.get(oldContact.AccountId) : 0;
                    accountChangeMap.put(oldContact.AccountId, oldChange - 1);

                    Integer newChange = accountChangeMap.containsKey(contact.AccountId) ? accountChangeMap.get(contact.AccountId) : 0;
                    accountChangeMap.put(contact.AccountId, newChange + 1);
                }
            }

            if(!accountChangeMap.isEmpty()){
                List<Account> accountsToUpdate = [SELECT Id, Active_Contacts__c FROM Account WHERE Id IN :accountChangeMap.keySet()];
                for (Account acc : accountsToUpdate) {
                    Integer currentCount = acc.Active_Contacts__c != null ? Integer.valueOf(acc.Active_Contacts__c) : 0;
                    Integer newCount = currentCount + accountChangeMap.get(acc.Id);
                    acc.Active_Contacts__c = newCount > 0 ? newCount : 0;
                }
                update accountsToUpdate;
            }
        }
        when AFTER_DELETE{
            // Account Id -> net change in active contacts for this transaction
            Map<Id, Integer> accountChangeMap = new Map<Id, Integer>();

            for (Contact contact : Trigger.old) {
                // un contacto borrado ya no puede contar, así que si contaba, se resta
                if(contact.Active__c == true && contact.AccountId != null){
                    Integer change = accountChangeMap.containsKey(contact.AccountId) ? accountChangeMap.get(contact.AccountId) : 0;
                    accountChangeMap.put(contact.AccountId, change - 1);
                }
            }

            if(!accountChangeMap.isEmpty()){
                List<Account> accountsToUpdate = [SELECT Id, Active_Contacts__c FROM Account WHERE Id IN :accountChangeMap.keySet()];
                for (Account acc : accountsToUpdate) {
                    Integer currentCount = acc.Active_Contacts__c != null ? Integer.valueOf(acc.Active_Contacts__c) : 0;
                    Integer newCount = currentCount + accountChangeMap.get(acc.Id);
                    acc.Active_Contacts__c = newCount > 0 ? newCount : 0;
                }
                update accountsToUpdate;
            }
        }
        when else {

        }
    }
}