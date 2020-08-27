data "azuredevops_project" "devops_project" {
  project_name = var.azure_devops_project
}

data "azurerm_policy_set_definition" "cis_set_definition" {
  display_name = local.cis_policy_display_name
}

data "azurerm_policy_set_definition" "official_set_definition" {
  display_name = local.official_policy_display_name
}
