public class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
        for (Integer i=0; i<newList.size(); i++) {
            if(
                newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && 
                oldList[i].Status == Constants.DRAFT_ORDER_STATUS
            ){
                orderIds.add(newList[i].Id);
            }
        }
        RollUpOrderItems(orderIds);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        Set<Id> productIds = new Set<Id>();

        //getting activated order's Product Id...
        for (OrderItem oi : [SELECT Id, Product2Id FROM OrderItem WHERE OrderId IN :activatedOrderIds]){
            productIds.add(oi.Product2Id);
        }

        productMap = new Map<Id, Product2>([SELECT Id, Quantity_Ordered__c FROM Product2 WHERE Id IN :productIds]); //Quantity orders needs to be updated that's why it is fetched from Query...

        //looping through aggregated quantity per product and set the values respectivly...
        for (AggregateResult ar : [SELECT Product2Id, SUM(Quantity) totalQuantity FROM OrderItem WHERE Product2Id IN :productMap.keySet() GROUP BY Product2Id]){
            productMap.get((String)ar.get('Product2Id')).Quantity_Ordered__c = Integer.valueOf(ar.get('totalQuantity'));
        }

        //null check and simple update
        if (
            productMap !=  null &&
            productMap.size() > 0
        ){
            update productMap.values();
        }
    }
}