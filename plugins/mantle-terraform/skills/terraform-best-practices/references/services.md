# Service Patterns

## API Services (ECS Fargate)

**Architecture:**
```
ALB -> Target Group -> ECS Service -> Container + Sidecar
```

**Required components:**
1. **ECR Repository** - Container image storage
2. **Secrets** - All sensitive config in Secrets Manager (individual keys per secret)
3. **ALB Target Group** - Registered with shared ALB
4. **ECS Service** - Fargate task with container + observability sidecar

**Logging:**
- All containers log to CloudWatch via `awslogs` driver
- Observability sidecar (OpenTelemetry Collector) forwards traces/metrics/logs

**Secrets pattern:**
```hcl
# secrets.local.yaml defines individual secrets
go_api_secret_values:
  DATABASE_URL: "postgres://..."
  AUTH0_CLIENT_SECRET: "..."
  DASH0_AUTH_TOKEN: "..."

# Secrets module creates JSON secret with all keys
# ECS task definition maps each key to env variable
secrets = dependency.secrets.outputs.secret_key_arns
```

**Security groups:**
- ECS service SG allows inbound ONLY from ALB SG on container port
- ECS service SG allows all outbound (required for AWS APIs, external services)

**IAM permissions (common access requirements):**

When creating an ECS service, always ask what AWS services the API needs access to. Common permissions:

| Service | Use Case | IAM Actions |
|---------|----------|-------------|
| Secrets Manager | App secrets (always required) | `secretsmanager:GetSecretValue`, `secretsmanager:DescribeSecret` |
| KMS | Decrypt secrets (always required) | `kms:Decrypt` (scoped to secretsmanager via condition) |
| S3 | File storage, PDF generation | `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, `s3:ListBucket` |
| SNS | Cross-service messaging | `sns:Publish`, `sns:ListTopics` |
| SQS | Async task processing | `sqs:SendMessage`, `sqs:ReceiveMessage`, `sqs:DeleteMessage`, `sqs:GetQueueUrl` |
| EFS | Shared file system | `elasticfilesystem:ClientMount`, `elasticfilesystem:ClientWrite` |
| RDS | Relational database | Connection via security group (no IAM actions needed for standard auth) |
| SES | Email sending | `ses:SendEmail`, `ses:SendRawEmail` |

The ECS service module accepts these as inputs:
- `secrets_arns` - Secrets Manager ARNs (required)
- `s3_bucket_name` - Grants S3 access to specified bucket
- `sns_topic_arns` - Grants SNS publish access
- `sqs_queue_arns` - Grants SQS access
- `efs_volumes` - Grants EFS mount access
- `task_role_policy_arns` - Additional managed policies

## Databases (RDS)

**Use community module:** `terraform-aws-modules/rds/aws`

**Required security settings:**
- `publicly_accessible = false` - Database must be in private subnets only
- `storage_encrypted = true` - Always encrypt at rest using KMS
- `deletion_protection = true` - Prevent accidental deletion (disable only for teardown)
- `multi_az = true` - Required for production, optional for dev
- `backup_retention_period = 7` - Minimum 7 days, 30+ for production
- `enabled_cloudwatch_logs_exports` - Enable audit, error, and slowquery logs
- `performance_insights_enabled = true` - Enable Performance Insights

**Security group:**
- Allow inbound on database port (5432/3306) ONLY from ECS service security groups
- No public access, no broad CIDR ranges

**Secrets derivation pattern:**
```hcl
# RDS module outputs
output "db_instance_endpoint" { value = module.rds.db_instance_endpoint }
output "db_instance_username" { value = module.rds.db_instance_username }
output "db_instance_password" { value = module.rds.db_instance_password }

# Secrets module references RDS outputs
dependency "rds" {
  config_path = "../../rds"
}

inputs = {
  secret_values = {
    DATABASE_URL = "postgres://${dependency.rds.outputs.db_instance_username}:${dependency.rds.outputs.db_instance_password}@${dependency.rds.outputs.db_instance_endpoint}/mydb"
  }
}
```

## Web Applications (S3 + CloudFront)

**Architecture:**
```
CloudFront -> S3 Bucket (website hosting)
```

**Required components:**
1. **S3 Bucket** - Static website hosting enabled
2. **CloudFront Distribution** - HTTPS termination, caching, custom domain
3. **ACM Certificate** - In us-east-1 (required for CloudFront)
4. **Route53 Record** - Points to CloudFront

## Observability (Sentry)

**Use Sentry Terraform provider:** `jianyuan/sentry`

**Per-service Sentry project:**
```hcl
resource "sentry_project" "api" {
  organization = data.sentry_organization.main.id
  teams        = [sentry_team.backend.id]
  name         = "go-api-${var.environment}"
  slug         = "go-api-${var.environment}"
  platform     = "python-fastapi"
}

data "sentry_key" "api" {
  organization = data.sentry_organization.main.id
  project      = sentry_project.api.id
}

output "sentry_dsn" {
  value     = data.sentry_key.api.dsn_public
  sensitive = true
}
```

**Recommended settings:**
- One Sentry project per service per environment (e.g., `go-api-dev`, `go-api-prod`)
- Configure issue alerts via `sentry_issue_alert` resource
- Configure metric alerts via `sentry_metric_alert` resource

## VPC & Networking

**Use community module:** `terraform-aws-modules/vpc/aws`

**Standard subnet layout:**
- 2+ Availability Zones for high availability
- **Public subnets** - ALBs, NAT Gateways, bastion hosts
- **Private subnets** - ECS services, RDS, ElastiCache, OpenSearch
- **Database subnets** (optional) - Isolated subnet group for RDS

**Required settings:**
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = var.environment == "dev"  # Cost savings for dev
  one_nat_gateway_per_az = var.environment == "prod" # HA for prod

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
}
```
