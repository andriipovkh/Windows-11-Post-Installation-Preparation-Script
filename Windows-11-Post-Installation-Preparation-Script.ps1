# ==============================================================================
# Windows 11 Post-Installation Preparation Script
# Run this script in an Elevated PowerShell Window (Run as Administrator)
# ==============================================================================

# Ensure script is running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating privileges to Administrator..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$ErrorActionPreference = "SilentlyContinue"
Write-Host "Starting Windows 11 Custom Preparation..." -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. System Storage & Restore Commands
# ------------------------------------------------------------------------------
Write-Host "Configuring Hibernation off, Shadow Storage = 1024MB, and System Restore = disable..." -ForegroundColor Green
powercfg -h off
vssadmin Resize ShadowStorage /For=C: /On=C: /MaxSize=1024MB
Disable-ComputerRestore -drive "C:\"

# ------------------------------------------------------------------------------
# 2. Display Scale (Set to 100% / 96 DPI)
# ------------------------------------------------------------------------------
Write-Host "Setting Display Scale to 100%..." -ForegroundColor Green
# Set standard scaling to 100% (0) for all known monitors
$MonitorSettings = "HKCU:\Control Panel\Desktop\PerMonitorSettings"
if (Test-Path $MonitorSettings) {
    Get-ChildItem -Path $MonitorSettings | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "DpiValue" -Value 0 -Type DWord
    }
}
# Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "LogPixels" -Value 96 -Type DWord
# Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Win8DpiScaling" -Value 1 -Type DWord
# Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DesktopDPIOverride" -Value 0 -Type DWord

# ------------------------------------------------------------------------------
# 3. Personalization (Spotlight, Dark Mode, Green Accent)
# ------------------------------------------------------------------------------
Write-Host "Applying Theme (Dark Mode, Green Accent, Windows Spotlight)..." -ForegroundColor Green

# Desktop Background to Windows Spotlight
$WallpapersPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers"
if (-not (Test-Path $WallpapersPath)) { New-Item -Path $WallpapersPath -Force | Out-Null }
Set-ItemProperty -Path $WallpapersPath -Name "BackgroundType" -Value 3 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-88000326Enabled" -Value 1 -Type DWord

# Dark Mode (Apps & System)
$PersonalizePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
if (-not (Test-Path $PersonalizePath)) { New-Item -Path $PersonalizePath -Force | Out-Null }
Set-ItemProperty -Path $PersonalizePath -Name "AppsUseLightTheme" -Value 0 -Type DWord
Set-ItemProperty -Path $PersonalizePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord

# Color: Green 
$AccentPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent"
if (-not (Test-Path $AccentPath)) { New-Item -Path $AccentPath -Force | Out-Null }
#Set-ItemProperty -Path $AccentPath -Name "AccentColorMenu" -Value 0xff107c10 -Type DWord
#Set-ItemProperty -Path $AccentPath -Name "AccentPalette" -Value ([byte[]](0x7a,0xc6,0x8b,0x00, 0x4c,0xaf,0x60,0x00, 0x10,0x89,0x3e,0x00, 0x0e,0x7a,0x37,0x00, 0x0b,0x60,0x2b,0x00, 0x08,0x49,0x21,0x00, 0x05,0x32,0x17,0x00, 0x00,0x00,0x00,0x00)) -Type Binary
#Set-ItemProperty -Path $AccentPath -Name "StartColorMenu" -Value 0xff0e6d0e -Type DWord
#Set-ItemProperty -Path $PersonalizePath -Name "ColorPrevalence" -Value 1 -Type DWord

# ------------------------------------------------------------------------------
# 4. Power Modes & Button / Lid Configurations
# ------------------------------------------------------------------------------
Write-Host "Configuring Power Profiles, Sleep Timeouts, and Button Actions..." -ForegroundColor Green

# Power Modes Slider: Plugged In = Best Performance, Battery = Best Power Efficiency
#powercfg /setacvalueindex SCHEME_CURRENT SUB_POWER OVERLAY_SCHEME_HIGH 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
#powercfg /setdcvalueindex SCHEME_CURRENT SUB_POWER OVERLAY_SCHEME_LOW 961b9f0e-4ab0-4796-9d1e-1929f06c00d4

