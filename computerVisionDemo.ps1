#Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

#Using default Photos app won't return Process Id
<#
.SYNOPSIS
Demo for Computer Vision APIs.
.DESCRIPTION
This script demonstrates how to do call the Computer Vision APIs from Azure Cognitive Services via REST, specifically the Analyze Image API to get image descriptions. Sources:
https://docs.microsoft.com/en-us/azure/cognitive-services/computer-vision/
https://docs.microsoft.com/en-us/azure/cognitive-services/computer-vision/concept-describing-images 
https://docs.microsoft.com/en-us/azure/cognitive-services/Computer-vision/Vision-API-How-to-Topics/HowToCallVisionAPI?tabs=rest
https://westcentralus.dev.cognitive.microsoft.com/docs/services/computer-vision-v3-2
The relevant Computer Vision resource needs to be created in the Azure Portal before running this script.
.EXAMPLE
.\computerVisionDemo.ps1 -Endpoint "<endpoint URL>" -SubscriptionKey "<subscription key>" -ImagePath .\Photos -OutputPath .\Out -VisualFeatures "Description" -ShowImages
#>

#region Params
param (
	[Parameter(Mandatory=$True,HelpMessage="Endpoint URL (unique for the resource registered in Azure")]
	[ValidateNotNullOrEmpty()]
	[string]$EndpointUrl,

	[Parameter(Mandatory=$True,HelpMessage="Subscription Key")]
	[ValidateNotNullOrEmpty()]
	[string]$SubscriptionKey,

    [Parameter(Mandatory=$True,HelpMessage="Path to the folder containing all images")]
	[ValidateNotNullOrEmpty()]
	[string]$ImagePath,

    [Parameter(Mandatory=$True,HelpMessage="Path to the output folder")]
	[string]$OutputPath,

    [Parameter(Mandatory=$True,HelpMessage="The visual features we request, separated by commas (no spacing).")]
	[string]$VisualFeatures,

	[Parameter(Mandatory=$False,HelpMessage="True/False switch to preview each image in IrfanView and write responses in console")]
	[switch]$ShowImages
)

#Using IrfanView because the built-in Photos app will not return a process ID when launched.
$PhotoAppPath = "C:\Program Files\IrfanView\i_view64.exe"

#endregion

#region FunctionDefinitions

<#function Convert-ImageToBase64{
    Param([String] $Path)
    $ImageB64 = [Convert]::ToBase64String((Get-Content $Path -AsByteStream))
    return $ImageB64
}

function ConvertTo-Raw{
    Param([String] $Path) 
    $RawImage = Get-Content $Path -AsByteStream -Raw
    #[byte []]$RawImage = [System.IO.File]::ReadAllBytes($Path)
    return $RawImage
}#>

function Send-PostRequest{
    param(
        $EndpointUrl,
        $SubscriptionKey,
        $ImagePath
    )

    $Url =  "$EndpointUrl/vision/v3.2/analyze?visualFeatures=$VisualFeatures"

    $HeaderParams = @{
        "Content-Type" = "application/octet-stream"
        "Ocp-Apim-Subscription-Key" = $SubscriptionKey 
    }

    $Response = Invoke-WebRequest -Headers $HeaderParams -Uri $Url -Method Post -InFile $ImagePath
    
    return $Response.Content

}
function Use-Image{
    param(
        $ImagePath,
        $ImageName

    )
    $FullPath = "$ImagePath$ImageName"
    Write-Output "Processing image $ImageName"

    if($ShowImages)
    {
        $ProcID = (Start-Process $PhotoAppPath $FullPath -PassThru).Id
    }

    try {
        $Result = Send-PostRequest $EndpointUrl $SubscriptionKey $FullPath | ConvertFrom-Json | ConvertTo-Json -Depth 13
        $Result | Out-File "$OutputPath$($ImageName.substring(0,$ImageName.Length-3)+"txt")"
        
        Write-Output "Sent POST request successfully. `n`nResponse for $ImageName`: `n"
        Write-Host $Result -ForegroundColor DarkGreen
    }
    catch {
        Write-Error "Could not process $ImageName with error: $_"
    }
    
    if($ShowImages)
    {
        Wait-Process $ProcID #-Timeout 30
    }
    else
    {
        Start-Sleep 1
    }

}

#endRegion

#region Main

#All of this path preprocessing is only needed to show the images in IrfanView, as it won't work nicely with relative paths from my tests.
if($ImagePath[0] -eq "."){
    $Path = (Get-Location).Path + $ImagePath.substring(1)
}
else {
    $Path = $ImagePath
}
if($Path[-1] -ne "\")
{
    $Path = $Path + "\"
}

if($OutputPath[0] -eq ".")
{
    $OutputPath = (Get-Location).Path + $OutputPath.substring(1)
}
if($OutputPath[-1] -ne "\")
{
    $OutputPath = $OutputPath + "\"
}

(Get-ChildItem $Path) | % { Use-Image $Path $_.Name }