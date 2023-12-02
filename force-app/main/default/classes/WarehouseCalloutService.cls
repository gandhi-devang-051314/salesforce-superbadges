public with sharing class WarehouseCalloutService implements Queueable{
    private static final String URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    @future(callout = true)
    public static void runWarehouseEquipmentSync(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndPoint(URL);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        List<Product2> updatedEquipments = new List<Product2>();
        if(res.getStatusCode() == 200){
            List<Object> jsonRes = (List<Object>)JSON.deserializeUntyped(res.getBody());
            
            for (Object jsonObj : jsonRes) {
                Map<String, Object> obj = (Map<String, Object>)jsonObj;
                Product2 equipment = new Product2(
                    Replacement_Part__c = (Boolean)obj.get('replacement'),
                    Cost__c = (Integer)obj.get('cost'),
                    Current_Inventory__c = (Double)obj.get('quantity'),
                    Lifespan_Months__c = (Integer)obj.get('lifespan'),
                    Maintenance_Cycle__c = (Integer)obj.get('maintenanceperiod'),
                    Warehouse_SKU__c = (String)obj.get('sku'),
                    ProductCode = (String)obj.get('_id'),
                    Name = (String)obj.get('name')
                );
                updatedEquipments.add(equipment);
            }
        }

        if(updatedEquipments.size() > 0){
            upsert updatedEquipments;
        }   
    }

    public static void execute (QueueableContext context){
        runWarehouseEquipmentSync();
    }
}