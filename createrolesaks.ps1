$aksresourceGroup="subashtest"
$aksclustername="subashtest"
$acrresourcegroup="subashtest"
$acrName="subashtest"
$subscription="XXXXXXXXXXX"
$principalUser="XXXXXXXX"
$principalPassword="XXXXXXXXXX"


#Login to Azure using the service principle

Write-Output "Loggin in with Service Principal $servicePrincipal"
#az login --service-principal -u $principalUser -p $principalPassword -t $principalTennant
az login --username $principalUser --password $principalPassword
az account set --subscription $subscription

# Get the id of the service principal configured for AKS
$Clientid=$(az aks show --resource-group $aksresourceGroup --name $aksclustername --query "servicePrincipalProfile.clientId" --output tsv)
Write-Output "Client id is: $Clientid"

# Get the ACR registry resource id
$Acrid=$(az acr show --name $acrName --resource-group $acrresourcegroup --query "id" --output tsv)
Write-Output "ACR id is: $Acrid"


# Create role assignment
$role=az role assignment list --assignee $Clientid --role acrpull --scope $Acrid --subscription $subscription
$role1= $role | ConvertFrom-Json
$role2=$role1.principalName
if($role2 -eq $Clientid){
Write-Output "Role is present: $role"
}
else{
Write-Host "Role Not Present Creating Role"
$role=az role assignment create --assignee $Clientid --role acrpull --scope $Acrid
Write-Host "Role Created : $role"
}


#AKs Get Credentails
az aks get-credentials --resource-group $aksresourceGroup --name $aksclustername --overwrite