function Get-ProjectTarget {
    $solution = Get-ChildItem -Path . -Recurse -Filter *.sln | Select-Object -First 1
    if ($solution) {
        return @{ Type = 'Solution'; Path = $solution.FullName }
    }

    $csproj = Get-ChildItem -Path . -Recurse -Filter *.csproj | Select-Object -First 1
    if ($csproj) {
        return @{ Type = 'Project'; Path = $csproj.FullName }
    }

    throw '找不到 .sln 或 .csproj，請確認 repo 內已放入 .NET 專案。'
}

function Ensure-Directory([string]$Path) {
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}
