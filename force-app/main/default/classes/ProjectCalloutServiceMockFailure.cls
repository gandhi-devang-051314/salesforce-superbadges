public with sharing class ProjectCalloutServiceMockFailure implements HttpCalloutMock{

    public HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(500);
        res.setStatus('Error');
        return res;
    }
}