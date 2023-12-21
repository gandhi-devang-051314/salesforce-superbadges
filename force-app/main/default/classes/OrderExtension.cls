/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}

    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        loadInitialOrderItemData();
        loadPriceBookentry();
    }

    public void loadInitialOrderItemData(){
        for(OrderItem o : orderRecord.OrderItems){
            orderItemMap.put(o.Product2Id, o);
        }
        loadChartData();
    }

    public void loadPriceBookentry(){
        String query = 'SELECT Name, Id, Pricebook2Id, Product2Id, UnitPrice, Product2.Name, Product2.Quantity_Remaining__c, Product2.Family FROM PricebookEntry WHERE isActive = true';

        if(
            String.isNotBlank(selectedFamily) && 
            selectedFamily != Constants.SELECT_ONE
        ){
            query += ' AND Product2.Family = \''+ selectedFamily + '\'';
        }

        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);

        loadOrderItem();
    }

    public void loadOrderItem(){
        orderItemList = new List<OrderItem>();

        if(StandardSetController.getRecords() != null && StandardSetController.getRecords().size() > 0){

            for (SObject obj : StandardSetController.getRecords()) {
                PricebookEntry pe = (PricebookEntry) obj;

                //check if pe contains orderItem or not?
                if(orderItemMap.containsKey(pe.Product2Id)){
                    orderItemList.add(orderItemMap.get(pe.Product2Id));
                }
                else{
                    OrderItem oi = new OrderItem(
                        Quantity = 0,
                        PricebookEntryId = pe.Id,
                        Product2Id = pe.Product2Id,
                        UnitPrice = pe.UnitPrice,
                        Product2 = pe.Product2
                    );
                    orderItemList.add(oi);
                    orderItemMap.put(pe.Product2Id, oi);
                }
            }
        }
    }

    public void loadChartData(){
        total = 0;
        pieData = new List<ChartHelper.ChartData>();

        for(OrderItem o : orderItemMap.values()){
            pieData.add(new ChartHelper.ChartData(o.Product2.Name, (o.UnitPrice * o.Quantity)));
            total = total + (o.UnitPrice * o.Quantity);
        }
    }


    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        for(OrderItem o : orderItemList){
            orderItemMap.put(o.Product2Id, o);
        }
        loadChartData();
    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        loadPriceBookentry();
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        SavePoint transcationInstance = Database.setSavePoint();

        try {
            if(orderRecord.Pricebook2Id == null) {
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
              
            upsert orderRecord;

            List<OrderItem> ordersForUpsert = new List<OrderItem>();
            List<OrderItem> ordersForDelete = new List<OrderItem>();

            for(OrderItem oi : orderItemMap.values()){
                if(oi.Quantity > 0){
                    if(oi.OrderId == null){
                        oi.OrderId = orderRecord.Id;
                    }
                    ordersForUpsert.add(oi);
                }
                else if(oi.Id != null){
                    ordersForDelete.add(new OrderItem(
                        Id = oi.Id
                    ));
                    oi.Id = null;
                }
            }

            upsert ordersForUpsert;
            delete ordersForDelete;
        } catch (Exception e) {
            Database.rollback(transcationInstance);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,Constants.ERROR_MESSAGE));
        }
    }


    /**
     * @name First
     * @description
    **/
    public void First(){
        standardSetController.first();
        loadOrderItem();
    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){
        standardSetController.next();
        loadOrderItem();
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
        standardSetController.previous();
        loadOrderItem();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
        standardSetController.last();
        loadOrderItem();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        return (Integer)math.ceil(standardSetController.getResultSize() / (Decimal)Constants.DEFAULT_ROWS);
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(
            Constants.SELECT_ONE, 
            Constants.SELECT_ONE
        ));

        for(Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY){
            options.add(new SelectOption(
                entry.getLabel(),
                entry.getValue()
            ));
        }
        return options;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}