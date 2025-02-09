param (
    [string]$ResourceGroupName = "SerhiiHomeniuk",
    [string]$VMName = "Task10VM"
)

# Authenticate using Managed Identity
$AzureContext = (Connect-AzAccount -Identity).context

# Retrieve VM Object
$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -ErrorAction Stop

# Define DSC Configuration Inline
$DSCConfiguration = @"
Configuration DeployIIS
{
    Node localhost
    {
        WindowsFeature IIS
        {
            Name = "Web-Server"
            Ensure = "Present"
        }
    }
}
"@

# Save Configuration to a Temp File
$DSCPath = "C:\Windows\Temp\DeployIIS.ps1"
$DSCConfiguration | Set-Content -Path $DSCPath -Force

# Execute DSC Configuration on VM
Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -VMName $VMName -CommandId "RunPowerShellScript" -ScriptString @"
    Configuration DeployIIS
    {
        Node localhost
        {
            WindowsFeature IIS
            {
                Name = "Web-Server"
                Ensure = "Present"
            }
        }
    }
    DeployIIS -OutputPath C:\Windows\Temp
    Set-DscLocalConfigurationManager -Path C:\Windows\Temp
    Start-DscConfiguration -Path C:\Windows\Temp -Wait -Force -Verbose
"@ -ErrorAction Stop

Write-Output "IIS Deployment via DSC completed successfully."
