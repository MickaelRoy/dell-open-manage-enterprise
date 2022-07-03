# Dell Open Manage Entreprise Powershell Module

Based on an initial work of Dell Bengalor team

This module provides the tools to manage Dell OpenManage through restfull API

## Installation

Clone the repository on your environment

Import module using Import-Module Powershell Cmdlet

## Usage

In order to use cmdlet, you have to generate an access token using New-OmeSession

```powershell
$headers = New-OMESession -Credentials $Credentials
```
$headers variable will contain the access tonken.

## Examples

Push a list as input objects to Get-OMEDevice to get device detail from OpenManage Server

```powershell
Read-MultiLineInputBoxDialog | Get-OMEDevice -Server $Server -Headers $Headers
```

Get BaseLines related to a server identified by servicetag

```powershell
$Device = Get-OMEDevice -Headers $headers -ServiceTag fgstcm2
$Baseline = Get-OMEDeviceBaseline -Server $Server -Headers $Headers -DeviceId $Device.Id
```

Don't confound with Get-OMEDevice whitch gives baseline details idetified by baseline id

Create and push a payload to discover a server identified by Ip address

```powershell
$Payload = New-OMEDiscoveryJob -Headers $headers -Credentials $cred -Verbose -Ipaddress "10.153.100.115"
Push-OMEdiscoveryJob -Headers $headers -Payload $Payload
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
