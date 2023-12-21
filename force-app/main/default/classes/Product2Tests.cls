@isTest (seeAllData=false)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @isTest
    static void Product2Extension_UnitTest(){
        PageReference pRef = page.Product2New;
        Test.setCurrentPage(pRef);

            Product2 p = new Product2(
                Name = 'Test Product',
                IsActive = true
            );
            ApexPages.StandardController controller = new ApexPages.StandardController(p);

            Product2Extension ext = new Product2Extension(controller);
            System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
            ext.addRows();
            System.assertEquals(2 * Constants.DEFAULT_ROWS, ext.productsToInsert.size());

            for(Integer i = 0; i < Constants.DEFAULT_ROWS; i++){

                Product2 pr = new Product2(
                    Name = 'Test Product'+i,
                    Initial_Inventory__c = 10, 
                    IsActive = true, 
                    Family = Constants.PRODUCT_FAMILY.get(math.mod(i,4)).getValue()
                );
                ext.productsToInsert.get(i).productRecord = pr;

                PriceBookEntry pb = new PriceBookEntry(
                    Unitprice = 999999999,
                    IsActive = true
                );
                ext.productsToInsert.get(i).pricebookEntryRecord = pb;
            }

            ext.save();
            ext.GetFamilyOptions();
            ext.GetInventory();

        Test.stopTest();

        List<Product2> product = [SELECT Id FROM Product2];
        System.assertEquals(Constants.DEFAULT_ROWS, product.size());
    }

    @isTest
    static void Product2Trigger_UnitTest(){
        Test.startTest();

            Product2 p = new Product2();
            p.Name = 'Test';
            p.Family = 'Dessert';
            p.IsActive = true;
            p.Quantity_Ordered__c = 5;
            p.Initial_Inventory__c = 10;
            insert p;
            
            CollaborationGroup c = new CollaborationGroup();
            c.Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS;
            c.Description = 'Description';
            c.CollaborationType = 'Public';
            insert c;
            
            p.Quantity_Ordered__c = 96;
            update p;

        Test.stopTest();
    }
}