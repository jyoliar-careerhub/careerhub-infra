output "mongodb_volume_ids" {
  value = [for volume in aws_ebs_volume.mongodb_volume : {
    volume_id : volume.id
    availability_zone : volume.availability_zone
  }]
}

output "mongodb_log_volume_ids" {
  value = [for volume in aws_ebs_volume.mongodb_log_volume : {
    volume_id : volume.id
    availability_zone : volume.availability_zone
  }]
}
