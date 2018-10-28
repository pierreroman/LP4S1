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
$TemplateRootUriString = "https://raw.githubusercontent.com/pierreroman/LP4S1/master"
$TemplateURI = New-Object System.Uri -ArgumentList @($TemplateRootUriString)


#region Prep & signin

# sign in
Write-Host "Logging in ...";
$AccountInfo = Login

# select subscription
$subscriptionId = "cd400f31-6f94-40ab-863a-673192a3c0d0"
Select-AzureRmSubscription -SubscriptionID $subscriptionId | out-null

# select Resource Group
$ResourceGroupName = "LP4S1-Storage-Migration2"

# select Location
$Location = "eastus"

# Define a credential object
Write-Host "You Will now be asked for a UserName and Password that will be applied to the VMs that will be created";
$cred = Get-Credential 

$domainToJoin = "tailwind.com"

#endregion

# Create Resource Group

Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent)
    {
        New-AzureRmResourceGroup -Name $ResourceGroupName -Location EastUS -Force
    }

# Deploy domain

$Template = $TemplateURI.AbsoluteUri + "/Storage-migration-demo/Domain.json"
$id=(Get-Random -Minimum 0 -Maximum 9999 ).ToString('0000')
$DeploymentName = "dc"+ $date + "-" +$id


New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateUri $Template -TemplateParameterObject `
            @{ ` 
                    adminUsername   = $cred.UserName; `
                    adminPassword   = $cred.Password; `
                    domainName      = $domainToJoin; `
            } -Force


# Deploy windows 2008 r2 machines

$Template = $TemplateURI.AbsoluteUri + "/Storage-migration-demo/WinServ2k8.json"
$id=(Get-Random -Minimum 0 -Maximum 9999 ).ToString('0000')
$DeploymentName = "windows2k8"+ $date + "-" +$id
$vmcount = 3
for ($i = 0; $i -lt $vmcount; $i++) {
    $vmname = "win2k8r2-" + $i
    New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateUri $Template -TemplateParameterObject `
                @{ `
                        vmName    = $vmname; `
                        adminUsername   = $cred.UserName; `
                        adminPassword   = $cred.Password; `
                        windowsOSVersion = "2008-R2-SP1" `
               } -Force
            }            
