#!/usr/bin/env bash
set -euo pipefail

GITHUB_USER="valtervilmerson"
GITHUB_REPO="agents-skill-planning"
GITHUB_BRANCH="main"
SKILL_REMOTE="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$GITHUB_BRANCH/skills/project-planner/SKILL.md"
DEST="$HOME/.claude/commands/project-planner.md"

echo ""
echo "Project Planner — instalação"
echo "-----------------------------"

mkdir -p "$(dirname "$DEST")"

# Se rodando de dentro do repo clonado, usa arquivo local. Caso contrário, baixa do GitHub.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd || echo "")"
LOCAL_SKILL="$SCRIPT_DIR/skills/project-planner/SKILL.md"

if [ -f "$LOCAL_SKILL" ]; then
  cp "$LOCAL_SKILL" "$DEST"
  echo "✓ Instalado de arquivo local"
else
  if ! command -v curl &>/dev/null; then
    echo "Erro: curl não encontrado. Instale curl e tente novamente."
    exit 1
  fi
  echo "→ Baixando de $GITHUB_USER/$GITHUB_REPO..."
  curl -fsSL "$SKILL_REMOTE" -o "$DEST"
  echo "✓ Instalado do GitHub"
fi

echo ""
echo "  Destino : $DEST"
echo "  Comando : /project-planner"
echo ""
echo "Pronto. Use /project-planner em qualquer projeto no Claude CLI."
echo ""
