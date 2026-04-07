#!/bin/bash
set -e

# ─────────────────────────────────────────────────────────────────────────────
#  SECOND BRAIN — One-command setup for Obsidian + Claude Code
# ─────────────────────────────────────────────────────────────────────────────

# SCRIPT_DIR must be defined first — used throughout
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Self-bootstrap: if repo files are missing, clone them ────────────────────
# This happens when the script is run via the one-liner curl command.
# We clone the full repo into a temp dir and re-exec from there.
if [ ! -f "$SCRIPT_DIR/CLAUDE.md" ]; then
  echo "Downloading Second Brain repo..."
  BOOTSTRAP_DIR="$(mktemp -d)"
  if ! git clone --depth=1 https://github.com/earlyaidopters/second-brain.git "$BOOTSTRAP_DIR" &>/dev/null; then
    echo "Error: Could not clone repo. Check your internet connection."
    echo "Alternative: download the ZIP from https://github.com/earlyaidopters/second-brain"
    echo "             unzip it, cd into it, and run: bash setup.sh"
    exit 1
  fi
  # Pass cleanup marker so the re-exec'd script can clean up
  SECOND_BRAIN_BOOTSTRAP_DIR="$BOOTSTRAP_DIR" exec bash "$BOOTSTRAP_DIR/setup.sh"
fi

# Clean up bootstrap temp dir if we were re-exec'd from the one-liner
if [ -n "$SECOND_BRAIN_BOOTSTRAP_DIR" ] && [ -d "$SECOND_BRAIN_BOOTSTRAP_DIR" ]; then
  trap 'rm -rf "$SECOND_BRAIN_BOOTSTRAP_DIR"' EXIT
fi

PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
WHITE='\033[1;37m'
DIM='\033[2m'
RESET='\033[0m'

# Helper: safe copy with fallback (prevents set -e from killing the script)
safe_cp() {
  if [ -f "$1" ]; then
    cp "$1" "$2"
  else
    echo -e "  ${ORANGE}⚠${RESET}  Missing: $1"
    return 0  # don't crash under set -e
  fi
}

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
echo -e "  ${WHITE}What this script installs:${RESET}"
echo ""
echo -e "  ${PURPLE}Obsidian${RESET}              Free note-taking app. Notes live as plain text files"
echo -e "                        on your computer — private, local, forever yours."
echo ""
echo -e "  ${PURPLE}Claude Code${RESET}           Anthropic's AI that runs in your terminal. Reads and"
echo -e "                        writes your vault directly — no copy-pasting."
echo ""
echo -e "  ${PURPLE}Python packages${RESET}       Background libraries used by Gemini 3 Flash to read"
echo -e "                        and synthesize your existing files (PDFs, docs, slides)."
echo ""
echo -e "  ${PURPLE}Vault skills${RESET}          Slash commands that teach Claude how to use your vault:"
echo -e "                        /vault-setup  /daily  /tldr  /file-intel"
echo ""
echo -e "  ${PURPLE}Obsidian Skills${RESET}       Official skills by Kepano (Obsidian CEO) — lets Claude"
echo -e "  ${DIM}(optional)${RESET}            navigate your vault using the Obsidian CLI."
echo ""
echo -e "  ${DIM}  Nothing is uploaded. Your vault stays on your machine.${RESET}"
echo ""
echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ─── STEP 1: Check OS ───────────────────────────────────────────────────────
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo -e "${ORANGE}⚠️  This setup script is currently macOS only.${RESET}"
  echo "   Windows: run setup.ps1 instead."
  exit 1
fi

echo -e "${WHITE}Step 1/7 — Checking dependencies + Homebrew${RESET}"

# ─── STEP 2: Homebrew ────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "  Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo -e "  ${GREEN}✓${RESET} Homebrew already installed"
fi

# ─── STEP 3: Obsidian ────────────────────────────────────────────────────────
echo ""
echo -e "${WHITE}Step 2/7 — Installing Obsidian${RESET}"
# Check brew AND direct DMG install (/Applications/Obsidian.app)
if brew list --cask obsidian &>/dev/null 2>&1 || [ -d "/Applications/Obsidian.app" ]; then
  echo -e "  ${GREEN}✓${RESET} Obsidian already installed"
