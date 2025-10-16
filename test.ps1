<#
.SYNOPSIS
  Converts a PowerShell script (.ps1) to a standalone .exe with no output.
  Automatically ensures a permissive execution scope for itself.
  Adds trademark and copyright metadata to the resulting EXE.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$InputScript,
    [string]$OutputExe = "",
    [switch]$HideConsole = $true,
    [switch]$RequireAdmin = $false,
    [string]$IconPath = ""
)

# --- quiet mode ---
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# --- temporarily relax execution policy ---
$oldPolicy = Get-ExecutionPolicy -Scope Process -ErrorAction SilentlyContinue
if ($oldPolicy -ne 'Bypass') {
    try { Set-ExecutionPolicy Bypass -Scope Process -Force -ErrorAction Stop } catch {}
}

# --- verify input ---
if (-not (Test-Path $InputScript)) { Write-Error "Input file not found: $InputScript"; exit 1 }
if (-not $OutputExe) { $OutputExe = [IO.Path]::ChangeExtension($InputScript, '.exe') }

# --- ensure TLS 1.2 for PSGallery ---
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# --- ensure ps2exe available ---
if (-not (Get-Module -ListAvailable -Name ps2exe -ErrorAction SilentlyContinue)) {
    try {
        Install-Module ps2exe -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop | Out-Null
    } catch {
        Write-Error "Failed to install ps2exe: $($_.Exception.Message)"
        if ($oldPolicy) { Set-ExecutionPolicy $oldPolicy -Scope Process -Force -ErrorAction SilentlyContinue }
        exit 1
    }
}
Import-Module ps2exe -Force -ErrorAction Stop | Out-Null

# --- define safe ASCII metadata ---
$Trademark = "Built with Neuralbytes EXE Tool"
$Copyright = "(c) Neuralbytes Systems - All Rights Reserved"

# --- build argument list ---
$invokeArgs = @{
    InputFile  = $InputScript
    OutputFile = $OutputExe
}
if ($HideConsole) { $invokeArgs.NoConsole = $true }
if ($IconPath -and (Test-Path $IconPath)) { $invokeArgs.Icon = $IconPath }

# add metadata if supported
try {
    $params = (Get-Command Invoke-PS2EXE).Parameters.Keys
    if ($params -contains 'Trademark') { $invokeArgs.Trademark = $Trademark }
    if ($params -contains 'Copyright') { $invokeArgs.CopyRight = $Copyright }
    if ($RequireAdmin -and ($params -contains 'RequireAdministrator')) {
        $invokeArgs.RequireAdministrator = $true
    }
} catch {}

# --- convert ---
try {
    Invoke-PS2EXE @invokeArgs | Out-Null
    if (Test-Path $OutputExe) {
        exit 0
    } else {
        Write-Error "EXE not created."
        exit 1
    }
} catch {
    Write-Error ("Conversion failed: " + $_.Exception.Message)
    exit 1
}
finally {
    if ($oldPolicy -and $oldPolicy -ne 'Bypass') {
        Set-ExecutionPolicy $oldPolicy -Scope Process -Force -ErrorAction SilentlyContinue
    }
}
