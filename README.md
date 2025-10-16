# 🧠 Neuralbytes EXE Compiler

A lightweight PowerShell-to-EXE compiler that runs even when PowerShell scripts are disabled.  
It safely enables its own execution scope, converts `.ps1` files into standalone `.exe` apps,  
and supports both console and GUI scripts.

## ⚙️ Features
- Works even under restricted PowerShell policies  
- Auto-installs or bundles **ps2exe** if missing  
- Fully silent (no prompts) — great for automation  
- Embeds metadata (trademark & copyright)  
- Supports **Windows Forms / GUI** apps (no console window)

## 🚀 Usage
```powershell
powershell -File ps1toexe-meta.ps1 -InputScript "C:\path\myscript.ps1"
