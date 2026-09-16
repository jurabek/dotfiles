# OCI Resource Manager — isolated Ubuntu 24.04 ARM VM stack

Upload this ZIP directly to **OCI Resource Manager -> Stacks -> Create stack -> My configuration -> .Zip file**.

## What every NEW Resource Manager stack creates

- New VCN: `10.1.0.0/16`
- New public subnet: `10.1.20.0/24`
- New Internet Gateway
- New route table with `0.0.0.0/0` through the Internet Gateway
- New security list
- 1 or more new `VM.Standard.A1.Flex` instances
- Public IP for each VM
- Optional/public flexible Load Balancer (enabled by default) with all VMs registered on port 80

The network is isolated per VCN, so separate stacks can reuse the same CIDRs without colliding.

## Fixed values

- Region: `eu-frankfurt-1`
- Availability domain: `aCvB:EU-FRANKFURT-1-AD-3`
- Shape: `VM.Standard.A1.Flex`
- Image: `Canonical-Ubuntu-24.04-Minimal-aarch64-2026.08.25-0`
- Image OCID: `ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa4nss3uamvyav7jykr6k4jw6jx5ysh2ggw6go5l56fm5qwfdktruq`
- Ubuntu SSH user: `ubuntu`

## Inputs you normally need

1. Compartment
2. SSH public key
3. VM count (default `1`)
4. OCPUs / memory if you want values other than `1 OCPU / 6 GB`

## Important Terraform behavior

A second **Apply on the same Resource Manager stack** does not create a duplicate environment. Terraform is intentionally idempotent.

To create another completely new VCN + subnet + VM environment, create a **new Resource Manager stack** and upload this exact same ZIP again. Each Resource Manager stack has its own Terraform state, so it creates another independent set of resources.

## Security-list ports

Inbound TCP is currently allowed from `0.0.0.0/0` on:

- 22
- 80
- 3000
- 3005

Outbound traffic is allowed to `0.0.0.0/0`.

If you do not need a public load balancer, turn off **Create public Load Balancer** in the stack form.
