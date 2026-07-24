# AWS Production Infrastructure (Terraform)

Self-hosted AWS stack for the Marbiks ERP backend: ECS Fargate running the NestJS
Docker image behind an Application Load Balancer, and RDS PostgreSQL - no third-party
BaaS, entirely inside your own AWS account.

## Status: written and reference-checked, not yet applied

This configuration was authored and manually cross-checked (every module input/output
reference verified by hand) in a sandbox whose network policy blocks
`registry.terraform.io` — the Terraform provider registry — so `terraform init` /
`terraform validate` / `terraform plan` could not be run there. `terraform fmt` did
run successfully (real syntax check: it parses and reformats every file). **No AWS
resources have been created by this work** — there are no AWS credentials available in
that sandbox either. Before you `apply` this for real:

```bash
cd infra/aws
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars   # review carefully before applying
```

## Architecture

```
Internet
   │
   ▼
Application Load Balancer (public subnets, 2 AZs)
   │  HTTP :80 (or HTTPS :443 if you supply certificate_arn)
   ▼
ECS Fargate service "backend" (private subnets, 2 AZs, auto-scales on CPU)
   │  reads DB + JWT credentials from Secrets Manager (never plaintext)
   ▼
RDS PostgreSQL (private subnets only, Multi-AZ by default, not publicly reachable)
```

- `modules/network` — VPC, public/private subnets across 2 AZs, single NAT gateway
  (documented cost/availability tradeoff — see the comment in
  `modules/network/main.tf` for how to switch to one NAT per AZ).
- `modules/database` — RDS Postgres, a dedicated security group only allowing the
  ECS service in, and a Secrets Manager secret holding the connection details.
- `modules/backend_service` — ECR repo, ECS cluster/service/task definition, ALB +
  target group + listener(s), IAM roles scoped to exactly what's needed (pull image,
  write logs, read the two secrets), and CPU-based autoscaling.

## First-time setup

1. `cp terraform.tfvars.example terraform.tfvars` and fill in real values —
   `container_image` (build+push the backend image to ECR once by hand, see the
   comment in the example file) and `jwt_secret` (generate with `openssl rand -base64 48`).
   Never commit the real `terraform.tfvars` — it's gitignored.
2. `terraform init && terraform plan -var-file=terraform.tfvars` and review the plan.
3. `terraform apply -var-file=terraform.tfvars`.
4. Run the backend's migrations against the new RDS instance once (from a host that
   can reach the private subnet — a bastion, VPN, or a one-off ECS task — the DB is
   deliberately not publicly reachable): `npm run migration:run` with `DB_HOST` etc.
   pointed at the Secrets Manager values Terraform created.
5. Point your domain at the `alb_dns_name` output (or hit it directly to confirm the
   backend responds at `/api/v1/health`).

After that, `.github/workflows/deploy-backend.yml` (see the repo root) builds and
pushes a new image to ECR and updates the ECS service on every push to `main` — you
only do steps 1-3 once.

## What this deliberately does not include

- **DNS/ACM**: no Route53 zone or ACM certificate is created — supply your own
  `certificate_arn` once you have a domain, or run HTTP-only to start (fine for
  initial setup, not for real production traffic carrying customer data).
- **Terraform remote state backend**: this uses local state by default. Before more
  than one person runs `apply`, configure an S3 backend + DynamoDB lock table (a few
  lines in `versions.tf`'s `terraform {}` block) so state isn't only on one laptop.
- **Bastion/VPN for migrations**: step 4 above needs *some* way to reach the private
  subnet; this repo doesn't provision one. A one-off Fargate task running
  `npm run migration:run` (using the same task execution role and secrets) is the
  simplest option if you don't already have a bastion or VPN.
- **Franchise royalty, multi-region, disaster recovery** — out of scope for this pass;
  see `docs/PHASE_6.md`.
