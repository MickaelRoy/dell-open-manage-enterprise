Function Get-OMECatalog {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter(Mandatory)]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [uint64] $CatalogId
    )

    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

    Try {
        $CatalogURL = "https://$Server/api/UpdateService/Catalogs($CatalogId)"

        $Response = Invoke-WebRequest -Uri $CatalogURL -UseBasicParsing -Headers $Headers -ContentType $Type
        Write-Verbose "Status Code is $($Response.StatusCode)"

        If ($Response.StatusCode -eq 200) {
            $Result = $Response.Content | ConvertFrom-Json
        }

    } Catch {
        $_ | ConvertFrom-ErrorJson
    }
    Return $Result
}

Export-ModuleMember Get-OMECatalog