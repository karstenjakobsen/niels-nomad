job "traefik_ingress" {

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

  constraint {
    attribute = "$${meta.env}"
    value     = "platform"
  }

  group "ingress" {

    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }

    task "traefik" {

      driver = "docker"

      template {
      data = <<EOF
${traefik_conf}
EOF
        destination = "local/traefik_ingress/files/etc/traefik/traefik.toml"

      }

      config {
        image = "traefik:v1.7.12-alpine"
        network_mode = "host"
        port_map {
          http = 80
          https = 443
          api = 8081
          insn = 10255
        }
        volumes = [
          "local/traefik_ingress/files/etc/traefik/:/etc/traefik"
        ]
      }

      resources {
        cpu    = 250
        memory = 128
        network {
          mbits = 20
          port "http" {
            static = 80
          }
          port "https" {
            static = 443
          }
          port "api" {
            static = 8081
          }
          port "insn" {
            static = 10255
          }
        }
      }

      service {
        name = "traefik"
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }

      }

    } # TASK

  } # GROUP

}