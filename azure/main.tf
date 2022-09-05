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
  dbfsname = join("", ["dbfs", trim(local.prefix, "-")]) 
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
  // The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'
  // this is not named as DATABRICKS_HOST, because it affect authentication
  value = "https://${azurerm_databricks_workspace.this.workspace_url}/"
}