Function Remove-OMESession {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter()]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json"
    )

    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

    $RSessionUrl = "https://$Server/api/SessionService/Sessions(`'$($Headers.Id)`')"
    $SessResponse = Invoke-WebRequest -Uri $RSessionUrl -Method Delete -ContentType $Type  -Headers $Headers
    
    If ($SessResponse.StatusCode -eq 204) { Write-Verbose -Message "Session closed" }

}

Export-ModuleMember Remove-OMESession