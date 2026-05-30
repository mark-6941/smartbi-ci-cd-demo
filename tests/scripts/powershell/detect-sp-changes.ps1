param(
    [string]$BaseRef = 'HEAD~1'
)
. "$PSScriptRoot/common.ps1"

Ensure-Directory "artifacts"
try {
    $changed = git diff --name-only $BaseRef HEAD | Where-Object { $_ -match '^sql/' -or $_ -match '\.sql$' }
} catch {
    $changed = @()
}

$result = [PSCustomObject]@{
    baseRef = $BaseRef
    changedSqlFiles = @($changed)
    count = @($changed).Count
    generatedAt = (Get-Date).ToString('s')
}

$result | ConvertTo-Json -Depth 5 | Out-File -FilePath artifacts/sp-changes.json -Encoding utf8
Write-Host "SQL changes count: $($result.count)"
