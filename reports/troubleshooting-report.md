# Week 15 Troubleshooting Report

## Project and environment

- Project: Week 15 Stateful Applications and Network Policies
- Target: Amazon EKS
- AWS region: eu-west-2
- Namespace: week15
- Date of testing:
- Kubernetes version:
- Git commit:
- Tester:

## Status

Preparation only. No deployment or runtime validation is recorded until
the corresponding tests are performed against EKS.

## Issue log

For every issue, create a separate entry using this template.

### Issue [number]: [short description]

**Expected behavior:**

**Observed symptom:**

**Impact:**

**Commands and evidence collected:**

```text
Paste actual command output here. Remove passwords, tokens, and sensitive data.
```

**Root cause:**  
Complete only after evidence identifies the cause.

**Resolution:**  
Record the exact change or command that resolved the issue.

**Verification:**  
Record the test performed and its actual result.

**Status:** Not tested / Investigating / Resolved / Unresolved

## Required validation checklist

- [ ] EKS cluster and worker nodes are healthy.
- [ ] EBS CSI driver and intended StorageClass are available.
- [ ] PostgreSQL PVC is Bound.
- [ ] PostgreSQL StatefulSet rollout succeeds.
- [ ] PostgreSQL readiness and SQL health checks pass.
- [ ] Data persists after deleting and recreating the PostgreSQL pod.
- [ ] Authorized client can connect to PostgreSQL.
- [ ] Unauthorized client is blocked by enforced network policy.
- [ ] DNS continues to work where required.
- [ ] Container security settings are accepted and verified.
- [ ] SQL backup is generated and is non-empty.
- [ ] Backup is restored into healthcare_restore.
- [ ] Restored database contents are verified.

## Backup and recovery evidence

- Backup filename:
- Backup size:
- Backup date/time:
- Restore date/time:
- Tables or records verified:
- Recovery result:

## Final outcome

**Completed deliverables:**

**Outstanding issues:**

**Lessons learned:**

**Evidence references:**
