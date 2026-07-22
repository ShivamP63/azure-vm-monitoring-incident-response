# Troubleshooting

## Bicep deployment fails with `SkuNotAvailable`

**Symptom:** Azure reports that the selected VM size is unavailable in the region or zone.

**Resolution:** List available sizes and update `vmSize` in the local parameter file.

```bash
az vm list-sizes --location canadacentral --output table
```

Regional capacity changes over time; this is not necessarily a template defect.

## Deployment reports `MissingSubscription`

**Symptom:** Azure CLI commands fail because no valid subscription context is selected.

```bash
az account list --output table
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
az account show --output table
```

## SSH connection fails

Check the public IP, VM state, NSG source CIDR, username, and private-key path.

```bash
az vm get-instance-view \
  --resource-group rg-monitoring-incident-dev \
  --name vm-monitoring-dev \
  --query "instanceView.statuses[].displayStatus" \
  --output table
```

If the administrator public IP changed, update `allowedSshSource` in the local parameter file and redeploy.

Use verbose SSH diagnostics when needed:

```bash
ssh -vvv azureadmin@<VM_PUBLIC_IP>
```

## Azure Monitor Agent data is missing

1. Confirm the extension provisioning state:

```bash
az vm extension show \
  --resource-group rg-monitoring-incident-dev \
  --vm-name vm-monitoring-dev \
  --name AzureMonitorLinuxAgent \
  --query "{State:provisioningState, Version:typeHandlerVersion}" \
  --output table
```

2. Confirm the DCR association:

```bash
VM_ID=$(az vm show -g rg-monitoring-incident-dev -n vm-monitoring-dev --query id -o tsv)
az monitor data-collection rule association list --resource "$VM_ID" --output table
```

3. Wait several minutes after initial deployment or a DCR update.
4. Run `queries/data-ingestion-status.kql` and broaden the time range if necessary.

## CPU counters are missing from `Perf`

Linux counter syntax and instance names differ from Windows. The working DCR counter is:

```text
\\Processor(*)\\% Processor Time
```

The collected aggregate instance is `total`, which is why the CPU investigation query filters on `InstanceName == "total"` rather than `_Total`.

## Disk query shows snap or pseudo-filesystems at 0% free

Linux telemetry includes mounts such as `/snap/...`, `/run/lock`, and `/dev/shm`. Some read-only snap mounts can appear as 100% used by design. Focus on the root filesystem, `total`, or the actual application data mount instead of treating every instance as an incident.

## High CPU alert does not fire

- Confirm the alert is enabled.
- Confirm the VM is in the alert scope.
- Confirm the load runs longer than the five-minute window.
- Confirm enough workers are used to drive average CPU above 70%.
- Review the VM `Percentage CPU` metric directly.
- Verify the action group is attached; note that notification failure does not prevent the alert itself from firing.

## Email notification is not received

- Check junk/spam folders.
- Confirm the Action Group receiver is enabled and uses the correct address.
- Confirm the Azure Action Group membership message was received.
- Use the Action Group **Test** function.
- Verify the alert action references the correct Action Group.

## `fallocate` is unavailable or fails

Use `dd` as a fallback on the lab VM:

```bash
sudo mkdir -p /var/tmp/azure-monitoring-lab
sudo dd if=/dev/zero of=/var/tmp/azure-monitoring-lab/disk-usage-test.bin bs=1M count=3072 status=progress
```

Check available capacity before creating the file.

## Generated `main.json` appears after validation

`az bicep build` creates compiled ARM JSON beside the Bicep file. It is not needed in this repository and can be removed:

```bash
rm -f infrastructure/main.json
```
