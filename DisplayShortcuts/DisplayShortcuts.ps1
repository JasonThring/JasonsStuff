# Load necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

# Script shortcuts
$shortcutsFolder = "F:\GameShortcuts"

# Function to set the theme mode
function Set-ThemeMode {
    param (
        [ValidateSet('Light', 'Dark')]
        [string]$mode
    )

    # Set the application-wide visual style to match the theme mode
    if ($mode -eq 'Dark') {
        [System.Windows.Forms.Application]::EnableVisualStyles()
        [System.Windows.Forms.Application]::VisualStyleState = 'ClientAndNonClientAreas'
        [System.Windows.Forms.Application]::SetHighDpiMode('PerMonitorV2')
    } else {
        [System.Windows.Forms.Application]::EnableVisualStyles()
        [System.Windows.Forms.Application]::VisualStyleState = 'ClientAndNonClientAreas'
        [System.Windows.Forms.Application]::SetHighDpiMode('PerMonitorV2')
    }

    # Refresh the form to apply the theme changes
    $form.Refresh()

    # Apply color changes based on the selected theme mode
    if ($mode -eq 'Dark') {
        $form.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        $form.ForeColor = [System.Drawing.Color]::White
        $listView.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
        $listView.ForeColor = [System.Drawing.Color]::White
        $refreshButton.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
        $refreshButton.ForeColor = [System.Drawing.Color]::White
        $openButton.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
        $openButton.ForeColor = [System.Drawing.Color]::White
        $themeButton.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
        $themeButton.ForeColor = [System.Drawing.Color]::White
    } else {
        $form.BackColor = [System.Drawing.SystemColors]::Control
        $form.ForeColor = [System.Drawing.SystemColors]::ControlText
        $listView.BackColor = [System.Drawing.SystemColors]::Window
        $listView.ForeColor = [System.Drawing.SystemColors]::WindowText
        $refreshButton.BackColor = [System.Drawing.SystemColors]::Control
        $refreshButton.ForeColor = [System.Drawing.SystemColors]::ControlText
        $openButton.BackColor = [System.Drawing.SystemColors]::Control
        $openButton.ForeColor = [System.Drawing.SystemColors]::ControlText
        $themeButton.BackColor = [System.Drawing.SystemColors]::Control
        $themeButton.ForeColor = [System.Drawing.SystemColors]::ControlText
    }
}

# Get the current Windows theme and set the default mode
$windowsTheme = [System.Windows.Forms.Application]::VisualStyleState
$defaultMode = if ($windowsTheme -eq 'ClientAndNonClientAreas') { 'Light' } else { 'Dark' }

# Create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Shortcut Files Viewer"
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = "CenterScreen"

# Create an ImageList for file icons
$imageList = New-Object System.Windows.Forms.ImageList
$imageList.ImageSize = New-Object System.Drawing.Size(48, 48) # Adjust the icon size

# Create a ListView to display shortcut files with large icons
$listView = New-Object System.Windows.Forms.ListView
$listView.Location = New-Object System.Drawing.Point(10, 10)
$listView.Size = New-Object System.Drawing.Size(580, 300)
$listView.View = [System.Windows.Forms.View]::LargeIcon # Set the view to LargeIcon
$listView.LargeImageList = $imageList
$listView.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($listView)

# Button to refresh the list
$refreshButton = New-Object System.Windows.Forms.Button
$refreshButton.Location = New-Object System.Drawing.Point(10, 330)
$refreshButton.Size = New-Object System.Drawing.Size(100, 30)
$refreshButton.Text = "Refresh"
$refreshButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
$refreshButton.Add_Click({
    Refresh-ShortcutList
})
$form.Controls.Add($refreshButton)

# Button to open the selected shortcut
$openButton = New-Object System.Windows.Forms.Button
$openButton.Location = New-Object System.Drawing.Point(490, 330)
$openButton.Size = New-Object System.Drawing.Size(100, 30)
$openButton.Text = "Open"
$openButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
$openButton.Add_Click({
    Open-SelectedShortcut
})
$form.Controls.Add($openButton)

# Button to switch between light and dark modes
$themeButton = New-Object System.Windows.Forms.Button
$themeButton.Location = New-Object System.Drawing.Point(250, 330)
$themeButton.Size = New-Object System.Drawing.Size(100, 30)
$themeButton.Text = "Toggle Theme"
$themeButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::None
$themeButton.Add_Click({
    if ($form.Tag -eq 'Light') {
        Set-ThemeMode -mode 'Dark'
        $form.Tag = 'Dark'
    } else {
        Set-ThemeMode -mode 'Light'
        $form.Tag = 'Light'
    }
})
$form.Controls.Add($themeButton)

# Function to refresh the list of shortcut files
function Refresh-ShortcutList {
    $listView.Items.Clear()
    $imageList.Images.Clear()

    $shortcutFiles = Get-ChildItem -Path $shortcutsFolder
    foreach ($file in $shortcutFiles) {
        $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($file.FullName)
        $imageList.Images.Add($icon)

        $itemName = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName)
        $item = New-Object System.Windows.Forms.ListViewItem
        $item.ImageIndex = $imageList.Images.Count - 1
        $item.Text = $itemName # Set the item text to display the name
        $listView.Items.Add($item)
    }
}

# Enable full row select and drag-and-drop for the ListView
$listView.FullRowSelect = $true
$listView.AllowDrop = $true

# Event handler for mouse down to initiate the drag
$listView.Add_MouseDown({
    $dragItem = $_.Item
    if ($dragItem -ne $null) {
        $listView.DoDragDrop($dragItem, [System.Windows.Forms.DragDropEffects]::Move)
    }
})

# Event handler for drag enter to set the effect
$listView.Add_DragEnter({
    $_.Effect = [System.Windows.Forms.DragDropEffects]::Move
})

# Event handler for drag drop to update the item position
$listView.Add_DragDrop({
    $point = $listView.PointToClient($_.MousePosition)
    $targetItem = $listView.GetItemAt($point.X, $point.Y)

    if ($targetItem -ne $null -and $targetItem -ne $dragItem) {
        $index = $targetItem.Index
        $listView.Items.Remove($dragItem)
        $listView.Items.Insert($index, $dragItem)
    }
})

# Function to open the selected shortcut
function Open-SelectedShortcut {
    if ($listView.SelectedItems.Count -eq 1) {
        $selectedItem = $listView.SelectedItems[0]
        $fileName = $selectedItem.Text
        Start-Process "$shortcutsFolder\$fileName"
    }
}

# Call the refresh function to populate the list on startup
Refresh-ShortcutList

# Set the default theme mode based on the current Windows theme
Set-ThemeMode -mode $defaultMode
$form.Tag = $defaultMode  #

# Show the form
$form.ShowDialog()
