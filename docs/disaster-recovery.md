# Disaster Recovery Plan

## Overview

This document outlines the disaster recovery (DR) procedures for the Azure infrastructure managed by Terraform.

## Recovery Objectives

- **RTO (Recovery Time Objective)**: 4 hours
- **RPO (Recovery Point Objective)**: 1 hour
- **Data Loss Tolerance**: Minimal (< 5 minutes for critical data)

## Risk Assessment

### High-Impact Scenarios
1. Complete Azure region failure
2. Accidental deletion of critical resources
3. State file corruption or loss
4. Security breach requiring infrastructure rebuild
5. Ransomware attack
6. Configuration drift causing system instability

## Backup Strategy

### Terraform State Backups
**Location**: Azure Storage with versioning enabled
**Frequency**: Automatic on every state change
**Retention**: 90 days

```bash
# List all state versions
az storage blob list \
  --account-name <storage-account> \
  --container-name tfstate \
  --prefix <layer>-<env>.tfstate

# Download specific version
az storage blob download \
  --account-name <storage-account> \
  --container-name tfstate \
  --name <layer>-<env>.tfstate \
  --version-id <version-id> \
  --file terraform.tfstate.backup
```

### Resource-Level Backups

#### Database Backups
- **Azure SQL**: Automated backups with 7-day retention (dev) to 35-day (prod)
- **Cosmos DB**: Continuous backup mode with 30-day retention
- **PostgreSQL/MySQL**: Automated backups with PITR capability

#### Storage Backups
- **Blob Storage**: Soft delete enabled (14-day retention)
- **File Shares**: Azure Backup with daily snapshots
- **Disk Snapshots**: Weekly snapshots of critical VMs

#### AKS Backups
- **etcd backups**: Automated daily backups
- **Persistent Volumes**: Velero backup solution
- **Configuration**: GitOps repository (source of truth)

## Recovery Procedures

### Scenario 1: Region Failure

**Detection**: Azure Service Health alerts, monitoring dashboards

**Recovery Steps**:

1. **Assess Impact**
```bash
# Check service health
az monitor activity-log list \
  --resource-group <rg> \
  --offset 1h
```

2. **Activate DR Region**
```bash
# Switch to DR environment
cd layers/networking/environments/prod-dr

# Initialize and deploy
terraform init -backend-config=backend.conf
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

3. **Restore Data**
```bash
# Restore databases from geo-redundant backups
az sql db restore \
  --dest-name <db-name> \
  --server <dr-server> \
  --resource-group <dr-rg> \
  --time "2025-10-05T00:00:00Z"

# Restore storage accounts
az storage blob copy start-batch \
  --source-account-name <source> \
  --destination-container <dest> \
  --account-name <dr-storage>
```

4. **Update DNS**
```bash
# Update DNS to point to DR region
terraform apply -target=module.dns -var-file=terraform-dr.tfvars
```

5. **Verify Services**
- Run smoke tests
- Check application health endpoints
- Verify data integrity
- Monitor for errors

**Estimated Time**: 2-4 hours

---

### Scenario 2: Accidental Resource Deletion

**Detection**: Azure Activity Log, monitoring alerts

**Recovery Steps**:

1. **Identify Deleted Resources**
```bash
# Check activity log
az monitor activity-log list \
  --resource-group <rg> \
  --offset 24h \
  --query "[?operationName.value=='Microsoft.Resources/resourceGroups/delete']"
```

2. **Restore from Terraform State**
```bash
# If resources deleted but state intact
terraform plan -refresh=false
terraform apply -target=<deleted-resource>
```

3. **Restore from Previous State Version**
```bash
# Download previous state
az storage blob download \
  --account-name <sa> \
  --container-name tfstate \
  --name <layer>-<env>.tfstate \
  --version-id <version-before-deletion> \
  --file terraform.tfstate.restored

# Replace current state (backup first!)
terraform state push terraform.tfstate.restored

