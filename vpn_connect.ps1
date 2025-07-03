param (
    [Parameter(Mandatory = $true)]
    [string]$VpnServer,

    [Parameter(Mandatory = $true)]
    [string]$CredentialTarget,

    [string]$VpnCliPath = "C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe"
)

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] [$Level] $Message"
    Write-Host $logLine
}

function Check-VpnStatus {
    Write-Log "Checking VPN status..."
    $statusOutput = & "$VpnCliPath" status 2>&1
    if ($statusOutput -match "state:\s+Connected") {
        Write-Log "VPN is already connected." "INFO"
        return $true
    } else {
        Write-Log "VPN is not connected." "INFO"
        return $false
    }
}

# --- Start ---
Write-Log "Starting VPN connection script"
Write-Log "VPN Server: $VpnServer"
Write-Log "Credential Target: $CredentialTarget"

# --- Check vpncli path ---
if (-Not (Test-Path $VpnCliPath)) {
    Write-Log "vpncli.exe not found at '$VpnCliPath'" "ERROR"
    exit 3
}

# --- VPN status check ---
if (Check-VpnStatus) {
    exit 0
}
taskkill /f /im "vpnui.exe"

# --- Load CredentialManager ---
if (-not (Get-Module -ListAvailable -Name CredentialManager)) {
    try {
        Write-Log "Installing CredentialManager module..." "WARN"
        Install-Module -Name CredentialManager -Scope CurrentUser -Force -AllowClobber
    } catch {
        Write-Log "Failed to install CredentialManager module: $_" "ERROR"
        exit 1
    }
}

Import-Module CredentialManager

# --- Get Credentials ---
$stored = Get-StoredCredential -Target $CredentialTarget
if ($null -eq $stored) {
    Write-Log "Credential '$CredentialTarget' not found in Credential Manager." "ERROR"
    exit 2
}
$username = $stored.Username
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($stored.Password)
)
Write-Log "Loaded credential for user: $username"

# --- Prepare scripted input for vpncli -s ---
$scriptInput = @(
    "connect $VpnServer",
    $username,
    $passwordPlain
)

# --- Show command ---
$commandLine = "`"$VpnCliPath`" -s"
Write-Log "Executing: $commandLine"

# --- Start process with live output and -s input ---
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $VpnCliPath
$psi.Arguments = "-s"
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true

$proc = New-Object System.Diagnostics.Process
$proc.StartInfo = $psi
$proc.Start() | Out-Null

# Write scripted input
foreach ($line in $scriptInput) {
    Write-Log ">> $line" "INPUT"
    $proc.StandardInput.WriteLine($line)
    Start-Sleep -Milliseconds 300
}
$proc.StandardInput.Close()
& "$PSScriptRoot\beep.cmd"

# --- Stream output live ---
while (-not $proc.HasExited) {
    $outLine = $proc.StandardOutput.ReadLine()
    if ($outLine -ne $null) {
        Write-Log $outLine "VPNCLI"
    }
    Start-Sleep -Milliseconds 50
}

# --- Capture remaining output after exit ---
while (-not $proc.StandardOutput.EndOfStream) {
    Write-Log ($proc.StandardOutput.ReadLine()) "VPNCLI"
}
while (-not $proc.StandardError.EndOfStream) {
    Write-Log ($proc.StandardError.ReadLine()) "WARN"
}

Write-Log "VPN process exited with code: $($proc.ExitCode)"
