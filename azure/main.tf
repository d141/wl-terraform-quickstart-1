provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

locals {
  prefix = var.resource_prefix
  cidr_block = var.cidr_block
  dbfsname = join("", [trim(local.prefix, "-"), var.region, "dbfs"]) 
  tags = {
    Owner       = lookup(data.external.me.result, "name")
  }
}

resource "azurerm_resource_group" "this" {
  name     = "${local.prefix}-rg"
  location = var.region
  tags     = local.tags
}

output "resource_group" {
  value = azurerm_resource_group.this.name
}

output "databricks_azure_workspace_resource_id" {
  value = azurerm_databricks_workspace.this.id
}

output "workspace_url" {
  value = "https://${azurerm_databricks_workspace.this.workspace_url}/"
}

output "region" {
    value = var.region
}

output "adls_path" {
    value = join("", [format("%s@%s.dfs.core.windows.net/", azurerm_storage_container.unity_catalog.name, azurerm_storage_account.unity_catalog.name), "managed/"])
}