# Apply to recreate resources
terraform apply
```

4. **Restore Data**
```bash
# Restore database from backup
az sql db restore \
  --dest-name <db-name> \
  --resource-group <rg> \
  --server <server> \
  --time <point-in-time>

# Restore blob storage
az storage blob restore \
  --account-name <sa> \
  --time-to-restore <timestamp> \
  --blob-range <container>/<blob-prefix>
```

**Estimated Time**: 1-2 hours

---

### Scenario 3: State File Corruption

**Detection**: Terraform errors, state inconsistencies

**Recovery Steps**:

1. **Verify Corruption**
```bash
# Try to pull state
terraform state pull

# Check for JSON errors
terraform state pull | jq .
```

2. **Restore from Azure Storage Version**
```bash
# List versions
az storage blob list \
  --account-name <sa> \
  --container-name tfstate \
  --prefix <layer>-<env>.tfstate

# Download working version
az storage blob download \
  --version-id <working-version-id> \
  --name <layer>-<env>.tfstate \
  --container-name tfstate \
  --account-name <sa> \
  --file terraform.tfstate.working

# Push to remote backend
terraform state push terraform.tfstate.working
```

3. **Verify State**
```bash
# Refresh state with actual resources
terraform refresh

# Verify no drift
terraform plan
```

**Estimated Time**: 30 minutes - 1 hour

---

### Scenario 4: Complete Infrastructure Loss

**Detection**: Multiple service failures, region outage

**Recovery Steps**:

1. **Initialize New Environment**
```bash
# Create new backend storage if needed
./scripts/setup-backend.sh

# Clone repository
git clone <repository-url>
cd terraform-azure-enterprise
```

2. **Deploy in Order** (follow deployment-guide.md)
```bash
# 1. Networking layer
cd layers/networking/environments/prod
terraform init -backend-config=backend.conf
terraform apply -var-file=terraform.tfvars

# 2. Security layer
cd ../../security/environments/prod
terraform init -backend-config=backend.conf
terraform apply -var-file=terraform.tfvars

# 3. Database layer
cd ../../database/environments/prod
terraform init -backend-config=backend.conf
terraform apply -var-file=terraform.tfvars

# 4. Storage layer
cd ../../storage/environments/prod
terraform init -backend-config=backend.conf
terraform apply -var-file=terraform.tfvars

# 5. Compute layer
cd ../../compute/environments/prod
terraform init -backend-config=backend.conf
terraform apply -var-file=terraform.tfvars

# 6. DNS layer
cd ../../dns/environments/prod
terraform init -backend-config=backend.conf
terraform apply -var-file=terraform.tfvars

# 7. Monitoring layer
cd ../../monitoring/environments/prod
terraform init -backend-config=backend.conf
terraform apply -var-file=terraform.tfvars
```

3. **Restore Data**
- Restore databases from geo-redundant backups
- Restore storage accounts from replication
- Redeploy applications from CI/CD
- Restore AKS workloads from GitOps

4. **Verify and Test**
- Run integration tests
- Perform manual verification
- Check monitoring dashboards
- Verify business continuity

**Estimated Time**: 6-8 hours

---

## Data Recovery Matrix

| Data Type | Backup Method | Retention | Recovery Time | RPO |
|-----------|--------------|-----------|---------------|-----|
| Terraform State | Azure Storage Versioning | 90 days | < 5 min | Real-time |
| SQL Databases | Automated Backups | 35 days | 10-30 min | 5 min |
| Cosmos DB | Continuous Backup | 30 days | 15-45 min | 5 min |
| Blob Storage | Soft Delete + Versioning | 14 days | 5-15 min | Real-time |
| File Shares | Azure Backup | 180 days | 30-60 min | 24 hours |
| VM Disks | Snapshots | 30 days | 20-40 min | 7 days |
| AKS PVs | Velero | 30 days | 10-30 min | 12 hours |
| Application Code | Git Repository | Indefinite | < 5 min | Real-time |

## Testing and Validation

### Quarterly DR Drills

**Schedule**: First Saturday of each quarter

**Procedure**:
1. Notify all stakeholders
2. Execute recovery procedures in DR environment
3. Document time to recovery
4. Identify issues and improvement areas
5. Update DR plan based on findings

### Testing Checklist
- [ ] State file restoration
- [ ] Database PITR restore
- [ ] Cross-region failover
- [ ] DNS failover
- [ ] Application functionality
- [ ] Data integrity verification
- [ ] Monitoring and alerting
- [ ] Team communication

## Communication Plan

### Incident Roles
- **Incident Commander**: Overall coordination
- **Technical Lead**: Terraform operations
- **Database Administrator**: Data restoration
- **Network Engineer**: Network and DNS changes
- **Security Lead**: Security validation
- **Communications Lead**: Stakeholder updates

### Communication Channels
1. **War Room**: Microsoft Teams channel
2. **Status Page**: Internal status dashboard
3. **Email**: Executive updates
4. **Slack**: Real-time team coordination

### Notification Templates

#### Initial Notification
```
SUBJECT: [P1] Disaster Recovery Activation - <Incident>

