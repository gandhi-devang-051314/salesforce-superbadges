public class BillingCalloutServiceMock implements WebServiceMock {

   //generate res instance from WSDL parsing (BillingServiceProxy) and statically set status, also need to set the Mock Response...
   public static void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType){
      BillingServiceProxy.billProjectResponse_element res = new BillingServiceProxy.billProjectResponse_element();
      res.status = 'OK';
      response.put('response_x', res); 
   }
}