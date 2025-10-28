# DevOps Lab - Production Infrastructure

## Application
- **Source**: https://github.com/loizenai/reactjs-nodejs-postgresql-example
- **Frontend**: React.js (SPA)
- **Backend**: Node.js + Express (REST API)
- **Database**: PostgreSQL (Customer management CRUD)

## Infrastructure
- **Region**: ap-south-1 (Mumbai)
- **Compute**: ECS Fargate
- **Network**: VPC with multi-AZ
- **Database**: RDS PostgreSQL Multi-AZ
- **Storage**: S3, ECR
- **Secrets**: Secrets Manager + KMS

## DevOps Tools
- **IaC**: Terraform v1.6.5
- **Containers**: Docker v28.2.2
- **CI/CD**: CircleCI
- **Monitoring**: Datadog + OpenTelemetry
- **VCS**: Git v2.34.1

## Terraform Backend
- **S3 Bucket**: devops-lab-tfstate-1761635567
- **DynamoDB**: devops-lab-tf-lock
- **Account**: 338658064058
- **Instance**: i-0cb48eab4210c138a

## Project Phases
- [x] Phase 0: Foundation ✅
- [ ] Phase 1: Network Infrastructure
- [ ] Phase 2: Application & GitHub
- [ ] Phase 3: Docker Containerization
- [ ] Phase 4: Secrets Management
- [ ] Phase 5: Database (RDS)
- [ ] Phase 6: ECS Deployment
- [ ] Phase 7: Monitoring
- [ ] Phase 8: CI/CD Pipeline
- [ ] Phase 9: Kubernetes (Optional)
- [ ] Phase 10: Documentation

Created: 2025-10-28
Region: ap-south-1
