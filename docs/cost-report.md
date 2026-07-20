# Cost Report

Actual numbers pulled from Portal → Cost Management → Cost analysis, filtered to `rg-azure-multiregion-dr-primary` and `rg-azure-multiregion-dr`, for July 2026 (the day this project was active).

| Item | Estimated | Actual |
|---|---|---|
| VM compute (Standard_D2s_v3, few hours running) | < $0.50 | $0.51 (primary VM) |
| Managed disk storage (OS + replica + ASR snapshot disks, both RGs) | < $0.10 | $0.06 (6 disks, each ≤ $0.02) |
| Public IP (Standard SKU, both RGs) | < $0.10 | $0.03 |
| Site Recovery replication (per-instance charge) | $1-3 | $0.00 — landed inside ASR's 31-day free trial per protected instance, so no separate replication charge appeared |
| DR test failover VM (ran for the test window only) | < $0.50 | $0.15 (test VM) + $0.02 (its 2 disks) = $0.17 |
| Storage account (ASR cache, auto-created) | — | < $0.01 |
| Automation accounts x2 (auto-created by ASR) | — | $0.00 |
| **Total** | **~$3-5** | **$0.77** |

Budget set: $10.00/month — actual spend used under 8% of that budget.

## How I kept it cheap

- No load balancer, no managed database, single VM scope
- Set a $10 budget alert before creating any resources
- Ran build → replicate → test failover → cleanup within one sitting
- Deleted both resource groups same day; verified in Cost Management
  that no orphaned disks/IPs/NSGs were left behind
- Landed inside Azure Site Recovery's 31-day free trial period for the
  protected instance, avoiding the ~$25/month per-instance charge that
  would apply on longer-running projects