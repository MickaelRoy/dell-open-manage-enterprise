Function Set-CertPolicy() {
    ## Trust all certs - for sample usage only
    Try {
        Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }
    Catch {
        Write-Error "Unable to add type for cert policy"
    }
}

Function ConvertFrom-ErrorJson {
    [cmdletbinding()]
    param(
        [parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true)]
        $catchedError
    )
        If ( -not [string]::IsNullOrEmpty($catchedError.ErrorRecord.ErrorDetails) ) {
            $Failure = $catchedError.ErrorRecord.ErrorDetails | ConvertFrom-Json
            Write-error -message "$($Failure.error."@Message.ExtendedInfo".Message)`n$($Failure.error."@Message.ExtendedInfo".Resolution)"

        } ElseIf (-not [string]::IsNullOrEmpty($catchedError.ErrorDetails)) {
             $Failure = $catchedError.ErrorDetails | ConvertFrom-Json
             Write-error -message "$($Failure.error."@Message.ExtendedInfo".Message)`n$($Failure.error."@Message.ExtendedInfo".Resolution)"
        
        } Else {
            Throw $catchedError
        }
}