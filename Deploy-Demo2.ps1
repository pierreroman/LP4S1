#******************************************************************************
# Script Functions
# Execution begins here
#******************************************************************************
#region Functions
function Login {
    $needLogin = $true
    Try {
        $content = Get-AzureRmContext
        if ($content) {
            $needLogin = ([string]::IsNullOrEmpty($content.Account))
        } 
    } 
    Catch {
        if ($_ -like "*Login-AzureRmAccount to login*") {
            $needLogin = $true
        } 
        else {
            throw
        }
    }

    if ($needLogin) {
        $content = Login-AzureRmAccount
    }
    $content = Get-AzureRmContext
    return $content
}

#endregion

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************

$ErrorActionPreference = "Stop"
$WarningPreference = "SilentlyContinue"
$starttime = get-date
$Date = Get-Date -Format yyyyMMdd
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

$TemplateRootUriString = "https://raw.githubusercontent.com/pierreroman/LP4S1/master"
$TemplateURI = New-Object System.Uri -ArgumentList @($TemplateRootUriString)


#region Prep & signin

# sign in
Write-Host "Logging in ...";
$AccountInfo = Login

# select subscription
$subscriptionId = "cd400f31-6f94-40ab-863a-673192a3c0d0"
#$subscriptionId = Read-Host -Prompt 'Input your Subscription ID'
Select-AzureRmSubscription -SubscriptionID $subscriptionId | out-null

# select Resource Group
$ResourceGroupName = "LP4S1-Storage-Migration"
#$ResourceGroupName = Read-Host -Prompt 'Input the resource group for your network'

# select Location
$Location = "eastus"
#$Location = Read-Host -Prompt 'Input the Location for your network'

# set location of template
$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir  = Split-Path -Parent $ScriptPath

# Define a credential object
Write-Host "You Will now be asked for a UserName and Password that will be applied to the VMs that will be created";
$cred = Get-Credential 

$domainToJoin = "tailwind.com"

#endregion

# Deploy domain
#$FilePath = $PSScriptRoot
#$Template = $scriptDir + "\Storage-migration-demo\Domain.json"

$Template = $TemplateURI.AbsoluteUri + "/Storage-migration-demo/Domain.json"
$id=(Get-Random -Minimum 0 -Maximum 9999 ).ToString('0000')
$DeploymentName = "dc"+ $date + "-" +$id


New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateUri $Template -TemplateParameterObject `
            @{ ` 
                    adminUsername   = $cred.UserName; `
                    adminPassword   = $cred.Password; `
                    domainName      = $domainToJoin; `
                    dnsPrefix       = "tailwind"; `
            } -Force | out-null


<#
$WACFileUri = $TemplateURI.AbsoluteUri + "/Storage-migration-demo/DSC/Install-WindowsAdminCenterDsc.ps1"

Set-AzureRmVMCustomScriptExtension -Argument "-domainAdminName $cred.UserName -domainAdminPassword $cred.Password" `
    -ResourceGroupName $ResourceGroupName `
    -VMName "adVM" `
    -Location $Location `
    -FileUri $WACFileUri `
    -Run "Install-WindowsAdminCenterDsc.ps1" `
    -Name "InstallWAC"
#>