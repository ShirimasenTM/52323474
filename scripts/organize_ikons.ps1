<#
Organize ikons/ into subfolders:
- ikons/champions     -> champion portraits (.png) (default destination for remaining images)
- ikons/items         -> item images (Item_*, *_item, Items_*)
- ikons/illustrations -> larger illustrative or misc images (Faelights, CrystalGrowth)

Usage: Run from repository root (PowerShell)
    powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\organize_ikons.ps1     # actually move files
    powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\organize_ikons.ps1 -DryRun  # print planned moves only

#>
[CmdletBinding()]
param(
    [switch]$DryRun
)

Set-StrictMode -Version Latest

$root = Split-Path -Parent $MyInvocation.MyCommand.Path | Resolve-Path -Relative | ForEach-Object { Join-Path (Get-Location) $_ }
Push-Location (Resolve-Path "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\..") | Out-Null

Write-Host "Organizing ikons/ into subfolders (dry run = $DryRun)"

# ensure folders
$championsDir = 'ikons\champions'
$itemsDir = 'ikons\items'
$illusDir = 'ikons\illustrations'

if(-not (Test-Path $championsDir)) { if($DryRun){ Write-Host "Would create: $championsDir" } else { New-Item -ItemType Directory -Path $championsDir | Out-Null } }
if(-not (Test-Path $itemsDir))     { if($DryRun){ Write-Host "Would create: $itemsDir" }     else { New-Item -ItemType Directory -Path $itemsDir | Out-Null } }
if(-not (Test-Path $illusDir))     { if($DryRun){ Write-Host "Would create: $illusDir" }     else { New-Item -ItemType Directory -Path $illusDir | Out-Null } }

# item-like files
$itemPatterns = @('Item_*','Items_*','*_item.*')
$moved = @()
foreach($p in $itemPatterns){
    Get-ChildItem ikons -File -Filter $p -ErrorAction SilentlyContinue | ForEach-Object {
        $dst = Join-Path $itemsDir $_.Name
        if($DryRun){ Write-Host "Would move: $($_.FullName) -> $dst" } else { Move-Item -Path $_.FullName -Destination $dst -Force; $moved += $_.Name }
    }
}

# explicit illustration files
$illustrations = @('CrystalGrowth.PNG','Faelights.PNG')
foreach($f in $illustrations){ if(Test-Path "ikons\$f"){ $dst=Join-Path $illusDir $f; if($DryRun){ Write-Host "Would move: ikons\$f -> $dst" } else { Move-Item -Path "ikons\$f" -Destination $dst -Force; $moved += $f } } }

# explicit known item images
$explicitItems = @('Hextech_Gunblade_item.png','Stormrazor_item.png')
foreach($f in $explicitItems){ if(Test-Path "ikons\$f"){ $dst=Join-Path $itemsDir $f; if($DryRun){ Write-Host "Would move: ikons\$f -> $dst" } else { Move-Item -Path "ikons\$f" -Destination $dst -Force; $moved += $f } } }

# move remaining images into champions (png/jpg/jpeg)
Get-ChildItem ikons -File | Where-Object { $_.Extension -in '.png','.PNG','.jpg','.jpeg' -and $_.Name -ne 'images.json' } | ForEach-Object {
    $src = $_.FullName; $dst = Join-Path $championsDir $_.Name
    # don't move if already in one of the subfolders
    if($_.DirectoryName -match "\\ikons$" ){
        if($DryRun){ Write-Host "Would move: $src -> $dst" } else { Move-Item -Path $src -Destination $dst -Force; $moved += $_.Name }
    }
}

if($DryRun){
    Write-Host 'Dry run finished - no file changes applied.'
    Pop-Location | Out-Null
    exit 0
}

Write-Host "Moved files (sample):" -ForegroundColor Green
$moved | Select-Object -First 40 | ForEach-Object { Write-Host " - $_" }

# update ikons/images.json so entries point to ikons/items/
if(Test-Path 'ikons\images.json'){
    try{
        $json = Get-Content 'ikons\images.json' -Raw | ConvertFrom-Json
        $json.images = $json.images | ForEach-Object { $_ -replace '^ikons\\', 'ikons/items/' }
        $json | ConvertTo-Json -Depth 5 | Set-Content 'ikons\images.json'
        Write-Host "Updated ikons/images.json -> item paths"
    } catch {
        Write-Warning "Failed to update ikons/images.json: $_"
    }
}

Write-Host "Done - ikons/ organized into: $championsDir, $itemsDir, $illusDir"
Pop-Location | Out-Null