else
  echo "  Installing Obsidian..."
  if brew install --cask obsidian; then
    echo -e "  ${GREEN}✓${RESET} Obsidian installed"
  else
    echo -e "  ${ORANGE}⚠${RESET}  Could not install via Homebrew. Download from: https://obsidian.md/download"
  fi
fi

# ─── STEP 4: Claude Code ─────────────────────────────────────────────────────
echo ""
echo -e "${WHITE}Step 3/7 — Installing Claude Code CLI${RESET}"
if ! command -v claude &>/dev/null; then
  echo "  Installing Claude Code..."
  if curl -fsSL https://claude.ai/install.sh | sh; then
    echo -e "  ${GREEN}✓${RESET} Claude Code installed"
    echo -e "  ${DIM}  Note: restart terminal if 'claude' isn't found after setup${RESET}"
  else
    echo -e "  ${ORANGE}⚠${RESET}  Install failed. Try manually: npm install -g @anthropic-ai/claude-code"
  fi
else
  echo -e "  ${GREEN}✓${RESET} Claude Code already installed"
fi

# ─── STEP 5: Python deps (venv to avoid PEP 668 on modern macOS) ─────────────
echo ""
echo -e "${WHITE}Step 4/7 — Installing Python dependencies${RESET}"
PIP_OK=false
if command -v python3 &>/dev/null; then
  VENV_DIR="$HOME/.second-brain-venv"
  python3 -m venv "$VENV_DIR" 2>/dev/null || true
  if "$VENV_DIR/bin/pip" install -q -r "$SCRIPT_DIR/requirements.txt" 2>/dev/null; then
    echo -e "  ${GREEN}✓${RESET} Python packages installed"
    PIP_OK=true
  else
    echo -e "  ${ORANGE}⚠${RESET}  pip install failed. To retry manually:"
    echo -e "     python3 -m venv ~/.second-brain-venv && ~/.second-brain-venv/bin/pip install -r requirements.txt"
  fi
else
  echo -e "  ${ORANGE}⚠${RESET}  Python 3 not found. Install: brew install python3"
fi

# ─── STEP 6: Vault setup ─────────────────────────────────────────────────────
echo ""
echo -e "${WHITE}Step 5/7 — Setting up your vault${RESET}"
echo ""
echo -e "  Where should your second brain live?"
echo -e "  ${DIM}Press Enter for default: ~/second-brain${RESET}"
echo -e "  ${DIM}(e.g. ~/Documents/MyVault or /Users/yourname/Notes)${RESET}"
read -rp "  Vault path: " VAULT_PATH
VAULT_PATH="${VAULT_PATH:-$HOME/second-brain}"
VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

# Strip trailing slash (unless it's root /)
if [ "${#VAULT_PATH}" -gt 1 ]; then
  VAULT_PATH="${VAULT_PATH%/}"
fi

# Guard: don't let vault = the repo folder (causes identical file cp errors)
REAL_VAULT="$(cd "$VAULT_PATH" 2>/dev/null && pwd || echo "$VAULT_PATH")"
REAL_SCRIPT="$(cd "$SCRIPT_DIR" 2>/dev/null && pwd)"
if [ "$REAL_VAULT" = "$REAL_SCRIPT" ]; then
  echo -e "  ${ORANGE}⚠${RESET}  Vault can't be the same folder as the repo. Using ~/second-brain instead."
  VAULT_PATH="$HOME/second-brain"
fi

# Guard: check if path is an existing file (not a directory)
if [ -e "$VAULT_PATH" ] && [ ! -d "$VAULT_PATH" ]; then
  echo -e "  ${RED}✗${RESET} That path points to a file, not a folder: $VAULT_PATH"
  echo "  Please re-run and enter a folder path."
  exit 1
fi

# --- Detect existing vault ---------------------------------------------------
IS_EXISTING_VAULT=false
HAS_OBSIDIAN_FOLDER=false
HAS_EXISTING_CLAUDE=false

if [ -d "$VAULT_PATH/.obsidian" ]; then
  HAS_OBSIDIAN_FOLDER=true
