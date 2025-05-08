# Create the peering connection request
# Create the peering connection request
resource "mongodbatlas_network_container" "this" {
  atlas_cidr_block = var.atlas_cidr_block
  project_id       = var.project_id
  provider_name    = "AWS"
  region_name      = var.region
}


resource "mongodbatlas_network_peering" "mongo_peer" {
  accepter_region_name   = var.region
  project_id             = var.project_id
  container_id           = mongodbatlas_network_container.this.id
  provider_name          = "AWS"
  route_table_cidr_block = var.vpc_cidr_block
  vpc_id                 = var.vpc_id
  aws_account_id         = var.aws_account_id
}

# Accept the connection 
resource "aws_vpc_peering_connection_accepter" "aws_peer" {
  vpc_peering_connection_id = mongodbatlas_network_peering.mongo_peer.connection_id
  auto_accept               = true
}

resource "mongodbatlas_project_ip_access_list" "atlas-ip-access-list-1" {
  project_id = var.project_id
  cidr_block = var.vpc_cidr_block
  comment    = "CIDR block for Staging AWS Subnet Access for Atlas"
}
