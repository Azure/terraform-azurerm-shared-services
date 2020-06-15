provider "azurerm" {
  version = "~>2.0"
  features {}
}

module "shared_services" {
  source                      = "../../"
  virtual_network_cidr        = "10.0.0.0/20"
  use_existing_resource_group = false
  resource_group_location     = "uksouth"
}


