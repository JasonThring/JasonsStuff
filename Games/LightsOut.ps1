Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the grid size
$gridSize =10

# Define the form
$form = New-Object Windows.Forms.Form
$form.Text = "Lights Out"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
$form.MinimumSize = New-Object Drawing.Size(200, 200)  # Set a minimum size to prevent it from being resized too small

# Create a grid of buttons
$buttons = @()

for ($i = 0; $i -lt $gridSize; $i++) {
    for ($j = 0; $j -lt $gridSize; $j++) {
        $button = New-Object Windows.Forms.Button
        $button.Size = New-Object Drawing.Size(50, 50)
        $button.Location = New-Object Drawing.Point(($j * 50), ($i * 50))
        $button.Tag = "$i,$j"
        $button.Add_Click({
            ToggleLights $button.Tag
        })

        # Set the Anchor property to make the button resize with the form
        <#$button.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor `
                         [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right#>

        $form.Controls.Add($button)
        $buttons += $button
    }
}

# Function to toggle lights
function ToggleLights($tag) {
    $row, $col = $tag -split ','
    $row = [int]$row
    $col = [int]$col

    # Toggle the clicked button
    $buttons[$row * $gridSize + $col].Text = $buttons[$row * $gridSize + $col].Text -eq "X" ? "" : "X"

    # Toggle adjacent buttons
    $adjacent = @(
        (($row - 1), $col),
        (($row + 1), $col),
        ($row, ($col - 1)),
        ($row, ($col + 1))
    )

    foreach ($pos in $adjacent) {
        $r, $c = $pos
        if ($r -ge 0 -and $r -lt $gridSize -and $c -ge 0 -and $c -lt $gridSize) {
            $buttons[$r * $gridSize + $c].Text = $buttons[$r * $gridSize + $c].Text -eq "X" ? "" : "X"
        }
    }

    # Check for victory
    $isVictory = $buttons -notcontains "X"
    if ($isVictory) {
        [System.Windows.Forms.MessageBox]::Show("Congratulations! You've won the game.", "Victory!")
        $form.Close()
    }
}

# Show the form
$form.ShowDialog()
