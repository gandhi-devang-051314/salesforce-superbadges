public without sharing class ChartHelper {

    //just because requirement is to get data from Lightning compo as well, so written...
    @AuraEnabled
    public static List<chartData> GetInventory(){
        List<chartData> cht = new List<chartData>();

        //getting totalQuantity with respect to product's Family
        for (AggregateResult ar : [SELECT SUM(Quantity_Remaining__c) totalQuantity, Family FROM Product2 WHERE Quantity_Remaining__c > 0 AND IsActive = true GROUP BY Family]){
            cht.add(new ChartData(
                String.valueOf(ar.get('Family')),
                Integer.valueOf(ar.get('totalQuantity')) 
            ));
        }
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }
}