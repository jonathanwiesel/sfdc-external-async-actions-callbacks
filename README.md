# External Async Actions Callbacks

TODO: lorem ipsum

Currently limited to org-driven development (due to difficulty to make the monitor functionality available in scratch orgs)

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
