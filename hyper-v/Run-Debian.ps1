Set-Location (Split-Path $MyInvocation.MyCommand.Path)
$isAdmin = [System.Security.Principal.WindowsPrincipal]::new(
    [System.Security.Principal.WindowsIdentity]::GetCurrent()).
        IsInRole('Administrators')

if(-not $isAdmin) {
    $params = @{
        FilePath     = 'powershell' # or pwsh if Core
        Verb         = 'RunAs'
        ArgumentList = @(
            '-NoExit'
            '-ExecutionPolicy ByPass'
            '-File "{0}"' -f $PSCommandPath
        )
    }

    Start-Process @params
    return
}

"Running........................."

# Create a VM with static IP configuration and ssh public key access
$imgFile = .\Get-DebianImage.ps1 -OutputPath 'C:\ProgramData\Microsoft\Windows\Virtual Hard Disks'
"Download done!"

$vmName = 'Jenkins-Lab'
$fqdn = 'test.example.com'
$rootPublicKey = Get-Content "$env:USERPROFILE\key_jenkins.pub"


.\New-VMFromDebianImage.ps1 -SourcePath $imgFile -VMName $vmName -FQDN $fqdn -RootPublicKey $rootPublicKey -VHDXSizeBytes 40GB -MemoryStartupBytes 2GB -ProcessorCount 2 -IPAddress 10.10.1.197/16 -Gateway 10.10.1.250 -DnsAddresses '8.8.8.8','8.8.4.4' -Verbose

# Your public key is installed. This should not ask you for a password.
ssh debian@10.10.1.197
