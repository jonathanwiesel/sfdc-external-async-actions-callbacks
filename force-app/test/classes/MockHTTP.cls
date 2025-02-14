@TestVisible
@IsTest
private class MockHTTP implements HttpCalloutMock {

    private Integer responseCode;
    private String responseBody;

    public MockHTTP(Integer responseCode, String responseBody) {

        this.responseCode = responseCode;
        this.responseBody = responseBody;
    }

    public HttpResponse respond(HttpRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setBody(this.responseBody);
        res.setStatusCode(this.responseCode);
        return res;
    }
}