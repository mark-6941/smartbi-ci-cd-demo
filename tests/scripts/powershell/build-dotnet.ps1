param(
    [string]$Configuration = 'Release'
)
. "$PSScriptRoot/common.ps1"

Ensure-Directory "artifacts/build"
$target = Get-ProjectTarget
Write-Host "Detected $($target.Type): $($target.Path)"

dotnet restore $target.Path

dotnet build $target.Path -c $Configuration --no-restore -o artifacts/build
if ($LASTEXITCODE -ne 0) { throw 'dotnet build failed' }
