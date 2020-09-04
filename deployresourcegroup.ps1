param (  
  [string]$ResourceGroup="subashtest",
  [string]$Subscription="xxxxxxxxxx",
  [string]$Templatefile="xxxxxx\azuredeploy.json",
  [string]$Parametersfile="xxxxxxxxx\azuredeploy.parameters.json",
  [string]$administratorLoginPassword

)

function Invoke-AzureCLI() {
  & az $args
  if ($LASTEXITCODE -ne 0) {
    throw "AzureCLI call failed: $LASTEXITCODE"
  }
}

function Get-SecretValue {
  param (
    [string]$VaultName="subashtest",
    [string]$SecretName="administratorLoginPassword"
  )
  return (Invoke-AzureCLI keyvault secret show --vault-name $VaultName --name $SecretName | ConvertFrom-JSON).value
}


function Invoke-ValidateResourceGroupDeployment
{
  param(
    [string]$ResourceGroup,
    [string]$Templatefile,
    [string]$Parametersfile,
    [string]$administratorLoginPassword,
    [string]$Subscription
  )

  $administratorLoginPassword=Get-SecretValue
 $result= az group deployment validate --resource-group $ResourceGroup --subscription $Subscription --template-file $Templatefile --parameters $Parametersfile --parameters adminPassword=$administratorLoginPassword
Write-Host $result

if($LASTEXITCODE -ne 0)
{
  throw "Template validation failed"
}
}
function Invoke-ResourceGroupDeployment{
  param(
    [string]$ResourceGroup,
    [string]$Templatefile,
    [string]$Parametersfile,
    [string]$administratorLoginPassword,
    [string]$Subscription  
  )
  $administratorLoginPassword=Get-SecretValue
  
    $result= az group deployment create --resource-group $ResourceGroup --subscription $Subscription --template-file $Templatefile --parameters $Parametersfile --parameters adminPassword=$administratorLoginPassword
   Write-Host $result
   
   if($LASTEXITCODE -ne 0)
   {
     throw "Template validation failed"
   }

}

Invoke-ValidateResourceGroupDeployment -ResourceGroup $ResourceGroup -Templatefile $Templatefile  -Parametersfile $Parametersfile -Subscription $Subscription
Invoke-ResourceGroupDeployment -ResourceGroup $ResourceGroup -Templatefile $Templatefile -Parametersfile $Parametersfile -Subscription $Subscription
