param(
    [string]$JsonPath = "./championstats.json",
    [string]$OutDir = "./ikons",
    [switch]$Force
)

if (-not (Test-Path $JsonPath)) {
    Write-Error "championstats.json not found at '$JsonPath'"
    exit 1
}

$root = Split-Path -Path $JsonPath -Parent
Push-Location $root

try {
    $j = Get-Content -Path $JsonPath -Raw | ConvertFrom-Json -ErrorAction Stop
} catch {
    Write-Error "Failed to read/parse JSON: $_"
    Pop-Location
    exit 1
}

$version = $j.version
Write-Output "Data Dragon version: $version"

if (-not (Test-Path $OutDir)) { New-Item -Path $OutDir -ItemType Directory -Force | Out-Null }

$items = @()
foreach ($prop in $j.data.psobject.properties) {
    # Use the JSON key name (prop.Name) as the filename (this matches URL pattern: /img/champion/<ChampionKey>.png)
    # Some champions use slightly different keys than display names (e.g. KSante -> KSante.png), so using prop.Name is reliable.
    $fileName = "$($prop.Name).png"
    $items += [pscustomobject]@{Name = $prop.Name; File = $fileName}
}

Write-Output "Found $($items.Count) champions to fetch"

$base = "https://ddragon.leagueoflegends.com/cdn/$version/img/champion"

$failed = @()
foreach ($it in $items) {
    $url = "$base/$($it.File)"
    $dst = Join-Path $OutDir $it.File

    if (Test-Path $dst -and -not $Force) {
        Write-Output "Skipping (exists): $($it.File)"
        continue
    }

    try {
        Write-Output "Downloading $($it.File)"
        Invoke-WebRequest -Uri $url -OutFile $dst -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Warning "Failed to download $url - $_"
        $failed += $it
    }
}
$pngCount = (Get-ChildItem -Path $OutDir -Filter '*.png' -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Output "Finished downloads: $pngCount PNGs in $OutDir"
if ($failed.Count -gt 0) { Write-Warning "Failed to download $($failed.Count) files. See the list above." }

Pop-Location
