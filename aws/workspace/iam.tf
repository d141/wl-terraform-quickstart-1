// Cross Account Role
resource "databricks_mws_credentials" "this" {
  provider         = databricks.mws
  account_id       = var.databricks_account_id
  role_arn         = var.iam_role_arn
  credentials_name = "${local.prefix}-cross-account-role"
}