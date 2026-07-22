# Incident report: sustained high CPU on monitored Linux VM

## Summary

A controlled CPU saturation event was generated on `vm-monitoring-dev` to validate the Azure Monitor detection, notification, investigation, and recovery workflow. The CPU load script used all available logical processors for approximately eight minutes. The severity-2 metric alert fired after the configured five-minute evaluation window, the Action Group notification path activated, and the alert later resolved automatically after CPU utilization returned below the threshold.

## Incident classification

| Field | Value |
|---|---|
| Environment | Development lab |
| Affected resource | `vm-monitoring-dev` |
| Detection source | Azure Monitor metric alert |
| Alert | `alert-vm-high-cpu-dev` |
| Severity | 2 |
| Condition | Average `Percentage CPU` greater than 70% for five minutes |
| Notification | Email through `ag-monitoring-operations-dev` |
| Impact | Controlled performance degradation; no customer workload |
| Root cause | Intentional CPU load simulation |
| Resolution | Test process ended; CPU returned to baseline |

## Timeline

1. Monitoring resources and Action Group were verified as enabled.
2. `generate-cpu-load.sh` was started on the VM with the default eight-minute duration and one worker per logical CPU.
3. VM CPU increased sharply and remained above the configured threshold.
4. Azure Monitor changed the alert state to **Fired**.
5. The Action Group notification path was confirmed.
6. CPU telemetry was reviewed with the Azure metric graph and the CPU investigation KQL query.
7. The script completed and terminated its worker processes.
8. CPU usage returned to normal.
9. Azure Monitor automatically changed the alert state to **Resolved**.
10. Post-incident checks confirmed normal VM access and continuing Log Analytics ingestion.

## Detection and evidence

- The CPU platform metric showed a clear spike during the simulation.
- The alert history recorded both fired and resolved states.
- The KQL investigation returned one-minute average and maximum CPU values for the `total` processor instance.
- Log Analytics continued receiving `Perf` records after recovery.

Supporting evidence is indexed in [Screenshots](screenshots/README.md), especially items 13 through 20.

## Investigation

The operator followed the high-CPU runbook and checked:

- VM availability and SSH access
- Current system load and memory availability
- Active processes and CPU consumers
- Azure Monitor metric history
- Log Analytics CPU performance records
- Alert configuration, threshold, and Action Group attachment

Because this was a controlled exercise, the responsible process was known. In an unplanned incident, the process list, application logs, recent deployments, scheduled tasks, and dependency health would be investigated before remediation.

## Resolution and validation

No manual termination was required because the simulation script used `timeout` and a cleanup trap. After the worker processes exited:

- VM CPU returned to its pre-test range.
- The metric alert auto-mitigated and resolved.
- SSH connectivity remained available.
- Memory and disk usage remained healthy.
- Log Analytics ingestion remained current.

## Root cause

The direct cause was the intentional execution of CPU-bound shell loops. The exercise reproduced the operational symptom of a runaway or compute-intensive process without introducing an application dependency.

## Lessons learned

- Platform metrics provide faster, simpler alert detection than relying on log ingestion for this scenario.
- Guest performance counters provide useful investigation detail and historical context.
- A five-minute window prevents a brief spike from creating an alert while still detecting sustained pressure.
- Alert evidence should be captured while the alert is fired because its active state is temporary.
- Test scripts should include duration limits and cleanup handlers to reduce operational risk.
- Notification delivery should be validated before running the incident simulation.

## Follow-up improvements

For a production environment, consider process-level telemetry, application logs, dynamic thresholds, automated diagnostics, scaling or restart automation, maintenance-window suppression, on-call routing, dashboards, and documented service-specific escalation paths.
