// Databricks Variables
databricks_account_username = ""
databricks_account_password = ""
databricks_account_id = ""
resource_owner = ""
resource_prefix = "wl-terraform-quickstart"

// AWS Variables
aws_access_key = ""
aws_secret_key = ""
data_bucket = ""

// Dataplane Variables
region = "us-east-1"
vpc_cidr_range = "10.0.0.0/18"
private_subnets_cidr = "10.0.0.0/22,10.0.4.0/22"
public_subnets_cidr = "10.0.8.0/25,10.0.8.128/25"
firewall_subnets_cidr = "10.0.9.0/25,10.0.9.128/25"
privatelink_subnets_cidr = "10.0.10.0/25,10.0.10.128/25"
availability_zones = "us-east-1a,us-east-1b"

// Regional Private Link Variables: https://docs.databricks.com/administration-guide/cloud-configurations/aws/privatelink.html#regional-endpoint-reference
relay_vpce_service = ""
workspace_vpce_service = ""

//Regional Metastore Variable: https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html#configure-a-firewall-and-outbound-access-optional
metastore_url = ""

// Firewall
firewall_allow_list = ""
firewall_protocol_deny_list = "ICMP,FTP,SSH"

// Authoritative User - WL Variables
customer_name = ""
authoritative_user_email = ""
authoritative_user_full_name = ""

// Co-Branding - WL Variables
sidebarLogoActive = "https://mlflow.org/images/MLflow-logo-final-white-TM.png"
sidebarLogoInactive = "https://databricks.com/wp-content/uploads/2020/04/Logo-mlflow-color.png"
sidebarLogoText = "Delta Inc."

homePageWelcomeMessage = "Let the Data Science begin"
homePageLogo = "https://docs.delta.io/latest/_static/delta-lake-logo.png"
homePageLogoWidth = "200px"

productName = "Koalas Analytics Studio"
loginLogo = "https://raw.githubusercontent.com/databricks/koalas/master/icons/koalas-logo.png"
loginLogoWidth = "300px"
