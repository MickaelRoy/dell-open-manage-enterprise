$ErrorActionPreference = "Continue"
Set-CertPolicy
[System.IO.Directory]::EnumerateFiles("$PSScriptRoot\Functions") | % {
    
    . $_

}
