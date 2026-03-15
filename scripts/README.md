# Scripts

Two Gemini-powered scripts for turning your existing files into Obsidian notes.

---

## Which script should I use?

| Script | Best for | Output |
|--------|----------|--------|
| `process_docs_to_obsidian.py` | Importing files **into your vault** — PDFs, Word docs, slides you want as structured notes | One `.md` file per input file → your vault's `inbox/` |
| `process_files_with_gemini.py` | **Analysing any folder of files** — get a quick-reference digest + master summary | Per-file summaries + `MASTER_SUMMARY.md` → `outputs/file_summaries/` |

If you're setting up your vault for the first time and want to import existing knowledge, use `process_docs_to_obsidian.py`.

If you want a fast overview of what's in a folder before deciding what to keep, use `process_files_with_gemini.py`.

---

## Prerequisites

```bash
# 1. Get a free Google API key
# https://aistudio.google.com/apikey

# 2. Add it to your vault's .env file
echo "GOOGLE_API_KEY=your_key_here" > .env

# 3. Install dependencies (setup.sh / setup.ps1 does this automatically)
pip install google-genai python-dotenv pdfplumber python-pptx python-docx openpyxl
```

---

## process_docs_to_obsidian.py

### Run it

```bash
# Basic usage
python scripts/process_docs_to_obsidian.py ~/Documents/old-files ~/vault/inbox

# Windows
python scripts\process_docs_to_obsidian.py %USERPROFILE%\Documents\old-files %USERPROFILE%\vault\inbox
```

### What it does

1. Reads every supported file in the input folder
2. Sends each file to **Gemini Flash** with a synthesis prompt
3. Extracts signal (key insights, decisions, facts, action items), discards noise (boilerplate, headers, repetition)
4. Saves a clean Obsidian-ready `.md` note for each file into your output folder

**Supported formats:** `.pdf` `.docx` `.pptx` `.txt` `.md`

### What's configurable

Open the script and look for the `# CONFIG` block near the top:

```python
# ─────────────────────────────────────────────
# CONFIG — change these to customise behaviour
# ─────────────────────────────────────────────

MODEL = "gemini-3-flash-preview"
# Swap to "gemini-3-pro-preview" for higher quality on complex documents.
# Flash is faster and cheaper — fine for most files.

SUPPORTED = {".pdf", ".pptx", ".ppt", ".docx", ".doc", ".txt", ".md"}
# Add or remove extensions to control which files get processed.
```

**The most powerful thing to customise is `SYNTHESIS_PROMPT`** — it's the instruction Gemini follows for every file. You can tell Claude Code:

> *"Edit the SYNTHESIS_PROMPT in process_docs_to_obsidian.py to focus more on extracting action items and ignore anything older than 2023"*

and it will rewrite it for you.

---

## process_files_with_gemini.py

### Run it

```bash
# Analyse a specific folder
python scripts/process_files_with_gemini.py ~/Downloads/client-files

# Analyse the built-in demo files
python scripts/process_files_with_gemini.py

# Windows
python scripts\process_files_with_gemini.py %USERPROFILE%\Downloads\client-files
```

### What it does

1. Reads every file in the folder (PDF, DOCX, PPTX, XLSX, CSV, JSON, code files, and more)
2. Extracts content from each file type
3. Sends content to **Gemini Flash** for analysis
4. Saves a quick-reference note per file + a `MASTER_SUMMARY.md` digest of everything

**Supported formats:** `.pdf` `.docx` `.pptx` `.xlsx` `.csv` `.json` `.xml` `.md` `.txt` `.py` `.js` `.html` `.css` and most text-based files

### What's configurable

```python
MODEL = "gemini-3-flash-preview"
# Change to "gemini-3-pro-preview" for more nuanced analysis.

max_chars = 12000
# How much text to send per file. Raise this for very dense documents.
# Lower it to save API quota on large batches.

rows[:50]  # in extract_xlsx / extract_csv
# How many rows of spreadsheet data to include. Default is 50.
```

**`ANALYSIS_PROMPT`** is the brain of this script — tell Claude Code what to change and it'll rewrite it instantly. For example:

> *"Update the ANALYSIS_PROMPT to always extract the author's name and date if present, and add a 'Confidence' rating for how complete the summary is"*

---

## Using these scripts with Claude Code

You don't have to run these scripts manually. Inside your vault, just tell Claude Code what you want:

**Run a script:**
```
Run the file processor on ~/Downloads/my-docs and save results to inbox/
```

**Customise the output:**
```
Edit process_docs_to_obsidian.py so it also extracts a "Key People" section
with names and roles mentioned in the document
```

**Change the model:**
```
Switch both scripts to use gemini-3-pro-preview
```

**Process and sort in one step:**
```
Process the files in ~/Desktop/old-notes into inbox/, then sort everything
in inbox/ into the right folders based on my vault structure
```

Claude Code reads your `CLAUDE.md` (your vault context) before doing any of this, so it already knows your folder structure and can route files intelligently.

---

## Output structure

```
process_docs_to_obsidian.py → your specified output folder (e.g. inbox/)
  └── original-filename.md      ← one per input file

process_files_with_gemini.py → outputs/file_summaries/YYYY-MM-DD/
  ├── filename1_summary.md
  ├── filename2_summary.md
  └── MASTER_SUMMARY.md          ← digest of all files
```

---

## Troubleshooting

**`GOOGLE_API_KEY not set`** — check your `.env` file is in the vault root and contains `GOOGLE_API_KEY=your_key`

**`No module named 'google'`** — run `pip install google-genai`

**PDF gives empty output** — some PDFs are image-only scans. These can't be read as text. Try a different file.

**Rate limit errors** — you've hit the free tier limit. Wait a minute or upgrade to a paid Google AI Studio plan.
