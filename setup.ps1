# ─────────────────────────────────────────────────────────────────────────────
#  SECOND BRAIN — Windows Setup (PowerShell)
#  Compatible with PowerShell 5.1+ (Windows default) and PowerShell 7+
#  Run with: powershell -ExecutionPolicy Bypass -File setup.ps1
# ─────────────────────────────────────────────────────────────────────────────

# --- Enable ANSI/VT100 color support for PS 5.1 (best-effort) ---------------
# PS 7+ enables this automatically. PS 5.1 on Windows 10 1903+ supports it
# but needs it turned on via Win32 API. If this fails, colors show as raw
# escape codes — ugly but the script still works.
try {
    $null = Add-Type -MemberDefinition @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool SetConsoleMode(IntPtr h, uint m);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GetConsoleMode(IntPtr h, out uint m);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern IntPtr GetStdHandle(int n);
'@ -Name 'VTConsole' -Namespace 'SecondBrainVT' -ErrorAction Stop
    $h = [SecondBrainVT.VTConsole]::GetStdHandle(-11)
    $mode = 0
    [SecondBrainVT.VTConsole]::GetConsoleMode($h, [ref]$mode) | Out-Null
    [SecondBrainVT.VTConsole]::SetConsoleMode($h, $mode -bor 0x0004) | Out-Null
} catch {
    # VT enablement failed — colors will show as raw escape codes
    # The script still works, just not pretty
}

# Fix winget UTF-8 encoding for PS 5.1 (prevents mojibake in winget output)
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# --- PowerShell 5.1 compatible escape codes (no backtick-e) -----------------
$ESC       = [char]27
$Purple    = "$ESC[35m"
$Green     = "$ESC[32m"
$Orange    = "$ESC[33m"
$Red       = "$ESC[31m"
$White     = "$ESC[1;37m"
$Cyan      = "$ESC[36m"
$Dim       = "$ESC[2m"
$Reset     = "$ESC[0m"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# --- Self-bootstrap: if repo files are missing, clone them -------------------
# This happens when the script is run via the one-liner (Invoke-WebRequest).
# We clone the full repo and re-exec from there.
if (-not (Test-Path "$scriptDir\CLAUDE.md")) {
    Write-Host "Repo files not found alongside script. Downloading full repo..."
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host ""
        Write-Host "  ${Red}ERROR${Reset}  git is required but not found."
        Write-Host ""
        Write-Host "  ${White}Option 1:${Reset} Install git, then re-run:"
        Write-Host "    winget install --id Git.Git --silent --accept-package-agreements --accept-source-agreements"
        Write-Host "    (Close and reopen PowerShell after installing git)"
        Write-Host ""
        Write-Host "  ${White}Option 2:${Reset} Clone the repo manually:"
        Write-Host "    1. Install git from https://git-scm.com/download/win"
        Write-Host "    2. git clone https://github.com/earlyaidopters/second-brain.git"
        Write-Host "    3. cd second-brain"
        Write-Host "    4. powershell -ExecutionPolicy Bypass -File setup.ps1"
        exit 1
    }
    $bootstrapDir = Join-Path ([System.IO.Path]::GetTempPath()) "second-brain-setup"
    Remove-Item $bootstrapDir -Recurse -Force -ErrorAction SilentlyContinue
    git clone --depth=1 https://github.com/earlyaidopters/second-brain.git $bootstrapDir *>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ${Red}ERROR${Reset}  Could not clone repo. Check your internet connection."
        Write-Host "  Alternative: download from https://github.com/earlyaidopters/second-brain"
        exit 1
    }
    Write-Host "  ${Green}OK${Reset} Repo downloaded"
    # Re-exec from the cloned repo
    & powershell -ExecutionPolicy Bypass -File "$bootstrapDir\setup.ps1"
    Remove-Item $bootstrapDir -Recurse -Force -ErrorAction SilentlyContinue
    exit $LASTEXITCODE
}

Clear-Host
Write-Host ""
Write-Host "${Purple}" -NoNewline
Write-Host @"
  ___  ___  ___ ___  _  _ ___     ___ ___  _   ___ _  _
 / __|| __|| __/ _ \| \| ||   \  | _ )_ _|/_\ |_ _| \| |
 \__ \| _| | _| (_) | .`` || |) | | _ \| | / _ \ | || .`` |
 |___/|___||___\___/|_|\_||___/  |___/___/_/ \_\___|_|\_|
