# Create github.com/00019021/Finance-bot if missing, then push main.
# Usage (PowerShell):
#   $env:GITHUB_TOKEN = 'ghp_xxxxxxxx'   # classic PAT with "repo", or fine-grained with Contents+Administration
#   .\push-to-github.ps1

$ErrorActionPreference = 'Stop'
$owner = '00019021'
$name  = 'Finance-bot'
$url   = "https://github.com/$owner/$name.git"

if (-not $env:GITHUB_TOKEN) {
  Write-Host 'Set env GITHUB_TOKEN first (GitHub → Settings → Developer settings → PAT).' -ForegroundColor Red
  Write-Host 'Then run this script again from this folder.' -ForegroundColor Yellow
  exit 1
}

$headers = @{
  Authorization = "Bearer $($env:GITHUB_TOKEN)"
  Accept        = 'application/vnd.github+json'
  'User-Agent'  = 'finance_bot-push-script'
}

# Create repo when it does not exist
try {
  $null = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$name" -Headers $headers -Method Get -ErrorAction Stop
  Write-Host "Repo $owner/$name already exists."
}
catch {
  if ($_.Exception.Response.StatusCode -ne [System.Net.HttpStatusCode]::NotFound) {
    throw
  }
  Write-Host "Creating $owner/$name ..."
  $body = @{ name = $name; private = $false; auto_init = $false } | ConvertTo-Json
  Invoke-RestMethod -Uri 'https://api.github.com/user/repos' -Headers $headers -Method Post -Body $body -ContentType 'application/json'
}

Push-Location $PSScriptRoot
try {
  git remote remove origin 2>$null
  git remote add origin $url
  git push -u origin main
  Write-Host "Done: $url" -ForegroundColor Green
}
finally {
  Pop-Location
}
