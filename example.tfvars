// Databricks Variables
databricks_account_username = 
databricks_account_password = 
databricks_account_id = 
resource_owner = 
resource_prefix = "wl-terraform-quickstart"

// AWS Variables
aws_access_key = 
aws_secret_key = 

// Dataplane Variables
region = "us-east-1"
vpc_cidr_range = "10.0.0.0/18"
private_subnets_cidr = "10.0.32.0/22,10.0.36.0/22"
public_subnets_cidr = "10.0.40.0/22,10.0.44.0/22"
firewall_subnets_cidr = "10.0.48.0/22,10.0.52.0/22"
privatelink_subnets_cidr = "10.0.56.0/22"
availability_zones = "us-east-1a,us-east-1b"

// Regional Private Link Variables: https://docs.databricks.com/administration-guide/cloud-configurations/aws/privatelink.html#regional-endpoint-reference
relay_vpce_service = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
workspace_vpce_service = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"

//Regional Metastore Variable: https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html#configure-a-firewall-and-outbound-access-optional
metastore_url = "mdb7sywh50xhpr.chkweekm4xjq.us-east-1.rds.amazonaws.com"

// Firewall
firewall_allow_list = ""
firewall_protocol_deny_list = "ICMP,FTP,SSH"

// WL Variables
customer_name = 
authoritative_user_email = 
authoritative_user_full_name = 

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