fi

if [ -f "$VAULT_PATH/CLAUDE.md" ]; then
  HAS_EXISTING_CLAUDE=true
fi

# Check if directory exists and is non-empty (excluding .DS_Store)
IS_NON_EMPTY=false
if [ -d "$VAULT_PATH" ] && [ -n "$(ls -A "$VAULT_PATH" 2>/dev/null | grep -v '^\.DS_Store$')" ]; then
  IS_NON_EMPTY=true
fi

if [ "$HAS_OBSIDIAN_FOLDER" = true ] || [ "$IS_NON_EMPTY" = true ]; then
  IS_EXISTING_VAULT=true
  echo ""
  echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "  ${CYAN}Existing vault detected at: $VAULT_PATH${RESET}"
  echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo -e "  We found existing files here. The script will:"
  echo ""
  echo -e "  ${GREEN}+${RESET} Add missing folders (inbox/, daily/, projects/, etc.)"
  echo -e "  ${GREEN}+${RESET} Install 4 slash commands: /vault-setup /daily /tldr /file-intel"
  echo -e "  ${GREEN}+${RESET} Copy helper scripts to scripts/"
  echo -e "  ${GREEN}+${RESET} Install skills globally to ~/.claude/skills/"
  if [ "$HAS_EXISTING_CLAUDE" = true ]; then
    PREVIEW_BACKUP="CLAUDE.md.backup-$(date +%Y-%m-%d-%H%M%S)"
    echo -e "  ${ORANGE}!${RESET} Back up your existing CLAUDE.md → $PREVIEW_BACKUP"
    echo -e "  ${ORANGE}!${RESET} Install new CLAUDE.md template (run /vault-setup to personalize)"
  else
    echo -e "  ${GREEN}+${RESET} Create CLAUDE.md template (run /vault-setup to personalize)"
  fi
  echo ""
  echo -e "  ${WHITE}Will NOT touch:${RESET}"
  echo -e "  - Your existing notes, including files already in inbox/, daily/, etc."
  echo -e "  - Your Obsidian plugins, themes, and settings (.obsidian/)"
  echo ""
  read -rp "  Continue? [Y/n]: " CONTINUE_ANSWER
  CONTINUE_ANSWER="${CONTINUE_ANSWER:-Y}"
  if [[ ! "$CONTINUE_ANSWER" =~ ^[Yy] ]]; then
    echo "  Setup cancelled. Your vault is unchanged."
    exit 0
  fi

  # Backup existing CLAUDE.md
  if [ "$HAS_EXISTING_CLAUDE" = true ]; then
    BACKUP_NAME="CLAUDE.md.backup-$(date +%Y-%m-%d-%H%M%S)"
    cp "$VAULT_PATH/CLAUDE.md" "$VAULT_PATH/$BACKUP_NAME"
    echo -e "  ${GREEN}✓${RESET} Backed up existing CLAUDE.md → $BACKUP_NAME"
  fi
fi

mkdir -p "$VAULT_PATH"/{inbox,daily,projects,research,archive,scripts,.claude/skills/vault-setup,.claude/skills/daily,.claude/skills/tldr,.claude/skills/file-intel}

# Copy core files using safe_cp (won't crash if source is missing)
safe_cp "$SCRIPT_DIR/CLAUDE.md"  "$VAULT_PATH/CLAUDE.md"

# Copy memory.md: on fresh installs always, on existing vaults only if missing
if [ "$IS_EXISTING_VAULT" = false ] || [ ! -f "$VAULT_PATH/memory.md" ]; then
  safe_cp "$SCRIPT_DIR/memory.md"  "$VAULT_PATH/memory.md"
fi

