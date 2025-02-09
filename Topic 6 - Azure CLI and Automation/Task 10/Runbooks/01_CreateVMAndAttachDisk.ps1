param (
    [string]$ResourceGroupName = "SerhiiHomeniuk",
    [string]$Location = "UK South",
    [string]$VMName = "Task10VM",
    [string]$VNetName = "Task10VNet",
    [string]$SubnetName = "Task10sub",
    [string]$StorageAccountName = "task10wsacc",
    [string]$DiskName = "Task10VM-Disk",
    [string]$PublicIPName = "Task10PublicIP",
    [string]$NICName = "Task10NIC",
    [string]$NSGName = "Task10NSG"
)

# Authenticate using Managed Identity
$AzureContext = (Connect-AzAccount -Identity).context

# Retrieve stored credentials from Automation Account
$AutomationCredential = Get-AutomationPSCredential -Name "VMAdminCreds"
if ($null -eq $AutomationCredential) {
    throw "Could not retrieve Automation Account credential. Ensure 'VMAdminCreds' exists."
}

# Ensure Resource Group exists
if (-not (Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}

# Create Public IP if it doesn’t exist
if (-not (Get-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue)) {
    $PublicIP = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Location $Location -Name $PublicIPName -AllocationMethod Static
}
else {
    $PublicIP = Get-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName
}

# Create Network Security Group and allow HTTP traffic
if (-not (Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NSGName -ErrorAction SilentlyContinue)) {
    $NSGRule = New-AzNetworkSecurityRuleConfig -Name "AllowHTTP" -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 80 -Access Allow
    $NSG = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $Location -Name $NSGName -SecurityRules $NSGRule
}
else {
    $NSG = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NSGName
}

# Create VNet and Subnet if they don’t exist
if (-not (Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue)) {
    $subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix "10.2.0.0/24"
    New-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Location $Location -Name $VNetName -AddressPrefix "10.2.0.0/16" -Subnet $subnet
}

# Create NIC with Public IP and NSG if it doesn’t exist
if (-not (Get-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue)) {
    $VNet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName
    $Subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $VNet | Where-Object { $_.Name -eq $SubnetName }
    
    $Nic = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $Subnet.Id -PublicIpAddressId $PublicIP.Id -NetworkSecurityGroupId $NSG.Id
}
else {
    $Nic = Get-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName
}

# Create Virtual Machine if it doesn’t exist
if (-not (Get-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue)) {
    $VMConfig = New-AzVMConfig -VMName $VMName -VMSize "Standard_B1s"
    $VMConfig = Set-AzVMOperatingSystem -VM $VMConfig -Windows -ComputerName $VMName -Credential $AutomationCredential -ProvisionVMAgent
    $VMConfig = Set-AzVMSourceImage -VM $VMConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"
    $VMConfig = Set-AzVMOSDisk -VM $VMConfig -StorageAccountType "Standard_LRS" -CreateOption "FromImage"
    $VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -Id $Nic.Id
    
    New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VMConfig
}

# Attach Managed Disk if not already attached
if (-not (Get-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName -ErrorAction SilentlyContinue)) {
    $diskConfig = New-AzDiskConfig -Location $Location -CreateOption Empty -DiskSizeGB 128
    $disk = New-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName -Disk $diskConfig
    
    $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
    Add-AzVMDataDisk -VM $vm -Name $DiskName -CreateOption Attach -ManagedDiskId $disk.Id -Lun 1
    Update-AzVM -ResourceGroupName $ResourceGroupName -VM $vm
}

# Output the public IP address for verification
$PublicIP = Get-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName
Write-Output "Public IP Address: $($PublicIP.IpAddress)"
