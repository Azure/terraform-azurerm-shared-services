output "sec_resource_group" {
  value = module.shared_services.sec_resource_group
}

output "sec_key_vault" {
  value = module.shared_services.sec_key_vault
}

output "diag_resource_group" {
  value = module.shared_services.diag_resource_group
}

output "diag_log_analytics_workspace" {
  value = module.shared_services.diag_log_analytics_workspace
}

output "diag_event_hub_namespace" {
  value = module.shared_services.diag_event_hub_namespace
}

output "diag_event_hubs" {
  value = module.shared_services.diag_event_hubs
}

output "diag_storage_account" {
  value = module.shared_services.diag_storage_account
}

output "net_resource_group" {
  value = module.shared_services.net_resource_group
}

output "net_virtual_network" {
  value = module.shared_services.net_virtual_network
}

/* output "net_firewall_subnet" {
  value = module.shared_services.net_firewall_subnet
} */

output "net_secrets_subnet" {
  value = module.shared_services.net_secrets_subnet
}

output "net_audit_subnet" {
  value = module.shared_services.net_audit_subnet
}

output "data_storage_account" {
  value = module.shared_services.data_storage_account
}
