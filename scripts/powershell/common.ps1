function Get-ProjectTarget {
    $solution = Get-ChildItem -Path . -Recurse -Filter *.sln | Select-Object -First 1
    if ($solution) {
        return @{ Type = 'Solution'; Path = $solution.FullName }
    }

    $csproj = Get-ChildItem -Path . -Recurse -Filter *.csproj | Select-Object -First 1
    if ($csproj) {
        return @{ Type = 'Project'; Path = $csproj.FullName }
    }

    throw "Could not find any .sln or .csproj file in the repository. Please make sure a .NET project is added."
}

function Ensure-Directory([string]$Path) {
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}
