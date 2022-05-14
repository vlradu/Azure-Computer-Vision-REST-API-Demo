# Azure-Computer-Vision-REST-API-Demo

This is a simple PowerShell script that iterates through images in a folder and calls the Analyze Images API to obtain their features.  
**Important:** This requires setting up your own Computer Vision resource in the Azure Portal.  

## How to run:  
In a PowerShell session, call the script with a syntax similar to this:  
*.\computerVisionDemo.ps1 -Endpoint "endpoint URL" -SubscriptionKey "subscription key" -ImagePath .\Photos -OutputPath .\Out -VisualFeatures "Description" -ShowImages*

## Prerequisites:  
If you're going to use the **-ShowImages** parameter to preview the images, you'll also need to install IrfanView or modify **$PhotoAppPath** to point out to your installed image viewing application.  
Due to how the default Windows Photos app is built, launching it will not return a process ID to the script and because of this, the script will not work as intended with the Photos app. In that case it's better to drop **-Previewimages** altogether.
  
## Sources:
https://docs.microsoft.com/en-us/azure/cognitive-services/computer-vision/  
https://docs.microsoft.com/en-us/azure/cognitive-services/computer-vision/concept-describing-images  
https://docs.microsoft.com/en-us/azure/cognitive-services/Computer-vision/Vision-API-How-to-Topics/HowToCallVisionAPI?tabs=rest  
https://westcentralus.dev.cognitive.microsoft.com/docs/services/computer-vision-v3-2  