param(
    [string]$Configuration = 'Release'
)
. "$PSScriptRoot/common.ps1"

Ensure-Directory "artifacts/test-results"
$target = Get-ProjectTarget
Write-Host "Detected $($target.Type): $($target.Path)"

dotnet test $target.Path -c $Configuration --logger "trx;LogFileName=test-results.trx" --results-directory artifacts/test-results
if ($LASTEXITCODE -ne 0) { throw 'dotnet test failed' }