# Power Overlay Modes
# Best Performance when Plugged in (Overlay scheme mode 0 = High Performance)
powercfg /setacvalueindex SCHEME_CURRENT SUB_NONE OVERLAY_SCHEME_HIGH 0

# Best Power Efficiency on Battery (Overlay scheme mode 0 = Max Battery Saver)
powercfg /setdcvalueindex SCHEME_CURRENT SUB_NONE OVERLAY_SCHEME_MAX 0

# Apply power configuration changes
powercfg /setactive SCHEME_CURRENT

# Screen & System Sleep (Plugged In: Screen 30m, Sleep Never | Battery: Screen 30m, Sleep Never)
powercfg /change monitor-timeout-ac 30
powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-dc 30
powercfg /change standby-timeout-dc 0

# Lid, Power, and Sleep Button Settings
# Actions: 0 = Do Nothing, 1 = Sleep, 2 = Hibernate, 3 = Shutdown
# Power Button -> Shutdown (3)
powercfg /setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e1e-b414-0d345a73a450 3
powercfg /setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e1e-b414-0d345a73a450 3

# Sleep Button -> Sleep (1)
powercfg /setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996be5-ad92-4e56-923b-6f4196421303 1
powercfg /setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996be5-ad92-4e56-923b-6f4196421303 1

# Lid Close -> AC: Do Nothing (0) | DC: Hibernate (2)
powercfg /setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-5e5d-459f-a2a6-3cb381434002 0
powercfg /setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-5e5d-459f-a2a6-3cb381434002 2

# Apply Power Scheme Changes
powercfg /setactive SCHEME_CURRENT

