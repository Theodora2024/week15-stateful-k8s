# Week 15 Project: Stateful Applications, Network Policies and Troubleshooting

## 1. Project Overview

**Platform:** Amazon EKS  
**Region:** eu-west-2  
**Kubernetes namespace:** week15  
**Database:** PostgreSQL 16  
**Deployment type:** StatefulSet  
**Storage:** PersistentVolumeClaim (PVC) backed by Kubernetes persistent storage  
**Automation:** GitHub Actions with secure AWS authentication

### Objectives

- Deploy PostgreSQL as a stateful application.
- Provide persistent database storage.
- Validate database persistence across pod replacement.
- Demonstrate database backup and restoration.
- Restrict network access using Kubernetes NetworkPolicies.
- Apply pod and container security contexts.
- Troubleshoot deployment, connectivity and infrastructure issues.

## 2. Troubleshooting Findings

### Issue 1: Terraform state upload failed

**Symptom:** Terraform infrastructure creation encountered a temporary DNS resolution error when attempting to access the S3 backend endpoint.

**Root cause:** The S3 endpoint hostname could not be resolved during that operation.

**Resolution:** DNS resolution and S3 bucket access were checked. The infrastructure operation was subsequently resolved, and Terraform apply and the GitHub Actions pipeline completed successfully.

**Validation:** The user confirmed successful Terraform apply and pipeline execution.

### Issue 2: Authorized PostgreSQL connection initially failed

**Symptom:** The authorized test client reported `fe_sendauth: no password supplied`.

**Root cause:** The test command referenced `POSTGRES_PASSWORD`, but the test-client pod was configured with the Secret value under the environment variable `PGPASSWORD`.

**Resolution:** The connection command was corrected to use the pod's existing `PGPASSWORD` configuration.

**Validation:** The authorized client successfully connected to PostgreSQL and completed the connection test.

### Issue 3: Unauthorized PostgreSQL network access

**Objective:** Confirm that a client outside the permitted access rules could not connect to PostgreSQL.

**Investigation:** Kubernetes NetworkPolicies and client connectivity were tested.

**Resolution:** The configured NetworkPolicies were retained.

**Validation:** The authorized client succeeded and the unauthorized client produced the expected blocked result. This demonstrated the intended access restriction in the tested environment.

### Issue 4: Stateful application security

**Investigation:** The committed PostgreSQL StatefulSet manifest was compared with the running StatefulSet configuration.

**Resolution:** No changes were necessary because both configurations matched and contained the intended security settings.

**Validated settings:**

- `runAsNonRoot: true`
- `runAsUser: 999`
- `runAsGroup: 999`
- `fsGroup: 999`
- `seccompProfile.type: RuntimeDefault`
- `allowPrivilegeEscalation: false`
- Linux capabilities dropped with `drop: [ALL]`
- `automountServiceAccountToken: false`
- CPU and memory requests and limits configured

**Note:** `readOnlyRootFilesystem` remains `false` to avoid introducing writable-directory compatibility issues for PostgreSQL without further testing.

## 3. Storage, Persistence and Recovery

The PostgreSQL StatefulSet used a PersistentVolumeClaim for database storage.

The following validations were completed successfully, as confirmed during project testing:

- PostgreSQL became available and accepted database connections.
- Database data remained available after PostgreSQL pod replacement.
- A database backup was created.
- The backup was restored and the restored data was verified.

The PVC and its backing storage were retained during the persistence test.

## 4. Network Security

NetworkPolicies were configured to restrict database traffic.

Testing confirmed the intended difference between permitted and unpermitted clients:

| Test | Expected result | Result |
|---|---|---|
| Authorized client to PostgreSQL | Connection succeeds | Passed |
| Unauthorized client to PostgreSQL | Connection blocked | Passed |

The test results apply to the deployed cluster and its active network-policy enforcement configuration.

## 5. Corrective Actions and Lessons Learned

1. Verify environment variable names inside a test container before troubleshooting database credentials.
2. Confirm the actual NetworkPolicy selectors and pod labels when validating access restrictions.
3. Keep Kubernetes security settings in version-controlled manifests so they are reproducible.
4. Validate persistent storage and recovery rather than relying only on pod readiness.
5. Investigate DNS and backend access failures before assuming Terraform infrastructure creation failed completely.
6. Inspect Terraform state and the proposed destroy plan before removing infrastructure.
7. Keep credentials and Secret values out of reports, logs and public repositories.

## 6. Final Project Status

The user confirmed that the required deployment, persistence, backup/restore, network-access and security-context checks passed.

The Terraform apply and GitHub Actions pipeline also completed successfully.

**Core Week 15 deliverables:** Completed, subject to retaining the supporting evidence and final teardown verification.

**Optional Istio traffic-routing demonstration:** Not implemented; it was treated as optional.

## 7. Teardown

After collecting evidence, the AWS infrastructure will be destroyed through the Terraform-managed workflow.

Final teardown validation should confirm that the EKS cluster and intended billable resources have been removed. Any intentionally retained S3 Terraform state, backup files or other resources should be reviewed separately.

---
End of report.
