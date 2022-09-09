resource "azurerm_private_endpoint" "dp-to-cp" {
  name                = "pe-${local.prefix}-dp-to-cp"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.plsubnet.id 

  private_service_connection {
    name                           = "pl-${local.prefix}-dp-to-cp"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "${local.prefix}-private-dnsz-dp-to-cp"
    private_dns_zone_ids = [azurerm_private_dns_zone.dp_to_cp.id]
  }
}

resource "azurerm_private_dns_zone" "dp_to_cp" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dp_to_cp" {
  name                  = "${local.prefix}-dp-to-cp-dns-link"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dp_to_cp.name
  virtual_network_id    = azurerm_virtual_network.this.id 
}

resource "azurerm_private_dns_cname_record" "cnamerecord" { 
  name                = "${azurerm_resource_group.this.location}.pl-auth"
  zone_name           = azurerm_private_dns_zone.dp_to_cp.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 60
  record              = azurerm_databricks_workspace.this.workspace_url
}


//dbfs pvt endpoint
resource "azurerm_private_endpoint" "dbfs" {
  name                = "pe-${local.prefix}-dbfs"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.plsubnet.id 


  private_service_connection {
    name                           = "pl-${local.prefix}-dbfs"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/${local.dbfsname}"])
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "${local.prefix}-private-dnsz-dbfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dbfs.id]
  }
}
resource "azurerm_private_dns_zone" "dbfs" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dbfs" {
  name                  = "${local.prefix}-dbfs-dns-link"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dbfs.name
  virtual_network_id    = azurerm_virtual_network.this.id 
}