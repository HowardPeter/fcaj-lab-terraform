# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Terraform implementations of the AWS Study Group "First Cloud AI Journey" (FCAJ) labs (https://cloudjourney.awsstudygroup.com/). Each top-level directory is one lab: a fully independent Terraform root module, with no shared modules between labs. READMEs and code comments are written in Vietnamese, so keep new docs and comments in Vietnamese to match.

Layout of each lab: `<lab>/README.md` (goals, architecture, services) plus `<lab>/terraform/`, which holds the `.tf` files. Architecture diagrams live in the shared `docs/` directory and are referenced from the READMEs as `../docs/<name>.png`.

## Commands

Run everything from inside a lab's `terraform/` directory. There is no build, lint or test tooling beyond Terraform itself.

```bash
cd <lab>/terraform
terraform init            # S3 backend; needs AWS credentials with access to the state bucket
terraform fmt             # formatting
terraform validate
terraform plan  -var="my_ip=<your-ip>/32"
terraform apply -var="my_ip=<your-ip>/32"
terraform destroy         # labs are meant to be torn down after use
```

`my_ip` (used by `amazon_rds` and `ec2-auto-scaling`) has no default. Pass it with `-var` or put it in a `*.tfvars` file; `*.tfvars` and `.terraform` are gitignored.

## Conventions shared across labs

- `backend.tf` holds the `terraform` block (Terraform `>= 1.6.0`, `hashicorp/aws ~> 6.49`), the S3 backend and the provider. Every lab uses the same state bucket `fcaj-lab-tf-state-430118860011-ap-southeast-1-an` with its own `key`, and region `ap-southeast-1`. When you add a lab, copy this file and give it a new unique `key`.
- `lightsail` also uses the `hashicorp/awscc` provider, because `awscc_lightsail_alarm` (CPU burst alarms) has no equivalent in the `aws` provider.
- Lab-only teardown settings are intentional: `skip_final_snapshot = true` on databases and `delete_on_termination` on volumes.
- EC2 key pairs read `~/.ssh/ec2-lab-key.pub` from the local machine. That file must exist before `plan` will succeed.