# Turn ON Battery Percentage display on taskbar
If (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Control Panel\Settings\BatteryPercentage")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Control Panel\Settings\BatteryPercentage" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Control Panel\Settings\BatteryPercentage" -Name "ShowBatteryPercentage" -Value 1 -Type DWord

# ------------------------------------------------------------------------------
# 5. Mouse Settings (Inverted Cursor, Precision Off, Speed 7)
# ------------------------------------------------------------------------------
Write-Host "Configuring Mouse Pointer Settings..." -ForegroundColor Green
$CursorsPath = "HKCU:\Control Panel\Cursors"
Set-ItemProperty -Path $CursorsPath -Name "(Default)" -Value "Inverted"
Set-ItemProperty -Path $CursorsPath -Name "Scheme Source" -Value 1 -Type DWord
Set-ItemProperty -Path $CursorsPath -Name "Arrow" -Value "%SystemRoot%\cursors\arrow_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "Help" -Value "%SystemRoot%\cursors\help_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "AppStarting" -Value "%SystemRoot%\cursors\wait_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "Wait" -Value "%SystemRoot%\cursors\busy_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "Crosshair" -Value "%SystemRoot%\cursors\cross_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "IBeam" -Value "%SystemRoot%\cursors\beam_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "NWPen" -Value "%SystemRoot%\cursors\pen_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "No" -Value "%SystemRoot%\cursors\no_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "SizeNS" -Value "%SystemRoot%\cursors\size4_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "SizeWE" -Value "%SystemRoot%\cursors\size3_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "SizeNWSE" -Value "%SystemRoot%\cursors\size2_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "SizeNESW" -Value "%SystemRoot%\cursors\size1_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "SizeAll" -Value "%SystemRoot%\cursors\move_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "UpArrow" -Value "%SystemRoot%\cursors\up_i.cur"
Set-ItemProperty -Path $CursorsPath -Name "Hand" -Value "%SystemRoot%\cursors\hand_i.cur"

# Enhance Pointer Precision = Off & Mouse Speed = 7
$CSharpSig = @'
[DllImport("user32.dll", SetLastError = true)]
public static extern bool SystemParametersInfo(uint action, uint param, IntPtr vparam, uint init);

[DllImport("user32.dll", SetLastError = true)]
public static extern bool SystemParametersInfo(uint action, uint param, int[] vparam, uint init);
'@
$User32 = Add-Type -MemberDefinition $CSharpSig -Name "User32Mouse" -Namespace "Win32" -PassThru

# Apply Speed (7)
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value "7"
$User32::SystemParametersInfo(0x0071, 0, [IntPtr]7, 0x01 -bor 0x02) | Out-Null

# Disable Enhance Pointer Precision
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0"

# Apply acceleration disable immediately via API
[int[]]$mouseParams = @(0, 0, 0)
$User32::SystemParametersInfo(0x0004, 0, $mouseParams, 0x01 -bor 0x02) | Out-Null


# ------------------------------------------------------------------------------
# 6. Taskbar & System Tray Settings
# ------------------------------------------------------------------------------
Write-Host "Configuring Taskbar Layout and System Tray Options..." -ForegroundColor Green
$AdvancedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
If (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
}

# Search = Hide (0)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Type DWord

# Task View = Off (0)
Set-ItemProperty -Path $AdvancedPath -Name "ShowTaskViewButton" -Value 0 -Type DWord

# Resume / Widgets / Recommended = Off (0)
Set-ItemProperty -Path $AdvancedPath -Name "TaskbarDa" -Value 0 -Type DWord
Set-ItemProperty -Path $AdvancedPath -Name "ShowRecommended" -Value 0 -Type DWord
Set-ItemProperty -Path $AdvancedPath -Name "ShowResume" -Value 0 -Type DWord

# Disable Taskbar Resume notification badges
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarResume" -Value 0 -Type DWord

# Show all system tray icons (EnableAutoTray = 0)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Value 0 -Type DWord

# Taskbar Alignment = Left (0)
Set-ItemProperty -Path $AdvancedPath -Name "TaskbarAl" -Value 0 -Type DWord

# Combine taskbar buttons and hide labels = When taskbar is full (1)
Set-ItemProperty -Path $AdvancedPath -Name "TaskbarGlomLevel" -Value 1 -Type DWord

# Show seconds in system tray clock = On (1)
Set-ItemProperty -Path $AdvancedPath -Name "ShowSecondsInSystemClock" -Value 1 -Type DWord

# Turn off recommended files in Start, recent files in File Explorer, and Jump Lists
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0 -Type DWord

# Turn off recommendations for tips, shortcuts, new apps, and more
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Value 0 -Type DWord

# Turn off account-related notifications on Start
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_AccountNotifications" -Value 0 -Type DWord

# Battery Percentage on Taskbar = On (1)
$PowerSettingsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Control Panel\Settings\Power"
if (-not (Test-Path $PowerSettingsPath)) { New-Item -Path $PowerSettingsPath -Force | Out-Null }
Set-ItemProperty -Path $PowerSettingsPath -Name "ShowBatteryPercentage" -Value 1 -Type DWord
Set-ItemProperty -Path $AdvancedPath -Name "ShowBatteryPercentage" -Value 1 -Type DWord

# Show all current system tray icons in Windows 11
$NotifyIconPath = "HKCU:\Control Panel\NotifyIconSettings"
if (Test-Path $NotifyIconPath) {
    Get-ChildItem -Path $NotifyIconPath | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "IsPromoted" -Value 1 -Type DWord
    }
}

# ==============================================================================
# Windows Explorer Customizations: Extensions, Hidden Items, "My PC", and Views
# ==============================================================================

Write-Host "Applying Windows Explorer customizations..." -ForegroundColor Cyan

# 1. Show File Name Extensions and Hidden Items
$explorerAdvanced = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $explorerAdvanced -Name "HideFileExt" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $explorerAdvanced -Name "Hidden" -Value 1 -Type DWord -Force

# 2. Rename "This PC" to "My PC"
$thisPcClsid = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
$thisPcKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\$thisPcClsid"
if (-not (Test-Path $thisPcKey)) { New-Item -Path $thisPcKey -Force | Out-Null }
New-ItemProperty -Path $thisPcKey -Name "(default)" -Value "My PC" -PropertyType String -Force | Out-Null

