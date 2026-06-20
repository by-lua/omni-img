#!/usr/bin/env bash
# Install script for omni-img (CLI + Claude Code global skill)
#
# Installs:
#   1. CLI binary in /usr/local/bin/omni-img
#   2. Claude Code global skill in ~/.claude/skills/omni-img/
#      (so any project on your machine has access)
#   3. Hermes skill copy in ~/.hermes/skills/media/omni-img/
#      (if Hermes Agent is installed)
#
# Re-run anytime to update.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------- 1. CLI binary ----------
chmod +x "$SCRIPT_DIR/omni_img"

if [ -w /usr/local/bin ]; then
    cp "$SCRIPT_DIR/omni_img" /usr/local/bin/omni-img
    echo "OK: CLI instalado em /usr/local/bin/omni-img"
else
    sudo cp "$SCRIPT_DIR/omni_img" /usr/local/bin/omni-img
    echo "OK: CLI instalado em /usr/local/bin/omni-img (com sudo)"
fi

# ---------- 2. Claude Code global skill ----------
CLAUDE_SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.claude/skills/omni-img}"
mkdir -p "$CLAUDE_SKILL_DIR"
cp "$SCRIPT_DIR/SKILL.md" "$CLAUDE_SKILL_DIR/SKILL.md"
cp "$SCRIPT_DIR/omni_img" "$CLAUDE_SKILL_DIR/omni_img"
chmod +x "$CLAUDE_SKILL_DIR/omni_img"
echo "OK: Claude Code skill instalado em $CLAUDE_SKILL_DIR/"
echo "    (disponivel em qualquer projeto do Claude Code na sua maquina)"

# ---------- 3. Hermes Agent skill (se existir) ----------
HERMES_SKILL_DIR="$HOME/.hermes/skills/media/omni-img"
if [ -d "$HOME/.hermes" ]; then
    mkdir -p "$HERMES_SKILL_DIR"
    cp "$SCRIPT_DIR/SKILL.md" "$HERMES_SKILL_DIR/SKILL.md"
    echo "OK: Hermes Agent skill instalado em $HERMES_SKILL_DIR/"
fi

echo ""
echo "Proximos passos:"
echo "  omni-img config https://sua-ominiroute.com.br sk-xxx"
echo "  omni-img models"
echo "  omni-img pick"
echo "  omni-img generate \"um gato astronauta\""
echo ""
echo "Desinstalar:"
echo "  sudo rm /usr/local/bin/omni-img"
echo "  rm -rf ~/.claude/skills/omni-img"
echo "  rm -rf ~/.hermes/skills/media/omni-img"
