# mantle-terraform

Terraform framework plugin for mantle. Provides a best-practices skill for production-grade AWS infrastructure with Terraform and Terragrunt.

## Components

| Type | Count | Description |
|------|-------|-------------|
| Skills | 1 | Terraform best practices reference with 4 reference files |

## Skills

### terraform-best-practices

A background reference skill (auto-loaded by Claude when working with Terraform/Terragrunt) covering infrastructure standards across four areas:

| Reference | Topics |
|-----------|--------|
| [architecture.md](skills/terraform-best-practices/references/architecture.md) | Folder structure, configuration hierarchy (root.hcl, env.hcl, secrets), shared infrastructure |
| [services.md](skills/terraform-best-practices/references/services.md) | ECS Fargate, RDS, S3+CloudFront, VPC, Sentry patterns with security and IAM |
| [modules.md](skills/terraform-best-practices/references/modules.md) | Community modules, environment-agnostic design, security groups, tagging standards |
| [cicd.md](skills/terraform-best-practices/references/cicd.md) | GitHub Actions, Terraform-managed secrets, deployment workflows, derivation chains |

## Installation

Install via the mantle marketplace:

```bash
claude /install-plugin mantle-terraform
```

## How It Works

The skill has `user-invocable: false` set, meaning Claude loads it automatically when working on Terraform/Terragrunt configurations. The skill description is always in context, and Claude reads the relevant reference files on demand based on the task.

## Requirements

- Terraform CLI installed
- Terragrunt CLI installed

## Author

Nate Frechette (nate@zette.dev)
https://github.com/natefrechette