safe_cp "$SCRIPT_DIR/skills/vault-setup/SKILL.md" "$VAULT_PATH/.claude/skills/vault-setup/SKILL.md"
safe_cp "$SCRIPT_DIR/skills/daily/SKILL.md"       "$VAULT_PATH/.claude/skills/daily/SKILL.md"
safe_cp "$SCRIPT_DIR/skills/tldr/SKILL.md"        "$VAULT_PATH/.claude/skills/tldr/SKILL.md"
safe_cp "$SCRIPT_DIR/skills/file-intel/SKILL.md"  "$VAULT_PATH/.claude/skills/file-intel/SKILL.md"
safe_cp "$SCRIPT_DIR/scripts/process_docs_to_obsidian.py" "$VAULT_PATH/scripts/process_docs_to_obsidian.py"
safe_cp "$SCRIPT_DIR/scripts/process_files_with_gemini.py" "$VAULT_PATH/scripts/process_files_with_gemini.py"

# Also install skills globally so they work in ANY folder, not just the vault
mkdir -p "$HOME/.claude/skills/vault-setup" "$HOME/.claude/skills/daily" \
         "$HOME/.claude/skills/tldr" "$HOME/.claude/skills/file-intel"
safe_cp "$SCRIPT_DIR/skills/vault-setup/SKILL.md" "$HOME/.claude/skills/vault-setup/SKILL.md"
safe_cp "$SCRIPT_DIR/skills/daily/SKILL.md"       "$HOME/.claude/skills/daily/SKILL.md"
safe_cp "$SCRIPT_DIR/skills/tldr/SKILL.md"        "$HOME/.claude/skills/tldr/SKILL.md"
safe_cp "$SCRIPT_DIR/skills/file-intel/SKILL.md"  "$HOME/.claude/skills/file-intel/SKILL.md"

if [ "$IS_EXISTING_VAULT" = true ]; then
  echo -e "  ${GREEN}✓${RESET} Skills + scripts added to existing vault at $VAULT_PATH"
else
  echo -e "  ${GREEN}✓${RESET} Vault created at $VAULT_PATH"
fi
echo -e "  ${GREEN}✓${RESET} Skills installed globally — work in any folder"

# ─── API key (masked input) ──────────────────────────────────────────────────
echo ""
echo -e "  ${CYAN}Get your free Google API key at: https://aistudio.google.com/apikey${RESET}"
echo -e "  ${DIM}(Used by Gemini 3 Flash to process your existing files — free tier works)${RESET}"
echo -e "  ${DIM}Your key will NOT be visible as you paste — this is normal. Press Enter when done.${RESET}"
echo ""
read -rsp "  Paste your Google API key (or press Enter to skip): " GOOGLE_KEY
echo ""  # newline after hidden input

# Trim whitespace from API key (clipboard paste often adds spaces)
GOOGLE_KEY="$(echo "$GOOGLE_KEY" | tr -d '[:space:]')"

if [ -n "$GOOGLE_KEY" ]; then
  # Use printf to safely write the key (handles special characters)
  printf 'GOOGLE_API_KEY=%s\n' "$GOOGLE_KEY" > "$VAULT_PATH/.env"
  echo -e "  ${GREEN}✓${RESET} API key saved (hidden from display)"
else
  if [ ! -f "$VAULT_PATH/.env" ]; then
    safe_cp "$SCRIPT_DIR/.env.example" "$VAULT_PATH/.env"
  fi
  echo -e "  ${ORANGE}⚠${RESET}  Skipped — add your key to $VAULT_PATH/.env before processing files"
fi

# ─── Import existing files ───────────────────────────────────────────────────
echo ""
echo -e "${WHITE}Step 6/7 — Import existing files (optional)${RESET}"
echo ""
echo -e "  Do you have existing files to import? (PDFs, Word docs, slides)"
echo -e "  ${DIM}Gemini 3 Flash will synthesize them into clean Markdown notes${RESET}"
echo ""
read -rp "  Folder path to import (or press Enter to skip): " IMPORT_FOLDER