"@
Write-Host "${Reset}"
Write-Host "  Obsidian + Claude Code - Your AI-powered second brain"
Write-Host ""
Write-Host "  ====================================================="
Write-Host ""
Write-Host "  ${White}What this script installs:${Reset}"
Write-Host ""
Write-Host "  ${Purple}Obsidian${Reset}              Free note-taking app. Notes live as plain text files"
Write-Host "                        on your computer - private, local, forever yours."
Write-Host ""
Write-Host "  ${Purple}Claude Code${Reset}           Anthropic's AI that runs in your terminal. Reads and"
Write-Host "                        writes your vault directly - no copy-pasting."
Write-Host ""
Write-Host "  ${Purple}Python packages${Reset}       Background libraries used by Gemini 3 Flash to read"
Write-Host "                        and synthesize your existing files (PDFs, docs, slides)."
Write-Host ""
Write-Host "  ${Purple}Vault skills${Reset}          Slash commands that teach Claude how to use your vault:"
Write-Host "                        /vault-setup  /daily  /tldr  /file-intel"
Write-Host ""
Write-Host "  ${Purple}Obsidian Skills${Reset}       Official skills by Kepano (Obsidian CEO) - lets Claude"
Write-Host "  ${Dim}(optional)${Reset}            navigate your vault using the Obsidian CLI."
Write-Host ""
Write-Host "  ${Dim}  Nothing is uploaded. Your vault stays on your machine.${Reset}"
Write-Host ""
Write-Host "  ====================================================="
Write-Host ""

# === STEP 1: Check winget ===================================================
Write-Host "${White}Step 1/8 -- Checking winget${Reset}"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "  ${Red}FAIL${Reset} winget not found."
    Write-Host "        Install 'App Installer' from the Microsoft Store,"
    Write-Host "        or update to Windows 11 / latest Windows 10."
    exit 1
}
Write-Host "  ${Green}OK${Reset} winget available"

# === STEP 2: Obsidian ========================================================
Write-Host ""
Write-Host "${White}Step 2/8 -- Installing Obsidian${Reset}"
$obsCheck = (winget list --id Obsidian.Obsidian 2>$null | Select-String "Obsidian.Obsidian")
if (-not $obsCheck) {
    Write-Host "  Installing Obsidian..."
    winget install --id Obsidian.Obsidian --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ${Green}OK${Reset} Obsidian installed"
    } else {
        Write-Host "  ${Orange}WARNING${Reset} Obsidian install may have failed."
        Write-Host "           To retry: winget install Obsidian.Obsidian"
        Write-Host "           Or download from: https://obsidian.md/download"
    }
} else {
    Write-Host "  ${Green}OK${Reset} Obsidian already installed"
}

# === STEP 3: Claude Code =====================================================
Write-Host ""
Write-Host "${White}Step 3/8 -- Installing Claude Code${Reset}"
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Claude Code via winget..."
    winget install --id Anthropic.ClaudeCode --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ${Green}OK${Reset} Claude Code installed"
    } else {
        Write-Host "  ${Orange}WARNING${Reset} Claude Code install may have failed."
        Write-Host "           You can also install via npm: npm install -g @anthropic-ai/claude-code"
    }
    Write-Host ""
    Write-Host "  ${Orange}NOTE${Reset}  You MUST close and reopen this terminal (or open a new one)"
    Write-Host "        for the 'claude' command to be available."
} else {
    Write-Host "  ${Green}OK${Reset} Claude Code already installed"
}

# === STEP 4: Python deps =====================================================
Write-Host ""
Write-Host "${White}Step 4/8 -- Installing Python dependencies${Reset}"

$pipInstalled = $false

# Check requirements.txt exists first
if (-not (Test-Path "$scriptDir\requirements.txt")) {
    Write-Host "  ${Orange}WARNING${Reset}  requirements.txt not found in script directory."
    Write-Host "        After cloning: cd second-brain, then rerun:"
    Write-Host "        powershell -ExecutionPolicy Bypass -File setup.ps1"
} else {
    # Try 'pip' first, then 'python -m pip', then 'py -m pip'
    if (Get-Command pip -ErrorAction SilentlyContinue) {
        pip install -q -r "$scriptDir\requirements.txt" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $pipInstalled = $true
            Write-Host "  ${Green}OK${Reset} Python packages installed"
        } else {
            Write-Host "  ${Orange}WARNING${Reset}  pip install had errors -- some packages may be missing"
        }
    } elseif (Get-Command python -ErrorAction SilentlyContinue) {
        python -m pip install -q -r "$scriptDir\requirements.txt" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $pipInstalled = $true
            Write-Host "  ${Green}OK${Reset} Python packages installed (via python -m pip)"
        } else {
            Write-Host "  ${Orange}WARNING${Reset}  pip install had errors -- some packages may be missing"
        }
    } elseif (Get-Command py -ErrorAction SilentlyContinue) {
        py -m pip install -q -r "$scriptDir\requirements.txt" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $pipInstalled = $true
            Write-Host "  ${Green}OK${Reset} Python packages installed (via py -m pip)"
        } else {
            Write-Host "  ${Orange}WARNING${Reset}  pip install had errors -- some packages may be missing"
        }
    }
}

