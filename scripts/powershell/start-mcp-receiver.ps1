# scripts/powershell/start-mcp-receiver.ps1
Write-Host "==== [SmartBI Git Automation] 正在初始化開發環境 ===="

# 1. 異步啟動本機 MCP OpenAPI 監聽器 (Port 8080)
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File .\scripts\powershell\WebhookListener.ps1" -WindowStyle Hidden
Write-Host "[MCP] OpenAPI 監聽器已在背景啟動 (Port 8080)"

# 2. 同步啟動您的 .NET 後端開發伺服器 (讓 Vibe 的 UI 能持續追蹤日誌)
Write-Host " [SmartBI] 正在啟動 .NET 後端服務..."
Set-Location src
dotnet run
