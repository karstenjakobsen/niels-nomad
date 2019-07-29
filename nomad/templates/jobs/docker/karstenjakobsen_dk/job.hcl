job "karstenjakobsen_dk" {

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

  group "web" {

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

    task "webserver" {

      driver = "docker"

      artifact {
        source      = "git::https://github.com/karstenjakobsen/karstenjakobsen-dk"
        destination = "local/repo/karstenjakobsen-dk"
        #options {
        #  archive = false
        #}
      }

      config {
        image = "python:3.6.4-alpine3.7"
        command = "python3"
        args = [
          "-m",
          "http.server",
          "8000"
        ]
        port_map {
          http = 8000
        }
        dns_servers = [
          "172.17.0.1"
        ]
        work_dir = "/var/www/html/"
        volumes = [
          "local/repo/karstenjakobsen-dk/html:/var/www/html"
        ]
      }

      resources {
        cpu    = 100
        memory = 128
        network {
          mbits = 5
          port "http" {}
        }
      }

      service {
        name = "karstenjakobsen-dk"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=Host:www.karstenjakobsen.dk",
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