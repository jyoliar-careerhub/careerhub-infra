resource "mongodbatlas_advanced_cluster" "example-flex" {
  project_id   = var.project_id
  name         = var.name
  cluster_type = "REPLICASET"

  replication_specs {
    region_configs {
      provider_name         = "FLEX"
      backing_provider_name = "AWS"
      region_name           = join("_", split("-", upper(var.region)))
      priority              = 7
    }
  }

  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}


