provider "azurerm" {
  version = "~>2.0"
  features {}
}

module "shared_services" {
  source                      = "../../"
  virtual_network_cidr        = "10.0.0.0/20"
  use_existing_resource_group = false
  resource_group_location     = "uksouth"
  devops_pat_token            = "g25u6yfar532e35g7md37mb3dzsq4s4wbho4ku6kt4jd3sluqbfa"
  devops_project              = "AnalyticsPlatform"
  devops_org                  = "https://dev.azure.com/lukedevonshire"
}
