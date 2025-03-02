# External Async Actions Callbacks

The following represents an implementation approach of the so-called delegated polling of platform async actions.

This is further detailed in the TDX '25 session **Optimize CI/CD Pipeline Resource with Deployment Callbacks** (link coming soon). 
It expands on the principle of delegating polling mechanics to an external system that is not the pipeline itself to free the runners from hogging.

As a summary, a Github Action will trigger a deployment to Salesforce asynchronously, create a pending check run and submit a new Monitor Request entry to Salesforce which will monitor when the deployment is finished and then trigger back a repository dispatch which will update the check run with its corresponding result.

Currently limited to non scratch org development (due to difficulty to make the monitor functionality available in scratch orgs).

## Resources

- [IdeaExchange idea to push forward on having a native callback](https://ideas.salesforce.com/s/idea/a0B8W00000H3VbTUAV/support-for-deployment-callbacks)
- [AWS-based Delegated Polling Initial Solution](https://github.com/jonathanwiesel/sfdc-deploy-checker)
- [Webhook Data Action Targets in Data Cloud](https://developer.salesforce.com/docs/atlas.en-us.c360a_api.meta/c360a_api/c360a_api_webhook_data_action_targets_in_customer_data_platform.htm)
- [Apex-based DeployCallback Interface](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_interface_Metadata_DeployCallback.htm)
- [Scratch Org Snapshots](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_snapshots_intro.htm)
- [GitHub Status Checks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/about-status-checks)
- [GitHub Repository Dispatch](https://docs.github.com/en/webhooks/webhook-events-and-payloads#repository_dispatch)
- [GitHub Check Runs API](https://docs.github.com/en/rest/checks/runs?apiVersion=2022-11-28)
- [GitLab External Deployment Tracking](https://docs.gitlab.com/ci/environments/external_deployment_tools/)

## Setup

### Github

-   Generate a personal access token
    -   Login to Github and go to Settings > Developer settings > Personal Access Tokens
    -   In case is a fine-grained token, ensure it has the following repo permissions for the repos you need
        -   Content: Read/Write
        -   Metadata: Read
-   Configure repo secrets
    -   Navigate to your repo > Settings > Secrets and variables > Actions > Secrets > New repository Secret
    -   Name it `SFDX_INTEGRATION_URL`
    -   Execute the following to get the `sfdxAuthUrl` and paste it as the secret value
    -   `sf org display --target-org my-org --verbose --json`

### Salesforce

-   Push source to org that will be "monitored"
-   Assign permset
-   Configure external credential
    -   Edit the principal and add an authentication parameter
        -   Name = `PersonalAccessToken`
        -   Value = `<the access token you created earlier>`

## Pieces

Description of the different parts of the architecture used to achieve the desired output

### Objects

#### Monitor Request

Represents an asynchronous action that desires to be monitored.

### Flows

#### ActionStatusCheckerScheduler

Handles the automatic triggering of the `ActionStatusChecker` class upon a `Monitor Request` creation or change of monitoring timestamp.

### Custom Metadata Types

#### Action Config

Represents an action type that can be monitored and the handler class that posesses the monitoring implementation. The handler must be a subclass of the `AbstractActionChecker` class.

#### Notifier Config

Represents a provider to which the notification of a monitored action will be sent when the monitor identifies the action as finished. The handler must be a subclass of the `AbstractMonitorNotifier` class.

### Classes

#### ActionStatusChecker

Orchestrates the logic of instantiating the corresponding `AbstractActionChecker` and `AbstractMonitorNotifier` subclassess based on the context `Monitor Request` record, trigger the checker and in case it determines that status is completed trigger the notifier.

#### AbstractActionChecker

Takes care of implementing the checking of a particular action and determining if said action is categorized as finished. 

The current `APIChecker` class (and its corresponding `DeploymentChecker` subclass) are examples of its implementation.

#### AbstractMonitorNotifier

Takes care of implementing the notifying of a completed action back to the provider that requested its monitoring. 

The current `GithubActionStatusNotifier` class is an example of its implementation.