if (-not $pipInstalled) {
    Write-Host "  ${Orange}WARNING${Reset}  Python/pip not found or install failed."
    Write-Host ""
    Write-Host "  ${White}How to fix:${Reset}"
    Write-Host "  1. Download Python from https://python.org/downloads"
    Write-Host "  2. On the FIRST screen of the installer, tick 'Add Python to PATH'"
    Write-Host "  3. Complete the install, then close and reopen PowerShell"
    Write-Host "  4. Re-run this script (it is safe to re-run)"
    Write-Host ""
    Write-Host "  ${Dim}NOTE: If Python is only installed inside WSL, this script cannot use it."
    Write-Host "  You need native Windows Python.${Reset}"
}

# === STEP 5: Vault setup =====================================================
Write-Host ""
Write-Host "${White}Step 5/8 -- Setting up your vault${Reset}"
Write-Host ""
Write-Host "  Where should your second brain live?"
Write-Host "  ${Dim}Press Enter for default: $env:USERPROFILE\second-brain${Reset}"
Write-Host "  ${Dim}(e.g. C:\Users\YourName\Documents\MyVault -- quotes OK)${Reset}"
$vaultInput = Read-Host "  Vault path"
if (-not $vaultInput) { $vaultInput = "$env:USERPROFILE\second-brain" }

