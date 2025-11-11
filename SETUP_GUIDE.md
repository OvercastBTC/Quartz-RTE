# Quartz-RTE GitHub Sync & Submodule Setup Guide

## Current Status
- **Local Repo**: `c:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\Extensions\.ui\RichEditors\Quartz-RTE`
- **Origin**: `https://github.com/OvercastBTC/Quartz-RTE.git`
- **Upstream**: `https://github.com/LaserMade/Quartz-RTE.git`
- **Current Branch**: `master`

## Dependencies Found
The script has external dependencies outside this folder:

1. `#Include <Extensions/.modules/Pipe>`
2. `#Include <Utilities/TestLogger>`
3. `#Include <Extensions/.modules/Clipboard>`
4. `#Include <Extensions/.primitives/Keys>`
5. `#Include <System/WebView2/WebView2/WebView2>`
6. `#Include <System/WebView2/ComVar>`
7. `#Include <Abstractions/WindowManager>`

These are currently loaded from your AutoHotkey Lib folder structure.

---

## Step 1: Branch Management Strategy

### Option A: Archive Old, Make This Master (Recommended)
```bash
# Navigate to repo
cd "c:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\Extensions\.ui\RichEditors\Quartz-RTE"

# Create backup of current master (if exists on remote)
git checkout master
git branch backup-original-master
git push origin backup-original-master

# Commit all your current changes
git add .
git commit -m "feat: Complete refactor with class-based architecture, RTF support, and TestLogger integration"

# Force push to master (WARNING: This overwrites remote master)
git push origin master --force

# Or safer: Push to new branch first for review
git checkout -b refactor-class-based
git push origin refactor-class-based
# Then merge via GitHub PR
```

### Option B: Keep Old Master, New Branch
```bash
# Your current work stays in a branch
git checkout -b feature/class-refactor
git add .
git commit -m "feat: Class-based refactor with enhanced RTF support"
git push origin feature/class-refactor
```

---

## Step 2: Handle External Dependencies

You have 3 options for external dependencies:

### Option 2A: Git Submodules (Best for shared libraries)
Create a separate repo for your AHK library dependencies:

```bash
# In your main AHK Lib folder
cd "c:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib"
git init
git add Extensions/ System/ Utilities/ Abstractions/
git commit -m "Initial commit of AHK v2 library collection"
# Create repo at https://github.com/OvercastBTC/AHK-v2-Lib
git remote add origin https://github.com/OvercastBTC/AHK-v2-Lib.git
git push -u origin master

# Then in Quartz-RTE
cd "c:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\Extensions\.ui\RichEditors\Quartz-RTE"
git submodule add https://github.com/OvercastBTC/AHK-v2-Lib.git lib/dependencies
git commit -m "Add AHK library dependencies as submodule"
```

### Option 2B: Copy Dependencies Locally (Simplest)
```bash
# Copy required files into Quartz-RTE/lib/
cd "c:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\Extensions\.ui\RichEditors\Quartz-RTE"
mkdir -p lib/Extensions/.modules
mkdir -p lib/Extensions/.primitives
mkdir -p lib/Utilities
mkdir -p lib/System/WebView2
mkdir -p lib/Abstractions

# Copy files (example - adjust paths as needed)
copy "C:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\Extensions\.modules\Pipe.ahk" "lib\Extensions\.modules\"
copy "C:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\Utilities\TestLogger.ahk" "lib\Utilities\"
# ... etc for all dependencies

# Update Quartz.ahk includes to use local lib folder
# Change from: #Include <Extensions/.modules/Pipe>
# Change to:   #Include ..\lib\Extensions\.modules\Pipe.ahk
```

### Option 2C: Symbolic Links (Developer-friendly)
```bash
# Create symbolic links in Quartz-RTE/lib/ pointing to your main Lib folder
cd "c:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\Extensions\.ui\RichEditors\Quartz-RTE"
mkdir lib

# Create junction points (Windows symlinks)
mklink /J "lib\Extensions" "C:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\Extensions"
mklink /J "lib\Utilities" "C:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\Utilities"
mklink /J "lib\System" "C:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\System"
mklink /J "lib\Abstractions" "C:\Users\bacona\AppData\Local\Programs\AutoHotkey\v2\Lib\Abstractions"

# Add to .gitignore
echo lib/Extensions/ >> .gitignore
echo lib/Utilities/ >> .gitignore
echo lib/System/ >> .gitignore
echo lib/Abstractions/ >> .gitignore

# Document in README
```

