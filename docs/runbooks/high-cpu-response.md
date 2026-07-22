# Runbook: high CPU response

## Purpose

Use this runbook when `alert-vm-high-cpu-dev` fires or when users report degraded performance on `vm-monitoring-dev`.

## Trigger

Average Azure VM `Percentage CPU` is greater than 70% for five minutes.

## Immediate triage

1. Acknowledge the alert and record the fired time, severity, resource, and current alert state.
2. Confirm whether the condition is part of an approved test or maintenance activity.
3. Review the VM CPU metric for the previous 30–60 minutes to determine duration and pattern.
4. Confirm VM availability:

```bash
az vm get-instance-view \
  --resource-group rg-monitoring-incident-dev \
  --name vm-monitoring-dev \
  --query "instanceView.statuses[].displayStatus" \
  --output table
```

5. Connect by SSH if access is available:

```bash
ssh azureadmin@<VM_PUBLIC_IP>
```

## Host investigation

```bash
uptime
free -m
df -h
ps -eo pid,ppid,user,comm,%cpu,%mem --sort=-%cpu | head -20
```

Use `top` for a live view if needed. Identify whether CPU is consumed by one process, several processes, kernel activity, or expected workload.

## Azure investigation

Run [cpu-investigation.kql](../../queries/cpu-investigation.kql) in Log Analytics. Compare average and maximum CPU values by minute and correlate the start time with deployments, scheduled jobs, or user activity.

Also verify that the alert rule is enabled and attached to the correct Action Group:

```bash
az monitor metrics alert show \
  --resource-group rg-monitoring-incident-dev \
  --name alert-vm-high-cpu-dev \
  --query "{Enabled:enabled, Severity:severity, Actions:actions}" \
  --output json
```

## Remediation options

Choose the least disruptive action supported by evidence and organizational procedure:

- Allow a known short-running job to finish while monitoring.
- Stop or restart a confirmed runaway noncritical process.
- Roll back a recent change associated with the spike.
- Restart the affected service when application guidance permits.
- Restart the VM only when service-level recovery requires it and impact is understood.
- Scale the VM or workload when CPU pressure is legitimate and sustained.
- Escalate to the application owner when the process purpose is unclear.

Do not kill unfamiliar processes solely because they are using CPU.

## Validation

1. Confirm the responsible process has stopped or stabilized.
2. Confirm CPU returns below the threshold.
3. Verify the application or service is healthy.
4. Confirm SSH access and basic system health.
5. Run [data-ingestion-status.kql](../../queries/data-ingestion-status.kql) to verify telemetry remains current.
6. Confirm the Azure Monitor alert changes to resolved.

## Escalation

Escalate when:

- CPU remains high after the identified process is remediated.
- The VM is unreachable or repeatedly restarts.
- The issue affects a production service or multiple resources.
- Root cause is unknown.
- Remediation requires a risky change, scaling approval, or application-owner decision.

## Closure record

Document detection time, impact, investigation evidence, root cause, action taken, recovery time, and follow-up work. Use the structure in [incident-report.md](../incident-report.md).
