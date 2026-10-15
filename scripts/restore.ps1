[CmdletBinding()]
param(
    [string]$Namespace = "week15",
    [string]$Pod = "postgres-0",
    [string]$BackupPath
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$BackupDirectory = Join-Path $ProjectRoot "backups"

if ([string]::IsNullOrWhiteSpace($BackupPath)) {
    $LatestBackup = Get-ChildItem $BackupDirectory -Filter "healthcare-*.sql" -File |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $LatestBackup) {
        throw "No timestamped healthcare-*.sql backup found in $BackupDirectory."
    }

    $BackupPath = $LatestBackup.FullName
} elseif (-not [System.IO.Path]::IsPathRooted($BackupPath)) {
    $BackupPath = Join-Path $ProjectRoot $BackupPath
}

if (-not (Test-Path $BackupPath -PathType Leaf)) {
    throw "Backup file not found: $BackupPath"
}

if ((Get-Item $BackupPath).Length -eq 0) {
    throw "Backup file is empty: $BackupPath"
}

Write-Host "Selected backup: $BackupPath"
Write-Host "Target database: healthcare_restore"
Write-Warning "This script replaces the dedicated healthcare_restore database."
Write-Warning "Do not modify this script to target the original healthcare database."

& kubectl get pod $Pod -n $Namespace
if ($LASTEXITCODE -ne 0) {
    throw "Cannot find or query pod $Pod in namespace $Namespace."
}

# Drop and recreate only the dedicated restore-test database.
& kubectl exec -n $Namespace $Pod -- sh -c 'PGPASSWORD="$POSTGRES_PASSWORD" psql -h 127.0.0.1 -U healthcare -d postgres -v ON_ERROR_STOP=1 -c "DROP DATABASE IF EXISTS healthcare_restore WITH (FORCE);"'
if ($LASTEXITCODE -ne 0) {
    throw "Could not drop the previous healthcare_restore database."
}

& kubectl exec -n $Namespace $Pod -- sh -c 'PGPASSWORD="$POSTGRES_PASSWORD" psql -h 127.0.0.1 -U healthcare -d postgres -v ON_ERROR_STOP=1 -c "CREATE DATABASE healthcare_restore;"'
if ($LASTEXITCODE -ne 0) {
    throw "Could not create healthcare_restore."
}

Write-Host "Importing SQL backup..."

Get-Content -LiteralPath $BackupPath -Raw -Encoding utf8 |
    & kubectl exec -i -n $Namespace $Pod -- sh -c 'PGPASSWORD="$POSTGRES_PASSWORD" psql -h 127.0.0.1 -U healthcare -d healthcare_restore -v ON_ERROR_STOP=1'

if ($LASTEXITCODE -ne 0) {
    throw "SQL restore failed. Inspect PostgreSQL logs and the selected backup."
}

Write-Host "SQL import completed. Verify restored tables and records before declaring success."
