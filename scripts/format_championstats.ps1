param(
    [string]$Path = "./championstats.json",
    [switch]$MakeBackup
)

if (-not (Test-Path $Path)) {
    Write-Error "File not found: $Path"
    exit 1
}

if ($MakeBackup) {
    $backup = "$Path.bak"
    Copy-Item -Path $Path -Destination $backup -Force
    Write-Output "Backup created: $backup"
}

try {
    $raw = Get-Content -Path $Path -Raw -ErrorAction Stop
    $obj = $raw | ConvertFrom-Json -ErrorAction Stop
    # ConvertTo-Json indenting defaults to 2 spaces, Depth must be set high enough
    $pretty = $obj | ConvertTo-Json -Depth 100
    $pretty | Out-File -FilePath $Path -Encoding utf8 -Force
    Write-Output "Formatted JSON written to: $Path"
} catch {
    Write-Error "Failed to parse or write JSON: $_"
    exit 1
}
