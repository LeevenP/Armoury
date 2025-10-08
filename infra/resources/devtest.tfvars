location                = "westeurope"
subscription_name       = "DER-AZ-DEVTEST-AzureLocalMAL"
environment             = "devtest"
name                    = "AzureLocalMAL"
create_private_dns_zone = false
tags = {
  role             = "infra",
  business-unit    = "infrastructure-technologies"
  customer         = "cross-customer"
  environment-type = "devtest"
  market           = "no-market-impact"
  owner            = "infra-operationsowner@derivco.com"
  support-owner    = "systemservicesinfrastructure@derivco.com"
  software-product = "infrastructure"
}
