$GitHubUser   = "valtervilmerson"
$GitHubRepo   = "agents-skill-planning"
$GitHubBranch = "main"
$SkillRemote  = "https://raw.githubusercontent.com/$GitHubUser/$GitHubRepo/$GitHubBranch/skills/project-planner/SKILL.md"
$Dest         = "$env:USERPROFILE\.claude\commands\project-planner.md"

Write-Host ""
Write-Host "Project Planner - instalacao"
Write-Host "-----------------------------"

New-Item -ItemType Directory -Force -Path (Split-Path $Dest) | Out-Null

# Se rodando de dentro do repo clonado, usa arquivo local. Caso contrario, baixa do GitHub.
$ScriptPath = $MyInvocation.MyCommand.Path
$LocalSkill = ""
if ($ScriptPath -ne $null -and $ScriptPath -ne "") {
    $LocalSkill = Join-Path (Split-Path -Parent $ScriptPath) "skills\project-planner\SKILL.md"
}

if ($LocalSkill -ne "" -and (Test-Path $LocalSkill)) {
    Copy-Item $LocalSkill $Dest -Force
    Write-Host "OK Instalado de arquivo local"
} else {
    Write-Host "-> Baixando de $GitHubUser/$GitHubRepo..."
    (New-Object Net.WebClient).DownloadFile($SkillRemote, $Dest)
    Write-Host "OK Instalado do GitHub"
}

Write-Host ""
Write-Host "  Destino : $Dest"
Write-Host "  Comando : /project-planner"
Write-Host ""
Write-Host "Pronto. Use /project-planner em qualquer projeto no Claude CLI."
Write-Host ""
