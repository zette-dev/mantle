# Changelog

All notable changes to the mantle-terraform plugin will be documented in this file.

## [1.0.0] - 2026-02-08

### Added

- **terraform-reviewer** agent: Quality standards reviewer covering module composition, naming conventions, lifecycle rules, dynamic blocks, provider aliasing, and backend configuration. Produces PASS/FAIL verdicts with severity levels.
- **terraform-drift** agent: Drift detector that analyzes `terraform plan` output, identifies resources changed outside of Terraform, detects state file conflicts, and validates plan matches PR intent.
- **terraform-security** agent: Security scanner checking S3 buckets, security groups, IAM policies, encryption at rest and in transit, logging, network exposure, and secrets in variables. Recommends tfsec and checkov.
- **terraform-lint** agent: Lightweight linter (haiku model) running `terraform fmt -check`, `terraform validate`, and `tflint`.
- **terraform-best-practices** skill: Comprehensive reference with core principles (DRY with modules, state isolation, least privilege, immutable infrastructure, plan before apply) and detailed reference guides.
- Reference guides for modules, state management, providers, security, and workspaces.
