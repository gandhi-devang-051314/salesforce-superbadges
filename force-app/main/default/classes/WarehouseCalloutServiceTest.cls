@isTest
private with sharing class WarehouseCalloutServiceTest {
    
    @isTest
    static void testWareHouseCallout(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService.runWarehouseEquipmentSync();

        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Product2]);
    }
}