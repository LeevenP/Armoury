subscription = {
  name                = ""
  management_group_id = ""
  location            = ""
  security_owners = [
    ""
  ]
  create_aks_dns         = true
  create_key_vault       = true
  create_storage_account = true
  budget_amount          = 10
  budget_emails = [
  ""]
  subnet_mask_size = "24"
  dual_region      = false
}

nsg_rules = {
  frontend_nsg = [],
  other_nsg    = []
}

tags = {
  role             = "infra",
  business-unit    = "Technology"
  customer         = "cross-customer"
  environment-type = "prod"
  market           = "no-market-impact"
  owner            = "infra-infrastructureowner@xyz.com"
  support-owner    = "systemservicesinfrastructure@xyz.com"
  software-product = "infrastructure"
}
