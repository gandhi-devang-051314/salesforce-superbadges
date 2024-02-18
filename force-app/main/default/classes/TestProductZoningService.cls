@isTest
public class TestProductZoningService {

    @TestSetup
    static void makeData(){
        Product2 product_1= new Product2(
            Name = 'Test Product 1',
            ProductCode = 'TE9999',
            Family = 'Fixed-Wing'
        );

        Product2 product_2 = new Product2(
            Name = 'Test Product 2',
            ProductCode = 'TE9898',
            Family = 'MALES'
        );

        insert new List<Product2>{product_1, product_2};
    }

    @isTest
    static void normalCase(){
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ProductZoning';
        req.httpMethod = 'GET';
        req.params.put('ProductCode', 'TE9999');
        req.headers.put('CountryCode', 'US');
        RestContext.request = req;
        String res = ProductZoningService.getPermissableZone();
        System.assertEquals('Regulated zones only', res);
    }

    @isTest
    static void nullCountryHeader(){
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ProductZoning';
        req.httpMethod = 'GET';
        req.params.put('ProductCode', 'TE9999');
        req.headers.put('CountryCode', null);
        RestContext.request = req;
        String res = ProductZoningService.getPermissableZone();
        System.assertEquals('Regulated zones only', res);
    }

    @isTest
    static void missProductCode(){
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ProductZoning';
        req.httpMethod = 'GET';
        // req.params.put('ProductCode', 'TE9999');
        req.headers.put('CountryCode', 'US');
        RestContext.request = req;
        String res = ProductZoningService.getPermissableZone();
        System.assertEquals('ProductCode is missing or doesn\'t exist', res);
    }

    @isTest
    static void checkWithLocalAuth(){
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ProductZoning';
        req.httpMethod = 'GET';
        req.params.put('ProductCode', 'TE9898');
        req.headers.put('CountryCode', 'US');
        RestContext.request = req;
        String res = ProductZoningService.getPermissableZone();
        System.assertEquals('Confirm with the local authorities', res);
    }
}