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

# resource "databricks_storage_credential" "external_mi" {
#   name = "${local.prefix}-mi"
#   azure_managed_identity {
#     access_connector_id = azapi_resource.access_connector.id
#   }
#   owner = lookup(data.external.me.result, "name")
#   comment = "UC Managed Identity managed by TF"
# #   depends_on = [
# #     databricks_metastore_assignment.this
# #   ]
# }

# resource "azurerm_storage_account" "unity_catalog" {
#   name                     = "${local.prefix}${var.region}adls"
#   resource_group_name      = azurerm_resource_group.this.name
#   location                 = azurerm_resource_group.this.location
#   tags                     = azurerm_resource_group.this.tags
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
#   is_hns_enabled           = true
# }

# resource "azurerm_storage_container" "unity_catalog" {
#   name                  = "${local.prefix}-container"
#   storage_account_name  = azurerm_storage_account.unity_catalog.name
#   container_access_type = "private"
# }

# resource "azurerm_role_assignment" "this" {
#   scope                = azurerm_storage_account.unity_catalog.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azapi_resource.access_connector.identity[0].principal_id
# }

# resource "databricks_metastore" "this" {
#   name = "primary"
#   storage_root = format("abfss://%s@%s.dfs.core.windows.net/", azurerm_storage_container.unity_catalog.name, azurerm_storage_account.unity_catalog.name)
#   owner = lookup(data.external.me.result, "name")
#   delta_sharing_scope                               = "INTERNAL"
#   delta_sharing_recipient_token_lifetime_in_seconds = 259200
#   force_destroy                                     = true
# }

# resource "databricks_metastore_data_access" "first" {
#   metastore_id = databricks_metastore.this.id
#   name         = "${local.prefix}-${var.region}-metastore"
#   azure_managed_identity {
#     access_connector_id = azapi_resource.access_connector.id
#   }

#   is_default = true
# }

# resource "databricks_metastore_assignment" "this" {
#   workspace_id         = azurerm_databricks_workspace.this.workspace_id
#   metastore_id         = databricks_metastore.this.id
#   default_catalog_name = "hive_metastore"
# }