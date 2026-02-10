# Architecture & Configuration Hierarchy

## Folder Structure

```
terraform/
├── root.hcl                    # Global Terragrunt config (provider, backend, common tags)
├── Makefile                    # Single Makefile with commands for all environments
├── modules/                    # Reusable, environment-agnostic modules
│   ├── alb/
│   ├── ecs-cluster/
│   ├── ecs-service/
│   ├── ecr-repository/
│   └── secrets/
└── environments/
    ├── dev/
    │   ├── env.hcl             # All dev-specific values
    │   ├── secrets.local.yaml  # Sensitive values (gitignored)
    │   ├── alb/
    │   ├── ecr/{service}/
    │   ├── ecs/{service}/
    │   └── secrets/{service}/
    └── prod/                   # Mirrors dev structure exactly
```

## Configuration Hierarchy

### root.hcl - Global Configuration
Defines settings shared across ALL environments:
- AWS provider version and configuration
- S3 backend for state (auto-generates `backend.tf`)
- Common resource tags (ManagedBy, Environment, Project)
- Account IDs and AWS profiles per environment

### env.hcl - Environment Configuration
Defines ALL environment-specific values:
- VPC, subnet IDs
- ACM certificate ARNs
- Service configuration (ports, CPU, memory)
- Environment variables (non-sensitive)
- References to secrets file

### secrets.local.yaml - Sensitive Values (gitignored)
Contains sensitive configuration loaded by env.hcl:
- Database credentials
- API keys
- Auth tokens

## Shared Infrastructure (per environment)

Each environment has ONE of each:
- **VPC** - Use `terraform-aws-modules/vpc/aws` for new environments
- **ECS Cluster** - Single cluster for all services
- **ALB** - Single ALB with multiple target groups and listener rules
- **ACM Certificate** - Single wildcard certificate

**Adding a new service to existing ALB:**
1. Add target group to `alb/terragrunt.hcl`
2. Add listener rule with path pattern
3. Reference target group from ECS service
