# White Label (WL) - Terraform QuickStart

This Terraform Quickstart is meant to be a **foundation** for creating reusable White Label Databricks solution within your AWS environment.

**Disclaimer**: There is no dedicated warranty or support for this Terraform script. Please raise GitHub issues as needed.

# Getting Started

1. Clone this Repo 

2. Install [Terraform](https://developer.hashicorp.com/terraform/downloads)

3. Fill out `example.tfvars` and place in `aws-wl` directory

4. Run `terraform init`

5. Run `terraform validate`

6. From `aws-wl` directory, run `terraform plan -var-file ../example.tfvars`

7. Run `terraform apply -var-file ../example.tfvars`

# Terraform Script

- Data Plane Creation
    - Workspace Subnets
    - Security Groups
    - NACLs
    - Route Tables
    - AWS VPC Endpoints (S3, Kinesis, STS, Databricks Endpoints)
    - Egress Firewall
    - S3 Root Bucket
    - Cross Account - IAM Role

- Workspace Deployment
    - Credential Configuration
    - Storage Configuration
    - Network Configuration (Backend PrivateLink Enabled)
    - External User Parameters (i.e. Authoritative User Parameters)
    - Co-Branding Options (Login Page, Home Page, Welcome Message)


# Network Diagram

![Architecture Diagram](https://github.com/JDBraun/wl-terraform-quickstart/blob/main/img/White%20Label%20-%20Network%20Topology.png)

# Login Screen Example

![Login Screen](https://github.com/JDBraun/wl-terraform-quickstart/blob/main/img/White%20Label%20-%20Login%20Screen%20Example.png)

# Home Screen Example

![Home Screen](https://github.com/JDBraun/wl-terraform-quickstart/blob/main/img/White%20Label%20-%Home%20Screen%20Example.png)

# Areas of Customization:

- Security - Add groups, users, entitlements, and assign IP access lists of your customers:
    - [Group Management](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group)
    - [User Management](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user)
    - [Entitlements](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/entitlements)
    - [IP Access List](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/ip_access_list)

- Cluster Management - Precreate clusters, restrict the clusters that can be created in the workspace, and assign the proper instance profile: 
    - [Cluster Creation](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster)
    - [Cluster Policy Creation + Assignment](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster_policy)
    - [Instance Profile](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/instance_profile)

- Unity Catalog - Assign a metastore and catalog to a workspace, then grant only a subset of data for the customer:
    - [Metastore Creation](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore)
    - [Metastore Assignment](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment)
    - [Catalog Creation + Assignment](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/catalog)
    - [Data Grants](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants)

- Repos - Preload notebooks that process data: 
    - [Repo Creation](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/repo)
