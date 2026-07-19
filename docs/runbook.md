# DR Runbook — vm-drdemo-web01

Purpose: step-by-step actions for an on-call engineer to fail the web
workload over to North Europe if West Europe becomes unavailable, and to
fail back once primary is restored.

## Roles
- **Incident commander**: decides to invoke failover, communicates status
- **Executor**: runs the failover steps below

## Failover (Primary → DR)

| Step | Action | Owner | Est. time |
|---|---|---|---|
| 1 | Confirm primary region outage via Azure Status page / Service Health | IC | 2 min |
| 2 | Open Recovery Services vault `rsv-drdemo` → Replicated items | Executor | 1 min |
| 3 | Select `vm-drdemo-web01` → **Failover** (not test failover) | Executor | 1 min |
| 4 | Choose latest recovery point → confirm | Executor | 1 min |
| 5 | Monitor job under Site Recovery jobs until "Completed" | Executor | 10-20 min |
| 6 | Verify app reachable at DR VM's public IP | Executor | 2 min |
| 7 | Update DNS / Traffic Manager to point at DR IP (manual in this demo scope; automated via Front Door in phase 2) | Executor | 5 min |
| 8 | Notify stakeholders: failover complete, app live in North Europe | IC | 2 min |

## Failback (DR → Primary, once primary region is healthy again)

| Step | Action |
|---|---|
| 1 | Re-enable replication in reverse direction (DR → Primary) from the vault |
| 2 | Wait for replication to sync |
| 3 | Perform a planned failover back to primary |
| 4 | Re-point DNS / Traffic Manager back to primary IP |
| 5 | Confirm app healthy in primary, disable reverse replication if project is ending |

## Rollback if failover itself fails

- Cancel the job from Site Recovery jobs if it's stuck
- If VM comes up unhealthy, use a prior recovery point and retry failover
- Escalate to Azure Support if the vault itself is unresponsive (rare)

## Notes for this project's scope

This runbook describes what a real on-call process looks like. For the
actual portfolio demonstration, only the **test failover** path
(non-disruptive) was executed — see `test-failover-results.md` for the
evidence and measured numbers. A full planned failover was scoped out to
control cost and time.
