# Module Design & Standards

## Always Use Community Modules

```hcl
# CORRECT - Use community module
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"
}

# WRONG - Custom resource implementation
resource "aws_lb" "this" { ... }
```

## Modules Must Be Environment-Agnostic

- No hardcoded account IDs, regions, or environment names
- All environment-specific values passed via `inputs` from terragrunt
- Modules define variables with sensible defaults

## Security Groups: Each Module Owns Its Own

```hcl
# ALB module creates its own SG
security_group_ingress_rules = { ... }

# ECS module references ALB SG via dependency
alb_security_group_id = dependency.alb.outputs.alb_security_group_id
```

Never cross-reference security groups - this causes circular dependencies.

## Tagging Standards

All resources must have consistent tags for cost allocation, ownership, and automation.

**Required tags (applied via root.hcl default_tags):**

| Tag | Purpose | Example |
|-----|---------|---------|
| `Environment` | Cost allocation, environment identification | `dev`, `prod` |
| `ManagedBy` | Identifies IaC-managed resources | `Terragrunt` |
| `Project` | Cost allocation by project | project name |

**Optional tags (applied per-resource as needed):**

| Tag | Purpose | Example |
|-----|---------|---------|
| `Service` | Identifies the service/application | `go-api`, `reporting-api` |
| `Owner` | Team or individual responsible | `backend-team` |
| `CostCenter` | Finance cost allocation | `engineering` |

**Implementation in root.hcl:**
```hcl
provider "aws" {
  default_tags {
    tags = {
      ManagedBy   = "Terragrunt"
      Environment = local.environment
      Project     = local.project_name
    }
  }
}
```

**Service-specific tags in modules:**
```hcl
tags = merge(var.tags, {
  Service = var.service_name
})
```

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| Circular dependency | Security groups reference each other | Each module creates own SG, reference via dependency |
| Module not found | Incorrect relative path | Check `source` path from environment dir to modules |
| Dependency output not found | Output name mismatch | Verify mock_outputs match actual module outputs |
| Target group not found | Key mismatch | Ensure `target_group_key` matches key in `target_groups` map |
