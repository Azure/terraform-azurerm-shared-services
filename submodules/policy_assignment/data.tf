data "azurerm_policy_set_definition" "cis_set_definition" {
  display_name = local.cis_policy_display_name
}

data "azurerm_policy_set_definition" "official_set_definition" {
  display_name = local.official_policy_display_name
}

/* data "azurerm_policy_set_definition" "auto_diagnostics_set_definition" {
  display_name = local.auto_diagnostics_display_name
}*/
