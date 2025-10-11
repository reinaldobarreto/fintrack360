<#
Script: rename_screenshots.ps1
Objetivo: Copiar e renomear screenshots da Área de Trabalho
para a pasta do projeto `assets/images/` com nomes padrão
para o README: tela_login_mobile.png, tela_dashboard_mobile.png,
e tela_lancamentos_mobile.png.

Nota: também remove duplicatas existentes no destino com padrão `Screenshot_*.png`
para manter somente o padrão `tela_*_mobile.png`.

Uso:
pwsh -File ./scripts/rename_screenshots.ps1
#>

$desktop = [Environment]::GetFolderPath('Desktop')
$repoRoot = Split-Path $PSScriptRoot -Parent
$target = Join-Path $repoRoot 'assets\images'

New-Item -ItemType Directory -Force -Path $target | Out-Null

# Limpeza: remover duplicatas 'Screenshot_*' no destino para evitar confusão no README
$dupScreens = Get-ChildItem -Path $target -Filter 'Screenshot_*.png' -File -ErrorAction SilentlyContinue
if ($dupScreens -and $dupScreens.Count -gt 0) {
  Write-Host "Removendo $($dupScreens.Count) duplicatas Screenshot_* do destino..."
  foreach ($f in $dupScreens) { Remove-Item -Path $f.FullName -Force }
}

$exts = @('*.png','*.jpg','*.jpeg')

function Get-AllImages($folder) {
  $files = @()
  foreach ($ext in $exts) {
    $files += Get-ChildItem -Path $folder -Filter $ext -File -ErrorAction SilentlyContinue
  }
  return $files
}

function FindByPatterns($folder, $patterns) {
  $files = Get-AllImages $folder
  $matches = $files | Where-Object {
    $n = $_.Name.ToLower()
    foreach ($p in $patterns) { if ($n -match $p) { return $true } }
    return $false
  } | Sort-Object LastWriteTime -Descending
  if ($matches.Count -gt 0) { return $matches[0] } else { return $null }
}

$login = FindByPatterns $desktop @('login','entrar','signin','logar')
$dashboard = FindByPatterns $desktop @('dashboard','dash','home','inicio')
$lanc = FindByPatterns $desktop @('lanc','lanç','transac','mov','lista','extrato')

if ($login) {
  Copy-Item $login.FullName (Join-Path $target 'tela_login_mobile.png') -Force
  Write-Host "Login: '$($login.Name)' -> tela_login_mobile.png"
} else {
  Write-Warning 'Não encontrei imagem de LOGIN. Copie manualmente para assets/images/tela_login_mobile.png'
}

if ($dashboard) {
  Copy-Item $dashboard.FullName (Join-Path $target 'tela_dashboard_mobile.png') -Force
  Write-Host "Dashboard: '$($dashboard.Name)' -> tela_dashboard_mobile.png"
} else {
  Write-Warning 'Não encontrei imagem de DASHBOARD. Copie manualmente para assets/images/tela_dashboard_mobile.png'
}

if ($lanc) {
  Copy-Item $lanc.FullName (Join-Path $target 'tela_lancamentos_mobile.png') -Force
  Write-Host "Lançamentos: '$($lanc.Name)' -> tela_lancamentos_mobile.png"
} else {
  Write-Warning 'Não encontrei imagem de LANÇAMENTOS. Copie manualmente para assets/images/tela_lancamentos_mobile.png'
}

Write-Host "Destino: $target"
Write-Host 'Concluído. Ajuste manual se algum não foi detectado.'