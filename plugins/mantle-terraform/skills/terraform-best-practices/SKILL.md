---
name: terraform-best-practices
description: Terraform and Terragrunt infrastructure standards covering module design, ECS/RDS/CloudFront patterns, security, CI/CD, and dependency ordering. This skill should be used when writing, reviewing, or planning Terraform/Terragrunt configurations and AWS infrastructure.
user-invocable: false
---

# Terraform & Terragrunt Best Practices

Standards and patterns for production-grade AWS infrastructure using Terraform and Terragrunt.

## Reference Files

Load the relevant reference based on the task at hand:

- [architecture.md](./references/architecture.md) - Folder structure, configuration hierarchy (root.hcl, env.hcl, secrets), and dependency ordering
- [services.md](./references/services.md) - ECS Fargate, RDS, S3+CloudFront, VPC patterns with security and IAM requirements
- [modules.md](./references/modules.md) - Module design principles, community modules, security groups, and tagging standards
- [cicd.md](./references/cicd.md) - GitHub Actions integration, secrets derivation, and deployment workflows

## Core Philosophy

1. **Community modules first** - Always use `terraform-aws-modules/*` for standard AWS resources
2. **Environment parity** - All environments implement identical components with different configurations
3. **Convention over configuration** - Standardized folder structure, Makefiles, and root.hcl patterns
4. **Least privilege security** - Minimal IAM permissions, security groups allow only required traffic
5. **Operational excellence** - Centralized logging, secrets management, observability built-in

## Quick Reference

### Technology Stack

| Layer | Technology |
|-------|------------|
| IaC | Terraform + Terragrunt |
| State | S3 backend with encryption |
| Modules | `terraform-aws-modules/*` community modules |
| Orchestration | Single Makefile with per-environment commands |

### Dependency Order

Resources must be deployed in order:
```
1. ECR Repositories
2. Secrets
3. ECS Cluster
4. ALB (with target groups)
5. ECS Services
```

Terragrunt handles this automatically via `dependency` blocks.

### Commands

```bash
make plan-dev       # Preview changes
make apply-dev      # Apply changes
make destroy-dev    # Destroy (with confirmation)
make validate       # Check formatting
make format         # Auto-format files
```
