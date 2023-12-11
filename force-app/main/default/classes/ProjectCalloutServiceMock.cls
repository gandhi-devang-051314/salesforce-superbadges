public with sharing class ProjectCalloutServiceMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(201);
        res.setStatus('OK');
        return res;
    }
}