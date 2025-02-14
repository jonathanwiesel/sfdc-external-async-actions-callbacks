public with sharing class ActionStatusChecker implements Queueable, Finalizer {
    
    private static final String REQUEST_STATUS_REQUESTED = 'Requested';
    private static final String REQUEST_STATUS_MONITORING = 'Monitoring';
    private static final String REQUEST_STATUS_COMPLETED = 'Completed';
    private static final String REQUEST_STATUS_ERROR = 'Error';

    private static final Set<String> PENDING_REQUEST_STATUS = new Set<String>{
        REQUEST_STATUS_REQUESTED,
        REQUEST_STATUS_MONITORING
    };

    private MonitorRequest__c request;
    private Boolean aborted;

    @InvocableMethod(label='Enqueue Action Status Check' description='Enqueue a job to check the status of an externally submitted acton' category='Action Monitor')
    public static void enqueue(MonitorRequest__c[] requests) {
        System.enqueueJob(new ActionStatusChecker(requests[0]), Integer.valueOf(requests[0].MonitorFrequency__c));
    }

    public ActionStatusChecker(MonitorRequest__c request) {
        this.request = request;
        this.aborted = false;
    }

    
    public void execute(QueueableContext ctx) {

        System.attachFinalizer(this);

        Integer inactiveCounter = [SELECT COUNT()
                                    FROM MonitorRequest__c 
                                    WHERE Id = :this.request.Id
                                    AND Status__c NOT IN :PENDING_REQUEST_STATUS];

        if (inactiveCounter > 0) {
            this.aborted = true;
            return;
        }

        this.request.Status__c = REQUEST_STATUS_MONITORING;

        AbstractActionChecker.Checkable checkResult = AbstractActionChecker.getInstance(this.request).checkStatus();

        if (checkResult.isFinished()) {

            this.request.Status__c = REQUEST_STATUS_COMPLETED;

            AbstractMonitorNotifier.getInstance(this.request).notify();
        }
    }


    public void execute(FinalizerContext ctx) {

        if (this.aborted) return;

        if (ctx.getResult() != ParentJobResult.SUCCESS) {
            this.request.Status__c = REQUEST_STATUS_ERROR;
            this.request.LastErrorDetail__c = ctx.getException().getMessage() + ' ' + ctx.getException().getStackTraceString();
        } else {
            this.request.LastErrorDetail__c = null;
        }

        this.request.LastActionCheckDate__c = Datetime.now();

        upsert this.request;
    }
}