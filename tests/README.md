# SmartBI CI/CD Template

這是一套可直接落地的 **GitHub Actions + GitLab CI/CD + Helm + Docker** 範例，適合 .NET / SmartBI / SmartQuery 專案。

## 目錄

- `.github/workflows/build.yml`：GitHub Actions 建置 / 測試 / Helm 檢查
- `.github/workflows/deploy.yml`：GitHub Actions 部署到 K8s (Helm)
- `.gitlab-ci.yml`：GitLab Pipeline 建置 / 測試 / 打包 / Helm 部署 / smoke test
- `charts/smartbi-app/`：Helm Chart
- `scripts/powershell/`：PowerShell 腳本（自動找 solution / build / test / publish / 偵測 SP 變更）
- `backup/backup.yml`：部署前備份範例
- `smartbi/xml/dashboard-sample.xml`：SmartBI XML 範例
- `sql/stored-procedures/usp_GetBiSummary.sql`：SP 範例

---

## 1. 必要條件

### 本機 / Runner 需安裝
- .NET SDK 8 或 9
- Docker
- Helm 3
- kubectl
- PowerShell 7

---

## 2. GitHub Secrets

到 **GitHub → Settings → Secrets and variables → Actions** 新增：

- `KUBE_CONFIG_B64`：`kubectl config view --raw --flatten | base64 -w 0`
- `REGISTRY_USERNAME`
- `REGISTRY_PASSWORD`
- `SMARTBI_BASE_URL`
- `SMARTQUERY_ENDPOINT`
- `IMAGE_REPOSITORY`（例如 `ghcr.io/your-org/smartbi-api`）

如果部署到 GHCR，可額外用 `GITHUB_TOKEN`。

---

## 3. GitLab CI/CD Variables

到 **GitLab → Settings → CI/CD → Variables** 新增：

- `KUBE_CONFIG_B64`
- `REGISTRY_USERNAME`
- `REGISTRY_PASSWORD`
- `IMAGE_REPOSITORY`
- `SMARTBI_BASE_URL`
- `SMARTQUERY_ENDPOINT`
- `K8S_NAMESPACE`（預設 `smartbi`）
- `HELM_RELEASE_NAME`（預設 `smartbi-app`）

---

## 4. 本機驗證步驟

### 4.1 Build
```powershell
pwsh ./scripts/powershell/build-dotnet.ps1 -Configuration Release
```

### 4.2 Test
```powershell
pwsh ./scripts/powershell/test-dotnet.ps1 -Configuration Release
```

### 4.3 Publish
```powershell
pwsh ./scripts/powershell/publish-dotnet.ps1 -Configuration Release
```

### 4.4 Helm Render
```powershell
helm template smartbi-app ./charts/smartbi-app -f ./charts/smartbi-app/values-dev.yaml
```

---

## 5. GitHub Actions 觸發方式

### build.yml
- push 到 `main`, `develop`
- pull request 到 `main`

### deploy.yml
- 只有 push 到 `main`
- 會 build image → push registry → helm upgrade --install

---

## 6. GitLab Pipeline 觸發方式

- branch push：validate / build / test / package
- main branch：deploy / smoke test

---

## 7. 如何直接跑起來

### GitHub
1. 將此模板放到 repo 根目錄
2. 設定 GitHub Secrets
3. 確認專案根目錄下有 `.sln` 或 `.csproj`
4. Push 到 `main`
5. 查看 **Actions** 頁面

### GitLab
1. 將此模板放到 repo 根目錄
2. 設定 GitLab Variables
3. 確認 runner 可用 Docker / Helm / kubectl
4. Push 到 `main`
5. 查看 **CI/CD → Pipelines**

---

## 8. 如果目前 repo 還沒有 .NET 專案

這套腳本會自動找：
- 第一個 `*.sln`
- 如果沒有 `*.sln`，就找第一個 `*.csproj`

所以你只要把 SmartBI API 專案放進 repo，就能直接沿用。

---

## 9. 建議的 repo 結構

```text
.
├─ .github/workflows/
├─ charts/smartbi-app/
├─ scripts/powershell/
├─ src/SmartBi.Api/
├─ tests/
├─ .gitlab-ci.yml
└─ README.md
```
