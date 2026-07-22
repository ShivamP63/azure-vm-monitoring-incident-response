# Cleanup

The project is designed so all Azure resources are contained in one resource group. Delete the group when the lab is complete to stop VM, disk, public IP, and log-ingestion costs.

## 1. Remove temporary test data

If the VM still exists and the disk test was run:

```bash
ssh azureadmin@<VM_PUBLIC_IP>
./cleanup-test-files.sh
exit
```

## 2. Confirm the target subscription and resource group

```bash
az account show --query "{Subscription:name, SubscriptionId:id}" --output table
az group show \
  --name rg-monitoring-incident-dev \
  --query "{Name:name, Location:location}" \
  --output table

az resource list \
  --resource-group rg-monitoring-incident-dev \
  --query "length(@)" \
  --output tsv
```

Review the resource group in the Azure portal or list its resources before deletion:

```bash
az resource list \
  --resource-group rg-monitoring-incident-dev \
  --query "[].{Name:name, Type:type}" \
  --output table
```

## 3. Delete the resource group

```bash
az group delete \
  --name rg-monitoring-incident-dev \
  --yes \
  --no-wait
```

The command submits asynchronous deletion.

## 4. Verify deletion

```bash
az group wait \
  --name rg-monitoring-incident-dev \
  --deleted
```

Or check:

```bash
az group exists --name rg-monitoring-incident-dev
```

Expected output after completion:

```text
false
```

## 5. Local cleanup

Remove the environment-specific parameter file if it is no longer needed:

```bash
rm -f infrastructure/main.dev.bicepparam
```

Keep the example parameter file, Bicep source, scripts, queries, documentation, and screenshots in the repository.

## Caution

Resource-group deletion is destructive. Confirm the selected subscription and ensure the group contains only this project before running the command.
