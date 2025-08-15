data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_ebs_volume" "mongodb_volume" {
  for_each          = toset(slice(data.aws_availability_zones.available.names, 0, 3))
  availability_zone = each.value
  size              = "30"
  type              = "gp3"
}

resource "aws_ebs_volume" "mongodb_log_volume" {
  for_each          = toset(slice(data.aws_availability_zones.available.names, 0, 3))
  availability_zone = each.value
  size              = "5"
  type              = "gp3"
}
