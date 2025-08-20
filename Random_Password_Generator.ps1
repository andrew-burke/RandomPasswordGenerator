#Create UI Window
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Random Password Generator'
$main_form.Width = 350
$main_form.Height = 200
$main_form.AutoSize = $false
$main_form.TopMost = $true
$CenterScreen = [System.Windows.Forms.FormStartPosition]::CenterScreen;
$main_form.StartPosition = $CenterScreen

#add Button Generate
$ButtonGenPW = New-Object System.Windows.Forms.Button
$ButtonGenPW.Location = New-Object System.Drawing.Size(100,20)
$ButtonGenPW.Size = New-Object System.Drawing.Size(120,23)
$ButtonGenPW.Text = "Generate Password"
$main_form.Controls.Add($ButtonGenPW)

#add selectable text field
$LabelGenPW = New-Object System.Windows.Forms.Textbox
$LabelGenPW.Text = "Password Generator"
$LabelGenPW.Location  = New-Object System.Drawing.Point(100,60)
$LabelGenPW.Size = New-Object System.Drawing.Size(120,23)
$LabelGenPW.AutoSize = $true
$main_form.Controls.Add($LabelGenPW)

#add Button Copy to Clipboard
$ButtonClipPW = New-Object System.Windows.Forms.Button
$ButtonClipPW.Location = New-Object System.Drawing.Size(100,100)
$ButtonClipPW.Size = New-Object System.Drawing.Size(120,23)
$ButtonClipPW.Text = "Copy to Clipboard"
$main_form.Controls.Add($ButtonClipPW)

$ButtonGenPW.Add_Click(
    {
        $WordList = @(get-content wordlist.txt)
        $Words = ((Get-Culture).TextInfo).ToTitleCase((($wordlist | Get-Random -count 1 ))) + ((Get-Culture).TextInfo).ToTitleCase((($wordlist | Get-Random -count 1 )))
        $RandomGenPassword = $words + ( Get-Random -Minimum 100 -Maximum 999 )
        $LabelGenPW.Text =  $RandomGenPassword
    }
)

$ButtonClipPW.Add_Click(
    {
        $LabelGenPW.SelectAll()
        $LabelGenPW.Copy()
    }
)

$main_form.ShowDialog()