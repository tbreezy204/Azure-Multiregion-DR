# Azure Multi-Region Disaster Recovery — Site Recovery Demo

A scoped, same-day, low-cost demonstration of **Azure Site Recovery** used to
protect and fail over a web VM from **West Europe** to **North Europe**,
including a measured RTO/RPO from an actual test failover.

## Why this project

Built to demonstrate hands-on DR design and execution beyond theory:
network pre-staging across regions, replication configuration, a runbook a
real on-call engineer could follow, and evidence (not just claims) of a
successful test failover with real timing data.

## Architecture

See [`docs/architecture.md`](docs/architecture.md) for the diagram and
design decisions.

**Scope**: single VM, no load balancer, no managed database tier —
deliberately trimmed to fit a one-day, ~$5 budget while still proving the
core ASR mechanism end-to-end. Expansion paths are documented, not ignored.

## What's in this repo

```
├── scripts/
│   ├── 00-prereqs.sh                       # login, subscription, shared env vars
│   ├── 01-budget-alert.sh                  # cost governance — set before anything else
│   ├── 02-build-primary.sh                 # RG, VNet, NSG, VM, nginx
│   ├── 03-create-vault-and-dr-network.sh   # vault + DR VNet, then manual ASR wizard
│   └── 04-cleanup.sh                       # full teardown, ordered correctly
├── docs/
│   ├── architecture.md
│   ├── runbook.md                          # failover/failback procedure
│   ├── test-failover-walkthrough.md        # how the test was run
│   ├── test-failover-results.md            # actual RTO/RPO evidence
│   └── cost-report.md
└── screenshots/
```

## How to reproduce

```bash
cd scripts
source 00-prereqs.sh          # edit vars inside if needed, then log in
./01-budget-alert.sh          # or set manually in Portal — see script output
./02-build-primary.sh         # builds primary VM + network
./03-create-vault-and-dr-network.sh   # vault + DR VNet, then finish in Portal
# → follow docs/test-failover-walkthrough.md
./04-cleanup.sh               # tear everything down same day
```

## Results

- **RTO measured**: see [`docs/test-failover-results.md`](docs/test-failover-results.md)
- **Total cost**: see [`docs/cost-report.md`](docs/cost-report.md)

## Skills demonstrated

Azure Site Recovery · cross-region VNet design · Recovery Services Vaults ·
NSG/network security basics · cost governance (budgets, resource sizing,
disciplined teardown) · DR runbook authoring · Azure CLI + Bicep-adjacent IaC
scripting

## Related projects

- [PaySecure Gateway — AWS Multi-Region DR](#) — larger-scale AWS equivalent
- [PaySecure — Azure VNet Multi-Tier Architecture](#) — networking foundation this project builds on
