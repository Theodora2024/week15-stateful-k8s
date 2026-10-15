# Week 15: Stateful Applications, Network Policies and Troubleshooting

## Project status

**Preparation stage:** manifests and automation are being prepared.
AWS infrastructure has been destroyed and will be recreated only after
configuration review. No EKS deployment or runtime test is claimed yet.

## Objectives

- Deploy PostgreSQL as a Kubernetes StatefulSet.
- Persist database data using a PersistentVolumeClaim.
- Prepare database backup and restore procedures.
- Restrict network traffic using Kubernetes NetworkPolicies.
- Apply Pod Security Standards and container security contexts.
- Automate deployment to Amazon EKS through GitHub Actions and AWS OIDC.
- Document troubleshooting findings and validation evidence.

## Architecture

- AWS region: eu-west-2
- Kubernetes namespace: week15
- Database: PostgreSQL 16
- Workload: one-replica StatefulSet named postgres
- Service: headless Service named postgres
- Storage: 2Gi PersistentVolumeClaim named postgres-data
- Database: healthcare
- Database user: healthcare
- Deployment workflow: .github/workflows/postgres-Apply.yml

The final storage class and NetworkPolicy enforcement capability must be
confirmed against the recreated EKS infrastructure.

## Repository layout

- k8s/namespace.yaml: namespace and Pod Security labels
- k8s/database/: PostgreSQL StatefulSet and Service
- k8s/storage/: persistent volume claim
- k8s/network/: default-deny and permitted traffic policies
- k8s/security/: security documentation or additional security manifests
- scripts/backup.ps1: create a SQL backup from the running database
- scripts/restore.ps1: restore a backup into a separate test database
- backups/: local database backup output
- reports/troubleshooting-report.md: troubleshooting evidence
- .github/workflows/postgres-Apply.yml: EKS deployment workflow

## Security

- Never commit database passwords or live credentials.
- Store POSTGRES_PASSWORD as a GitHub Actions secret.
- Use GitHub OIDC to obtain temporary AWS credentials.
- Restrict the deployment IAM role to the required resources and actions.
- Run containers as non-root with a RuntimeDefault seccomp profile.
- Disable privilege escalation and drop Linux capabilities.
- Apply default-deny network policies and explicitly allow required traffic.
- Confirm that the EKS network implementation enforces NetworkPolicies.
- Keep backups out of public repositories if they contain sensitive data.

## Deployment sequence

1. Review manifests and the GitHub Actions workflow.
2. Review Terraform configuration, IAM/OIDC and estimated AWS costs.
3. Configure the GitHub repository, environment and required secrets.
4. Run Terraform plan and inspect the proposed infrastructure changes.
5. Apply Terraform when the infrastructure is approved.
6. Confirm EKS nodes, EBS CSI driver and storage classes.
7. Run postgres-Apply.yml manually from GitHub Actions.
8. Verify the PVC, StatefulSet, database health and network restrictions.
9. Test persistence, backup and restore.
10. Record actual results and troubleshooting evidence.

Do not run the deployment workflow before the EKS cluster and required
AWS authentication configuration exist.

## Backup and restore

Run the PowerShell backup script only after PostgreSQL is healthy.
The script creates a timestamped SQL dump in backups/.

The restore script recreates a dedicated healthcare_restore database
and imports a selected backup into it. Do not point this procedure at
the production healthcare database.

A successful script exit is not sufficient proof of recoverability:
validate the restored database and record the evidence in the report.

## Validation evidence

Record the actual results of:
- EKS node readiness
- PVC binding and StatefulSet rollout
- SQL health check
- Data persistence after PostgreSQL pod replacement
- Authorized and unauthorized network connection tests
- Backup file creation and restore verification
- Pod security and NetworkPolicy enforcement

## Cost control

EKS, EC2 worker nodes, EBS volumes, load balancers and related services
can incur charges. Review the Terraform plan before applying and clean
up resources when the project is complete, while preserving any evidence
and backups that need to be retained.
