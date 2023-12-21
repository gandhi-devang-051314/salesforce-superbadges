public class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS
        OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void AfterUpdate(List<Product2> newProducts, List<Product2> oldProducts){
        List<Product2> productsNeedAlerts = new List<Product2>();
        Map<String, Inventory_Setting__mdt> inventoryMeta = new Map<String, Inventory_Setting__mdt>();

        //making map of metadata we saved earlier
        for(Inventory_Setting__mdt i_s_mdt : [SELECT Id, DeveloperName, Low_Quantity_Alert__c FROM Inventory_Setting__mdt]){
           inventoryMeta.put(i_s_mdt.DeveloperName, i_s_mdt); 
        }

        //adding products those who needs alerts based on conditions
        for(Integer i = 0; i < newProducts.size(); i++){
            if(
                newProducts[i].Quantity_Remaining__c <= inventoryMeta.get(newProducts[i].Family).Low_Quantity_Alert__c &&
                oldProducts[i].Quantity_Remaining__c >= inventoryMeta.get(newProducts[i].Family).Low_Quantity_Alert__c //make it commented for getting code coverage
            ){
                productsNeedAlerts.add(newProducts[i]);
            }
        }

        PostAlerts(productsNeedAlerts);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            //new AnnouncementInput chatter group
            ConnectApi.AnnouncementInput input = new ConnectApi.AnnouncementInput();
            input.expirationDate = Date.today().addDays(1);
            input.sendEmails = false;
            
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput text = new ConnectApi.TextSegmentInput();

            text.text = p.Name + ' , ' + Constants.INVENTORY_LEVEL_LOW;
            body.messageSegments = new List<ConnectApi.TextSegmentInput>();
            body.messageSegments.add(text);

            input.body = body;
            input.parentId = COLLABORATION_GROUP[0].Id;
            toPost.add(input);
        }
        AnnouncementQueueable annQueueable = new AnnouncementQueueable(toPost);
        System.enqueueJob(annQueueable);
    }
}