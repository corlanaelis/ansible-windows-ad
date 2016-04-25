# Installs and configures Windows Server Update Services

Install-WindowsFeature -Name "UpdateServices" -IncludeManagementTools
# Create a folder where WSUS will download its content
New-Item C:\WSUS -Type Directory           
& 'C:\Program Files\Update Services\Tools\WsusUtil.exe' --% postinstall CONTENT_DIR=C:\WSUS
# List all built-in cmdlets associated with WSUS
Get-Command -Module UpdateServices

# View the configuration options
(Get-WsusServer).GetConfiguration()

# Choose the upstream server
Set-WsusServerSynchronization -SyncFromMU

# Set the Proxy
$config = (Get-WsusServer).GetConfiguration()
$config.GetContentFromMU = $true
# Choose Languages
$config.AllUpdateLanguagesEnabled = $false
$config.AllUpdateLanguagesDssEnabled = $false
$config.SetEnabledUpdateLanguages("en")
$config.Save()

# View enabled Languages
#(Get-WsusServer).GetConfiguration().GetEnabledUpdateLanguages()

# Begin initial synchronization
$subscription = (Get-WsusServer).GetSubscription()
$subscription.StartSynchronizationForCategoryOnly()
While ($subscription.GetSynchronizationStatus() -ne 'NotProcessing')
{
    Write-Host "waiting on sync"
    Start-Sleep -Seconds 5
}

# View all products
#(Get-WsusServer).GetUpdateCategories() | ft Title,Id

# Choose Products
$subscription = (Get-WsusServer).GetSubscription()
$products = (Get-WsusServer).GetUpdateCategories() | ? {$_.Id -in @(
    '84f5f325-30d7-41c4-81d1-87a0e6535b66', # Office 2010
    'bfe5b177-a086-47a0-b102-097e4fa1f807'  # Windows 7
)}

$coll = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateCategoryCollection
$products | % { $coll.Add($_) }
$subscription.SetUpdateCategories($coll)
$subscription.Save()

# View all classifications
Get-WsusClassification | % {'{0}, # {1}' -f $_.Classification.Id,$_.Classification.Title }
(Get-WsusServer).GetUpdateClassifications()

$host.CurrentCulture

# Choose Classifications
$subscription = (Get-WsusServer).GetSubscription()
$classifications = (Get-WsusServer).GetUpdateClassifications() | ? {$_.Id -in @(
    'e6cf1350-c01b-414d-a61f-263d14d133b4', # 'Critical Updates',
    '0fa1201d-4330-4fa8-8ae9-b877473b6441', # "Security Updates",
    '68c5b0a3-d1a6-4553-ae49-01d3a7827828'  # "Service Packs"
)}

$coll = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateClassificationCollection
$classifications  | % { $coll.Add($_) }
$subscription.SetUpdateClassifications($coll)
$subscription.Save()

# Check selected classifications
#(Get-WsusServer).GetSubscription().GetUpdateClassifications()

# Start a sync
(Get-WsusServer).GetSubscription().StartSynchronization()

# View progress
#(Get-WsusServer).GetSubscription().GetSynchronizationProgress()

# Wait for sync
$subscription = (Get-WsusServer).GetSubscription()
while ($subscription.GetSynchronizationProgress().ProcessedItems -ne $subscription.GetSynchronizationProgress().TotalItems) {
    Write-Progress -PercentComplete (
    $subscription.GetSynchronizationProgress().ProcessedItems*100/($subscription.GetSynchronizationProgress().TotalItems)
    ) -Activity "Sync" 
}

# Make sure the default automatic approval rule is not enabled
(Get-WsusServer).GetInstallApprovalRules()

# View synchronization schedule options
(Get-WsusServer).GetSubscription()

# Get Configuration state
(Get-WsusServer).GetConfiguration().GetUpdateServerConfigurationState()

# Get WSUS status
(Get-WsusServer).GetStatus()