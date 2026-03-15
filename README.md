<div align="center">

```
 ░▒▓███████▓▒░▒▓████████▓▒░▒▓██████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░░▒▓███████▓▒░
░▒▓█▓▒░      ░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
░▒▓█▓▒░      ░▒▓█▓▒░     ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 ░▒▓██████▓▒░░▒▓██████▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
       ░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
       ░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
░▒▓███████▓▒░░▒▓████████▓▒░▒▓██████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░

 ░▒▓███████▓▒░▒▓███████▓▒░  ░▒▓██████▓▒░░▒▓█▓▒░▒▓███████▓▒░
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 ░▒▓██████▓▒░░▒▓███████▓▒░░▒▓████████▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
       ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
       ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
░▒▓███████▓▒░░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
```

**An AI that already knows who you are before you type a word.**

![macOS](https://img.shields.io/badge/macOS-✓-8A2BE2?style=flat-square) ![Windows](https://img.shields.io/badge/Windows-✓-8A2BE2?style=flat-square) ![Free](https://img.shields.io/badge/cost-free-8A2BE2?style=flat-square) ![One command](https://img.shields.io/badge/setup-one_command-8A2BE2?style=flat-square)

[Obsidian](https://obsidian.md) + [Claude Code](https://claude.ai/code) · Local · Private · One command

```
  Your files (PDFs, docs, notes)
          │
          ▼
  ┌───────────────────┐
  │   Obsidian vault  │  ← plain .md files on your computer
  │  inbox/  daily/   │
  │  projects/  ...   │
  └────────┬──────────┘
           │  Claude Code reads this folder
           ▼
  ┌───────────────────┐
  │   Claude Code     │  ← knows your projects, voice, context
  │   /vault-setup    │     before you type a single word
  │   /daily  /tldr   │
  └───────────────────┘
           │
           ▼
    AI that compounds.
    Session 1: knows your folders.
    Session 20: knows more about
    your work than you consciously remember.
```

*If this saves you hours, drop a ⭐ — it helps others find it.*

</div>

---

## Quick Start

### macOS

**Option A — One-liner** (paste this into Terminal and hit Enter):

```bash
curl -fsSL https://raw.githubusercontent.com/earlyaidopters/second-brain/main/setup.sh -o setup.sh && bash setup.sh
```

**Option B — Clone the repo:**

Open **Terminal** (press `⌘ Space`, type `Terminal`, hit Enter) and run:

```bash
git clone https://github.com/earlyaidopters/second-brain.git
cd second-brain
./setup.sh
```

> **Don't have git?** Run `xcode-select --install` first, then retry.

---

### Windows

> **First: do you have git?**
> Open **PowerShell** (press `Win`, type `powershell`, hit Enter) and run:
> ```powershell
> git --version
> ```
> If you see a version number, you're good. If not, install git from [git-scm.com](https://git-scm.com/download/win) — use all the default options during install, then reopen PowerShell.

**Option A — One-liner** (paste this into PowerShell and hit Enter):

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/earlyaidopters/second-brain/main/setup.ps1" -OutFile setup.ps1; powershell -ExecutionPolicy Bypass -File setup.ps1
```

**Option B — Clone the repo:**

Once git is ready, run:

```powershell
git clone https://github.com/earlyaidopters/second-brain.git
cd second-brain
powershell -ExecutionPolicy Bypass -File setup.ps1
```

> **"Running scripts is disabled" error?** That's a Windows safety setting. The `-ExecutionPolicy Bypass` part in the command above overrides it just for this one script — it doesn't change anything permanent on your computer.

> **Python not found warning?** Download Python from [python.org/downloads](https://python.org/downloads) — on the first screen of the installer, check **"Add Python to PATH"** before clicking Install. Then rerun the setup script.

---

The script handles the rest: installs Obsidian, installs Claude Code, creates your vault, and optionally imports your existing files.

---

## Why This Exists

You've tried to build a second brain before.

Maybe Notion. Maybe Apple Notes. Maybe a folder of markdown files you swore you'd organize.

Every time, the same outcome: you'd set it up, use it for a week, and then completely forget it existed.

The problem was never the tool. **It was that you had to remember to use it.**

This wires **Obsidian** (your local knowledge vault) to **Claude Code** (your AI agent) so that:

- Claude Code **reads your notes** before answering — it knows your projects, your clients, your voice
- Claude Code **writes your notes** after working — your vault builds itself from your sessions
- Your existing files (PDFs, docs, slides) get **synthesized and imported automatically** via Gemini 3 Flash
- Everything stays **local, private, and yours** — no cloud lock-in, no subscription creep

The result: an AI that knows who you are from the first prompt of every session. Not because you told it. Because it read your vault.

---

## What Gets Installed

| Tool | What it is | Why |
|------|-----------|-----|
| **Obsidian** | Free note-taking app | Your notes live as plain `.md` files on your computer — no cloud, no subscription, yours forever |
| **Claude Code** | Anthropic's AI terminal | Reads and writes files directly in your vault — no copy-pasting, no switching tabs |
| **Python packages** | Background libraries | Used by Gemini 3 Flash to read and synthesize your existing files (PDFs, docs, slides) |
| **Vault skills** | Slash commands | `/vault-setup` `/daily` `/tldr` `/file-intel` — teach Claude how to work with your vault |
| **Obsidian Skills** *(optional)* | Official skills by [Kepano](https://github.com/kepano) (Obsidian CEO) | Lets Claude navigate, read, and write your vault natively using the Obsidian CLI |

> **Nothing is uploaded.** Your vault is a folder on your computer. Claude Code reads it locally. The only optional network call is Gemini file processing — and that's fully skippable.

---

## What the Setup Script Does

```
Step 1 — Check dependencies       (Homebrew on Mac / winget on Windows)
Step 2 — Install Obsidian         (free, local note-taking app)
Step 3 — Install Claude Code CLI  (Anthropic's AI terminal)
Step 4 — Install Python packages  (for Gemini file processing)
Step 5 — Create your vault        (inbox, daily, projects, research, archive + skills)
Step 6 — Import existing files    (optional — Gemini reads and synthesizes them)
Step 7 — Obsidian Skills          (optional — official skills by Kepano, Obsidian CEO)
         └─> Opens Obsidian pointed at your new vault
```

---

## After Setup

### 1. Enable the Obsidian CLI
```
Obsidian → Settings → General → Enable Command Line Interface
```
This adds the `obsidian` command to your PATH so you can open your vault from the terminal. ([CLI docs](https://help.obsidian.md/cli))

### 2. Open Claude Code in your vault
```bash
cd ~/second-brain
claude
```

### 3. Run your first command
```
/vault-setup
```

Claude Code will interview you about your role and work, then generate a personalized `CLAUDE.md` and suggest slash commands for your specific workflow. Business owner gets different folders than a developer. Creator gets different slash commands than a consultant.

---

## Slash Commands

Four commands come pre-installed. More get added as you use the system.

| Command | What it does |
|---------|-------------|
| `/vault-setup` | Interviews you (role, projects, goals) and generates your personalized vault structure + CLAUDE.md + custom slash commands |
| `/daily` | Starts your day — reads today's note or creates one, surfaces your top priorities, asks what you're working on |
| `/tldr` | At the end of any session, saves a structured summary to the right folder in your vault automatically |
| `/file-intel` | Point it at any folder — Gemini reads every file and generates Obsidian-ready summaries into your inbox |

---

## Importing Existing Files

Have years of PDFs, Word docs, and slide decks sitting in folders? Don't manually convert them.

```bash
python3 scripts/process_docs_to_obsidian.py ~/your-files ~/second-brain/inbox
```

**What happens:**
1. Every file gets read by **Gemini 3 Flash** (`gemini-3-flash-preview`)
2. Signal is extracted, noise is discarded (legal boilerplate, headers, filler)
3. A clean compressed Markdown note is saved to your `inbox/` (300–600 words max)

Then open Claude Code and say: *"Sort everything in inbox/ into the right folders."*

It reads your CLAUDE.md, understands your vault structure, and routes every note to where it belongs.

**Supported formats:** `.pdf` `.docx` `.pptx` `.txt` `.md`

---

## How the Memory Works

Your vault is structured so Claude Code can find the right context for any task:

```
~/second-brain/
├── CLAUDE.md        ← The brain of the brain. Read at every session start.
├── memory.md        ← Session log. Updated by Claude Code after each conversation.
├── inbox/           ← Drop zone. Anything new lands here first.
├── daily/           ← Daily notes (YYYY-MM-DD.md). Your running log.
├── projects/        ← Active projects. Claude reads the relevant one before helping.
├── research/        ← Synthesized knowledge. Sources, notes, ideas.
└── archive/         ← Completed work. Never delete — just archive.
```

**The compounding effect:**
- Session 1: Claude knows your folder structure
- Session 5: Claude knows your projects, your voice, your preferences
- Session 20: Claude is your personalized operating system — it knows more about your knowledge base than you consciously remember

---

## Requirements

| Tool | Platform | How to get it |
|------|----------|--------------|
| Obsidian | macOS / Windows / Linux | `brew install --cask obsidian` or `winget install Obsidian.Obsidian` |
| Claude Code | macOS / Linux | `curl -fsSL https://claude.ai/install.sh \| sh` |
| Claude Code | Windows | `winget install Anthropic.ClaudeCode` |
| Python 3.8+ | All | [python.org](https://python.org) |
| Google API key | All | [aistudio.google.com/apikey](https://aistudio.google.com/apikey) — free |
| Claude account | All | [claude.ai](https://claude.ai) — Pro recommended for heavy use |

---

## Repository Structure

```
second-brain/
├── setup.sh                              ← macOS/Linux one-command setup
├── setup.ps1                             ← Windows one-command setup
├── CLAUDE.md                             ← Vault system file (personalized by /vault-setup)
├── memory.md                             ← Session memory (auto-updated by Claude Code)
├── requirements.txt                      ← Python dependencies
├── .env.example                          ← Copy to .env, add your Google API key
├── .gitignore                            ← Keeps .env and .venv out of git
├── scripts/
│   ├── process_docs_to_obsidian.py      ← Gemini 3 Flash file synthesizer
│   └── process_files_with_gemini.py     ← Batch Gemini file processor
├── skills/
│   ├── vault-setup/SKILL.md             ← Interactive vault configurator
│   ├── daily/SKILL.md                   ← Daily standup command
│   ├── tldr/SKILL.md                    ← Session summary command
│   └── file-intel/SKILL.md              ← Process any folder via Gemini
└── vault-template/
    ├── inbox/   daily/   projects/
    ├── research/   archive/
```

---

## Manual Setup

<details>
<summary>Prefer to install each piece yourself? Click to expand the full step-by-step for both platforms.</summary>

---

### macOS — Manual Steps

**1. Install Homebrew** (macOS app installer — skip if you have it)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**2. Install Obsidian**
```bash
brew install --cask obsidian
```

**3. Install Claude Code**
```bash
curl -fsSL https://claude.ai/install.sh | sh
```

**4. Download and set up the vault**
```bash
git clone https://github.com/earlyaidopters/second-brain.git
mkdir -p ~/second-brain/{inbox,daily,projects,research,archive,.claude/skills/vault-setup,.claude/skills/daily,.claude/skills/tldr,.claude/skills/file-intel,scripts}
cp second-brain/CLAUDE.md second-brain/memory.md ~/second-brain/
cp second-brain/skills/vault-setup/SKILL.md ~/second-brain/.claude/skills/vault-setup/
cp second-brain/skills/daily/SKILL.md ~/second-brain/.claude/skills/daily/
cp second-brain/skills/tldr/SKILL.md ~/second-brain/.claude/skills/tldr/
cp second-brain/skills/file-intel/SKILL.md ~/second-brain/.claude/skills/file-intel/
cp second-brain/scripts/* ~/second-brain/scripts/
cp second-brain/.env.example ~/second-brain/.env
```

**5. Add your Google API key**

Open `~/second-brain/.env` in any text editor and replace `your_key_here` with your key from [aistudio.google.com/apikey](https://aistudio.google.com/apikey).

**6. (Optional) Install Kepano's Obsidian Skills**
```bash
git clone --depth=1 https://github.com/kepano/obsidian-skills.git /tmp/obs-skills
for d in /tmp/obs-skills/skills/*/; do
  name=$(basename "$d")
  mkdir -p ~/second-brain/.claude/skills/$name
  cp "$d/SKILL.md" ~/second-brain/.claude/skills/$name/
done
rm -rf /tmp/obs-skills
```

**7. Open Claude Code in your vault**
```bash
cd ~/second-brain && claude
```

---

### Windows — Manual Steps

Open **PowerShell** for all commands below.

**1. Install Obsidian**
```powershell
winget install Obsidian.Obsidian
```

**2. Install Claude Code**
```powershell
winget install Anthropic.ClaudeCode
```
Close and reopen PowerShell after this step.

**3. Install Python** (if you don't have it)

Download from [python.org/downloads](https://python.org/downloads). On the installer's first screen, check **"Add Python to PATH"** before clicking Install.

**4. Download and set up the vault**
```powershell
git clone https://github.com/earlyaidopters/second-brain.git
$vault = "$env:USERPROFILE\second-brain"
New-Item -ItemType Directory -Force -Path "$vault\inbox","$vault\daily","$vault\projects","$vault\research","$vault\archive","$vault\scripts","$vault\.claude\skills\vault-setup","$vault\.claude\skills\daily","$vault\.claude\skills\tldr","$vault\.claude\skills\file-intel" | Out-Null
Copy-Item "second-brain\CLAUDE.md","second-brain\memory.md" $vault
Copy-Item "second-brain\skills\vault-setup\SKILL.md" "$vault\.claude\skills\vault-setup\"
Copy-Item "second-brain\skills\daily\SKILL.md" "$vault\.claude\skills\daily\"
Copy-Item "second-brain\skills\tldr\SKILL.md" "$vault\.claude\skills\tldr\"
Copy-Item "second-brain\skills\file-intel\SKILL.md" "$vault\.claude\skills\file-intel\"
Copy-Item "second-brain\scripts\*" "$vault\scripts\"
Copy-Item "second-brain\.env.example" "$vault\.env"
```

**5. Install Python dependencies**
```powershell
pip install -r second-brain\requirements.txt
```

**6. Add your Google API key**

Open `%USERPROFILE%\second-brain\.env` in Notepad and replace `your_key_here` with your key from [aistudio.google.com/apikey](https://aistudio.google.com/apikey).

**7. (Optional) Install Kepano's Obsidian Skills**
```powershell
$tmp = "$env:TEMP\obs-skills"
git clone --depth=1 https://github.com/kepano/obsidian-skills.git $tmp
Get-ChildItem "$tmp\skills" -Directory | ForEach-Object {
    $dest = "$env:USERPROFILE\second-brain\.claude\skills\$($_.Name)"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item "$($_.FullName)\SKILL.md" "$dest\" -Force
}
Remove-Item $tmp -Recurse -Force
```

**8. Open Claude Code in your vault**
```powershell
cd "$env:USERPROFILE\second-brain"
claude
```

</details>

---

## FAQ

**Is my data private?**
Yes. Obsidian stores everything as local markdown files on your computer. Nothing is uploaded to any server. Claude Code processes your files locally in the folder you open it in. The only time anything leaves your machine is when you call the Gemini API to process existing files — and that's optional.

**Do I need a paid Claude account?**
The free tier works for light use. For daily use with long sessions, Claude Pro ($20/month) gives substantially more usage than equivalent API costs in other tools.

**What if I already have an Obsidian vault?**
The setup script asks where your vault is. Point it at your existing vault — it'll copy the CLAUDE.md template, skills, and scripts into it without touching your existing notes.

**Can I use this without the file processing?**
Absolutely. The Gemini API key and file processing are optional. The core system (Obsidian + Claude Code + CLAUDE.md + slash commands) works without it.

---

<div align="center">

Built by [Mark Kashef](https://youtube.com/@marwankashef) · [Prompt Advisers](https://promptadvisers.com)

*If this helped you build your second brain, drop a ⭐ — it helps others find it.*

</div>
