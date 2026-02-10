# mantle-terraform

Terraform framework plugin for mantle. Includes 4 specialized agents and 1 skill for Terraform code review, drift detection, security scanning, linting, and best practices.

## Components

### Agents

All agents are located in the `agents/review/` directory.

| Agent | Model | Description |
|-------|-------|-------------|
| terraform-reviewer | inherit | Quality standards reviewer for module composition, naming conventions, lifecycle rules, and Terraform best practices. Produces PASS/FAIL verdicts. |
| terraform-drift | inherit | Drift detector that compares `terraform plan` output against expected changes, identifies state conflicts, and flags resources changed outside of Terraform. |
| terraform-security | inherit | Security scanner that checks S3 buckets, security groups, IAM policies, encryption, logging, and network exposure. Suggests running tfsec and checkov. |
| terraform-lint | haiku | Lightweight linter that runs `terraform fmt -check`, `terraform validate`, and `tflint` to report formatting issues and validation errors. |

### Skills

| Skill | Description |
|-------|-------------|
| terraform-best-practices | Comprehensive reference for production-grade Terraform covering module design, state management, provider configuration, security hardening, and workspace strategies. |

#### Skill Reference Files

The `terraform-best-practices` skill includes detailed reference guides:

- **modules.md** - Module structure, inputs/outputs, nested modules, versioning, registry modules, and when to create a module
- **state.md** - Remote state backends (S3, GCS), state locking, state isolation per environment, terraform import, state mv/rm
- **providers.md** - Provider configuration, version constraints, multi-region deployments, aliases, and required_providers
- **security.md** - IAM best practices, encryption patterns, network security, secrets management, and compliance checking
- **workspaces.md** - Workspace strategies (per-environment vs per-component), workspace vs directory isolation, and CI/CD patterns

## Installation

Install via the mantle marketplace:

```bash
claude /plugin install mantle-terraform
```

## Usage

### Agents

```bash
# Run a quality review on your Terraform code
claude agent terraform-reviewer "Review my Terraform configuration"

# Check for infrastructure drift
claude agent terraform-drift "Analyze the terraform plan output"

# Scan for security issues
claude agent terraform-security "Scan this configuration for security problems"

# Lint Terraform files
claude agent terraform-lint "Check formatting and validation"
```

### Skills

```bash
# Access Terraform best practices
claude skill terraform-best-practices
```

## Requirements

- Terraform CLI installed (for lint and drift agents)
- Optional: tfsec, checkov, tflint, terrascan for extended security scanning
