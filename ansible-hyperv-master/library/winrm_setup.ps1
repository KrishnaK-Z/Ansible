#!powershell
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# WANT_JSON
# POWERSHELL_COMMON

$result = '';

# refer https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse

Function Install-winrm {
    Write-Host "Installing WinRm"
    $url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
    $file = "$env:temp\ConfigureRemotingForAnsible.ps1"

    (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

    powershell.exe -ExecutionPolicy ByPass -File $file

    Write-Host "Installed WinRm"
    winrm enumerate winrm/config/Listener

    # Add firewall for http
    # refer https://docs.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule?view=win10-ps
    New-NetFirewallRule -Name winrm-http -DisplayName 'WinRm HTTP' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 5985
    Adding-trusted-hosts
}

function Adding-trusted-hosts {
    Write-Host "Adding IP into  Trusted Hosts"
    $env:HostIP = (
        Get-NetIPConfiguration |
        Where-Object {
            $_.IPv4DefaultGateway -ne $null -and
            $_.NetAdapter.Status -ne "Disconnected"
        }
    ).IPv4Address.IPAddress
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $env:HostIP
}

Try{     
    Install-winrm
} Catch {
    Write-Host $result
}
