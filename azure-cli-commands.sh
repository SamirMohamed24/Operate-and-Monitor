#!/bin/bash
az group create --name My_New_ResourceGrp --location westeurope
az appservice plan create --name My_App_Service_Plan --resource-group My_New_ResourceGrp --sku B1 --is-linux
az webapp create --resource-group My_New_ResourceGrp --plan My_App_Service_Plan --name MyUniqueAppServiceName --runtime "PYTHON|3.9"
az webapp config appsettings set --resource-group My_New_ResourceGrp --name MyUniqueAppServiceName --settings "ENVIRONMENT=production" "DEBUG=False"
# Create Storage Acount: 
az storage account create   --name mybeststorageaccnt   --resource-group My_New_ResourceGrp --location westeurope --sku Standard_LRS
# Create App Container:
az storage container create   --name appservice-backup   --account-name mybeststorageaccnt
#Genarate SAS-token for Blob-container:
az storage container generate-sas \
  --account-name mybeststorageaccnt \
  --name appservice-backup \
  --permissions rl \
  --expiry "2024-12-31T23:59:00Z" \
  --output tsv

# SAS Token
"se=2025-01-01T00%3A00%3A00Z&sp=rwdl&sv=2022-11-02&sr=c&sig=dXrQVLHqqLCkwC5e2Wwm8PNz1A%2BpluIlKnkJ33FUrgg%3D
# Create backup
 az webapp config backup create \
>   --resource-group My_New_ResourceGrp \
>   --webapp-name MyUniqueAppServiceName \
# create auomation account:
az automation account create \
>   --name MyAutomationAccount \
>   --resource-group My_New_ResourceGrp \
>   --location westeurope

# create runbook:

az automation runbook create \
>   --automation-account-name MyAutomationAccount \
>   --name WeeklyAppServiceBackup \
>   --resource-group My_New_ResourceGrp \
>   --type PowerShell
# Use SAS-URL i Azure CLI for create a backup:

az webapp config backup create \
  --resource-group My_New_ResourceGrp \
  --webapp-name MyUniqueAppServiceName \
  --container-url "https://mybeststorageaccnt.blob.core.windows.net/appservice-backup?sv=2022-11-02&st=2024-11-01T12%3A00%3A00Z&se=2024-12-31T23%3A59%3A00Z&sp=rl&sr=c&sig=5t0J%2BhyOZGo3DCWk7B1APVSHJLeRBvl2VWtye3TIlrA%3D"

# List all backup

az webapp config backup list     --resource-group My_New_ResourceGrp     --webapp-name MyUniqueAppServiceName


az webapp config backup update \
  --resource-group My_New_ResourceGrp \
  --webapp-name MyUniqueAppServiceName \
  --container-url "https://mybeststorageaccnt.blob.core.windows.net/appservice-backup?sp=rcwd&st=2024-11-15T16:53:29Z&se=2024-11-16T00:53:29Z&sv=2022-11-02&sr=c&sig=FbZ7PFSUvTj02epyMp9Cdk6CuPGnWZyO9M7VtRhtFOU%3D" \
  --frequency 7d \
  --retention 30 \
  --retain-one true

# Upgrade service plan to priemum:####

az appservice plan update \
  --resource-group My_New_ResourceGrp \
  --name My_App_Service_Plan \
  --sku S1

# Create dev slot:
az webapp deployment slot create \
  --resource-group My_New_ResourceGrp \
  --name MyUniqueAppServiceName \
  --slot dev
  # Ceate staging slot:####

  az webapp deployment slot create \
  --resource-group My_New_ResourceGrp \
  --name MyUniqueAppServiceName \
  --slot staging


  # Create sutoscaling:

  az monitor autoscale create \
  --resource-group My_New_ResourceGrp \
  --name MyAutoScaleSetting \
  --resource My_App_Service_Plan \
  --resource-type Microsoft.Web/serverFarms \
  --min-count 1 \
  --max-count 3 \
  --count 1

# Add a Scaling Condition (based on CPU utilization):

# Create Action Group formetric alert: 
az monitor action-group create \
  --resource-group My_New_ResourceGrp \
  --name MyActionGroup \
  --short-name "AlertGroup" \
  --action email receiver robin.kamo@iths.se

  # Delete always on:
  az webapp config set \
  --resource-group My_New_ResourceGrp \
  --name MyUniqueAppServiceName \
  --always-on false


