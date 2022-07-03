<#
    .SYNOPSIS
    Prompts the user with a multi-line input box and returns the text they enter, or null if they cancelled the prompt.

    .DESCRIPTION
    Prompts the user with a multi-line input box and returns the text they enter, or null if they cancelled the prompt.

    .PARAMETER Message
    The message to display to the user explaining what text we are asking them to enter.

    .PARAMETER WindowTitle
    The text to display on the prompt window's title.

    .PARAMETER DefaultText
    The default text to show in the input box.

    .EXAMPLE
    $userText = Read-MultiLineInputDialog "Input some text please:" "Get User's Input"

    Shows how to create a simple prompt to get mutli-line input from a user.

    .EXAMPLE
    # Setup the default multi-line address to fill the input box with.
    $defaultAddress = @'
    John Doe
    123 St.
    Some Town, SK, Canada
    A1B 2C3
    '@

    $address = Read-MultiLineInputDialog "Please enter your full address, including name, street, city, and postal code:" "Get User's Address" $defaultAddress
    if ($address -eq $null)
    {
        Write-Error "You pressed the Cancel button on the multi-line input box."
    }

    Prompts the user for their address and stores it in a variable, pre-filling the input box with a default multi-line address.
    If the user pressed the Cancel button an error is written to the console.

    .EXAMPLE
    $inputText = Read-MultiLineInputDialog -Message "If you have a really long message you can break it apart`nover two lines with the powershell newline character:" -WindowTitle "Window Title" -DefaultText "Default text for the input box."

    Shows how to break the second parameter (Message) up onto two lines using the powershell newline character (`n).
    If you break the message up into more than two lines the extra lines will be hidden behind or show ontop of the TextBox.

    .EXAMPLE
    $multiLineText = Read-MultiLineInputBoxDialog -Message "Please enter some text. It can be multiple lines" -WindowTitle "Multi Line Example" -DefaultText "Enter some text here..."
    if ($multiLineText -eq $null) { Write-Host "You clicked Cancel" } else { Write-Host "You entered the following text: $multiLineText" }

    .NOTES
    Name: Show-MultiLineInputDialog
    Author: Daniel Schroeder (originally based on the code shown at http://technet.microsoft.com/en-us/library/ff730941.aspx)
    Version: 1.0
#>
function Read-MultiLineInputBoxDialog() {
    param(
        [string]$WindowTitle = "FGT Input Box",
        [string]$DefaultText = "Just here...",
        [ValidateSet("ComputerName", "ServiceTag")]
        [String]$Type = "ServiceTag"
    )

    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms
    


    # Create the TextBox used to capture the user's text.
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10,40)
    $textBox.Size = New-Object System.Drawing.Size( 580 ,200)
    $textBox.AcceptsReturn = $true
    $textBox.AcceptsTab = $false
    $textBox.Multiline = $true
    $textBox.ScrollBars = 'Both'
    $textBox.Text = $DefaultText
    $textBox.Font = [System.Drawing.Font]::new('Lucida Console', 9, [System.Drawing.FontStyle]::Regular)
 
     # Create the Label.
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(($textBox.Location.X) ,10)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.AutoSize = $true
    $label.Text = "Enter list of $Type below"
    $label.Anchor = [System.Windows.Forms.AnchorStyles]::left


    # Create the ListBox used to determine object property name.
    $ComboBox = New-Object System.Windows.Forms.ComboBox
    $ComboBox.Location = New-Object System.Drawing.Point(($textBox.Size.Width -100) ,10)
    $ComboBox.Size = New-Object System.Drawing.Size(100,20)
    $ComboBox.Items.AddRange(@("ComputerName", "ServiceTag"))
    $ComboBox.SelectedItem = $Type
    $ComboBox.Anchor = [System.Windows.Forms.AnchorStyles]::Right
    $ComboBox.Add_SelectedValueChanged({
        $label.Text = "Enter list of $($ComboBox.SelectedItem.ToString().ToLower()) below"
    })

    # Create the OK button.
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(($textBox.Size.Width -175),250)
    $okButton.Size = New-Object System.Drawing.Size(75,25)
    $okButton.Text = "OK"
    $okButton.Anchor = [System.Windows.Forms.AnchorStyles]::Right
    $okButton.Add_Click({
        $List = New-Object System.Collections.ArrayList
        $SplitOption = [System.StringSplitOptions]::RemoveEmptyEntries
        $ItemList  = $textBox.Text.Split([System.Environment]::NewLine, $SplitOption)

        Foreach ( $item in $ItemList ) {

            $List.Add([PsCustomObject]@{ $($ComboBox.SelectedItem.ToString().ToLower()) = $item } )
        }
        $form.Tag = $List 
        $form.Close()
    })

    # Create the Cancel button.
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(($textBox.Size.Width -75),250)
    $cancelButton.Size = New-Object System.Drawing.Size(75,25)
    $cancelButton.Text = "Cancel"
    $cancelButton.Add_Click({ $form.Tag = $null; $form.Close() })
    $cancelButton.Anchor = [System.Windows.Forms.AnchorStyles]::Right


    # Create the form.
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $WindowTitle
    $form.Size = New-Object System.Drawing.Size(($textBox.Size.Width +25),320)
    $form.FormBorderStyle = 'FixedSingle'
    $form.StartPosition = "CenterScreen"
    $form.AutoSizeMode = 'GrowAndShrink'
    $form.Topmost = $True
    $form.AcceptButton = $okButton
    $form.CancelButton = $cancelButton
    $form.ShowInTaskbar = $true
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.ShowIcon = $false

    # Add all of the controls to the form.
    $form.Controls.Add($label)
    $form.Controls.Add($textBox)
    $form.Controls.Add($ComboBox)
    $form.Controls.Add($okButton)
    $form.Controls.Add($cancelButton)

    # Initialize and show the form.
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog() > $null   # Trash the text of the button that was clicked.
    
    # Return the text that the user entered.
    return $form.Tag 
}

New-Alias -name rmib -Value Read-MultiLineInputBoxDialog

Export-ModuleMember Read-MultiLineInputBoxDialog -Alias gib