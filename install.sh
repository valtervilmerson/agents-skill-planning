#!/usr/bin/env bash
set -euo pipefail

GITHUB_USER="valtervilmerson"
GITHUB_REPO="agents-skill-planning"
GITHUB_BRANCH="main"
RAW="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$GITHUB_BRANCH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd || echo "")"

echo ""
echo "Project Planner — instalacao"
echo "-----------------------------"
echo ""
echo "Plataforma:"
echo "  [1] Claude CLI"
echo "  [2] Codex"
echo ""
read -rp "Opcao [1/2]: " PLATAFORMA

download() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  local local_path=""
  if [ -n "$SCRIPT_DIR" ]; then
    local_path="$SCRIPT_DIR/$src"
  fi
  if [ -n "$local_path" ] && [ -f "$local_path" ]; then
    cp "$local_path" "$dest"
  else
    if ! command -v curl &>/dev/null; then
      echo "Erro: curl nao encontrado. Instale curl e tente novamente."
      exit 1
    fi
    curl -fsSL "$RAW/$src" -o "$dest"
  fi
}

install_claude_global() {
  local dest="$HOME/.claude/commands/project-planner.md"
  download "skills/project-planner/SKILL.md" "$dest"
  echo "  Destino : $dest"
  echo "  Escopo  : global (qualquer projeto)"
  echo "  Comando : /project-planner"
}

install_claude_local() {
  local dest="./.claude/commands/project-planner.md"
  download "skills/project-planner/SKILL.md" "$dest"
  echo "  Destino : $dest"
  echo "  Escopo  : local (somente este repositorio)"
  echo "  Comando : /project-planner"
}

install_codex() {
  download "skills/project-planner/SKILL.md" "./skills/project-planner/SKILL.md"
  download "skills/project-planner/agents/openai.yaml" "./skills/project-planner/agents/openai.yaml"
  echo "  Destino : ./skills/project-planner/"
  echo "  Escopo  : local (somente este repositorio)"
  echo "  Comando : \$project-planner"
}

echo ""

case "$PLATAFORMA" in
  1)
    echo "Escopo:"
    echo "  [1] Global — disponivel em qualquer projeto"
    echo "  [2] Local  — disponivel somente neste repositorio"
    echo ""
    read -rp "Opcao [1/2]: " ESCOPO
    echo ""
    case "$ESCOPO" in
      1) install_claude_global ;;
      2) install_claude_local ;;
      *) echo "Opcao invalida."; exit 1 ;;
    esac
    ;;
  2)
    echo "Codex instala sempre no repositorio atual."
    echo ""
    install_codex
    ;;
  *)
    echo "Opcao invalida. Execute novamente e escolha 1 ou 2."
    exit 1
    ;;
esac

echo ""
echo "Pronto."
echo ""
