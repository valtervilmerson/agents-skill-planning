$ErrorActionPreference = "Stop"

$GitHubUser   = "valtervilmerson"
$GitHubRepo   = "agents-skill-planning"
$GitHubBranch = "main"
$SkillRemote  = "https://raw.githubusercontent.com/$GitHubUser/$GitHubRepo/$GitHubBranch/skills/project-planner/SKILL.md"
$Dest         = "$env:USERPROFILE\.claude\commands\project-planner.md"

Write-Host ""
Write-Host "Project Planner — instalação"
Write-Host "-----------------------------"

New-Item -ItemType Directory -Force -Path (Split-Path $Dest) | Out-Null

# Se rodando de dentro do repo clonado, usa arquivo local. Caso contrário, baixa do GitHub.
$ScriptPath = $MyInvocation.MyCommand.Path
$LocalSkill = if ($ScriptPath) { Join-Path (Split-Path -Parent $ScriptPath) "skills\project-planner\SKILL.md" } else { "" }

if ($LocalSkill -and (Test-Path $LocalSkill)) {
    Copy-Item $LocalSkill $Dest -Force
    Write-Host "✓ Instalado de arquivo local"
} else {
    Write-Host "→ Baixando de $GitHubUser/$GitHubRepo..."
    Invoke-WebRequest -Uri $SkillRemote -OutFile $Dest -UseBasicParsing
    Write-Host "✓ Instalado do GitHub"
}

Write-Host ""
Write-Host "  Destino : $Dest"
Write-Host "  Comando : /project-planner"
Write-Host ""
Write-Host "Pronto. Use /project-planner em qualquer projeto no Claude CLI."
Write-Host ""
