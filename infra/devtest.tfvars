subscription = {
  name                = "Sub_Name"
  management_group_id = "LZ-DEVTEST-HOLDING"
  location            = "westeurope"
  security_owners = [
    "xxx@oak.group"
  ]
  create_aks_dns         = false
  create_key_vault       = true
  create_storage_account = true
  budget_amount          = 10
  budget_emails = [
  "xxx@oak.group"]
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
  environment-type = "devtest"
  market           = "no-market-impact"
  owner            = "lee@test.group"
  support-owner    = "technology@test.group"
  software-product = "infrastructure"
}
