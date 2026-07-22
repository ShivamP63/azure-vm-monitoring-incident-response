# Screenshot evidence

This directory contains numbered deployment and incident-response evidence. Sensitive public IP and email values are redacted where visible.

## Repository and deployment

1. [GitHub repository overview](01-github-repository-overview.png) — Repository structure and project description before the final documentation pass.
2. [GitHub commit history](02-github-commit-history.png) — Incremental implementation history across infrastructure, monitoring, and incident testing.
3. [Resource group overview](03-resource-group-overview.png) — Development resource group, Canada Central location, and project tags.
4. [Azure resource list](04-resource-list.png) — Deployed compute, networking, monitoring, and alerting resources.

## Compute and networking

5. [Virtual machine overview](05-virtual-machine-overview.png) — Running Ubuntu 22.04 VM, selected size, region, and network association.
6. [Virtual network and subnet](06-virtual-network-and-subnet.png) — Monitoring VNet and subnet with NSG association.

## Monitoring configuration

7. [Log Analytics workspace](07-log-analytics-workspace.png) — Workspace receiving Linux performance telemetry.
8. [Data Collection Rule](08-data-collection-rule.png) — Linux DCR used to collect guest performance counters.
9. [DCR association](09-data-collection-rule-association.png) — Rule association attached to `vm-monitoring-dev`.
10. [Action Group](10-action-group.png) — Enabled email notification receiver with the address redacted.
11. [High CPU alert overview](11-high-cpu-alert-overview.png) — Enabled severity-2 metric alert.
12. [High CPU alert condition](12-high-cpu-alert-condition.png) — CPU metric, five-minute window, and Action Group configuration.

## High CPU incident lifecycle

13. [CPU load simulation](13-cpu-load-simulation.png) — Controlled CPU load running on the Linux VM.
14. [CPU percentage metric](14-cpu-percentage-metric.png) — Azure Monitor graph showing the generated CPU spike.
15. [Alert fired](15-alert-fired.png) — Active high-CPU alert after the threshold was sustained.
16. [Alert resolved](16-alert-resolved.png) — Alert history showing automatic recovery after CPU returned to normal.
17. [Action Group email notification](17-action-group-email-notification.png) — Azure Monitor Action Group membership and notification-path confirmation.

## Log Analytics investigation

18. [CPU investigation query](18-cpu-investigation-query.png) — One-minute average and maximum processor utilization from the `Perf` table.
19. [Disk investigation query](19-disk-investigation-query.png) — Filesystem free-space telemetry and calculated used-space percentage.
20. [Data ingestion status query](20-data-ingestion-status-query.png) — Latest performance record and record count confirming collection health.

## Host validation

21. [Linux VM SSH session](21-linux-vm-ssh-session.png) — Successful key-based connection with hostname, filesystem, and memory checks.

## Notes

- Screenshots are evidence of a controlled development lab, not a live production environment.
- Read-only snap mounts can appear as 100% used in Linux disk telemetry; the disk runbook explains how to focus on meaningful filesystems.
- The root [README](../../README.md) links to the most important incident and investigation images, while this index preserves the complete evidence set.
