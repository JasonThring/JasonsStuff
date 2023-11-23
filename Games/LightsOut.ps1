Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the form
$form = New-Object Windows.Forms.Form
$form.Text = "Lights Out"
$form.Size = New-Object Drawing.Size(300, 300)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle

# Create a 5x5 grid of buttons
$gridSize = 5
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
