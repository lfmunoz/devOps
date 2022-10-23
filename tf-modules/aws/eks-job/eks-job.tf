
resource "kubernetes_job" "job" {
  metadata {
    name = var.service.name
  }
  spec {
    template {
      metadata {}
      spec {
        image_pull_secrets {
          name = data.kubernetes_secret.eco_docker.metadata[0].name
        }
        container {
          name  = var.service.name
          image = var.service.image
          command = var.command

          dynamic "env" {
            for_each = var.env_variables
            content {
              name = env.value["name"]
              value = env.value["value"]
            }
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = true
}

