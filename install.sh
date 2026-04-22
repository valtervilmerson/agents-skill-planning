#!/usr/bin/env bash
set -euo pipefail

GITHUB_USER="valtervilmerson"
GITHUB_REPO="agents-skill-planning"
GITHUB_BRANCH="main"
RAW="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$GITHUB_BRANCH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd || echo "")"
LOCAL_SKILL="$SCRIPT_DIR/skills/project-planner/SKILL.md"
LOCAL_YAML="$SCRIPT_DIR/skills/project-planner/agents/openai.yaml"

echo ""
echo "Project Planner — instalação"
echo "-----------------------------"
echo ""
echo "Para qual plataforma deseja instalar?"
echo "  [1] Claude CLI  — disponível em qualquer projeto via /project-planner"
echo "  [2] Codex       — instala no repositório atual via \$project-planner"
echo "  [3] Ambos"
echo ""
read -rp "Opção [1/2/3]: " OPCAO

download() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -f "$SCRIPT_DIR/$src" ]; then
    cp "$SCRIPT_DIR/$src" "$dest"
  else
    if ! command -v curl &>/dev/null; then
      echo "Erro: curl não encontrado. Instale curl e tente novamente."
      exit 1
    fi
    curl -fsSL "$RAW/$src" -o "$dest"
  fi
}

install_claude() {
  local dest="$HOME/.claude/commands/project-planner.md"
  download "skills/project-planner/SKILL.md" "$dest"
  echo "  Claude CLI : $dest"
  echo "  Comando    : /project-planner"
}

install_codex() {
  local dest_skill="./skills/project-planner/SKILL.md"
  local dest_yaml="./skills/project-planner/agents/openai.yaml"
  download "skills/project-planner/SKILL.md" "$dest_skill"
  download "skills/project-planner/agents/openai.yaml" "$dest_yaml"
  echo "  Codex : $dest_skill"
  echo "          $dest_yaml"
  echo "  Comando : \$project-planner"
}

echo ""
case "$OPCAO" in
  1)
    install_claude
    ;;
  2)
    install_codex
    ;;
  3)
    install_claude
    install_codex
    ;;
  *)
    echo "Opção inválida. Execute novamente e escolha 1, 2 ou 3."
    exit 1
    ;;
esac

echo ""
echo "Pronto."
echo ""