# 3. Pin "My PC" to Quick Access
$shell = New-Object -ComObject Shell.Application
$thisPC = $shell.Namespace(17) # 17 is the Shell Special Folder constant for 'This PC'
# Invoke the native pinning verb
$thisPC.Self.InvokeVerb("pintohome")

<# 
# 4. Set Default Folder View to Sort by Type (and set to Details view)
Write-Host "Resetting folder view cache and setting default sort to 'Type'..." -ForegroundColor Cyan

# Clear existing folder view cache (BagMRU and Bags) to force the new default on all folders, including C:\
$bagMru = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU"
$bags = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags"
if (Test-Path $bagMru) { Remove-Item -Path $bagMru -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path $bags) { Remove-Item -Path $bags -Recurse -Force -ErrorAction SilentlyContinue }

# Apply "Sort by Type" (prop:System.ItemTypeText;1) to all standard folder templates
$folderTypes = @(
    "{5C4F28B5-F869-4E84-8E60-F11DB97C5CC7}", # Generic (Applies to root drives like C:\)
    "{7D49D726-3C21-4F05-99AA-FDC2C9474656}", # Documents
    "{B3690E58-E961-423B-B687-386EBFD83239}", # Pictures
    "{94D6DDCC-4A68-4175-A374-BD584A510B78}", # Music
    "{5FA96407-7E77-483C-AC93-691D05850DE8}", # Videos
    "{885A186E-A440-4ADA-812B-DB871B942259}"  # Downloads
)

foreach ($type in $folderTypes) {
    $regPath = "HKCU:\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell\$type"
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    
    # Sort by Type (Ascending)
    Set-ItemProperty -Path $regPath -Name "Sort" -Value "prop:System.ItemTypeText;1" -Type String -Force
    # Set to 'Details' view (LogicalViewMode = 1) so the sorting is visible
    Set-ItemProperty -Path $regPath -Name "LogicalViewMode" -Value 1 -Type DWord -Force
}
 #>

# 5. Restart Explorer to apply CLSID namespace changes, pins, and folder bags
Write-Host "Restarting Explorer to apply changes..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force

# ------------------------------------------------------------------------------
# 7. Default App Removal
# ------------------------------------------------------------------------------
Write-Host "Removing Specified Default AppX Packages..." -ForegroundColor Green
$AppsToRemove = @(
    "Microsoft.People",
    "Microsoft.WindowsMaps",
    "Microsoft.BingWeather",
    "MicrosoftTeams",
    "MSTeams",
    "Microsoft.ZuneVideo",
    "Microsoft.LinkedIn",
    "WhatsApp",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.GamingApp"
)

foreach ($App in $AppsToRemove) {
    Get-AppxPackage -AllUsers -Name "*$App*" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*$App*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# Restart Explorer to apply Taskbar, Tray, Display Scale, and Spotlight registry changes
Write-Host "Restarting Explorer to apply UI changes..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 3

# ------------------------------------------------------------------------------
# 8. External Optimization & Telemetry Scripts
# ------------------------------------------------------------------------------
Write-Host "Executing External Debloat and Telemetry Reduction Scripts..." -ForegroundColor Cyan
Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/andriipovkh/Disable-Windows-11-telemetry/refs/heads/main/Windows11-Telemetry-Reduction-v2.2.ps1")
Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/andriipovkh/Windows-11-LTSC-Style-Debloat-RAM-Optimization/refs/heads/main/Windows-11-LTSC-Style-Debloat-and-RAM-Optimization.ps1")

# ------------------------------------------------------------------------------
# 9. Windows Update (Install PSWindowsUpdate Module and Run Updates)
# ------------------------------------------------------------------------------
Write-Host "Checking and Installing Windows Updates..." -ForegroundColor Cyan
Set-ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
    Install-Module -Name PSWindowsUpdate -Force -Confirm:$false -Scope CurrentUser
}

Import-Module PSWindowsUpdate
Get-WindowsUpdate -AcceptAll -Install -AutoReboot
