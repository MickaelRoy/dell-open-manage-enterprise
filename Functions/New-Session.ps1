Function New-OMESession {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter(Mandatory)]
        [pscredential] $Credentials,

        [Parameter()]
        [String] $Type = "application/json"
    )

    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

    $NSessionUrl = "https://$Server/api/SessionService/Sessions"
    $UserName = $Credentials.UserName
    $Password = $Credentials.GetNetworkCredential().password
    $UserDetails = @{"UserName" = $UserName; "Password" = $Password; "SessionType" = "API"} | ConvertTo-Json
    $Headers = @{}

    $SessResponse = Invoke-WebRequest -Uri $NSessionUrl -Method Post -Body $UserDetails -ContentType $Type
    $Headers."X-Auth-Token" = $SessResponse.Headers["X-Auth-Token"]
    $Headers.Id = ($SessResponse.Content | ConvertFrom-Json).Id
    Write-Verbose -Message "Successfully created session with $($Server)"

    Return $Headers

}

Export-ModuleMember New-OMESession