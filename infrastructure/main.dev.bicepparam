using './main.bicep'

param location = 'canadacentral'
param resourceGroupName = 'rg-monitoring-incident-dev'
param environment = 'Development'
param owner = 'ShivamP63'
param adminUsername = 'azureadmin'
param vmSize = 'Standard_D2s_v3'

param adminSshPublicKey = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpFok7mwiUZ3kreTrlhDpQJKfB2dXm9xS/SAhIgr1Nz portfolio-project'
param allowedSshSource = '216.211.57.193/32'
param alertEmailAddress = 'shivampande3@gmail.com'