if [ -n "$IMPORT_FOLDER" ] && [ -d "$IMPORT_FOLDER" ]; then
  if [ "$PIP_OK" = false ]; then
    echo -e "  ${ORANGE}⚠${RESET}  Python packages were not installed in Step 4."
    echo -e "     File processing may fail. Install Python + deps first, then run manually:"
    echo -e "     ${DIM}python3 \"$VAULT_PATH/scripts/process_docs_to_obsidian.py\" \"$IMPORT_FOLDER\" \"$VAULT_PATH/inbox\"${RESET}"
  else
    echo ""
    echo "  Processing files with Gemini 3 Flash..."
    if "$HOME/.second-brain-venv/bin/python3" "$VAULT_PATH/scripts/process_docs_to_obsidian.py" \
      "$IMPORT_FOLDER" "$VAULT_PATH/inbox"; then
      echo ""
      echo -e "  ${GREEN}✓${RESET} Files processed → saved to $VAULT_PATH/inbox"
      echo -e "  ${DIM}Open Claude Code and say: \"Sort everything in inbox/ into the right folders\"${RESET}"
    else
      echo ""
      echo -e "  ${ORANGE}⚠${RESET}  File processing failed — check your API key in .env and try again manually"
    fi
  fi
elif [ -n "$IMPORT_FOLDER" ]; then
  echo -e "  ${ORANGE}⚠${RESET}  Folder not found: $IMPORT_FOLDER"
fi

# ─── Kepano Obsidian Skills (optional) ──────────────────────────────────────
echo ""
echo -e "${WHITE}Step 7/7 — Obsidian Skills by Kepano (optional)${RESET}"
echo ""
echo -e "  Kepano (Steph Ango) is the CEO of Obsidian. He published a set of"
echo -e "  official agent skills that teach Claude Code to natively read, write,"
echo -e "  and navigate your vault using the Obsidian CLI."
echo ""
echo -e "  Adds these slash commands to Claude Code:"
echo -e "  ${DIM}  obsidian-cli · obsidian-markdown · obsidian-bases · json-canvas${RESET}"
echo -e "  ${DIM}  (Read-only navigation commands — they do not send your notes anywhere.)${RESET}"
echo ""
read -rp "  Install Kepano's Obsidian skills? [Y/n]: " KEPANO_ANSWER
KEPANO_ANSWER="${KEPANO_ANSWER:-Y}"

