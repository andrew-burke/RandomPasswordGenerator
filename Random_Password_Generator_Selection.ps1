Add-Type -AssemblyName System.Windows.Forms

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = 'Random Password Generator'
$main_form.Width = 400
$main_form.Height = 220
$main_form.AutoSize = $false
$main_form.TopMost = $true
$main_form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

# ComboBox: Number of Words
$ComboWords = New-Object System.Windows.Forms.ComboBox
$ComboWords.Location = New-Object System.Drawing.Size(20, 20)
$ComboWords.Size = New-Object System.Drawing.Size(80, 23)
$ComboWords.Items.AddRange(@(2,3,4,5))
$ComboWords.SelectedIndex = 0
$main_form.Controls.Add($ComboWords)

$LabelWords = New-Object System.Windows.Forms.Label
$LabelWords.Text = "Words"
$LabelWords.Location = New-Object System.Drawing.Size(110, 22)
$LabelWords.Size = New-Object System.Drawing.Size(60, 23)
$main_form.Controls.Add($LabelWords)

# ComboBox: Order (second selector)
$ComboOrder = New-Object System.Windows.Forms.ComboBox
$ComboOrder.Location = New-Object System.Drawing.Size(20, 60)
$ComboOrder.Size = New-Object System.Drawing.Size(80, 23)
$ComboOrder.Items.AddRange(@("WordsFirst", "DigitsFirst", "Alternate"))
$ComboOrder.SelectedIndex = 0
$main_form.Controls.Add($ComboOrder)

$LabelOrder = New-Object System.Windows.Forms.Label
$LabelOrder.Text = "Order"
$LabelOrder.Location = New-Object System.Drawing.Size(110, 62)
$LabelOrder.Size = New-Object System.Drawing.Size(60, 23)
$main_form.Controls.Add($LabelOrder)

# ComboBox: Digits (shows only if not Alternate)
$ComboDigits = New-Object System.Windows.Forms.ComboBox
$ComboDigits.Location = New-Object System.Drawing.Size(20, 100)
$ComboDigits.Size = New-Object System.Drawing.Size(80, 23)
$ComboDigits.Items.AddRange(@(2,3,4,5))
$ComboDigits.SelectedIndex = 0
$ComboDigits.Visible = $true
$main_form.Controls.Add($ComboDigits)

$LabelDigits = New-Object System.Windows.Forms.Label
$LabelDigits.Text = "Digits"
$LabelDigits.Location = New-Object System.Drawing.Size(110, 102)
$LabelDigits.Size = New-Object System.Drawing.Size(60, 23)
$LabelDigits.Visible = $true
$main_form.Controls.Add($LabelDigits)

# ComboBox: Digits per Alternate (shows only if Alternate)
$ComboAltDigits = New-Object System.Windows.Forms.ComboBox
$ComboAltDigits.Location = New-Object System.Drawing.Size(20, 100)
$ComboAltDigits.Size = New-Object System.Drawing.Size(80, 23)
$ComboAltDigits.Items.AddRange(@(1,2,3,4,5))
$ComboAltDigits.SelectedIndex = 0
$ComboAltDigits.Visible = $false
$main_form.Controls.Add($ComboAltDigits)

$LabelAltDigits = New-Object System.Windows.Forms.Label
$LabelAltDigits.Text = "Digits to alternate"
$LabelAltDigits.Location = New-Object System.Drawing.Size(110, 102)
$LabelAltDigits.Size = New-Object System.Drawing.Size(120, 23)
$LabelAltDigits.Visible = $false
$main_form.Controls.Add($LabelAltDigits)

# Show/hide Digits or Digits per Alternate based on order selection
$ComboOrder.Add_SelectedIndexChanged({
    if ($ComboOrder.SelectedItem -eq "Alternate") {
        $ComboAltDigits.Visible = $true
        $LabelAltDigits.Visible = $true
        $ComboDigits.Visible = $false
        $LabelDigits.Visible = $false
    } else {
        $ComboAltDigits.Visible = $false
        $LabelAltDigits.Visible = $false
        $ComboDigits.Visible = $true
        $LabelDigits.Visible = $true
    }
})

# TextBox: Password Output
$LabelGenPW = New-Object System.Windows.Forms.TextBox
$LabelGenPW.Text = "Password Generator"
$LabelGenPW.Location = New-Object System.Drawing.Point(200, 60)
$LabelGenPW.Size = New-Object System.Drawing.Size(150, 23)
$LabelGenPW.ReadOnly = $true
$LabelGenPW.AutoSize = $false
$main_form.Controls.Add($LabelGenPW)

# Button: Generate Password
$ButtonGenPW = New-Object System.Windows.Forms.Button
$ButtonGenPW.Location = New-Object System.Drawing.Size(200, 20)
$ButtonGenPW.Size = New-Object System.Drawing.Size(150, 23)
$ButtonGenPW.Text = "Generate Password"
$main_form.Controls.Add($ButtonGenPW)

# Button: Copy to Clipboard (always below password textbox)
$ButtonClipPW = New-Object System.Windows.Forms.Button
$ButtonClipPW.Location = New-Object System.Drawing.Size(200, 95)
$ButtonClipPW.Size = New-Object System.Drawing.Size(150, 23)
$ButtonClipPW.Text = "Copy to Clipboard"
$main_form.Controls.Add($ButtonClipPW)

# Bring "Copy to Clipboard" button to the front
$ButtonClipPW.BringToFront()

# Load wordlist once
$WordListPath = "wordlist.txt"
if (!(Test-Path $WordListPath)) {
    [System.Windows.Forms.MessageBox]::Show("Wordlist file not found!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}
$WordList = Get-Content $WordListPath

$ButtonGenPW.Add_Click({
    $numWords = [int]$ComboWords.SelectedItem
    $order = $ComboOrder.SelectedItem

    if ($order -eq "Alternate") {
        $numDigits = $numWords * [int]$ComboAltDigits.SelectedItem
        $altDigits = [int]$ComboAltDigits.SelectedItem
    } else {
        $numDigits = [int]$ComboDigits.SelectedItem
        $altDigits = $null
    }

    # Use .NET Secure RNG for digits
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    function Get-SecureRandomDigit {
        $byte = New-Object 'Byte[]' 1
        do {
            $rng.GetBytes($byte)
            $value = $byte[0] % 10
        } while ($byte[0] -ge 250) # avoid modulo bias
        return $value
    }

    $words = @()
    for ($i=0; $i -lt $numWords; $i++) {
        $words += ((Get-Culture).TextInfo).ToTitleCase(($WordList | Get-Random))
    }
    $digits = ""
    for ($i=0; $i -lt $numDigits; $i++) {
        $digits += Get-SecureRandomDigit
    }

    switch ($order) {
        "WordsFirst"   { $Password = ($words -join "") + $digits }
        "DigitsFirst"  { $Password = $digits + ($words -join "") }
        "Alternate"    {
            $Password = ""
            $digitIndex = 0
            for ($i=0; $i -lt $numWords; $i++) {
                $Password += $words[$i]
                if ($digitIndex -lt $numDigits) {
                    $remainingDigits = $numDigits - $digitIndex
                    $takeDigits = [Math]::Min($altDigits, $remainingDigits)
                    $Password += $digits.Substring($digitIndex, $takeDigits)
                    $digitIndex += $takeDigits
                }
            }
        }
    }
    $LabelGenPW.Text = $Password
})

$ButtonClipPW.Add_Click({
    [System.Windows.Forms.Clipboard]::SetText($LabelGenPW.Text)
})

$main_form.ShowDialog()