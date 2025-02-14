public with sharing abstract class APIChecker extends AbstractActionChecker {
    
    private static final Integer SUCCESS_RESPONSE_CODE = 200;

    protected abstract String getEndpoint();
    protected abstract AbstractActionChecker.Checkable deserializeResult(String responseBody);
    
    public override AbstractActionChecker.Checkable checkStatus() {

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + this.getEndpoint());

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() != SUCCESS_RESPONSE_CODE) {
            throw new APICheckerException('Failed to get ' + this.request.ActionType__c  + ' status for ' + this.request.ActionId__c + ': ' + res.getBody());
        }

        return this.deserializeResult(res.getBody());
    }

    public class APICheckerException extends Exception {}
}