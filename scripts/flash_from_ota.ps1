<#
.SYNOPSIS
  Extract an A/B OTA (payload.bin) and flash via bootloader + fastbootd.

.PARAMETER OtaZip
  Path to OTA zip (Voltage, BestROM, etc.)

.PARAMETER WorkDir
  Directory for extracted images

.PARAMETER SkipTinyModem
  Skip flashing modem*.img smaller than 8KB (BestROM stub protection)

.PARAMETER PayloadDumper
  Path to payload-dumper-go.exe
#>
param(
  [Parameter(Mandatory = $true)][string]$OtaZip,
  [string]$WorkDir = ".\ota_extract",
  [string]$PayloadDumper = "",
  [string]$Fastboot = "",
  [switch]$SkipTinyModem,
  [switch]$SkipFirmware
)

$ErrorActionPreference = "Continue"

function Find-Tool([string]$Name, [string]$Hint) {
  if ($Hint -and (Test-Path $Hint)) { return (Resolve-Path $Hint).Path }
  $cmd = Get-Command $Name -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  $candidates = @(
    "C:\Program Files (x86)\ADB & Fastboot++\$Name.exe",
    "C:\Program Files\platform-tools\$Name.exe",
    "$PSScriptRoot\..\tools\$Name.exe",
    "$env:USERPROFILE\.grok\tmp_serverhive\bestrom_agent\tools\$Name.exe"
  )
  foreach ($c in $candidates) {
    if (Test-Path $c) { return $c }
  }
  throw "Cannot find $Name. Install platform-tools / payload-dumper-go."
}

$fb = Find-Tool "fastboot" $Fastboot
$dumper = Find-Tool "payload-dumper-go" $PayloadDumper
$OtaZip = (Resolve-Path $OtaZip).Path
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null
$WorkDir = (Resolve-Path $WorkDir).Path

function Invoke-Fb {
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$FbArgs)
  Write-Host (">>> fastboot " + ($FbArgs -join " ")) -ForegroundColor Cyan
  & $fb @FbArgs 2>&1 | ForEach-Object { "$_" }
  if ($LASTEXITCODE -ne 0) { Write-Host "exit=$LASTEXITCODE" -ForegroundColor DarkYellow }
  return $LASTEXITCODE
}

Write-Host "OTA: $OtaZip"
Write-Host "WorkDir: $WorkDir"
Write-Host "Free GB: $([math]::Round((Get-PSDrive C).Free/1GB, 2))"

# Extract if needed
$needExtract = -not (Test-Path (Join-Path $WorkDir "system.img"))
if ($needExtract) {
  Write-Host "=== EXTRACT ===" -ForegroundColor Yellow
  $env:TEMP = $WorkDir
  $env:TMP = $WorkDir
  & $dumper -c 2 -o $WorkDir $OtaZip
  if ($LASTEXITCODE -ne 0) { throw "payload-dumper-go failed" }
} else {
  Write-Host "Using existing images in WorkDir"
}

$imgCount = (Get-ChildItem $WorkDir -Filter "*.img").Count
Write-Host "Images: $imgCount"
if ($imgCount -lt 10) { throw "Too few images extracted" }

# Ensure bootloader mode
$us = & $fb getvar is-userspace 2>&1 | Out-String
if ($us -match "yes") {
  Write-Host "Currently fastbootd -> reboot bootloader"
  Invoke-Fb reboot bootloader | Out-Null
  Start-Sleep -Seconds 12
}

Write-Host "=== BOOT CHAIN ===" -ForegroundColor Yellow
foreach ($p in @("boot", "dtbo", "vendor_boot", "init_boot")) {
  $img = Join-Path $WorkDir "$p.img"
  if (Test-Path $img) { Invoke-Fb flash $p $img | Out-Null }
}
Invoke-Fb --disable-verity --disable-verification flash vbmeta (Join-Path $WorkDir "vbmeta.img") | Out-Null
Invoke-Fb --disable-verity --disable-verification flash vbmeta_system (Join-Path $WorkDir "vbmeta_system.img") | Out-Null

if (-not $SkipFirmware) {
  Write-Host "=== FIRMWARE ===" -ForegroundColor Yellow
  $fw = @(
    "abl", "aop", "aop_config", "bluetooth", "cpucp", "cpucp_dtb", "devcfg", "dsp",
    "featenabler", "hyp", "imagefv", "keymaster", "modem", "modemfirmware", "multiimgqti",
    "qupfw", "shrm", "tz", "uefi", "uefisecapp", "xbl", "xbl_config", "xbl_ramdump", "countrycode"
  )
  foreach ($p in $fw) {
    $img = Join-Path $WorkDir "$p.img"
    if (-not (Test-Path $img)) { continue }
    $sz = (Get-Item $img).Length
    if ($SkipTinyModem -and $p -match "modem" -and $sz -lt 8192) {
      Write-Host "SKIP tiny $p ($sz bytes)" -ForegroundColor DarkYellow
      continue
    }
    if ($sz -lt 4096) {
      Write-Host "SKIP tiny $p ($sz bytes)" -ForegroundColor DarkYellow
      continue
    }
    Invoke-Fb flash $p $img | Out-Null
  }
}

Write-Host "=== FASTBOOTD ===" -ForegroundColor Yellow
Invoke-Fb reboot fastboot | Out-Null
Start-Sleep -Seconds 18
$ready = $false
for ($i = 0; $i -lt 40; $i++) {
  $u = & $fb getvar is-userspace 2>&1 | Out-String
  Write-Host "wait $i is-userspace check..."
  if ($u -match "yes") { $ready = $true; break }
  Start-Sleep -Seconds 2
}
if (-not $ready) {
  Write-Host @"
ERROR: Not in fastbootd (is-userspace is not yes).

Bootloader cannot flash system/vendor. Options:
1) Use a known-good vendor_boot (e.g. Voltage) to enter fastbootd, then re-run logical flash.
2) Fix BestROM vendor_boot so 'fastboot reboot fastboot' works.
"@ -ForegroundColor Red
  exit 2
}

Write-Host "=== LOGICAL PARTITIONS ===" -ForegroundColor Yellow
$failed = @()
foreach ($p in @("system", "system_ext", "product", "vendor", "odm", "system_dlkm", "vendor_dlkm")) {
  $img = Join-Path $WorkDir "$p.img"
  if (-not (Test-Path $img)) { Write-Host "MISSING $p"; $failed += $p; continue }
  Write-Host "Flashing $p ($([math]::Round((Get-Item $img).Length/1MB,1)) MB)..." -ForegroundColor Yellow
  $ok = $false
  for ($try = 1; $try -le 3; $try++) {
    & $fb flash $p $img 2>&1 | ForEach-Object { "$_" }
    if ($LASTEXITCODE -eq 0) { $ok = $true; break }
    Start-Sleep -Seconds 3
  }
  if (-not $ok) { $failed += $p }
}

if ($failed.Count -gt 0) {
  Write-Host "FAILED: $($failed -join ', ')" -ForegroundColor Red
  exit 1
}

Write-Host "=== WIPE + REBOOT ===" -ForegroundColor Yellow
& $fb -w 2>&1 | ForEach-Object { "$_" }
& $fb reboot bootloader 2>&1 | ForEach-Object { "$_" }
Start-Sleep -Seconds 10
& $fb erase userdata 2>&1 | ForEach-Object { "$_" }
& $fb erase metadata 2>&1 | ForEach-Object { "$_" }
& $fb reboot 2>&1 | ForEach-Object { "$_" }

Write-Host "FLASH COMPLETE — wait several minutes on logo for first boot." -ForegroundColor Green