# Sanitize: strip surrounding quotes, trim whitespace, expand tilde
$vaultPath = $vaultInput.Trim().Trim('"').Trim("'")
if ($vaultPath.StartsWith('~')) {
    $vaultPath = $vaultPath.Replace('~', $env:USERPROFILE)
}
# Strip trailing backslash (unless it's a root like C:\)
if ($vaultPath.Length -gt 3 -and $vaultPath.EndsWith('\')) {
    $vaultPath = $vaultPath.TrimEnd('\')
}

# Guard: don't let vault = the repo folder (causes identical file cp errors)
$realVault = if (Test-Path $vaultPath) { (Resolve-Path $vaultPath).Path } else { $vaultPath }
$realScript = (Resolve-Path $scriptDir).Path
if ($realVault -eq $realScript) {
    Write-Host "  ${Orange}WARNING${Reset}  Vault can't be the same folder as the repo. Using $env:USERPROFILE\second-brain instead."
    $vaultPath = "$env:USERPROFILE\second-brain"
}

# Guard: check if path is an existing file (not a directory)
if ((Test-Path $vaultPath) -and -not (Test-Path $vaultPath -PathType Container)) {
    Write-Host "  ${Red}ERROR${Reset}  That path points to a file, not a folder: $vaultPath"
    Write-Host "        Please re-run and enter a folder path."
    exit 1
}

# --- Detect existing vault ---------------------------------------------------
$isExistingVault = $false
$hasObsidianFolder = Test-Path "$vaultPath\.obsidian"
$hasExistingClaude = Test-Path "$vaultPath\CLAUDE.md"
# Check if the directory exists and is non-empty (any file or folder inside)
$isNonEmptyDir = (Test-Path $vaultPath) -and ((Get-ChildItem $vaultPath -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne '.DS_Store' } | Measure-Object).Count -gt 0)

if ($hasObsidianFolder -or $isNonEmptyDir) {
    $isExistingVault = $true
    Write-Host ""
    Write-Host "  ====================================================="
    Write-Host "  ${Cyan}Existing vault detected at: $vaultPath${Reset}"
    Write-Host "  ====================================================="
    Write-Host ""
    Write-Host "  We found existing files here. The script will:"
    Write-Host ""
    Write-Host "  ${Green}+${Reset} Add missing folders (inbox/, daily/, projects/, etc.)"
    Write-Host "  ${Green}+${Reset} Install 4 slash commands: /vault-setup /daily /tldr /file-intel"
    Write-Host "  ${Green}+${Reset} Copy helper scripts to scripts/"
    Write-Host "  ${Green}+${Reset} Install skills globally to $env:USERPROFILE\.claude\skills\"
    if ($hasExistingClaude) {
        $previewBackup = "CLAUDE.md.backup-$(Get-Date -Format 'yyyy-MM-dd-HHmmss')"
        Write-Host "  ${Orange}!${Reset} Back up your existing CLAUDE.md -> $previewBackup"
        Write-Host "  ${Orange}!${Reset} Install new CLAUDE.md template (run /vault-setup to personalize)"
    } else {
        Write-Host "  ${Green}+${Reset} Create CLAUDE.md template (run /vault-setup to personalize)"
    }
    Write-Host ""
    Write-Host "  ${White}Will NOT touch:${Reset}"
    Write-Host "  - Your existing notes, including files already in inbox/, daily/, etc."
    Write-Host "  - Your Obsidian plugins, themes, and settings (.obsidian/)"
    Write-Host ""
    $continueAnswer = Read-Host "  Continue? [Y/n]"
    if (-not $continueAnswer) { $continueAnswer = "Y" }
    if (-not ($continueAnswer -match "^[Yy]")) {
        Write-Host "  Setup cancelled. Your vault is unchanged."
        exit 0
    }

    # Backup existing CLAUDE.md
    if ($hasExistingClaude) {
        $backupName = "CLAUDE.md.backup-$(Get-Date -Format 'yyyy-MM-dd-HHmmss')"
        Copy-Item "$vaultPath\CLAUDE.md" "$vaultPath\$backupName" -Force
        Write-Host "  ${Green}OK${Reset} Backed up existing CLAUDE.md -> $backupName"
    }
}

# Create folder structure (New-Item -Force won't remove existing content)
New-Item -ItemType Directory -Force -Path $vaultPath | Out-Null
New-Item -ItemType Directory -Force -Path "$vaultPath\inbox" | Out-Null
New-Item -ItemType Directory -Force -Path "$vaultPath\daily" | Out-Null
New-Item -ItemType Directory -Force -Path "$vaultPath\projects" | Out-Null
New-Item -ItemType Directory -Force -Path "$vaultPath\research" | Out-Null
New-Item -ItemType Directory -Force -Path "$vaultPath\archive" | Out-Null
New-Item -ItemType Directory -Force -Path "$vaultPath\scripts" | Out-Null
New-Item -ItemType Directory -Force -Path "$vaultPath\.claude\skills\vault-setup" | Out-Null
New-Item -ItemType Directory -Force -Path "$vaultPath\.claude\skills\daily" | Out-Null
New-Item -ItemType Directory -Force -Path "$vaultPath\.claude\skills\tldr" | Out-Null
New-Item -ItemType Directory -Force -Path "$vaultPath\.claude\skills\file-intel" | Out-Null

# Copy core files (with existence checks to handle partial repo downloads)
$copyErrors = 0
foreach ($src in @(
    @("$scriptDir\CLAUDE.md", "$vaultPath\CLAUDE.md"),
    @("$scriptDir\skills\vault-setup\SKILL.md", "$vaultPath\.claude\skills\vault-setup\SKILL.md"),
    @("$scriptDir\skills\daily\SKILL.md", "$vaultPath\.claude\skills\daily\SKILL.md"),
    @("$scriptDir\skills\tldr\SKILL.md", "$vaultPath\.claude\skills\tldr\SKILL.md"),
    @("$scriptDir\skills\file-intel\SKILL.md", "$vaultPath\.claude\skills\file-intel\SKILL.md")
)) {
    if (Test-Path $src[0]) {
        Copy-Item $src[0] $src[1] -Force
    } else {
        Write-Host "  ${Orange}WARNING${Reset}  Missing: $($src[0])"
        $copyErrors++
    }
}

# Copy memory.md: on fresh installs always, on existing vaults only if missing
if (Test-Path "$scriptDir\memory.md") {
    if ((-not $isExistingVault) -or (-not (Test-Path "$vaultPath\memory.md"))) {
        Copy-Item "$scriptDir\memory.md" "$vaultPath\memory.md" -Force
    }
}

# Copy scripts (optional -- file processing won't work without them but vault still works)
foreach ($script in @("gemini_auth.py", "process_docs_to_obsidian.py", "process_files_with_gemini.py")) {
    if (Test-Path "$scriptDir\scripts\$script") {
        Copy-Item "$scriptDir\scripts\$script" "$vaultPath\scripts\" -Force
    }
}

if ($copyErrors -gt 0) {
    Write-Host "  ${Orange}WARNING${Reset}  $copyErrors file(s) missing -- vault may not work correctly."
    Write-Host "        Try: git clone https://github.com/earlyaidopters/second-brain.git"
    Write-Host "        Then: cd second-brain && powershell -ExecutionPolicy Bypass -File setup.ps1"
}

# Install skills globally (so they work in ANY folder, not just the vault)
$globalSkillsPath = "$env:USERPROFILE\.claude\skills"
foreach ($skill in @("vault-setup", "daily", "tldr", "file-intel")) {
    New-Item -ItemType Directory -Force -Path "$globalSkillsPath\$skill" | Out-Null
    if (Test-Path "$scriptDir\skills\$skill\SKILL.md") {
        Copy-Item "$scriptDir\skills\$skill\SKILL.md" "$globalSkillsPath\$skill\SKILL.md" -Force
    }
}

if ($isExistingVault) {
    Write-Host "  ${Green}OK${Reset} Skills + scripts added to existing vault at $vaultPath"
} else {
    Write-Host "  ${Green}OK${Reset} Vault created at $vaultPath"
}
Write-Host "  ${Green}OK${Reset} Skills installed globally -- work in any folder"

# === Step 6: Configure Gemini Authentication ================================
Write-Host ""
Write-Host "${White}Step 6/8 -- Configure Gemini Authentication${Reset}"
Write-Host ""
Write-Host "  Gemini 3 Flash processes your files (PDFs, docs, slides) into Markdown."
Write-Host "  ${Dim}Choose how to authenticate:${Reset}"
Write-Host ""
Write-Host "  ${Cyan}1.${Reset} Google API Key ${Dim}(recommended for individuals -- free tier works)${Reset}"
Write-Host "  ${Cyan}2.${Reset} Vertex AI ${Dim}(for Google Cloud users)${Reset}"
Write-Host "  ${Cyan}3.${Reset} Skip ${Dim}(configure later by editing .env)${Reset}"
Write-Host ""

# Prompt for authentication method choice
$authChoice = ""
while ($authChoice -notmatch "^[123]$") {
    $authInput = Read-Host "  Choose authentication method [1-3, default 3]"
    if (-not $authInput) { $authInput = "3" }
    $authChoice = $authInput
    if ($authChoice -notmatch "^[123]$") {
        Write-Host "  ${Orange}Please enter 1, 2, or 3${Reset}"
    }
}

# Prompt for model selection (if not skipping)
$geminiModel = ""
if ($authChoice -ne "3") {
    Write-Host ""
    Write-Host "  ${White}Which Gemini model should file processing use?${Reset}"
    Write-Host "  ${Dim}(Same models available for both API Key and Vertex AI)${Reset}"
    Write-Host ""
    Write-Host "  ${Cyan}1.${Reset} gemini-3-flash-preview ${Dim}(fast, cheap, recommended)${Reset}"
    Write-Host "  ${Cyan}2.${Reset} gemini-3-pro-preview ${Dim}(slower, higher quality)${Reset}"
    Write-Host "  ${Cyan}3.${Reset} Custom model name ${Dim}(e.g., gemini-2.0-flash-exp)${Reset}"
    Write-Host ""
    $modelInput = Read-Host "  Choose model [default: 1]"
    if (-not $modelInput) { $modelInput = "1" }

    switch ($modelInput) {
        "1" { $geminiModel = "gemini-3-flash-preview" }
        "2" { $geminiModel = "gemini-3-pro-preview" }
        "3" {
            $customModel = Read-Host "  Enter model name"
            $geminiModel = $customModel.Trim()
            if (-not $geminiModel) {
                Write-Host "  ${Orange}Empty input, using default: gemini-3-flash-preview${Reset}"
                $geminiModel = "gemini-3-flash-preview"
            }
        }
        default {
            Write-Host "  ${Orange}Invalid choice, using default: gemini-3-flash-preview${Reset}"
            $geminiModel = "gemini-3-flash-preview"
        }
    }
}

# Check for existing .env file
if (Test-Path "$vaultPath\.env") {
    Write-Host ""
    Write-Host "  ${Orange}WARNING${Reset}  Found existing .env file at $vaultPath\.env"
    $overwriteAnswer = Read-Host "  Overwrite with new configuration? [y/N]"
    if (-not $overwriteAnswer) { $overwriteAnswer = "N" }
    if ($overwriteAnswer -notmatch "^[Yy]") {
        Write-Host "  ${Dim}  Keeping existing .env file${Reset}"
        $authChoice = "skip"
    }
}

Write-Host ""

# Execute the chosen authentication flow
if ($authChoice -eq "1") {
    # ─── Option 1: Google API Key ────────────────────────────────────────────
    Write-Host "  ${Cyan}Get your free Google API key at: https://aistudio.google.com/apikey${Reset}"
    Write-Host "  ${Dim}Your key will NOT be visible as you paste -- this is normal. Press Enter when done.${Reset}"
    Write-Host ""
    $secureKey = Read-Host "  Paste your Google API key (or press Enter to skip)" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
    $apiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

    # Trim whitespace from API key (clipboard paste often adds spaces)
    if ($apiKey) { $apiKey = $apiKey.Trim() }

    if ($apiKey) {
        # Write without BOM (PS5.1's Out-File -Encoding UTF8 adds a BOM that breaks Python dotenv)
        $envContent = "GOOGLE_API_KEY=$apiKey`nMODEL=$geminiModel`n"
        [System.IO.File]::WriteAllText("$vaultPath\.env", $envContent, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "  ${Green}OK${Reset} API key saved (hidden from display)"
    } else {
        if (-not (Test-Path "$vaultPath\.env")) {
            if (Test-Path "$scriptDir\.env.example") {
                Copy-Item "$scriptDir\.env.example" "$vaultPath\.env" -Force
            }
        }
        Write-Host "  ${Orange}WARNING${Reset}  Skipped -- add your key to $vaultPath\.env before processing files"
    }

} elseif ($authChoice -eq "2") {
    # ─── Option 2: Vertex AI ─────────────────────────────────────────────────
    Write-Host "  ${Cyan}Vertex AI requires a Google Cloud project. Get started at:${Reset}"
    Write-Host "  ${Cyan}https://console.cloud.google.com${Reset}"
    Write-Host ""

    # Step 1: Collect project ID
    $gcpProject = Read-Host "  Google Cloud Project ID (or press Enter to skip)"
    $gcpProject = $gcpProject.Trim()

    if (-not $gcpProject) {
        Write-Host "  ${Orange}WARNING${Reset}  Skipped -- Vertex AI setup cancelled"
        if (-not (Test-Path "$vaultPath\.env")) {
            if (Test-Path "$scriptDir\.env.example") {
                Copy-Item "$scriptDir\.env.example" "$vaultPath\.env" -Force
            }
        }
    } else {
        # Step 2: Collect location/region
        Write-Host ""
        $gcpLocationInput = Read-Host "  Google Cloud Location [default: us-central1]"
        $gcpLocation = if ($gcpLocationInput) { $gcpLocationInput.Trim() } else { "us-central1" }

        # Step 3: Write Vertex AI configuration
        $envContent = @"
GOOGLE_GENAI_USE_VERTEXAI=true
GOOGLE_CLOUD_PROJECT=$gcpProject
GOOGLE_CLOUD_LOCATION=$gcpLocation
MODEL=$geminiModel
"@
        [System.IO.File]::WriteAllText("$vaultPath\.env", $envContent, (New-Object System.Text.UTF8Encoding $false))

        Write-Host ""
        Write-Host "  ${Green}OK${Reset} Vertex AI configuration saved"

        # Step 4: gcloud authentication (optional)
        Write-Host ""
        Write-Host "  ${White}GCloud Authentication Required:${Reset}"
        Write-Host "  Vertex AI requires application-default credentials."
        Write-Host ""

        if (Get-Command gcloud -ErrorAction SilentlyContinue) {
            Write-Host "  ${Green}OK${Reset} gcloud CLI detected"
            Write-Host ""
            $gcloudAuthAnswer = Read-Host "  Run 'gcloud auth application-default login' now? [Y/n]"
            if (-not $gcloudAuthAnswer) { $gcloudAuthAnswer = "Y" }

            if ($gcloudAuthAnswer -match "^[Yy]") {
                Write-Host ""
                Write-Host "  Opening browser for authentication..."
                try {
                    gcloud auth application-default login
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host ""
                        Write-Host "  ${Green}OK${Reset} gcloud authentication successful"
                    } else {
                        Write-Host ""
                        Write-Host "  ${Orange}WARNING${Reset}  gcloud authentication failed"
                        Write-Host "        You can run it manually later: ${Dim}gcloud auth application-default login${Reset}"
                    }
                } catch {
                    Write-Host ""
                    Write-Host "  ${Orange}WARNING${Reset}  gcloud authentication failed"
                    Write-Host "        You can run it manually later: ${Dim}gcloud auth application-default login${Reset}"
                }
            } else {
                Write-Host "  ${Dim}  Skipped -- run later: gcloud auth application-default login${Reset}"
            }
        } else {
            Write-Host "  ${Orange}WARNING${Reset}  gcloud CLI not found"
            Write-Host "        Install it: ${Cyan}https://cloud.google.com/sdk/docs/install${Reset}"
            Write-Host "        Then run: ${Dim}gcloud auth application-default login${Reset}"
        }
    }

} else {
    # ─── Option 3: Skip ──────────────────────────────────────────────────────
    if (-not (Test-Path "$vaultPath\.env")) {
        if (Test-Path "$scriptDir\.env.example") {
            Copy-Item "$scriptDir\.env.example" "$vaultPath\.env" -Force
        }
    }
    Write-Host "  ${Orange}WARNING${Reset}  Skipped -- configure authentication by editing $vaultPath\.env"
}

# === STEP 7: Import existing files ==========================================
Write-Host ""
Write-Host "${White}Step 7/8 -- Import existing files (optional)${Reset}"
Write-Host ""
Write-Host "  Do you have existing files to import? (PDFs, Word docs, slides)"
Write-Host "  ${Dim}Gemini 3 Flash will synthesize them into clean Markdown notes${Reset}"
Write-Host ""
$importFolder = Read-Host "  Folder path to import (or press Enter to skip)"
if ($importFolder) {
    $importFolder = $importFolder.Trim().Trim('"').Trim("'")
}
if ($importFolder -and (Test-Path $importFolder)) {
    # Ask about recursive scanning
    Write-Host ""
    Write-Host "  ${White}Search for files recursively in subdirectories?${Reset}"
    Write-Host "  ${Dim}Yes: scan all nested folders | No: only top-level files${Reset}"
    $recursiveAnswer = Read-Host "  Scan recursively? [y/N]"
    if (-not $recursiveAnswer) { $recursiveAnswer = "N" }

    $recursiveFlag = ""
    if ($recursiveAnswer -match "^[Yy]") {
        $recursiveFlag = "--recursive"
        Write-Host "  ${Dim}Will scan subdirectories recursively${Reset}"
    } else {
        Write-Host "  ${Dim}Will scan top-level files only${Reset}"
    }

    if (-not $pipInstalled) {
        Write-Host "  ${Orange}WARNING${Reset}  Python packages were not installed in Step 4."
        Write-Host "        File processing may fail. Install Python + deps first, then run manually:"
        Write-Host "        python `"$vaultPath\scripts\process_docs_to_obsidian.py`" `"$importFolder`" `"$vaultPath\inbox`" $recursiveFlag"
    } else {
        Write-Host ""
        Write-Host "  Processing files with Gemini 3 Flash..."
        $pythonCmd = $null
        if (Get-Command python -ErrorAction SilentlyContinue) { $pythonCmd = "python" }
        elseif (Get-Command py -ErrorAction SilentlyContinue) { $pythonCmd = "py" }
        if ($pythonCmd) {
            $cmdArgs = @("$vaultPath\scripts\process_docs_to_obsidian.py", $importFolder, "$vaultPath\inbox")
            if ($recursiveFlag) { $cmdArgs += $recursiveFlag }
            & $pythonCmd $cmdArgs
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "  ${Green}OK${Reset} Files processed -> saved to $vaultPath\inbox"
                Write-Host "  ${Dim}Open Claude Code and say: 'Sort everything in inbox/ into the right folders'${Reset}"
            } else {
                Write-Host ""
                Write-Host "  ${Orange}WARNING${Reset}  File processing failed -- check your API key in .env and try again manually"
            }
        } else {
            Write-Host "  ${Orange}WARNING${Reset}  Python not found -- install Python first, then run:"
            Write-Host "        python `"$vaultPath\scripts\process_docs_to_obsidian.py`" `"$importFolder`" `"$vaultPath\inbox`" $recursiveFlag"
        }
    }
} elseif ($importFolder) {
    Write-Host "  ${Orange}WARNING${Reset}  Folder not found: $importFolder"
}

