# Test Failover Results

## Test details

- **Date**: 2026-07-19
- **Recovery point used**: Latest processed
- **Source VM**: vm-azure-multiregion-dr-web01 (West Europe)
- **Target region**: North Europe

## Timeline

| Event | Timestamp |
|---|---|
| Test failover initiated | |
| Site Recovery job completed | |
| App confirmed reachable (curl/browser) | |
| Test failover cleaned up | |

**Calculated RTO**: `11:45 PM` − `10:55 PM` = 50 minutes

## Replication health at time of test

- **RPO shown in vault**: 1 minute (as of 7/19/2026, 10:48:28 PM)
- Screenshot: `../screenshots/replication-health.png`

Note: ~3 minutes of this was the actual ASR test failover job (VM created and 
started by 10:57:53 PM). The remaining ~47 minutes was spent diagnosing and 
fixing a networking gap on the DR-side test VM. Standard SKU public IPs deny 
all inbound traffic by default when no NSG is attached, which isn't obvious 
until you hit it. In a production runbook, this NSG would be pre-configured 
and validated ahead of time, so a real failover event would land close to 
the ~3 minute ASR job time, not the 50-minute first-attempt total.

## Evidence

- [ ] `../screenshots/asr-job-succeeded.png`
- [ ] `../screenshots/dr-vm-nginx-page.png`
- [ ] `../screenshots/vault-replicated-items.png`

## Observations / what I'd improve

ASR job completion time: ~3 minutes (10:55 PM → 10:57:53 PM)
Total time to confirmed app availability: 50 minutes (10:55 PM → 11:45 PM)
Root cause of the gap: DR-side test VM had no NSG attached, and Standard SKU public IPs deny all inbound traffic by default with no NSG present required creating and attaching an NSG before the app was reachable

The main gotchas: the vault must sit in a different region than the source 
VM for cross-regional DR; the VM size must support an SCSI disk controller 
(NVMe-only sizes like Standard_F1als_v7 are rejected); and the source OS 
kernel must fall within what ASR's Mobility Service agent supports.
Ubuntu 22.04's kernel was too new, 20.04 LTS worked fine.

The costliest issue was on the DR side: the test failover VM got a Standard 
SKU public IP with no NSG attached, which silently denies all inbound 
traffic by default. That ate most of the debugging time before I found it.

Next time I'd pre-validate VM size/OS against Microsoft's supported 
configurations list before building, and attach a baseline NSG to every 
NIC by default rather than assuming no NSG means open access.
