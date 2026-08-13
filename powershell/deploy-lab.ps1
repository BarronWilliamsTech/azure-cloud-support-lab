# =====================================================================
# Contoso Health - Azure Cloud Support Home Lab
# PowerShell Deployment Script
# Save this file as: powershell/deploy-lab.ps1 in your GitHub repo
# =====================================================================

# --- Connect to Azure ---
Connect-AzAccount

# --- Variables (edit these if you want different names) ---
$rg              = "rg-contoso-health-lab"
$location        = "eastus"
$vnetName        = "vnet-contoso-health"
$storageAccount  = "stcontosohealthlab2026"   # must be globally unique, lowercase only
$logAnalytics    = "law-contoso-health"
$backupVault     = "rsv-contoso-health-backup"

# --- 1. Create Resource Group ---
New-AzResourceGroup -Name $rg -Location $location

# --- 2. Create Virtual Network with two subnets ---
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name "snet-servers-windows" -AddressPrefix "10.0.1.0/24"
$subnet2 = New-AzVirtualNetworkSubnetConfig -Name "snet-servers-linux"   -AddressPrefix "10.0.2.0/24"

$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rg `
  -Location $location -AddressPrefix "10.0.0.0/16" -Subnet $subnet1, $subnet2

Write-Host "Virtual network created: $vnetName"

# --- 3. Create Network Security Groups ---
$myIp = (Invoke-WebRequest -Uri "https://api.ipify.org").Content

$rdpRule = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP-MyIP" -Description "Allow RDP from my IP" `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 `
  -SourceAddressPrefix $myIp -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

$nsgWindows = New-AzNetworkSecurityGroup -Name "nsg-windows-subnet" -ResourceGroupName $rg `
  -Location $location -SecurityRules $rdpRule

$sshRule = New-AzNetworkSecurityRuleConfig -Name "Allow-SSH-MyIP" -Description "Allow SSH from my IP" `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 `
  -SourceAddressPrefix $myIp -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22

$nsgLinux = New-AzNetworkSecurityGroup -Name "nsg-linux-subnet" -ResourceGroupName $rg `
  -Location $location -SecurityRules $sshRule

Write-Host "NSGs created and locked to your current IP: $myIp"

# --- 4. Create Storage Account with Blob container and File share ---
New-AzStorageAccount -ResourceGroupName $rg -Name $storageAccount `
  -Location $location -SkuName Standard_LRS -Kind StorageV2

$ctx = (Get-AzStorageAccount -ResourceGroupName $rg -Name $storageAccount).Context
New-AzStorageContainer -Name "blob-container-01" -Context $ctx -Permission Off
New-AzStorageShare -Name "fileshare-01" -Context $ctx

Write-Host "Storage account created: $storageAccount"

# --- 5. Create Log Analytics Workspace ---
New-AzOperationalInsightsWorkspace -ResourceGroupName $rg -Name $logAnalytics -Location $location

Write-Host "Log Analytics workspace created: $logAnalytics"

# --- 6. Create Backup Vault (Recovery Services Vault) ---
$vault = New-AzRecoveryServicesVault -ResourceGroupName $rg -Name $backupVault -Location $location
Set-AzRecoveryServicesVaultContext -Vault $vault

Write-Host "Backup vault created: $backupVault"

Write-Host ""
Write-Host "===================================================="
Write-Host " Base lab infrastructure deployed successfully."
Write-Host " Next: create your VMs and attach them to this"
Write-Host " network, storage, monitoring, and backup vault"
Write-Host " through the Azure Portal (see the full guide)."
Write-Host "===================================================="