# Cost Report

Pull actual numbers from Portal → Cost Management → Cost analysis,
filtered to `rg-dr-primary` and `rg-dr-dr`, for the day(s) this
project was active.

| Item | Estimated | Actual |
|---|---|---|
| VM compute (Standard_D2s_v3, few hours running) | < $0.50 | |
| Managed disk storage (OS disk, ~1 day) | < $0.10 | |
| Public IP (Standard SKU, ~1 day) | < $0.10 | |
| Site Recovery replication (per-instance, prorated for <1 day of a ~$25/mo charge) | $1-3 | |
| DR test failover VM (ran for the test window only) | < $0.50 | |
| **Total** | **~$3-5** | |

## How I kept it cheap


- No load balancer, no managed database, single VM scope
- Set a $10 budget alert before creating any resources
- Ran build → replicate → test failover → cleanup within one sitting
- Deleted both resource groups same day; verified in Cost Management
  that no orphaned disks/IPs/NSGs were left behind