# === STEP 8: Kepano Obsidian Skills (optional) ==============================
Write-Host ""
Write-Host "${White}Step 8/8 -- Obsidian Skills by Kepano (optional)${Reset}"
Write-Host ""
Write-Host "  Kepano (Steph Ango) is the CEO of Obsidian. He published a set of"
Write-Host "  official agent skills that teach Claude Code to natively read, write,"
Write-Host "  and navigate your vault using the Obsidian CLI."
Write-Host ""
Write-Host "  Adds these slash commands to Claude Code:"
Write-Host "  ${Dim}  obsidian-cli  obsidian-markdown  obsidian-bases  json-canvas${Reset}"
Write-Host "  ${Dim}  (Read-only navigation commands -- they do not send your notes anywhere.)${Reset}"
Write-Host ""
$kepanoAnswer = Read-Host "  Install Kepano's Obsidian skills? [Y/n]"
if (-not $kepanoAnswer) { $kepanoAnswer = "Y" }

if ($kepanoAnswer -match "^[Yy]") {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "  ${Orange}WARNING${Reset}  git not found."
        Write-Host "        To install: winget install --id Git.Git --silent --accept-package-agreements"
        Write-Host "        Then close and reopen PowerShell, and re-run this script."
        Write-Host "        Or install manually: https://github.com/kepano/obsidian-skills"
    } else {
        Write-Host "  Cloning obsidian-skills..."
        $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
        try {
            git clone --depth=1 https://github.com/kepano/obsidian-skills.git "$tempDir\obsidian-skills" *>$null
            $skillsPath = "$tempDir\obsidian-skills\skills"
            if (Test-Path $skillsPath) {
                Get-ChildItem $skillsPath -Directory | ForEach-Object {
                    $skillName = $_.Name
                    # Install to vault AND globally
                    New-Item -ItemType Directory -Force -Path "$vaultPath\.claude\skills\$skillName" | Out-Null
                    New-Item -ItemType Directory -Force -Path "$globalSkillsPath\$skillName" | Out-Null
                    Copy-Item "$($_.FullName)\SKILL.md" "$vaultPath\.claude\skills\$skillName\SKILL.md" -Force -ErrorAction SilentlyContinue
                    Copy-Item "$($_.FullName)\SKILL.md" "$globalSkillsPath\$skillName\SKILL.md" -Force -ErrorAction SilentlyContinue
                }
                Write-Host "  ${Green}OK${Reset} Kepano's Obsidian skills installed (vault + global)"
            } else {
                Write-Host "  ${Orange}WARNING${Reset}  Cloned repo but skills/ folder not found"
            }
        } catch {
            Write-Host "  ${Orange}WARNING${Reset}  Could not reach GitHub."
            Write-Host "        Optional -- your vault works without this."
            Write-Host "        To install later: https://github.com/kepano/obsidian-skills"
        } finally {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
} else {
    Write-Host "  ${Dim}  Skipped -- install anytime: https://github.com/kepano/obsidian-skills${Reset}"
}

# === VERIFICATION ============================================================
Write-Host ""
Write-Host "  ${White}Checking installation...${Reset}"
Write-Host "  ${Dim}(Any failures above are safe to retry -- just re-run this script.)${Reset}"
Write-Host ""

$obsVerify = (winget list --id Obsidian.Obsidian 2>$null | Select-String "Obsidian.Obsidian")
if ($obsVerify) {
    Write-Host "  ${Green}OK${Reset} Obsidian"
} else {
    Write-Host "  ${Red}FAIL${Reset} Obsidian -- run: winget install Obsidian.Obsidian"
}

if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "  ${Green}OK${Reset} Claude Code"
} else {
    Write-Host "  ${Orange}NOTE${Reset} Claude Code not in PATH -- close and reopen this terminal"
}

