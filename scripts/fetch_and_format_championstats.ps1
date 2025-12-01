param(
    [string]$OutPath = "./championstats.json",
    [switch]$Force
)

function Get-LatestDataDragonVersion {
    $versionsUrl = 'https://ddragon.leagueoflegends.com/api/versions.json'
    try {
        $text = Invoke-RestMethod -Uri $versionsUrl -UseBasicParsing -ErrorAction Stop
        return $text[0]
    } catch {
        Write-Error "Failed to fetch versions.json: $_"
        exit 1
    }
}

$latest = Get-LatestDataDragonVersion
Write-Output "Latest Data Dragon version: $latest"

$champUrl = "https://ddragon.leagueoflegends.com/cdn/$latest/data/en_US/champion.json"
Write-Output "Downloading: $champUrl"

try {
    if (Test-Path $OutPath -and -not $Force) {
        Write-Error "$OutPath already exists. Use -Force to overwrite."
        exit 1
    }
    Invoke-WebRequest -Uri $champUrl -UseBasicParsing -OutFile $OutPath -ErrorAction Stop
    Write-Output "Downloaded champion data to $OutPath"
} catch {
    Write-Error "Failed to download champion.json: $_"
    exit 1
}

# Format the file in-place
.
Join-Path $PSScriptRoot 'format_championstats.ps1' | ForEach-Object {
    & $_ -Path $OutPath -MakeBackup
}
