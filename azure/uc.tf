# resource "azapi_resource" "access_connector" {
#   type      = "Microsoft.Databricks/accessConnectors@2022-04-01-preview"
#   name      = "${local.prefix}-mi"
#   location  = azurerm_resource_group.this.location
#   parent_id = azurerm_resource_group.this.id
#   identity {
#     type = "SystemAssigned"
#   }
#   body = jsonencode({
#     properties = {}
#   })
# }

resource "azurerm_storage_account" "unity_catalog" {
  name                     = "${local.prefix}${var.region}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  tags                     = azurerm_resource_group.this.tags
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "unity_catalog" {
  name                  = "${local.prefix}-uc"
  storage_account_name  = azurerm_storage_account.unity_catalog.name
  container_access_type = "private"
}

# resource "azurerm_role_assignment" "this" {
#   scope                = azurerm_storage_account.unity_catalog.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azapi_resource.access_connector.identity[0].principal_id
# }