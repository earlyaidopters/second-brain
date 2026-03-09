#!/bin/bash
set -e

# ─────────────────────────────────────────────────────────────────────────────
#  SECOND BRAIN — One-command setup for Obsidian + Claude Code
# ─────────────────────────────────────────────────────────────────────────────

PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
RESET='\033[0m'

clear
echo ""
echo -e "${PURPLE}"
cat << 'ASCII'
  ███████╗███████╗ ██████╗ ██████╗ ███╗   ██╗██████╗
  ██╔════╝██╔════╝██╔════╝██╔═══██╗████╗  ██║██╔══██╗
  ███████╗█████╗  ██║     ██║   ██║██╔██╗ ██║██║  ██║
  ╚════██║██╔══╝  ██║     ██║   ██║██║╚██╗██║██║  ██║
  ███████║███████╗╚██████╗╚██████╔╝██║ ╚████║██████╔╝
  ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝

  ██████╗ ██████╗  █████╗ ██╗███╗   ██╗
  ██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║
  ██████╔╝██████╔╝███████║██║██╔██╗ ██║
  ██╔══██╗██╔══██╗██╔══██║██║██║╚██╗██║
  ██████╔╝██║  ██║██║  ██║██║██║ ╚████║
  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
ASCII
echo -e "${RESET}"
echo -e "${DIM}  Obsidian + Claude Code · Your AI-powered second brain${RESET}"
echo ""
echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ─── STEP 1: Check OS ───────────────────────────────────────────────────────
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo -e "${ORANGE}⚠️  This setup script is currently macOS only.${RESET}"
  echo "   Windows/Linux support coming soon."
  exit 1
fi

echo -e "${WHITE}Step 1/6 — Checking dependencies${RESET}"

# ─── STEP 2: Homebrew ────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "  Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo -e "  ${GREEN}✓${RESET} Homebrew already installed"
fi

# ─── STEP 3: Obsidian ────────────────────────────────────────────────────────
echo ""
echo -e "${WHITE}Step 2/6 — Installing Obsidian${RESET}"
if ! brew list --cask obsidian &>/dev/null 2>&1; then
  echo "  Installing Obsidian..."
  brew install --cask obsidian
  echo -e "  ${GREEN}✓${RESET} Obsidian installed"
else
  echo -e "  ${GREEN}✓${RESET} Obsidian already installed"
fi

# ─── STEP 4: Claude Code ─────────────────────────────────────────────────────
echo ""
echo -e "${WHITE}Step 3/6 — Installing Claude Code CLI${RESET}"
if ! command -v claude &>/dev/null; then
  echo "  Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | sh
  echo -e "  ${GREEN}✓${RESET} Claude Code installed"
  echo -e "  ${DIM}  Note: restart terminal if 'claude' isn't found after setup${RESET}"
else
  echo -e "  ${GREEN}✓${RESET} Claude Code already installed"
fi

# ─── STEP 5: Python deps ─────────────────────────────────────────────────────
echo ""
echo -e "${WHITE}Step 4/6 — Installing Python dependencies${RESET}"
if command -v python3 &>/dev/null; then
  # Use a local venv to avoid macOS PEP 668 "externally managed" pip errors
  python3 -m venv "$SCRIPT_DIR/.venv" 2>/dev/null || true
  "$SCRIPT_DIR/.venv/bin/pip" install -q -r "$SCRIPT_DIR/requirements.txt"     && echo -e "  ${GREEN}✓${RESET} Python packages installed"     || echo -e "  ${ORANGE}⚠${RESET}  pip install failed — try: pip3 install -r requirements.txt"
else
  echo -e "  ${ORANGE}⚠${RESET}  Python 3 not found. Install: brew install python3"
fi

# ─── STEP 6: Vault setup ─────────────────────────────────────────────────────
echo ""
echo -e "${WHITE}Step 5/6 — Setting up your vault${RESET}"
echo ""
echo -e "  Where should your second brain live?"
echo -e "  ${DIM}Press Enter for default: ~/second-brain${RESET}"
read -p "  Vault path: " VAULT_PATH
VAULT_PATH="${VAULT_PATH:-$HOME/second-brain}"
VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

mkdir -p "$VAULT_PATH"/{inbox,daily,projects,research,archive,.claude/skills/vault-setup,.claude/skills/daily,.claude/skills/tldr}

