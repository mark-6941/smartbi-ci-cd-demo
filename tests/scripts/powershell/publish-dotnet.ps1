param(
    [string]$Configuration = 'Release'
)
. "$PSScriptRoot/common.ps1"

Ensure-Directory "artifacts/publish"
$target = Get-ProjectTarget
Write-Host "Detected $($target.Type): $($target.Path)"

dotnet publish $target.Path -c $Configuration -o artifacts/publish /p:UseAppHost=false
if ($LASTEXITCODE -ne 0) { throw 'dotnet publish failed' }
