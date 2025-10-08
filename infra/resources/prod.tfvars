location                = "westeurope"
subscription_name       = "DER-AZ-PROD-AzureLocalMAL"
environment             = "prod"
name                    = "AzureLocalMAL"
create_private_dns_zone = true
tags = {
  role             = "infra",
  business-unit    = "infrastructure-technologies"
  customer         = "cross-customer"
  environment-type = "prod"
  market           = "no-market-impact"
  owner            = "infra-infrastructureowner@domain-name.com"
  support-owner    = "teamname@domian-name.com"
  software-product = "infrastructure"
}

hcicluster = {
  network = {
    dns-servers = {
      primary   = "10.40.4.xx"
      secondary = "10.40.4.xx"
    }

  }
  customlocation = "malalxx"
}