# Copy template files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/CLAUDE.md" "$VAULT_PATH/CLAUDE.md"
cp "$SCRIPT_DIR/memory.md" "$VAULT_PATH/memory.md"
cp "$SCRIPT_DIR/skills/vault-setup/SKILL.md" "$VAULT_PATH/.claude/skills/vault-setup/SKILL.md"
cp "$SCRIPT_DIR/skills/daily/SKILL.md"       "$VAULT_PATH/.claude/skills/daily/SKILL.md"
cp "$SCRIPT_DIR/skills/tldr/SKILL.md"        "$VAULT_PATH/.claude/skills/tldr/SKILL.md"
cp "$SCRIPT_DIR/scripts/process_docs_to_obsidian.py" "$VAULT_PATH/scripts/process_docs_to_obsidian.py" 2>/dev/null || \
  mkdir -p "$VAULT_PATH/scripts" && cp "$SCRIPT_DIR/scripts/process_docs_to_obsidian.py" "$VAULT_PATH/scripts/"

echo -e "  ${GREEN}✓${RESET} Vault created at $VAULT_PATH"

# ─── STEP 7: API key ─────────────────────────────────────────────────────────
echo ""
echo -e "  ${CYAN}Get your free Google API key at: https://aistudio.google.com/apikey${RESET}"
echo -e "  ${DIM}(Used by Gemini 3 Flash to process your existing files — free tier works fine)${RESET}"
echo ""
read -p "  Paste your Google API key (or press Enter to skip): " GOOGLE_KEY

if [ -n "$GOOGLE_KEY" ]; then
  echo "GOOGLE_API_KEY=$GOOGLE_KEY" > "$VAULT_PATH/.env"
  echo -e "  ${GREEN}✓${RESET} API key saved to $VAULT_PATH/.env"
else
  cp "$SCRIPT_DIR/.env.example" "$VAULT_PATH/.env"
  echo -e "  ${ORANGE}⚠${RESET}  Skipped — add your key to $VAULT_PATH/.env before processing files"
fi

# ─── STEP 8: Import existing files ───────────────────────────────────────────
echo ""
echo -e "${WHITE}Step 6/6 — Import existing files (optional)${RESET}"
echo ""
echo -e "  Do you have existing files to import into your vault?"
echo -e "  ${DIM}(PDFs, Word docs, slide decks, text files — Gemini will synthesize them)${RESET}"
echo ""
read -p "  Enter folder path to import (or press Enter to skip): " IMPORT_FOLDER

if [ -n "$IMPORT_FOLDER" ] && [ -d "$IMPORT_FOLDER" ]; then
  echo ""
  echo "  Processing files with Gemini 3 Flash..."
  cd "$VAULT_PATH"
  "$SCRIPT_DIR/.venv/bin/python3" scripts/process_docs_to_obsidian.py "$IMPORT_FOLDER" "$VAULT_PATH/inbox"
  echo ""
  echo -e "  ${GREEN}✓${RESET} Files processed → saved to $VAULT_PATH/inbox"
  echo -e "  ${DIM}Open Claude Code in your vault and say:${RESET}"
  echo -e "  ${DIM}\"Sort everything in inbox/ into the right folders\"${RESET}"
elif [ -n "$IMPORT_FOLDER" ]; then
  echo -e "  ${ORANGE}⚠${RESET}  Folder not found: $IMPORT_FOLDER"
fi

# ─── DONE ────────────────────────────────────────────────────────────────────
echo ""
echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "  ${GREEN}✅ Your second brain is ready.${RESET}"
echo ""
echo -e "  ${WHITE}Your vault:${RESET} $VAULT_PATH"
echo ""
echo -e "  ${WHITE}Next steps:${RESET}"
echo -e "  ${CYAN}1.${RESET} Open Obsidian and select your vault: ${DIM}$VAULT_PATH${RESET}"
echo -e "  ${CYAN}2.${RESET} In Obsidian → Settings → General → enable 'URI scheme'"
echo -e "  ${CYAN}3.${RESET} Open a terminal in your vault:"
echo -e "     ${DIM}cd $VAULT_PATH && claude${RESET}"
echo -e "  ${CYAN}4.${RESET} Run your first command: ${DIM}/vault-setup${RESET}"
echo -e "     Claude Code will interview you and personalize your CLAUDE.md"
echo ""
echo -e "  ${DIM}Need to process more files later?${RESET}"
echo -e "  ${DIM}"$SCRIPT_DIR/.venv/bin/python3" scripts/process_docs_to_obsidian.py ~/your-files $VAULT_PATH/inbox${RESET}"
echo ""

# Open Obsidian
if command -v open &>/dev/null; then
  open -a Obsidian "$VAULT_PATH" 2>/dev/null || open -a Obsidian 2>/dev/null || true
fi

