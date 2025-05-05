resource "mongodbatlas_advanced_cluster" "this" {
  project_id   = var.project_id
  name         = var.name
  cluster_type = "REPLICASET"

  replication_specs {
    region_configs {
      electable_specs {
        instance_size = "M10"
        node_count    = 3
      }
      provider_name = "AWS"
      region_name   = join("_", split("-", upper(var.region)))
      priority      = 7
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


