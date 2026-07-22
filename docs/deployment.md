# Deployment and validation

## 1. Prepare local parameters

Copy the safe example file and edit only the ignored local copy:

```bash
cp infrastructure/main.dev.bicepparam.example infrastructure/main.dev.bicepparam
```

Set:

- `adminSshPublicKey` to the complete one-line public key
- `allowedSshSource` to the administrator public IPv4 address in CIDR form, such as `203.0.113.10/32`
- `alertEmailAddress` to the notification recipient
- `vmSize` to an available SKU if the default is unavailable in the selected region

Do not commit the local parameter file.

## 2. Select the Azure subscription

```bash
az login
az account list --output table
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
az account show --query "{Name:name, SubscriptionId:id, TenantId:tenantId}" --output table
```

## 3. Validate Bicep

```bash
az bicep build --file infrastructure/main.bicep
rm -f infrastructure/main.json
```

## 4. Preview changes

```bash
az deployment sub what-if \
  --location canadacentral \
  --template-file infrastructure/main.bicep \
  --parameters infrastructure/main.dev.bicepparam
```

Review all planned creates, modifications, and deletions before proceeding.

## 5. Deploy

```bash
az deployment sub create \
  --name deploy-vm-monitoring-incident-response \
  --location canadacentral \
  --template-file infrastructure/main.bicep \
  --parameters infrastructure/main.dev.bicepparam \
  --query properties.outputs \
  --output json
```

## 6. Verify infrastructure

```bash
az resource list \
  --resource-group rg-monitoring-incident-dev \
  --query "[].{Name:name, Type:type, Location:location}" \
  --output table
```

```bash
az vm get-instance-view \
  --resource-group rg-monitoring-incident-dev \
  --name vm-monitoring-dev \
  --query "instanceView.statuses[].displayStatus" \
  --output table
```

## 7. Verify monitoring association

```bash
VM_ID=$(az vm show \
  --resource-group rg-monitoring-incident-dev \
  --name vm-monitoring-dev \
  --query id -o tsv)

az monitor data-collection rule association list \
  --resource "$VM_ID" \
  --query "[].{Association:name, RuleId:dataCollectionRuleId}" \
  --output table
```

## 8. Verify Action Group and alert

```bash
az monitor action-group show \
  --resource-group rg-monitoring-incident-dev \
  --name ag-monitoring-operations-dev \
  --query "{Name:name, Enabled:enabled, Receivers:emailReceivers[].name}" \
  --output json
```

```bash
az monitor metrics alert show \
  --resource-group rg-monitoring-incident-dev \
  --name alert-vm-high-cpu-dev \
  --query "{Name:name, Enabled:enabled, Severity:severity, Window:windowSize, Frequency:evaluationFrequency}" \
  --output table
```

Confirm receipt of the Azure Monitor Action Group membership email.

## 9. Verify data ingestion

Allow several minutes after deployment, then run [data-ingestion-status.kql](../queries/data-ingestion-status.kql) in the Log Analytics workspace. A recent `LastPerformanceRecord` and a nonzero record count confirm the collection path.

## 10. Connect to the VM

```bash
ssh azureadmin@<VM_PUBLIC_IP>
```

On the VM:

```bash
hostname
free -m
df -h
```
