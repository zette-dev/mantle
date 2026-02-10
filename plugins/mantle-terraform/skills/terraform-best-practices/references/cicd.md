# CI/CD Integration (GitHub Actions)

All CI/CD runs through GitHub Actions. Terraform manages GitHub repository environments and secrets so that pipelines automatically have access to infrastructure outputs.

## GitHub Environments

Terraform creates GitHub repository environments (`dev`, `prod`) and populates them with secrets derived from infrastructure:

```hcl
module "github_environment" {
  source = "..."

  environment = "dev"
  secrets = {
    AWS_ACCOUNT_ID     = local.aws_account
    ECR_REPOSITORY_URL = dependency.ecr.outputs.repository_url
    ECS_CLUSTER_NAME   = dependency.cluster.outputs.cluster_name
    ECS_SERVICE_NAME   = dependency.ecs.outputs.service_name
    ALB_DNS_NAME       = dependency.alb.outputs.alb_dns_name
    DATABASE_URL       = dependency.rds.outputs.db_instance_endpoint
  }
}
```

**Benefits:**
- Single source of truth - infrastructure outputs flow directly to CI/CD
- Environment parity - same secret names across dev/prod, different values
- No manual secret management - Terraform keeps GitHub secrets in sync
- Immediate availability - deploy infrastructure once, CI/CD works everywhere

## Common GitHub Secrets (pushed by Terraform)

| Secret | Source | Used For |
|--------|--------|----------|
| `AWS_ACCOUNT_ID` | env.hcl | ECR login, resource ARNs |
| `AWS_REGION` | env.hcl | AWS CLI/SDK configuration |
| `ECR_REPOSITORY_URL` | ECR module output | Docker push destination |
| `ECS_CLUSTER_NAME` | ECS cluster output | Service deployment target |
| `ECS_SERVICE_NAME` | ECS service output | Force new deployment |
| `ALB_DNS_NAME` | ALB module output | Health check URLs |
| `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront output | Cache invalidation |

## Workflow Pattern

```yaml
# .github/workflows/deploy.yml
jobs:
  deploy:
    environment: ${{ github.ref == 'refs/heads/main' && 'prod' || 'dev' }}
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/github-actions

      - uses: aws-actions/amazon-ecr-login@v2

      - run: |
          docker build -t ${{ secrets.ECR_REPOSITORY_URL }}:${{ github.sha }} .
          docker push ${{ secrets.ECR_REPOSITORY_URL }}:${{ github.sha }}

      - run: |
          aws ecs update-service \
            --cluster ${{ secrets.ECS_CLUSTER_NAME }} \
            --service ${{ secrets.ECS_SERVICE_NAME }} \
            --force-new-deployment
```

## Secrets Derivation Pattern

Infrastructure resources often generate values that downstream resources need. Use Terraform dependencies to flow these values automatically.

**Common derivation chains:**
```
RDS -> Secrets Manager -> ECS Task Definition (DATABASE_URL)
ALB -> GitHub Secrets (ALB_DNS_NAME for health checks)
ECR -> GitHub Secrets (ECR_REPOSITORY_URL for docker push)
CloudFront -> GitHub Secrets (DISTRIBUTION_ID for cache invalidation)
```

**Key principle:** Never hardcode derived values. Always reference outputs from the resource that creates them.