if [[ "$KEPANO_ANSWER" =~ ^[Yy] ]]; then
  echo "  Cloning obsidian-skills..."
  TEMP_DIR=$(mktemp -d)
  if git clone --depth=1 https://github.com/kepano/obsidian-skills.git "$TEMP_DIR/obsidian-skills" &>/dev/null; then
    for skill_dir in "$TEMP_DIR/obsidian-skills/skills"/*/; do
      skill_name=$(basename "$skill_dir")
      # Install to vault AND globally
      mkdir -p "$VAULT_PATH/.claude/skills/$skill_name" "$HOME/.claude/skills/$skill_name"
      cp "$skill_dir/SKILL.md" "$VAULT_PATH/.claude/skills/$skill_name/SKILL.md" 2>/dev/null || true
      cp "$skill_dir/SKILL.md" "$HOME/.claude/skills/$skill_name/SKILL.md" 2>/dev/null || true
    done
    rm -rf "$TEMP_DIR"
    echo -e "  ${GREEN}✓${RESET} Kepano's Obsidian skills installed (vault + global)"
  else
    rm -rf "$TEMP_DIR"
    echo -e "  ${ORANGE}⚠${RESET}  Couldn't reach GitHub."
    echo -e "     Optional — your vault works without this."
    echo -e "     To install later: ${DIM}https://github.com/kepano/obsidian-skills${RESET}"
  fi
else
  echo -e "  ${DIM}  Skipped — install anytime: https://github.com/kepano/obsidian-skills${RESET}"
fi

# ─── VERIFICATION ────────────────────────────────────────────────────────────
echo ""
echo -e "  ${WHITE}Checking installation...${RESET}"
echo -e "  ${DIM}(Any failures above are safe to retry — just re-run this script.)${RESET}"
echo ""

if brew list --cask obsidian &>/dev/null 2>&1 || [ -d "/Applications/Obsidian.app" ]; then
  echo -e "  ${GREEN}✓${RESET} Obsidian"
else
  echo -e "  ${ORANGE}✗${RESET} Obsidian — run: brew install --cask obsidian"
fi

if command -v claude &>/dev/null; then
  echo -e "  ${GREEN}✓${RESET} Claude Code  $(claude --version 2>/dev/null | head -1)"
else
  echo -e "  ${ORANGE}✗${RESET} Claude Code not in PATH — restart terminal then run: claude"
fi

if command -v python3 &>/dev/null; then
  echo -e "  ${GREEN}✓${RESET} $(python3 --version 2>&1)"
else
  echo -e "  ${ORANGE}✗${RESET} Python 3 not found — run: brew install python3"
fi

if [ -f "$VAULT_PATH/CLAUDE.md" ]; then
  echo -e "  ${GREEN}✓${RESET} Vault  $VAULT_PATH"
else
  echo -e "  ${ORANGE}✗${RESET} Vault files missing at $VAULT_PATH"
fi

SKILL_COUNT=$(find "$VAULT_PATH/.claude/skills" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${RESET} $SKILL_COUNT skills installed"

# ─── IMPORTANT WARNINGS ─────────────────────────────────────────────────────
echo ""
echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "  ${ORANGE}IMPORTANT — Read before using:${RESET}"
echo ""
echo -e "  ${WHITE}Obsidian Sync / Cloud Sync users:${RESET}"
echo -e "  If you use Obsidian Sync, iCloud, Dropbox, or any cloud"
echo -e "  sync, ${RED}EXCLUDE${RESET} these folders from sync:"
echo -e "  ${CYAN}.claude/${RESET}  ${CYAN}scripts/${RESET}  ${CYAN}.env${RESET}"
echo ""
echo -e "  In Obsidian: Settings → Sync → Excluded folders"
echo -e "  Add: .claude, scripts"
echo ""
echo -e "  ${RED}Why?${RESET} If .claude/ gets synced, it can create a recursive loop"
echo -e "  that bloats your vault and corrupts Claude's context."
echo -e "  (In severe cases, this has made vaults completely unusable.)"
echo ""
echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ─── DONE ────────────────────────────────────────────────────────────────────
if [ "$IS_EXISTING_VAULT" = true ]; then
  echo -e "  ${GREEN}✅ Your vault is upgraded.${RESET}"
  echo ""
  echo -e "  ${WHITE}What you just got:${RESET}"
  echo -e "  - 4 slash commands: /vault-setup /daily /tldr /file-intel"
  if [ "$HAS_EXISTING_CLAUDE" = true ]; then
    echo -e "  - New CLAUDE.md template (your original backed up as $BACKUP_NAME)"
  else
    echo -e "  - CLAUDE.md template (personalize with /vault-setup)"
  fi
  echo -e "  - Missing vault folders added (your existing notes untouched)"
  echo -e "  - File processing scripts in scripts/"
else
  echo -e "  ${GREEN}✅ Your second brain is ready.${RESET}"
  echo ""
  echo -e "  ${WHITE}What you just got:${RESET}"
  echo -e "  - 4 slash commands: /vault-setup /daily /tldr /file-intel"
  echo -e "  - CLAUDE.md template (personalize it with /vault-setup)"
  echo -e "  - Vault folder structure for organizing your notes"
  echo -e "  - File processing scripts (optional, needs Gemini API key)"
fi
echo ""
echo -e "  Claude Code now knows your vault structure and will read it before every session."
echo ""
echo -e "  ${WHITE}Vault:${RESET} $VAULT_PATH"
echo ""
echo -e "  ${WHITE}Next steps:${RESET}"
echo -e "  ${CYAN}1.${RESET} Open Obsidian → open vault → ${DIM}$VAULT_PATH${RESET}"
echo -e "  ${CYAN}2.${RESET} In Obsidian: gear icon (bottom-left) → General → Enable CLI"
echo -e "  ${CYAN}3.${RESET} In a new terminal:"
echo -e "     ${DIM}cd \"$VAULT_PATH\" && claude${RESET}"
echo -e "  ${CYAN}4.${RESET} Type ${DIM}/vault-setup${RESET} — Claude will interview you and personalize your vault"
echo ""
echo -e "  ${DIM}This script is safe to re-run — it detects existing vaults, creates"
echo -e "  timestamped backups of CLAUDE.md, and only adds what is missing.${RESET}"
echo ""

# Open Obsidian
open -a Obsidian "$VAULT_PATH" 2>/dev/null || open -a Obsidian 2>/dev/null || true