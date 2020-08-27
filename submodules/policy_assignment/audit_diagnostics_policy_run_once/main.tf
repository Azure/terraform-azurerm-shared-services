provider "azurerm" {
  version = "~>2.0"
  features {}
}

module "auto_diagnostics_definition" {
  source = "git::https://github.com/Nepomuceno/terraform-azurerm-monitoring-policies.git"
}
