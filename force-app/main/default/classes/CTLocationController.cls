public with sharing class CTLocationController {

    public static List<Location__c> getRecentStatusChanges(){

        return [SELECT id, Name, Status__c, Red_Score__c, Pincode__c, Address__c, Status_Update_Date__c 
        FROM Location__c
        ORDER BY Status_Update_Date__c DESC 
        LIMIT 100]; 
    }

    public static List<Location__c> searchLocations(String searchText) {
        
        return [SELECT id, Name, Status__c, Red_Score__c, Pincode__c, Address__c, Status_Update_Date__c 
                FROM Location__c 
                WHERE Name LIKE :('%' + searchText + '%') OR Pincode__c LIKE :('%' + searchText + '%') 
                OR Address__c LIKE :('%' + searchText + '%') ORDER BY Status_Update_Date__c DESC];
    }

    public static Location__c getLocationById(Id locationId) {
        Location__c loc = [SELECT id, Name, Status__c, Red_Score__c, Pincode__c, Address__c, Status_Update_Date__c 
                            FROM Location__c 
                            WHERE Id = :locationId];
        if (loc != null) {
            return loc;
        }else{
            return null;
        }
    }

    public static Map<String, Integer> getStatusCount(){
        Map<String, Integer> healthCountMap = new Map<String, Integer>();
        
        for (AggregateResult ar : [SELECT Status__c, COUNT(Id) total 
                                    FROM Location__c 
                                    GROUP BY Status__c]) {
            healthCountMap.put(String.valueOf(ar.get('Status__c')), Integer.valueOf(ar.get('total')));
        }
        return healthCountMap;
    }
}