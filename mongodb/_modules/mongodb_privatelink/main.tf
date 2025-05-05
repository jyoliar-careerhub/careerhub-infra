data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "mongodbatlas_privatelink_endpoint" "this" {
  project_id    = var.project_id
  provider_name = "AWS"
  region        = replace(upper(var.region), "-", "_")
}

resource "aws_security_group" "this" {
  vpc_id = var.vpc_id
  name   = "${var.name}-sg"
}

resource "aws_security_group_rule" "this" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
}

resource "aws_vpc_endpoint" "this" {

  vpc_id             = var.vpc_id
  service_name       = mongodbatlas_privatelink_endpoint.this.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.subnet_ids
  security_group_ids = [aws_security_group.this.id]

  auto_accept = true
}

resource "mongodbatlas_privatelink_endpoint_service" "this" {
  project_id          = mongodbatlas_privatelink_endpoint.this.project_id
  private_link_id     = mongodbatlas_privatelink_endpoint.this.private_link_id
  endpoint_service_id = aws_vpc_endpoint.this.id
  provider_name       = "AWS"
}


