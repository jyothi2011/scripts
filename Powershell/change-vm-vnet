#This script should only be used to move VMs from vnet to vnet within the same subscription.
#It won't work when moving VMs between subscriptions.
 
#Note you need the AzureRM module installed. The next line will attempt to detect if it is not installed and install it for you.
#If for any reason it doesn't work you will need to DL the module manually.
#Check that AzureRM module is installed and if not then install it
$temp= (Get-Module -ListAvailable | ? {$_.name -eq 'azurerm'}) 
if ($temp.count -eq 0) {Install-Module azurerm}
 
#########Variables################################################
$original_VM_Name = 'vm-01'                                  #Enter here the VMname which you want to move
$Newnicname = $original_VM_Name+'-NIC'                       #The script must create a new nic which will get attached to the destination vNet, name the nic here our leave as is to be automatically named.
$original_VM_resource_group ='rg-lab'                        #Enter here the Resource Group name the VM is in
$Destination_vnet_name = 'vnet-b'                            #Enter here the vnet you wish to move the VM to
$Destination_subnet_name= 'default'                          #Enter here the destination subnet name, This should be the subnet name only, not vNET_name/subnet
$Destination_vnet_resource_group = 'rg-lab'                  #Enter here the RG name that destination vNet belongs to (this can sometimes be different to the VM RG)
$Region = "eastus"                                           #set the location of where to move the VM to
########End Varibles###############################################
 
 
 
#######################Login to Azure###############################
Write-Host "Log into Azure Services..."
#Azure Account Login
try {
                Login-AzureRmAccount -ErrorAction Stop
}
catch {
                # The exception lands in [Microsoft.Azure.Commands.Common.Authentication.AadAuthenticationCanceledException]
                Write-Host "User Cancelled The Authentication" -ForegroundColor Yellow
                exit
}
 
#Prompt to select an Azure subscription
Get-AzureRmSubscription | Out-GridView -OutputMode Single -Title "Select a subscription" | ForEach-Object {$selectedSubscriptionID = $PSItem.SubscriptionId}
 
# Set selected Azure subscription
Select-AzureRmSubscription -SubscriptionId $selectedSubscriptionID
 
 
 
#########################Start Script#############################
 
 
#Function that creates the new nic and attaches it to the VM
function NewNIC($nicname, $vnetname, $rg, $region) {
    $vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rg -Name $vnetname
    $nic = New-AzureRmNetworkInterface -Name $nicname -ResourceGroupName $original_VM_resource_group -Location $region -Subnet ($vnet.Subnets | ? {$_.name -eq $Destination_subnet_name})
    Write-Output $nic.Id
}
 
#Get details on the VM to move
$vm = Get-AzureRmVM -Name $original_VM_Name -ResourceGroupName $original_VM_resource_group
 
#Remove old NICc
$newvm = $vm | Remove-AzureRmVMNetworkInterface
 
#Create new NIC and attach it to destination vNET then attach the new NIC to the VM 
$newvm = Add-AzureRmVMNetworkInterface -VM $newvm -Id (NewNic -nicname $Newnicname -vnetname $Destination_vnet_name -rg $Destination_vnet_resource_group -region $Region)
 
#Remove some info from original VM which conflicts when creating a new VM
$newvm.OSProfile = $null
$newvm.StorageProfile.ImageReference = $null
$newvm.StorageProfile.OsDisk.CreateOption ='attach'
 
#Save VM config and export to temp folder in case you need to roll back
Export-AzResourceGroup -ResourceGroupName $original_VM_resource_group -Resource $vm.Id -path "c:\temp\$original_VM_Name.json"
 
#Remove/delete the VM from Azure.
Write-Output "Removing VM. Disks don't get removed and are readded next"
$vm | Remove-AzureRmVM
 
#Deploy new VM to Azure
Write-Output "creating the new VM"
New-AzureRmVM -ResourceGroupName $original_VM_resource_group -Location $Region -VM $newvm -AsJob
Write-Output "Completed"
