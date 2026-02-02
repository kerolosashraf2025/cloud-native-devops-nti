region      = "eu-west-1"
environment = "nonprod"
name_prefix = "nti-nonprod"

vpc_cidr = "10.0.0.0/16"

azs = ["eu-west-1a", "eu-west-1b"]

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

cluster_name    = "nti-nonprod-eks"
cluster_version = "1.29"

node_desired = 2
node_min     = 1
node_max     = 3

instance_types = ["t3.medium"]
capacity_type  = "ON_DEMAND"

tags = {
  Project = "cloud-native-devops-nti"
}
