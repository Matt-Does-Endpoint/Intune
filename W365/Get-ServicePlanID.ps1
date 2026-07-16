Install-Module Microsoft.Graph -Scope CurrentUser -Force

Connect-MgGraph -Scopes "Organization.Read.All"

Get-MgSubscribedSku |
    ForEach-Object {
        $Sku = $_

        $Sku.ServicePlans |
            Sort-Object ServicePlanName |
            Select-Object @{
                Name='SkuPartNumber'
                Expression={$Sku.SkuPartNumber}
            },
            ServicePlanName,
            ProvisioningStatus,
            ServicePlanId
    } |
    Out-GridView -Title "Microsoft 365 Service Plans"
    