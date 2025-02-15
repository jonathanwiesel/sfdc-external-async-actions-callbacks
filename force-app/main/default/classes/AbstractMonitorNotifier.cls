public with sharing abstract class AbstractMonitorNotifier {
    
    @TestVisible
    private static AbstractMonitorNotifier mockedNotifier;

    protected MonitorRequest__c request;
    protected NotifierConfig__mdt config;

    public abstract void notify();
    
    protected virtual void setContext(MonitorRequest__c request, NotifierConfig__mdt config) {
        this.request = request;
        this.config = config;
    }

    public static AbstractMonitorNotifier getInstance(MonitorRequest__c request) {

        if (mockedNotifier != null) return mockedNotifier;

        NotifierConfig__mdt[] configs = [SELECT HandlerApexClass__c, NamedCredential__c
                                            FROM NotifierConfig__mdt 
                                            WHERE Provider__c = :request.Provider__c];

        if (configs.isEmpty()) {
            throw new MonitorNotifierException('No notifier configured for provider ' + request.Provider__c);
        }

        Type notifierType = Type.forName(configs[0].HandlerApexClass__c);

        if (!AbstractMonitorNotifier.class.isAssignableFrom(notifierType)) {
            throw new MonitorNotifierException(configs[0].HandlerApexClass__c + ' must extend ' + AbstractMonitorNotifier.class.getName());
        }

        AbstractMonitorNotifier instance = (AbstractMonitorNotifier)notifierType.newInstance();
        instance.setContext(request, configs[0]);

        return instance;
    }

    public class MonitorNotifierException extends Exception {}
}