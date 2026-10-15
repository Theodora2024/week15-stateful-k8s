[CmdletBinding()]
param(
    [string]$Namespace = "week15",
    [string]$Pod = "postgres-0"
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$BackupDirectory = Join-Path $ProjectRoot "backups"

New-Item -ItemType Directory -Path $BackupDirectory -Force | Out-Null

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupPath = Join-Path $BackupDirectory "healthcare-$Timestamp.sql"

Write-Host "Checking PostgreSQL pod..."
& kubectl get pod $Pod -n $Namespace
if ($LASTEXITCODE -ne 0) {
    throw "Cannot find or query pod $Pod in namespace $Namespace."
}

Write-Host "Creating SQL backup at: $BackupPath"

& kubectl exec -n $Namespace $Pod -- sh -c 'PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -h 127.0.0.1 -U healthcare -d healthcare --no-owner --no-privileges' > $BackupPath

if ($LASTEXITCODE -ne 0) {
    Remove-Item $BackupPath -Force -ErrorAction SilentlyContinue
    throw "pg_dump failed. The backup file was removed."
}

if (-not (Test-Path $BackupPath) -or (Get-Item $BackupPath).Length -eq 0) {
    Remove-Item $BackupPath -Force -ErrorAction SilentlyContinue
    throw "The backup file is missing or empty."
}

Write-Host "Backup file created: $BackupPath"
Write-Host "Size: $((Get-Item $BackupPath).Length) bytes"
Write-Host "This confirms file creation only; restore validation is still required."
