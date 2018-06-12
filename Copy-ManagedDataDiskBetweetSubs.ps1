### Script: 1. Copies a Managed Disk from one Sub in to another 2: Attaches to a Target VM

#region Initialize

    # If not logged in to Azure, start login
        if ((Get-AzureRmContext).Account -eq $Null) {
Connect-AzureRmAccount -Environment AzureUSGovernment}

    # List all subs:
    Get-AzureRmSubscription

#endregion 

#region Gather Source Information

    # Choose Source Sub
    Get-AzureRmSubscription | 
        # Select-Object -Property Name,SubscriptionId,TenantId,State | 
        Out-GridView -OutputMode Single -Title  "Choose the Source Subscription" | Set-AzureRmContext

    # Provide the subscription Id of the subscription where managed disk exists
    $sourceSubscriptionId = (Get-AzureRmContext).Subscription.Id

    Write-Host "SourceSubscriptionId = $sourceSubscriptionId"

    # Provide the name of your resource group where managed disk exists
    $sourceResourceGroupName = (Get-AzureRmResourceGroup | Out-GridView -OutputMode Single -Title  "Choose Source Resource Group").ResourceGroupName

    Write-Host "sourceResourceGroupName = $sourceResourceGroupName"

    # Provide the name of the managed disk
    $managedDiskName = (Get-AzureRmDisk | Out-GridView -OutputMode Single -Title  "Choose Source Managed Disk").Name

    Write-Host "managedDiskName = $managedDiskName"

    # Get the source managed disk object
    $managedDisk = Get-AzureRMDisk -ResourceGroupName $sourceResourceGroupName -DiskName $managedDiskName

    Write-host "managedDisk object = "
    $managedDisk

#endregion

#region Gather Target Information

    # Choose Target Sub
        Get-AzureRmSubscription | 
        # Select-Object -Property Name,SubscriptionId,TenantId,State | 
        Out-GridView -OutputMode Single -Title  "Choose the Target Subscription" | Set-AzureRmContext

    $targetSubscriptionId = (Get-AzureRmContext).Subscription.Id 

    Write-Host "targetSubscriptionId = $targetSubscriptionId"

    # Name of the resource group where snapshot will be copied to
    $targetResourceGroupName = (Get-AzureRmResourceGroup | Out-GridView -OutputMode Single -Title  "Choose Target Resource Group").ResourceGroupName

    Write-Host "TargetResourceGroupName = $TargetResourceGroupName"

#endregion

#region Copy Disk to Target Subscription and Resource Group

    # Create a new managed disk in the target subscription and resource group
    $diskConfig = New-AzureRmDiskConfig -SourceResourceId $managedDisk.Id -Location $managedDisk.Location -CreateOption Copy 

    New-AzureRmDisk -Disk $diskConfig -DiskName $managedDiskName -ResourceGroupName $targetResourceGroupName

    # Get newly created Target disk object
    $targetDisk = Get-AzureRmDisk -ResourceGroupName $targetResourceGroupName -DiskName $managedDiskName

    Write-Host "targetDisk ="
    $targetDisk

#endregion

#region Attach Disk to Target VM
    
    # Choose Target VM

    $vm = Get-AzureRmVM -Name ((Get-AzureRmVM | Out-GridView -OutputMode Single -Title  "Choose Target VM").Name) -ResourceGroupName $TargetResourceGroupName

    $vm = Add-AzureRmVMDataDisk -CreateOption Attach -Lun 0 -VM $vm -ManagedDiskId $targetDisk.Id

    Write-Host "VM object"
    $vm

    Update-AzureRmVM -VM $vm -ResourceGroupName $targetResourceGroupName

    # Validate the Disk is ManagedBy Target VM
    Write-Host "Final Disk Properties"
    Get-AzureRmDisk -ResourceGroupName $targetResourceGroupName -DiskName $managedDiskName 

#endregion
