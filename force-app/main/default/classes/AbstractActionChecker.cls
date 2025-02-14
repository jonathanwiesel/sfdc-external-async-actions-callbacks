public with sharing abstract class AbstractActionChecker {
    
    @TestVisible
    private static AbstractActionChecker mockedChecker;

    protected MonitorRequest__c request;

    public interface Checkable {
        Boolean isFinished();
    }

    public abstract Checkable checkStatus();
    protected virtual void setContext(MonitorRequest__c request) {
        this.request = request;
    }
    
    public static AbstractActionChecker getInstance(MonitorRequest__c request) {

        if (mockedChecker != null) return mockedChecker;

        ActionConfig__mdt[] configs = [SELECT HandlerApexClass__c 
                                        FROM ActionConfig__mdt 
                                        WHERE ActionType__c = :request.ActionType__c];

        if (configs.isEmpty()) {
            throw new ActionCheckerException('No checker configured for action ' + request.ActionType__c);
        }

        Type checkerType = Type.forName(configs[0].HandlerApexClass__c);

        if (!AbstractActionChecker.class.isAssignableFrom(checkerType)) {
            throw new ActionCheckerException(configs[0].HandlerApexClass__c + ' must extend ' + AbstractActionChecker.class.getName());
        }

        AbstractActionChecker instance = (AbstractActionChecker)checkerType.newInstance();
        instance.setContext(request);

        return instance;
    }

    public class ActionCheckerException extends Exception {}
}