@isTest (seeAllData=false)
private class OrderTests {

    @TestSetup
    static void SetupTestData(){
        TestDataFactory.InsertTestData(10);
    }

    //verify orderHelper class's method via order trigger's update event
    @isTest
    static void OrderUpdate_UnitTest(){
        Order o = [SELECT Id, Name, Status FROM Order LIMIT 1];
        Product2 old_p = [SELECT Id, Name, Quantity_Ordered__c FROM Product2 LIMIT 1];

        o.Status = Constants.ACTIVATED_ORDER_STATUS;

        update o;

        Product2 new_p = [SELECT Id, Name, Quantity_Ordered__c FROM Product2 LIMIT 1];

        TestDataFactory.VerifyQuantityOrdered(old_p, new_p, Constants.DEFAULT_ROWS);
    }

    //verify orderExtension class
    @isTest
    static void OrderExtension_UnitTest(){
        PageReference ref = Page.OrderEdit;

        Test.setCurrentPage(ref);

        Order o = [SELECT Id,Status FROM Order LIMIT 1];

        ApexPages.StandardController controller = new Apexpages.StandardController(o);
        OrderExtension extension = new OrderExtension(controller);
        System.assertEquals(5, extension.orderItemList.size());

        extension.selectedFamily = 'Dessert';
        extension.SelectFamily();
        extension.OnFieldChange();
        extension.First();
        extension.Next();
        extension.Previous();
        extension.Last();
        extension.GetHasNext();
        extension.GetPageNumber();
        extension.GetHasPrevious();
        extension.GetTotalPages();
        extension.GetFamilyOptions();
        extension.Save();

        ChartHelper.GetInventory();
    }
}