$pyFound = $false
if (Get-Command python -ErrorAction SilentlyContinue) {
    $pyVer = python --version 2>&1
    Write-Host "  ${Green}OK${Reset} $pyVer"
    $pyFound = $true
} elseif (Get-Command py -ErrorAction SilentlyContinue) {
    $pyVer = py --version 2>&1
    Write-Host "  ${Green}OK${Reset} $pyVer (via py launcher)"
    $pyFound = $true
}
if (-not $pyFound) {
    Write-Host "  ${Orange}WARNING${Reset} Python not found -- install from python.org (tick 'Add to PATH')"
}

if (Test-Path "$vaultPath\CLAUDE.md") {
    Write-Host "  ${Green}OK${Reset} Vault  $vaultPath"
} else {
    Write-Host "  ${Red}FAIL${Reset} Vault files missing at $vaultPath"
}

$skillCount = (Get-ChildItem "$vaultPath\.claude\skills" -Directory -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Host "  ${Green}OK${Reset} $skillCount skills installed"

# === IMPORTANT WARNINGS =====================================================
Write-Host ""
Write-Host "  ====================================================="
Write-Host ""
Write-Host "  ${Orange}IMPORTANT -- Read before using:${Reset}"
Write-Host ""
Write-Host "  ${White}Obsidian Sync / Cloud Sync users:${Reset}"
Write-Host "  If you use Obsidian Sync, iCloud, OneDrive, or Dropbox,"
Write-Host "  EXCLUDE these folders from sync: ${Cyan}.claude/${Reset}  ${Cyan}scripts/${Reset}  ${Cyan}.env${Reset}"
Write-Host ""
Write-Host "  In Obsidian: Settings -> Sync -> Excluded folders"
Write-Host "  Add: .claude, scripts"
Write-Host ""
Write-Host "  ${Red}Why?${Reset} If .claude/ gets synced, it can create a recursive loop"
Write-Host "  that bloats your vault and corrupts Claude's context."
Write-Host "  (In severe cases, this has made vaults completely unusable.)"
Write-Host ""
Write-Host "  ====================================================="
Write-Host ""

# Done
if ($isExistingVault) {
    Write-Host "  ${Green}Your vault is upgraded.${Reset}"
    Write-Host ""
    Write-Host "  ${White}What you just got:${Reset}"
    Write-Host "  - 4 slash commands: /vault-setup /daily /tldr /file-intel"
    if ($hasExistingClaude) {
        Write-Host "  - New CLAUDE.md template (your original backed up as $backupName)"
    } else {
        Write-Host "  - CLAUDE.md template (personalize with /vault-setup)"
    }
    Write-Host "  - Missing vault folders added (your existing notes untouched)"
    Write-Host "  - File processing scripts in scripts/"
} else {
    Write-Host "  ${Green}Your second brain is ready.${Reset}"
    Write-Host ""
    Write-Host "  ${White}What you just got:${Reset}"
    Write-Host "  - 4 slash commands: /vault-setup /daily /tldr /file-intel"
    Write-Host "  - CLAUDE.md template (personalize it with /vault-setup)"
    Write-Host "  - Vault folder structure for organizing your notes"
    Write-Host "  - File processing scripts (optional, needs Gemini API key)"
}
Write-Host ""
Write-Host "  Claude Code now knows your vault structure and will read it before every session."
Write-Host ""
Write-Host "  ${White}Next steps:${Reset}"
Write-Host "  1. Open Obsidian, select vault: $vaultPath"
Write-Host "  2. In Obsidian: gear icon (bottom-left) -> General -> Enable CLI"
Write-Host "  3. Open a new PowerShell window (Win -> type 'powershell' -> Enter):"
Write-Host "     cd `"$vaultPath`""
Write-Host "     claude"
Write-Host "  4. Type: /vault-setup"
Write-Host "     (Claude will interview you and personalize your vault)"
Write-Host ""
Write-Host "  ${Dim}This script is safe to re-run -- it detects existing vaults, creates"
Write-Host "  timestamped backups of CLAUDE.md, and only adds what is missing.${Reset}"
Write-Host ""

# Open Obsidian
Start-Process "obsidian://" -ErrorAction SilentlyContinue