We are activating disaster recovery procedures due to <reason>.

Estimated Impact: <affected services>
Estimated Recovery Time: <RTO>
Next Update: <time>

Incident Commander: <name>
```

#### Progress Update
```
SUBJECT: [P1] DR Update #<n> - <Incident>

Current Status: <status>
Completed Steps: <list>
In Progress: <list>
Next Steps: <list>
Revised ETA: <time>
```

#### Resolution Notice
```
SUBJECT: [RESOLVED] DR Complete - <Incident>

Services Restored: <list>
Actual Recovery Time: <time>
Root Cause: <summary>
Follow-up Actions: <list>
Post-Incident Review: <date/time>
```

## Post-Incident Procedures

### Immediate (Within 24 hours)
1. Document timeline of events
2. Collect all logs and evidence
3. Verify all services restored
4. Communicate resolution to stakeholders

### Short-term (Within 1 week)
1. Conduct post-incident review
2. Update DR documentation
3. Identify process improvements
4. Train team on lessons learned

### Long-term (Within 1 month)
1. Implement process improvements
2. Update automation scripts
3. Conduct DR training refresher
4. Review and update RTO/RPO targets

## Maintenance and Updates

### Monthly
- Review backup retention policies
- Verify backup completion
- Test state file restoration

### Quarterly
- Full DR drill
- Update DR documentation
- Review and update RTO/RPO
- Train new team members

### Annually
- Complete infrastructure review
- Third-party DR audit
- Update disaster scenarios
- Review insurance and contracts

## Tools and Resources

### Required Tools
- Azure CLI
- Terraform CLI
- Git
- Access to Azure Portal
- Access to state storage account

### Documentation Links
- [Architecture Documentation](./architecture.md)
- [Deployment Guide](./deployment-guide.md)
- [Troubleshooting Guide](./troubleshooting.md)
- Azure Service Health Dashboard
- Internal Runbooks

### Contact Information
- **Platform Team Lead**: platform-lead@company.com
- **On-Call SRE**: +1-XXX-XXX-XXXX
- **Azure Support**: 1-800-XXX-XXXX
- **Security Team**: security@company.com

## Compliance and Audit

### Required Records
- DR test results (quarterly)
- Actual incident reports
- RTO/RPO metrics
- Recovery procedures documentation
- Team training records

### Audit Trail
All DR activities must be logged:
- Commands executed
- Time stamps
- Personnel involved
- Decisions made
- Outcomes

### Compliance Requirements
- SOC 2 Type II
- ISO 27001
- Industry-specific requirements

---

**Document Version**: 1.0
**Last Updated**: 2025-10-05
**Next Review**: 2026-01-05
**Owner**: Platform Engineering Team
