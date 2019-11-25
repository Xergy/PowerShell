$VerbosePreference =  "SilentlyContinue"

#Move to the location of the script if you not threre already.
$ScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition) 
Set-Location $ScriptDir

#If not logged in to Azure, start login
if ($Null -eq (Get-AzureRmContext).Account) {
    $AzureEnv = Get-AzureRmEnvironment | Select-Object -Property Name  | 
    Out-GridView -Title "Choose your Azure environment.  NOTE: For Azure Commercial choose AzureCloud" -OutputMode Single
    Connect-AzureRmAccount -Environment $AzureEnv.Name }

$Subs = @()
$RGs = @()
$TargetResources = @()
$TargetResourcesFiltered = @() 

$Subs = Get-AzureRmSubscription | Out-GridView -OutputMode Multiple -Title "Select Subscriptions"

$Subs | FL *

foreach ( $Sub in $Subs ) {

    Select-AzureRmSubscription -SubscriptionName $sub.Name
    $SubRGs = @()
    $SubRGs = Get-AzureRmResourceGroup |  
        Out-GridView -OutputMode Multiple -Title "Select Resource Groups for SUBSCRIPTION: $($Sub.Name)"

    foreach ( $SubRG in $SubRGs ) { $SubRg = $SubRg |
    Add-Member -MemberType NoteProperty –Name "Subscription" –Value $($sub.Name) -PassThru |
    Add-Member -MemberType NoteProperty –Name "SubscriptionId" –Value $($sub.Id) -PassThru
    
    $RGs += $SubRg
    }
}

$RGs | fl *

foreach ($RG in $RGs )
{
    Select-AzureRmSubscription -SubscriptionName $RG.Subscription
    
    $RGTargetResources = Get-AzureRmResource -ResourceGroupName $RG.ResourceGroupName | 
    Out-GridView -Title "Choose Target Resources in SUBSCRIPTION: $($RG.Subscription) RG: $($RG.ResourceGroupName)" -OutputMode Multiple

    foreach ( $RGTargetResource in $RGTargetResources ) { $RGTargetResource = $RGTargetResource |
    Add-Member -MemberType NoteProperty –Name "Subscription" –Value $($RG.Subscription) -PassThru |
    Add-Member -MemberType NoteProperty –Name "SubscriptionId" –Value $($Rg.SubscriptionId) -PassThru
    
    $TargetResources += $RGTargetResource

    }
}

$TargetResources | Fl *

$TargetResourcesFiltered = $TargetResources | Select-Object -Property Name,Subscription,SubscriptionId,location,ResourceGroupName,ResourceType

$OutputFilename = Read-Host "Output File Name"

$TargetResourcesFiltered | Export-Csv -Path $OutputFilename -NoTypeInformation

Import-Csv -Path $OutputFilename | Out-GridView