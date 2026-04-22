$GitHubUser   = "valtervilmerson"
$GitHubRepo   = "agents-skill-planning"
$GitHubBranch = "main"
$Raw          = "https://raw.githubusercontent.com/$GitHubUser/$GitHubRepo/$GitHubBranch"

$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir  = if ($ScriptPath -ne $null -and $ScriptPath -ne "") { Split-Path -Parent $ScriptPath } else { "" }

function Get-File($Src, $Dest) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Dest) | Out-Null
    $LocalPath = if ($ScriptDir -ne "") { Join-Path $ScriptDir $Src.Replace("/", "\") } else { "" }
    if ($LocalPath -ne "" -and (Test-Path $LocalPath)) {
        Copy-Item $LocalPath $Dest -Force
    } else {
        (New-Object Net.WebClient).DownloadFile("$Raw/$Src", $Dest)
    }
}

function Install-ClaudeGlobal {
    $Dest = "$env:USERPROFILE\.claude\commands\project-planner.md"
    Get-File "skills/project-planner/SKILL.md" $Dest
    Write-Host "  Destino : $Dest"
    Write-Host "  Escopo  : global (qualquer projeto)"
    Write-Host "  Comando : /project-planner"
}

function Install-ClaudeLocal {
    $Dest = ".\.claude\commands\project-planner.md"
    Get-File "skills/project-planner/SKILL.md" $Dest
    Write-Host "  Destino : $Dest"
    Write-Host "  Escopo  : local (somente este repositorio)"
    Write-Host "  Comando : /project-planner"
}

function Install-Codex {
    Get-File "skills/project-planner/SKILL.md" ".\skills\project-planner\SKILL.md"
    Get-File "skills/project-planner/agents/openai.yaml" ".\skills\project-planner\agents\openai.yaml"
    Write-Host "  Destino : .\skills\project-planner\"
    Write-Host "  Escopo  : local (somente este repositorio)"
    Write-Host "  Comando : `$project-planner"
}

Write-Host ""
Write-Host "Project Planner - instalacao"
Write-Host "-----------------------------"
Write-Host ""
Write-Host "Plataforma:"
Write-Host "  [1] Claude CLI"
Write-Host "  [2] Codex"
Write-Host ""
$Plataforma = Read-Host "Opcao [1/2]"

Write-Host ""

switch ($Plataforma) {
    "1" {
        Write-Host "Escopo:"
        Write-Host "  [1] Global - disponivel em qualquer projeto"
        Write-Host "  [2] Local  - disponivel somente neste repositorio"
        Write-Host ""
        $Escopo = Read-Host "Opcao [1/2]"
        Write-Host ""
        switch ($Escopo) {
            "1" { Install-ClaudeGlobal }
            "2" { Install-ClaudeLocal }
            default { Write-Host "Opcao invalida."; exit 1 }
        }
    }
    "2" {
        Write-Host "Codex instala sempre no repositorio atual."
        Write-Host ""
        Install-Codex
    }
    default {
        Write-Host "Opcao invalida. Execute novamente e escolha 1 ou 2."
        exit 1
    }
}

Write-Host ""
Write-Host "Pronto."
Write-Host ""
