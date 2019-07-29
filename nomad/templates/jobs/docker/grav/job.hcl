job "${job_name}" {

  region = "${region}"
  datacenters = "${datacenters}"
  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    auto_revert = false
    canary = 0
  }

  group "grav" {

    count = 1

    restart {
      attempts = 4
      interval = "1m"
      delay = "5s"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }

    task "grav" {

      driver = "docker"

      env {
        SKELETONFILE = "${skeleton_file}"
        ADMIN = "yes"
      }

      config {
        image = "${image}"
        port_map {
          http = 80
        }
        dns_servers = [
          "172.17.0.1"
        ]        
        volumes = [
          "/var/persistent-data/$${NOMAD_JOB_NAME}-$${NOMAD_TASK_NAME}-volume:/var/www/html"
        ]        
      }

      resources {
        cpu    = 250
        memory = 256
        network {
          mbits = 5
          port "http" {}
        }
      }

      service {
        name = "${service_name}"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=Host:${service_url}.",
          "traefik.frontend.entryPoints=https"
        ]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }

      }

    } #TASK   

  } # GROUP

}