---

## Step 3: Setup as Git Submodule (For Parent Projects)

Once Quartz-RTE is properly synced, you can use it as a submodule:

```bash
# In your main AHK project
cd "C:\Users\bacona\Documents\MyAHKProject"
git init  # if not already a git repo

# Add Quartz-RTE as submodule
git submodule add https://github.com/OvercastBTC/Quartz-RTE.git lib/Quartz-RTE

# Initialize and update
git submodule init
git submodule update

# Commit the submodule reference
git add .gitmodules lib/Quartz-RTE
git commit -m "Add Quartz-RTE as submodule"
```

### Using Submodules
```bash
# Clone project with submodules
git clone --recursive https://github.com/YourUsername/YourProject.git

# Or after cloning
git submodule init
git submodule update

# Update submodule to latest
cd lib/Quartz-RTE
git pull origin master
cd ../..
git add lib/Quartz-RTE
git commit -m "Update Quartz-RTE submodule"
```

---

## Step 4: Update Include Paths

If you choose Option 2B (copy locally), update `src/Quartz.ahk`:

```ahk
; OLD:
#Include <Extensions/.modules/Pipe>
#Include <Utilities/TestLogger>
#Include <Extensions/.modules/Clipboard>
#Include <Extensions/.primitives/Keys>
#Include <System/WebView2/WebView2/WebView2>
#Include <System/WebView2/ComVar>
#Include <Abstractions/WindowManager>

; NEW (relative paths):
#Include ..\lib\Extensions\.modules\Pipe.ahk
#Include ..\lib\Utilities\TestLogger.ahk
#Include ..\lib\Extensions\.modules\Clipboard.ahk
#Include ..\lib\Extensions\.primitives\Keys.ahk
#Include ..\lib\System\WebView2\WebView2\WebView2.ahk
#Include ..\lib\System\WebView2\ComVar.ahk
#Include ..\lib\Abstractions\WindowManager.ahk
```

---

## Step 5: Create .gitignore (if not exists)

```gitignore
# Temporary files
~$*
*.tmp
*.bak

# Test files (optional - you may want to keep test file.rtf)
# (AJB - 2024.06.19) - test file.rtf

# Dependencies (if using symlinks - Option 2C)
lib/Extensions/
lib/Utilities/
lib/System/
lib/Abstractions/

# Build output
*.exe
compiled/

# IDE
.vscode/
*.code-workspace
```

---

## Recommended Approach

**For your situation, I recommend:**

1. **Branch Strategy**: Option A (make this master) - your refactor is substantial
2. **Dependencies**: Option 2B (copy locally) - makes repo self-contained
3. **Submodule**: Yes - good for reusing Quartz-RTE in other projects

**Steps to execute:**

```bash
# 1. Backup current state
git checkout master
git branch backup-pre-refactor

# 2. Copy dependencies locally
# (I can help create a script for this)

# 3. Update include paths in Quartz.ahk
# (I can do this automatically)

# 4. Commit everything
git add .
git commit -m "feat: Self-contained class-based architecture with local dependencies"

# 5. Push to GitHub
git push origin master --force-with-lease

# 6. Create release/tag
git tag -a v2.0.0 -m "Version 2.0 - Class-based refactor"
git push origin v2.0.0
```

---

## Questions to Answer:

1. **Do you want to keep the original LaserMade version accessible?**
   - If yes → Use Option B (new branch)
   - If no → Use Option A (replace master)

2. **Will other projects need these same AHK libraries?**
   - If yes → Consider creating separate AHK-v2-Lib repo (Option 2A)
   - If no → Copy locally (Option 2B)

3. **Are you the only developer or collaborative?**
   - Solo → Symlinks OK (Option 2C)
   - Team → Copy locally (Option 2B) or submodule (Option 2A)

Let me know your preferences and I'll execute the setup!
