Function New-OMECatalog {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",
        [Parameter()]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter()]
        [String] $Name = "Catalog_$([datetime]::Now.ToString("yyyyMMdd"))",

        [Parameter()]
        [ValidateSet("HTTP", "HTTPS", "CIFS", "DELL_ONLINE", "NFS")]
        [String] $RepositoryType = "HTTP",

        [Parameter()]
        [String] $Description = $null,

        [Parameter()]
        [String] $Source = "parg1pdrm002.gaia.net.intra",

        [Parameter()]
        [String] $Filename = "Catalog.xml",

        [Parameter()]
        [String] $Path = "S2D_Nodes"

    )

$CatalogPayload = @{
    "Filename" = $Filename;
    "SourcePath" = $Path;
    "Repository" = @{
        "Name" = $Name;
        "Description" = $Description;
        "RepositoryType" = $RepositoryType;
        "Source" = $Source;
        "DomainName" = "";
        "Username" = "";
        "Password" = "";
        "CheckCertificate" = $false
    }
} | ConvertTo-Json -Depth 6

Remove-Variable Catalog, Object -ea 0

$Response  = Invoke-WebRequest -UseBasicParsing -Uri http://$Source/$Path
$LookedFile = $Response.Links | Where-Object outerHTML -match $Filename
If ( [String]::IsNullOrEmpty($LookedFile) ) {
    $Found = $Response.Links | Where-Object outerHTML -match ".xml"
    $html = [HtmlAgilityPack.HtmlDocument]::new()
    $html.LoadHtml($Found.outerHTML)
    $html.DocumentNode.InnerText
    Throw "File or repository not found, Do you mean $($html.DocumentNode.InnerText) ?"
}

    $CatalogURL = "https://$Server/api/UpdateService/Catalogs"
    $Body = $CatalogPayload

    $Response = Invoke-WebRequest -Uri $CatalogURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $Body
    Write-Verbose "Status Code is $($Response.StatusCode)"
    If ($Response.StatusCode -eq 201) {
        Write-Verbose -Message "Catalog creation successful... waiting for completion"
        $TaskId = ($Response.Content | ConvertFrom-Json).TaskId

        $i=0
        While ( [String]::IsNullOrEmpty($Object) ) {
            $i++
            If ($i -gt 30){ Break }
            Start-Sleep -s 1
            $Response2 = Invoke-WebRequest -Uri $CatalogURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method GET
            Write-Verbose "Status Code is $($Response2.StatusCode)"
            If ($Response2.StatusCode -eq 200) {
                Write-Verbose "Api call is good, looking for task Id..."
                $CatalogInfo = $Response2 | ConvertFrom-Json
                Foreach ($catalog in $CatalogInfo.value) {
                    If ($catalog.TaskId -eq $TaskId) {
                        Write-Verbose "Getting Ids and builing object to return"
                        $Object = [PsCustomObject] @{ RepositoryId = [uint64]$catalog.Repository.Id; CatalogId = [uint64]$catalog.Id }
                    }
                }
            }
        }
    } Else {
        Write-Warning "Catalog creation failed...skipping update"
    }
    Return $Object
}

Export-ModuleMember New-OMECatalog