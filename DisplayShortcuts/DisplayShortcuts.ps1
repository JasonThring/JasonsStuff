# Load necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

# Script shortcuts
$shortcutsFolder = "F:\GameShortcuts"

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
$form.Controls.Add($listView)

# Button to refresh the list
$refreshButton = New-Object System.Windows.Forms.Button
$refreshButton.Location = New-Object System.Drawing.Point(10, 330)
$refreshButton.Size = New-Object System.Drawing.Size(100, 30)
$refreshButton.Text = "Refresh"
$refreshButton.Add_Click({
    Refresh-ShortcutList
})
$form.Controls.Add($refreshButton)

# Button to open the selected shortcut
$openButton = New-Object System.Windows.Forms.Button
$openButton.Location = New-Object System.Drawing.Point(490, 330)
$openButton.Size = New-Object System.Drawing.Size(100, 30)
$openButton.Text = "Open"
$openButton.Add_Click({
    Open-SelectedShortcut
})
$form.Controls.Add($openButton)

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

# Show the form
$form.ShowDialog()
