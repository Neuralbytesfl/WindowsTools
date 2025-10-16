<#
.SYNOPSIS
  Simple Notepad-style text editor GUI built with Windows Forms.
  No console output — designed to be compiled with ps2exe / -NoConsole.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Form setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Neuralbytes Notepad"
$form.Size = New-Object System.Drawing.Size(800,600)
$form.StartPosition = "CenterScreen"

# --- Main textbox ---
$box = New-Object System.Windows.Forms.TextBox
$box.Multiline = $true
$box.Dock = "Fill"
$box.ScrollBars = "Both"
$box.Font = New-Object System.Drawing.Font("Consolas",12)
$form.Controls.Add($box)

# --- File dialogs ---
$openDialog = New-Object System.Windows.Forms.OpenFileDialog
$openDialog.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
$saveDialog = New-Object System.Windows.Forms.SaveFileDialog
$saveDialog.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"

# --- Menu strip ---
$menu = New-Object System.Windows.Forms.MenuStrip
$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem("File")
$editMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Edit")
$menu.Items.AddRange(@($fileMenu,$editMenu))
$form.MainMenuStrip = $menu
$form.Controls.Add($menu)

# --- File menu items ---
$newItem  = New-Object System.Windows.Forms.ToolStripMenuItem("New")
$openItem = New-Object System.Windows.Forms.ToolStripMenuItem("Open")
$saveItem = New-Object System.Windows.Forms.ToolStripMenuItem("Save")
$exitItem = New-Object System.Windows.Forms.ToolStripMenuItem("Exit")
$fileMenu.DropDownItems.AddRange(@($newItem,$openItem,$saveItem,$exitItem))

# --- Edit menu items ---
$cutItem   = New-Object System.Windows.Forms.ToolStripMenuItem("Cut")
$copyItem  = New-Object System.Windows.Forms.ToolStripMenuItem("Copy")
$pasteItem = New-Object System.Windows.Forms.ToolStripMenuItem("Paste")
$editMenu.DropDownItems.AddRange(@($cutItem,$copyItem,$pasteItem))

# --- Event handlers ---
$newItem.Add_Click({ $box.Clear() })
$openItem.Add_Click({
    if ($openDialog.ShowDialog() -eq "OK") {
        $box.Text = Get-Content $openDialog.FileName -Raw
    }
})
$saveItem.Add_Click({
    if ($saveDialog.ShowDialog() -eq "OK") {
        $box.Text | Out-File $saveDialog.FileName -Encoding UTF8
    }
})
$exitItem.Add_Click({ $form.Close() })

$cutItem.Add_Click({ $box.Cut() })
$copyItem.Add_Click({ $box.Copy() })
$pasteItem.Add_Click({ $box.Paste() })

# --- Keyboard shortcuts ---
$form.KeyPreview = $true
$form.Add_KeyDown({
    if ($_.Control -and $_.KeyCode -eq 'S') { $saveItem.PerformClick() }
    elseif ($_.Control -and $_.KeyCode -eq 'O') { $openItem.PerformClick() }
    elseif ($_.Control -and $_.KeyCode -eq 'N') { $newItem.PerformClick() }
})

# --- Run app ---
[void]$form.ShowDialog()
