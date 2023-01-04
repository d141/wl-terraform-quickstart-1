//  Account Instance Profile 
resource "databricks_instance_profile" "shared" {
  instance_profile_arn = var.instance_profile
}


// Instance Profile for SQL Warehouse
resource "databricks_sql_global_config" "this" {
  instance_profile_arn = var.instance_profile
  depends_on = [
    databricks_instance_profile.shared
  ]
}

// SQL Warehouse
resource "databricks_sql_endpoint" "this" {
  name             = "Endpoint for ${var.customer_name}"
  cluster_size     = "X-Small"
  max_num_clusters = 2

  tags {
    custom_tags {
      key   = "Customer"
      value = var.customer_name
    }
  }
  depends_on = [
    databricks_sql_global_config.this
  ]
}

// DE + ML Cluster
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "shared_autoscaling" {
  cluster_name            = "Cluster for ${var.customer_name}"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = "i3.xlarge"
  autotermination_minutes = 20
  autoscale {
    min_workers = 1
    max_workers = 8
  }
  aws_attributes {
    instance_profile_arn    = var.instance_profile
    availability            = "SPOT_WITH_FALLBACK"
    zone_id                 = "auto"
    first_on_demand         = 1
    spot_bid_price_percent  = 100
  }
  custom_tags = {
    "Customer" = var.customer_name
  }
  depends_on = [
    databricks_instance_profile.shared
  ]
}