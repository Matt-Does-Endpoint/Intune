<#
.SYNOPSIS
	This script performs the installation or uninstallation of an application(s).
	# LICENSE #
	PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows.
	Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
	This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
.DESCRIPTION
	The script is provided as a template to perform an install or uninstall of an application(s).
	The script either performs an "Install" deployment type or an "Uninstall" deployment type.
	The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
	The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
.PARAMETER DeploymentType
	The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
	Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.PARAMETER AllowRebootPassThru
	Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
.PARAMETER TerminalServerMode
	Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
.PARAMETER DisableLogging
	Disables logging to file for the script. Default is: $false.
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"
.EXAMPLE
    Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"
.NOTES
	Toolkit Exit Code Ranges:
	60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
	69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
	70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK
	http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[ValidateSet('Install','Uninstall','Repair')]
	[string]$DeploymentType = 'Install',
	[Parameter(Mandatory=$false)]
	[ValidateSet('Interactive','Silent','NonInteractive')]
	[string]$DeployMode = 'Interactive',
	[Parameter(Mandatory=$false)]
	[switch]$AllowRebootPassThru = $false,
	[Parameter(Mandatory=$false)]
	[switch]$TerminalServerMode = $false,
	[Parameter(Mandatory=$false)]
	[switch]$DisableLogging = $false
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}

	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = 'Whoever'
	[string]$appName = 'ApplicationNameHere'
	[string]$appVersion = '1'
	[string]$appArch = ''
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.0'
	[string]$appScriptDate = '4/17/2026'
	[string]$appScriptAuthor = 'Me'
	##*===============================================
	## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = 'ApplicationNameHere'
	[string]$installTitle = 'ApplicationNameHere'

	##* Do not modify section below
	#region DoNotModify

	## Variables: Exit Code
	[int32]$mainExitCode = 0

	## Variables: Script
	[string]$deployAppScriptFriendlyName = 'Deploy Application'
	[version]$deployAppScriptVersion = [version]'3.8.4'
	[string]$deployAppScriptDate = '26/01/2021'
	[hashtable]$deployAppScriptParameters = $psBoundParameters

	## Variables: Environment
	If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
	[string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

	## Dot source the required App Deploy Toolkit Functions
	Try {
		[string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
		If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
		If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
	}
	Catch {
		If ($mainExitCode -eq 0){ [int32]$mainExitCode = 60008 }
		Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
		## Exit the script, returning the exit code to SCCM
		If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
	}

	#endregion
	##* Do not modify section above
	##*===============================================
	##* END VARIABLE DECLARATION
	##*===============================================

	If ($deploymentType -ine 'Uninstall' -and $deploymentType -ine 'Repair') {
		##*===============================================
		##* PRE-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Installation'

		## Show Welcome Message, close apps if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
		Show-InstallationWelcome -CloseApps 'Excel, winword' -AllowDefer -CloseAppsCountdown 3600 -PersistPrompt

		## Show Progress Message (with the default message)
		Show-InstallationProgress

		## <Perform Pre-Installation tasks here>


		##*===============================================
		##* INSTALLATION
		##*===============================================
		[string]$installPhase = 'Installation'

		## <Perform Installation tasks here>

        
#stops the app if its running        
Get-Process -Name *APPNAMEHERE* | Stop-Process -Force -ErrorAction SilentlyContinue

#uninstalls old version

$AppDescription = "APPNAMEHERE"
#REPLACE THIS VARIABLE EVERYWHERE WITH FIND AND REPLACE
$AppName = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\uninstall\*' -ErrorAction SilentlyContinue | Where-Object {((Get-ItemProperty -Path $_.PsPath) -match 'APP NAME HERE')} -ErrorAction SilentlyContinue

#add in variable for if it is an upgrade vs. new install
if ($null -ne $AppName) {$AppNameOld = $True}else {
$AppNameOld = $false}


if ($AppNameOld -eq $true) { 
Start-Process msiexec.exe -ArgumentList /x, $AppName.pschildname, /quiet, /norestart -Wait -ErrorAction SilentlyContinue


}


#Copies Silent install stuff locally because installshield is ancient.
#Copy-Item -Path ".\setup.log" -Destination "C:\Windows\Temp" -Force
Copy-Item -Path ".\setup.iss" -Destination "C:\Windows\Temp" -Force

#run silent install
start-process ".\AppInstaller.exe" -argumentlist  '/s /f1"C:\Windows\Temp\setup.iss" /f2"C:\Windows\temp\Setup.log"' -Wait

Remove-Item -Path "C:\Windows\Temp\setup.iss" -Force

#get all possible users
$users = Get-ChildItem -Path 'C:\Users\' -Directory -Exclude 'Public', 'Default', 'Default User' -ErrorAction SilentlyContinue
# parse through each users appdata and delete the old version of preferences
foreach ($user in $users) {
    $path = Join-Path -Path $user.FullName -ChildPath 'AppData\Roaming\APPFOLDERHERE'
    if (Test-Path -Path $path) {
        Remove-Item -Path $path -Recurse -Force
    }
}


#Ensure Directory is present for config files to copy to.
$AppNameDirectory = "C:\Program Files\APPInstallLocation"
# If local path doesn't exist, create it
If (!(Test-Path $AppNameDirectory)) { New-Item -Path $AppNameDirectory -ItemType Directory -Force }
#copy configs to overwrite unconfigured versions of the file
Copy-Item -Path ".\studio.config" -Destination "C:\Program Files\APPInstallLocation" -Force -ErrorAction SilentlyContinue
Copy-Item -Path ".\LicenseSettings.Config" -Destination "C:\Program Files\APPInstallLocation" -Force -ErrorAction SilentlyContinue

#parse users folders again
$users = Get-ChildItem -Path 'C:\Users\' -Directory -Exclude 'Public', 'Default', 'Default User' -ErrorAction SilentlyContinue
#copy new config for each user
foreach ($user in $users) {
    $path = Join-Path -Path $user.FullName -ChildPath 'AppData\Roaming\APPNAME\Common'
    if (Test-Path -Path $path) {
        Copy-Item -Path ".\LicenseSettings.Config" -Destination "$path" -Force
    }else {new-item -path $path -itemtype Directory}
     Copy-Item -Path ".\LicenseSettings.Config" -Destination "$path" -Force
    }



		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'

		## <Perform Post-Installation tasks here>



    #gets current version of App

    $AppNameNew = Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object {
    (
        (Get-ItemProperty -Path $_.PsPath) -match 'APPNAMEHERE' -and
        (Get-ItemProperty -Path $_.PsPath) -match 'InstallShield'
    )
}
$AppNamePath = $null -ne $AppNameNew -and ( Test-Path -Path $AppNameNew.pspath)


		## Display a message at the end of the install, based on what version of SAP is still installed after running
		 if ($AppNameNew.DisplayVersion -ge 20.0 -and $AppNameOld -eq $true) { Show-InstallationPrompt -Message "$AppDescription successfully Upgraded!" -ButtonMiddleText 'OK' -Icon Information -NoWait }    
	}

if ($AppNameNew.DisplayVersion -lt 20.0 -and $AppNameOld -eq $True) {Show-InstallationPrompt -Message "$AppDescription failed to upgrade." -ButtonMiddleText 'OK' -Icon Information -NoWait}

if ($null -eq $AppNameNew -and $AppNameold -eq $False) {Show-InstallationPrompt -Message "$AppDescription failed to install." -ButtonMiddleText 'OK' -Icon Information -NoWait}

if ($AppNameNew.DisplayVersion -ge 20.0 -and $AppNameOld -eq $false) {Show-InstallationPrompt -Message "$AppDescription successfully installed!" -ButtonMiddleText 'OK' -Icon Information -NoWait}
	{


		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'

		## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
		Show-InstallationWelcome -CloseApps 'AppNameHere' -CloseAppsCountdown 60

		## Show Progress Message (with the default message)
		Show-InstallationProgress

		## <Perform Pre-Uninstallation tasks here>


		##*===============================================
		##* UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Uninstallation'

		## Handle Zero-Config MSI Uninstallations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat
		}

		# <Perform Uninstallation tasks here>


		##*===============================================
		##* POST-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Uninstallation'
		
		## <Perform Post-Uninstallation tasks here>
		
		
	}
	
	##*===============================================
	##* END SCRIPT BODY
	##*===============================================
	
	## Call the Exit-Script function to perform final cleanup operations
	Exit-Script -ExitCode $mainExitCode
}
Catch {
	[int32]$mainExitCode = 60001
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}

