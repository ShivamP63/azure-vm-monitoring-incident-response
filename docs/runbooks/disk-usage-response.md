# Runbook: disk usage response

## Purpose

Use this runbook when filesystem free space is decreasing, disk-related errors appear, or Log Analytics indicates abnormal Linux disk utilization.

## Immediate triage

1. Identify the affected VM and filesystem.
2. Determine whether the condition is expected, temporary, or part of a test.
3. Connect to the VM and inspect current capacity:

```bash
ssh azureadmin@<VM_PUBLIC_IP>
df -hT
```

4. Identify large directories and files without crossing other mounted filesystems:

```bash
sudo du -xhd1 / 2>/dev/null | sort -h
sudo find / -xdev -type f -size +500M -printf '%s %p\n' 2>/dev/null | sort -n | tail -20
```

5. Check inode usage:

```bash
df -ih
```

## Log Analytics investigation

Run [disk-investigation.kql](../../queries/disk-investigation.kql). Focus on persistent filesystems such as `total`, `/`, or the relevant data mount. Ignore pseudo-filesystems and read-only snap mounts when they are not related to the incident.

Correlate the decline with deployments, log growth, package operations, backups, temporary files, or application jobs.

## Remediation options

- Remove confirmed temporary lab files with `cleanup-test-files.sh`.
- Rotate or archive logs according to retention policy.
- Clear approved package caches or obsolete temporary files.
- Stop a process producing uncontrolled file growth after identifying its owner.
- Extend the managed disk and filesystem when growth is legitimate.
- Move application data to an appropriate data disk.
- Escalate before deleting unknown business or system data.

Never delete files solely because they are large. Confirm ownership, retention requirements, and recoverability first.

## Validation

```bash
df -hT
df -ih
```

Then wait for the next collection interval and rerun the KQL query. Confirm that:

- Free space has recovered or stabilized.
- The affected service can write normally.
- No required files were removed.
- Log Analytics ingestion remains current.

## Lab cleanup

For the controlled disk test:

```bash
./cleanup-test-files.sh
```

The script removes only `/var/tmp/azure-monitoring-lab` and prints the current root filesystem utilization.

## Escalation

Escalate when the filesystem is critically full, the root cause is unknown, cleanup risks data loss, disk expansion is required, or the condition returns after remediation.
