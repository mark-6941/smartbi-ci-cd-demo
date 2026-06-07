# scripts/powershell/Invoke-McpRegister.ps1
# 檢查 Port 8080 是否已經被佔用，如果沒被佔用才啟動，避免重複建立
$portCheck = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if (-not $portCheck) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File .\scripts\powershell\WebhookListener.ps1" -WindowStyle Hidden
    Write-Host "💡 [Git Hook] 檢測到分支變更，已在背景自動掛載 Jira MCP OpenSpec 接收器。"
}
