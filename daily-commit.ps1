param(
    [string]$Repo = "C:\Users\Pradnya Rode\daily-notes",
    [string]$LogFile = "C:\Users\Pradnya Rode\daily-notes\daily-commit.log"
)

$ErrorActionPreference = "Stop"
$date = Get-Date
$stamp = $date.ToString("yyyy-MM-dd")
$file = Join-Path $Repo "notes\$stamp.md"

if (-not (Test-Path -LiteralPath (Split-Path $file))) {
    New-Item -ItemType Directory -Path (Split-Path $file) -Force | Out-Null
}

if (-not (Test-Path -LiteralPath $file)) {
    $content = @"
# $($date.ToString("dddd, MMMM d, yyyy"))

## What did I do today?

- 

## What did I learn?

- 

## Ideas / todos

- 
"@
    Set-Content -LiteralPath $file -Value $content -Encoding UTF8
}

Set-Location -LiteralPath $Repo
git pull --quiet
git add -A
$changed = git status --porcelain
if (-not $changed) {
    Add-Content -LiteralPath $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') nothing to commit"
    exit 0
}

git commit --quiet -m "docs: daily note $stamp"
git push --quiet 2>$null
if ($LASTEXITCODE -ne 0) {
    Add-Content -LiteralPath $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') commit ok, push failed (no remote or auth?)"
    exit 1
}

Add-Content -LiteralPath $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') committed and pushed $stamp"