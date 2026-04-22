$GitHubUser   = "valtervilmerson"
$GitHubRepo   = "agents-skill-planning"
$GitHubBranch = "main"
$Raw          = "https://raw.githubusercontent.com/$GitHubUser/$GitHubRepo/$GitHubBranch"

$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir  = if ($ScriptPath -ne $null -and $ScriptPath -ne "") { Split-Path -Parent $ScriptPath } else { "" }

Write-Host ""
Write-Host "Project Planner - instalacao"
Write-Host "-----------------------------"
Write-Host ""
Write-Host "Para qual plataforma deseja instalar?"
Write-Host "  [1] Claude CLI  - disponivel em qualquer projeto via /project-planner"
Write-Host "  [2] Codex       - instala no repositorio atual via `$project-planner"
Write-Host "  [3] Ambos"
Write-Host ""
$Opcao = Read-Host "Opcao [1/2/3]"

function Get-File($Src, $Dest) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Dest) | Out-Null
    $LocalPath = if ($ScriptDir -ne "") { Join-Path $ScriptDir $Src.Replace("/", "\") } else { "" }
    if ($LocalPath -ne "" -and (Test-Path $LocalPath)) {
        Copy-Item $LocalPath $Dest -Force
    } else {
        (New-Object Net.WebClient).DownloadFile("$Raw/$Src", $Dest)
    }
}

function Install-Claude {
    $Dest = "$env:USERPROFILE\.claude\commands\project-planner.md"
    Get-File "skills/project-planner/SKILL.md" $Dest
    Write-Host "  Claude CLI : $Dest"
    Write-Host "  Comando    : /project-planner"
}

function Install-Codex {
    $DestSkill = ".\skills\project-planner\SKILL.md"
    $DestYaml  = ".\skills\project-planner\agents\openai.yaml"
    Get-File "skills/project-planner/SKILL.md" $DestSkill
    Get-File "skills/project-planner/agents/openai.yaml" $DestYaml
    Write-Host "  Codex : $DestSkill"
    Write-Host "          $DestYaml"
    Write-Host "  Comando : `$project-planner"
}

Write-Host ""
switch ($Opcao) {
    "1" { Install-Claude }
    "2" { Install-Codex }
    "3" { Install-Claude; Install-Codex }
    default {
        Write-Host "Opcao invalida. Execute novamente e escolha 1, 2 ou 3."
        exit 1
    }
}

Write-Host ""
Write-Host "Pronto."
Write-Host ""
