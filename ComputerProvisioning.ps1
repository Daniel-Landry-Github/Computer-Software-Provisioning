#(3/30/2023)

#Consider placing this powershell script into the following network share directory and setting it as the new hire login script when provisioing the machine then wiping it out.
#\\sparkhound.com\Installs

# 8/14/23 - Can download and install from the '.\Public\Downloads' directory instead and copy shortcut to '.\Public\Desktop'

<#----------Change Log:
10/18   - Added return variable '$ProgramStatus' to the 'SDTeamOne' profile function and 'SDTeamTwo' profile function.
        - Added the 'inspection', 'installNable', 'dialpadProvisioning', 'groupPolicyProvisioning', and 'CleanUp' functions to the 'SDTeamTwo' profile function.
        - Modified the transcript code to rename the local transcript file to a identify the machine.
        - Changed the send-mailmessage section to include attachments and referenced the transcript text file location.
10/19   - After noticing that the recent runs were not installing the Meraki VPN, I realized the issue and added the 'MerakiVPNProvisioning' function to each profile functions.
----------#>

# Get-Ciminstance -ClassName Win32_ComputerSystem | fl * | Will use to fetch logged in user.
$username = ("$((Get-Ciminstance -ClassName Win32_ComputerSystem).UserName)".split("\"))[1] #Fetch logged in username.
$HomeDownload = "C:\Users\$username\Downloads"
$PublicDownloads = "C:\Users\Public\Downloads"
$PublicDesktop = "C:\Users\Public\Desktop"
$Transcript = "$PublicDownloads\ProvisioningTranscript.txt"
Start-Transcript -Path "$Transcript"
$TimeStart = Get-Date;
$computername = hostname
$installedPrograms = Get-Ciminstance -ClassName Win32_InstalledWin32Program | Select-Object Name
$TaskbarDirectory = "$Home2\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar" #Still not pinning.
$adminDownload = "C:\users\dalandry.admin\downloads\"
$LogTimeStamp = $((("$(get-date)").split(" "))[1])
$ProgramStatus = @();
$ProgramStatus += "==========`n"
$ProgramStatus += "SUMMARY:`n"



# BROWSER EXECUTABLE PATHS
    $chromeBrowser = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    $edgeBrowser = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

# APPLICATION INSTALLER PATHS
    $citrixWorkspaceInstaller =  "$HomeDownload\CitrixWorkspaceApp.exe"
    $nableExe = "$HomeDownload\100WindowsAgentSetup_VALID_UNTIL_*.exe"
    $teamsExe = "$HomeDownload\TeamsSetup_c_w_.exe"
    $dialpadExe = "$HomeDownload\DialpadSetup_x64.exe"
    $vpnInstall = "$HomeDownload\Install-meraki-vpn.v1.4.ps1"
    $teamviewerInstall = "$HomeDownload\TeamViewer_Setup_x64.exe"
    $netextenderInstall = "$HomeDownload\NXSetupU.exe"
    $vmwareHorizonInstall = "$HomeDownload\VMware-Horizon-Client-2303-8.9.0-21444108.exe"
    $splashtopBusinessInstall = "$HomeDownload\Splashtop_Business_Win_INSTALLER_v3.5.8.0.exe" 

# APPLICATION DOWNLOAD URL PATHS
    $teamsDownload = "https://go.microsoft.com/fwlink/?linkid=2187327&clcid=0x409&culture=en-us&country=us"
    $nableDownload = "https://landrylabsstorageacct1.blob.core.windows.net/landrylabs-public-container/100WindowsAgentSetup_VALID_UNTIL_2023_10_26.exe"
    $nableExpiredDownload = "https://landrylabsstorageacct1.blob.core.windows.net/landrylabs-public-container/100WindowsAgentSetup_VALID_UNTIL_2023_07_07.exe"
    $citrixWorkspaceDownload = "https://landrylabsstorageacct1.blob.core.windows.net/landrylabs-public-container/CitrixWorkspaceApp.exe"
    $chromeDownload = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B52346727-B563-9258-96E6-A3B500DF4C18%7D%26lang%3Den%26browser%3D5%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-stable-statsdef_1%26brand%3DRXQR%26installdataindex%3Dempty/update2/installers/ChromeSetup.exe"
    $dialpadDownload = "https://storage.googleapis.com/dialpad_native/x64/DialpadSetup_x64.exe"
    $vpnDownload = "https://landrylabsstorageacct1.blob.core.windows.net/landrylabs-public-container/Install-meraki-vpn.v1.4.ps1"
    $teamviewerDownload = "https://download.teamviewer.com/download/TeamViewer_Setup_x64.exe" # Also https://dl.teamviewer.com/download/version_15x/TeamViewer_Setup_x64.exe
    $netextenderDownload = "https://vpn.celtic.computer:4433/NXSetupU.exe"
    $vmwareHorizonDownload = "https://download3.vmware.com/software/CART24FQ1_WIN_2303/VMware-Horizon-Client-2303-8.9.0-21444108.exe"
    $splashtopBusinessDownload = "https://download.splashtop.com/winclient/STB/Splashtop_Business_Win_INSTALLER_v3.5.8.0.exe"
    $remoteDesktopConnectionManagerDownload = "https://download.sysinternals.com/files/RDCMan.zip"
    # Applications Pending:
        # Splashtop Business
        # Visual Studio 2022
        # Microsoft SQL Server Management Studio v18
        # Remote Desktop Connection Manager
        # KeePass

<#
Service Desk:
    Team 4 (FSSD):
        ALL
        TeamViewer (ARS)
    Team 3:
        Citrix Workspace (Aptim)
        TeamViewer (Brown and Root)
        NetExtender (Celtic)
        N/A (Children's Aid Society)
        N/A (Crypton)
        N/A (Diamond Offshore)
        N/A (HTB)
        VMWare (Childrens of Alabama)(Newton Medical)
        N/A (SecurIT360)
        N/A (Tortorigi)
        N/A (TER)
        N/A (ONI)
    Team 2:
        RDP, ?? (BRG)
        VMWare (Childrens of Alabama)
        RDP, ?? (Cornerstone)
        N/A (Eagle)
        RDP, ?? (HMH)
        Splashtop, RDP, CiscoAnyConnect, ?? (The Advocate)
        Citrix Workspace (Viva Health)
        ?? (Pulse)
    Team 1:
        Citrix Workspace (LCMC)

Web & Mobile:
    Visual Studio 2022?

#>

function Inspection
{
    Write-Host "$((("$(get-date)").split(" "))[1]) | Starting Software Provisioning..."
    Write-Host "$((("$(get-date)").split(" "))[1]) | Machine: '$computername'";
    Write-Host "$((("$(get-date)").split(" "))[1]) | Logged in user: '$username'";
    Write-Host "$((("$(get-date)").split(" "))[1]) | Generating List of Existing Software.";
}

function ProfileSelection
{
    # Profiles will be the following:
    # Team | SDTeamOne;
    SDTeamOne;
    # Team | SDTeamTwo;
    SDTeamTwo;
    # Team | SDTeamThree;
    # Team | WebAndMobile;
    # Team | HR;
    # Program | N-Able

}

function SDTeamOne ($ProgramStatus)
{
    <# Team 1:
        Citrix Workspace (LCMC)
    #>

    $ProgramStatus += Inspection
    $ProgramStatus += InstallNAble
    $ProgramStatus += DialpadProvisioning
    $ProgramStatus += CitrixWorkspaceProvisioning
    $ProgramStatus += MerakiVPNProvisioning
    $ProgramStatus += GroupPolicyProvisioning
    $ProgramStatus += CleanUp
    return $ProgramStatus
}

function SDTeamTwo
{
    <# Team 2:
        RDP, ?? (BRG)
        VMWare (Childrens of Alabama)
        RDP, ?? (Cornerstone)
        N/A (Eagle)
        RDP, ?? (HMH)
        Splashtop, RDP, CiscoAnyConnect, ?? (The Advocate)
        Citrix Workspace (Viva Health)
        ?? (Pulse)
    #>
    $ProgramStatus += Inspection
    $ProgramStatus += InstallNAble
    $ProgramStatus += DialpadProvisioning
    $ProgramStatus += CitrixWorkspaceProvisioning
    $ProgramStatus += VMWareHorizonProvisioning
    $ProgramStatus += MerakiVPNProvisioning
    $ProgramStatus += GroupPolicyProvisioning
    $ProgramStatus += CleanUp
    return $ProgramStatus
}

function WindowsInspection # 1-2. Check windows version and check for windows updates;
{
    Write-Host "Operating System | CONFIRMING BUILD AND EDITION"
    $winEnterprise = "Microsoft Windows 11 Enterprise"
    $osBuild = (Get-CimInstance -ClassName Win32_OperatingSystem).Version
    $osEdition = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
    Write-Host "Operating System | Build: $osBuild"
    Write-Host "Operating System | Edition: $osEdition"
    $i = 0;
        if ($osEdition -ne $winEnterprise)
        {
            do 
            {
                Write-Host "Operating System | NOT Enterprise..." -NoNewline
                Write-Host "Operating System | Applying Enterprise product key."
                #slmgr /ipk XXXX-XXXX-XXXX-XXXX
                # -LogPath: Specifies the full path and file name to log to. If not set, the default is %WINDIR%\Logs\Dism\dism.log.
                $i++
            } 
            until ($osEdition -eq $winEnterprise -or $i -eq 3)
            
        }
        if ($i -eq 3)
            {
                Write-Host "Operating System | Unable to adjust OS edition to '$winEnterprise'. Skipping"
            }
        Write-Host "Operating System | Applying Enterprise product key."
        
}

function ProgramDetection # WIP
{
    foreach ($program in $installedPrograms)
        {
            if ($program.name -eq "Windows Agent")
                {
                    $nableInstalled = "Y"
                    $nableVersion = $program.version
                }
        }

    if ($nableInstalled -eq "Y")
        {
            Write-Host "N-ABle 'Windows Agent' detected. " -NoNewline
            Write-Host "Version $nableVersion"
        }

}

function InstallNAble
{
    $nableInstalled = "N"
    foreach ($program in $installedPrograms)
            {
                if ($program.name -eq "Windows Agent")
                    {
                    $nableInstalled = "Y"
                    #$nableVersion = $program.version
                    }
            }
    if ($nableInstalled -eq "Y")
        {
        Write-Host "$((("$(get-date)").split(" "))[1]) | N-Able | 'Windows Agent' program detected..." -NoNewline
        $ProgramStatus += "Existing N-Able Installation Detected.`n"
        #Write-Host "N-Able | Version $nableVersion"
        }
    else
        {
        Write-Host "$((("$(get-date)").split(" "))[1]) | N-Able | Not Detected. Downloading..."
        Start-Process $chromeBrowser $nableDownload
        Start-Sleep 45
        Write-Host "$((("$(get-date)").split(" "))[1]) | N-Able | Installing..."
        Start-Process $nableExe -ArgumentList /quiet
        $ProgramStatus += "N-Able successfully installed.`n"
        Write-Host "$((("$(get-date)").split(" "))[1]) | N-Able | Complete."
        }
    return $ProgramStatus

    # DOCS
    # https://documentation.n-able.com/N-central/userguide/Content/Deploying/silent_win_install.htm  /silent
    # .\100WindowsAgentSetup_VALID_UNTIL_2023_06_09.exe /quiet
    
}

function TeamsProvisioning
{
    # Teams Update/Download/Install
    # "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Microsoft Teams.lnk" Program Shortcut. Copy shortcut to desktop folder?
    Write-Host "PROVISIONING TEAMS"
    $teamsInstalled = "N"
        foreach ($program in $installedPrograms)
            {
                if ($program.name -eq "Microsoft Teams")
                    {
                        $teamsInstalled = "Y"
                        $teamsVersion = $program.version
                    }
            }
        if ($teamsInstalled -eq "Y")
            {
                Write-Host "MS Teams detected. " -NoNewline
                Write-Host "Version $teamsVersion"
            }
        else
            {
                Write-Host "Teams Not Detected. Downloading now."
                #invoke-webrequest -Uri $teamsDownload -UseBasicParsing -OutFile $teamsExe
                start $edgeBrowser $teamsDownload
                Start-Sleep 10
                Write-Host "Launching Teams Installer."
                start $teamsExe         
            }
}

function DialpadProvisioning
{
    $dialpadInstalled = "N"
    foreach ($program in $installedPrograms)
        {
            if ($program.name -eq "Dialpad")
                {
                    $dialpadInstalled = "Y"
                    #$dialpadVersion = $program.version
                }
        }
    if ($dialpadInstalled -eq "Y")
        {
            Write-Host "$((("$(get-date)").split(" "))[1]) | Dialpad | Program detected. " -NoNewline
            $ProgramStatus += "Existing Dialpad Installation Detected.`n"
            #Write-Host "$LogTimeStamp | Dialpad | Version $dialpadVersion"
        }
    else
        {
            Write-Host "$((("$(get-date)").split(" "))[1]) | Dialpad | Not Detected. Downloading..."
            Start-Process $chromeBrowser $dialpadDownload
            Start-Sleep 30
            Write-Host "$((("$(get-date)").split(" "))[1]) | Dialpad | Installing..."
            Start-Process $dialpadExe
            $ProgramStatus += "Dialpad successfully installed.`n"
            Write-Host "$((("$(get-date)").split(" "))[1]) | Dialpad | Complete."
        }
    return $ProgramStatus
}

function CitrixWorkspaceProvisioning
{
    Write-Host "Citrix Workspace | Downloading"
    Start-Process $chromeBrowser $citrixWorkspaceDownload
    Start-Sleep 60
    Write-Host "Citrix Workspace | Installing"
    start-Process $citrixWorkspaceInstaller /silent
    Start-Sleep 30
    # copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Citrix Workspace.lnk" "C:\Users\Public\Desktop"
    Write-Host "Citrix Workspace | Complete"
    $ProgramStatus += "Citrix Workspace successfully installed.`n"
    return $ProgramStatus
}

function TeamviewerProvisioning
{
    Write-Host "TeamViewer | Downloading"
    Start-Process $chromeBrowser $teamviewerDownload
    Start-Sleep 10
    Write-Host "TeamViewer | Installing"
    start-Process $teamviewerInstall /S
    Write-Host "TeamViewer | Complete"
}

function NetExtenderProvisioning
{
    Write-Host "NetExtender | Downloading"
    Start-Process $chromeBrowser $netextenderDownload
    Start-Sleep 15
    Write-Host "NetExtender | Installing"
    start-Process $netextenderInstall /S
    Write-Host "NetExtender | Complete"
}

function VMWareHorizonProvisioning
{
    Write-Host "VMWareHorizon | Downloading"
    Start-Process $chromeBrowser $vmwareHorizonDownload
    Start-Sleep 20
    Write-Host "VMWareHorizon | Installing"
    start-Process $vmwareHorizonInstall /S
    Write-Host "VMWareHorizon | Complete"
}

function GroupPolicyProvisioning
{
    Write-Host "$((("$(get-date)").split(" "))[1]) | Group Policy | Applying update with 'gpupdate /force'..."
    gpupdate /force
    Write-Host "$((("$(get-date)").split(" "))[1]) | Group Policy | Complete."
    $ProgramStatus += "Group Policy successfully updated.`n"
    # ADD(9/11/23): Generate a GPReport HTML and attach it to end of script email.
    return $ProgramStatus
}
function MerakiVPNProvisioning
{
    #Install Meraki VPN
    Write-Host "Meraki VPN | DOWNLOADING 'SPARKHOUND EMPLOYEE VPN' ENTRY"
    # Meraki Azure Storage URL: https://landrylabsstorageacct1.blob.core.windows.net/landrylabs-public-container/Install-meraki-vpn.v1.4.ps1
    #$vpnInstallURL = "https://landrylabsstorageacct1.blob.core.windows.net/landrylabs-public-container/Install-meraki-vpn.v1.3.ps1"
    #$vpnInstallPath = "$HOME\downloads\Install-meraki-vpn.v1.3.ps1"
    #invoke-webrequest -Uri $vpnInstallURL -UseBasicParsing -OutFile $vpnInstallPath
    Start-Process $chromeBrowser $vpnDownload
    Start-sleep 10
    & $vpnInstall
    $ProgramStatus += "Meraki VPN successfully installed.`n"
    return $ProgramStatus
}

function OutlookCheck
{
    # C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Outlook.lnk
    # C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.exe
}
function CleanUp
{
    Write-Host "CLEAN UP | Deleting N-Able Agent Installer"
        Remove-Item "$nableExe"
    Write-Host "CLEAN UP | Deleting Dialpad Installer"
        Remove-Item "$dialpadExe"
    Write-Host "CLEAN UP | Deleting Citrix Workspace Installer"
        Remove-Item "$citrixWorkspaceInstaller"
    Write-Host "CLEAN UP | Deleting Meraki VPN Installer"
        Remove-Item "$vpnDownload"
    Write-Host "CLEAN UP | Deleting Provisioning Script"
        Remove-Item "$HomeDownload\ComputerProvisioning.ps1"
}

<# # Start of program
Inspection
#WindowsInspection
$ProgramStatus += DialpadProvisioning
#TeamsProvisioning
InstallNAble
CitrixWorkspaceProvisioning
TeamviewerProvisioning #>
$EmailPass = Read-Host "Enter LandryLabs.Bot password"
$ProgramStatus += SDTeamOne -ProgramStatus $ProgramStatus





$ProgramStatus += "==========`n"
$TimeEnd = Get-Date;
Stop-Transcript
    $UniqueTranscriptFileName = "ProvisioningTranscript_$computername.txt"
    Rename-Item -Path $Transcript -NewName $UniqueTranscriptFileName;
    $Transcript = "$PublicDownloads\$UniqueTranscriptFileName"

$LOGFile = Get-Content -Path "$Transcript"
$LOGArray = @()
    foreach ($item in $LOGFile)
        {
            $LogArray += "$item`n";
        }

#Mailing info below
    $PasswordEmail = ConvertTo-SecureString $EmailPass -AsPlainText -Force
    $From = "landrylabs.bot@sparkhound.com";
    #$To = "mi-t2@sparkhound.com";
    $To = "daniel.landry@sparkhound.com";
    $Port = 587
    $Subject = "Workstation Provisioning Complete | $computername"
    $SMTPserver = "smtp.office365.com"
    $Cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $from, $PasswordEmail
    $Signature = "`n`nThank you,`nLandryLabs `nAutomation Assistant `nQuestions? Email 'mi-t2@sparkhound.com'"
    #$LogTranscriptStart = "TRANSCRIPT BELOW"
    Send-MailMessage -from $From -To $To -Subject $Subject -Body "$ProgramStatus`n`n$signature" -Attachments $Transcript -SmtpServer $SMTPserver -Credential $Cred -Verbose -UseSsl -Port $Port
    #Send-MailMessage -from $From -To $To -Subject $Subject -Body "$ProgramStatus`n`n$LogTranscriptStart`n$LOGArray`n$signature" -SmtpServer $SMTPserver -Credential $Cred -Verbose -UseSsl -Port $Port

<# # 6 Run group policy update
    Write-Host "Group Policy | Applying Update"
    gpupdate /force
    Write-Host "Group Policy | Complete"

# 7 Add user to "administrators" localgroup on machine
        # Include option to add domain user that can not be logged into (existing users).
    Write-Host "Local Administrator | ADDING $username TO LOCALGROUP."
    #$username = ("$(pwd)".split("\"))[2] #Fetch logged in username.
    net localgroup administrators $username /add
    Write-Host "Local Administrator | $username added successfully."
    Write-Host "Local Administrator | Generating updated list of local admins."
    net localgroup administrators

# 8 Install Meraki VPN
    Write-Host "INSTALL 'SPARKHOUND EMPLOYEE VPN' ENTRY"
    # Meraki Azure Storage URL: https://landrylabsstorageacct1.blob.core.windows.net/landrylabs-public-container/Install-meraki-vpn.v1.4.ps1
    #$vpnInstallURL = "https://landrylabsstorageacct1.blob.core.windows.net/landrylabs-public-container/Install-meraki-vpn.v1.3.ps1"
    #$vpnInstallPath = "$HOME\downloads\Install-meraki-vpn.v1.3.ps1"
    #invoke-webrequest -Uri $vpnInstallURL -UseBasicParsing -OutFile $vpnInstallPath
    start $chromeBrowser $vpnDownload
    cd "$HOME2\downloads"
    Start-sleep 5
    mv "$adminDownload\Install-meraki-vpn.v1.4.ps1" "$home2\downloads\"
    & $vpnInstall

Write-Host "CLEAN UP | Deleting N-Able Agent Installer"
    Remove-Item "$PublicDownloads\100WindowsAgentSetup_VALID_UNTIL_*.exe"
Write-Host "CLEAN UP | Deleting Dialpad Installer"
    Remove-Item "$PublicDownloads\DialpadSetup_x64.exe"
Write-Host "CLEAN UP | Deleting Citrix Workspace Installer"
    Remove-Item "$PublicDownloads\CitrixWorkspaceApp.exe"
Write-Host "CLEAN UP | Deleting Meraki VPN Installer"
    Remove-Item "$PublicDownloads\Install-meraki-vpn.v1.4.ps1"
Write-Host "CLEAN UP | Deleting Provisioning Script"
    Remove-Item "$PublicDownloads\ComputerProvisioning.ps1" #>

<# 
    1. Check windows version and check for windows updates;
    2. Confirm windows license is activated.
    3. Launch teams, pin to taskbar.
        a. Teams Desktop for Work Download URL: https://go.microsoft.com/fwlink/?linkid=2187327&clcid=0x409&culture=en-us&country=us
        b. Installation file name: "TeamsSetup_c_w_.exe"
    4. Launch outlook, pin to taskbar.
    5. If user is a technician:
        a. Download and install Dialpad. Don't login. Pin to taskbar.
        b. Download URL: https://storage.googleapis.com/dialpad_native/x64/DialpadSetup_x64.exe
    6. Run group policy update
        b. Push "gpupdate /force".
    7. Add onboarded user to "administrators" localgroup on machine
        b. Push "net localgroup administrators <username> /add".
    8. Install Meraki VPN entry:
        a. If machine is available through n-able, push script there.
        b. If not:
            i. Transfer script file through ScreenConnect (Install-meraki-vpn.v1.3.ps1)
            ii. Run powershell as administrator
            iii. Push "set-executionpolicy -executionpolicy bypass -scope process"
            iv. Push script
            v. Check network to confirm vpn entry.

    9. Confirm internal webcam (if applicable) works.
        snap picture and add it as an email attachment to the summary email.
        Camera.exe app.
        "$HOME\OneDrive - Sparkhound Inc\Pictures\Camera Roll"
        "WIN_20230424_16_39_29_Pro.jpg"
 #>