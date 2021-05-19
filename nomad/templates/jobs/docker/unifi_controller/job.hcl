job "unifi_controller" {

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
    value     = "infrastructure"
  }

  group "unifi" {

    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 3000
    }

    task "controller" {

      driver = "docker"

      config {        
        image = "${image}"
        port_map {
          speed_test = 6789
          inform = 8080
          https = 8443
          portal_redirect = 8843
          stun = 3478
          discovery = 10001
          portal = 8880

        }
        dns_servers = [
          "172.17.0.1"
        ]
        volumes = [
          "/var/persistent-data/$${NOMAD_JOB_NAME}-$${NOMAD_TASK_NAME}-volume-1:/config"
        ]
      }

      resources {
        cpu    = 500
        memory = 512
        network {
          mbits = 5
          port "speed_test" {
            static = 6789
          }
          port "inform" {
            static = 8080
          }
          port "https" {
            static = 8443
          }
          port "portal_redirect" {
            static = 8843
          }
          port "stun" {
            static = 3478
          }
          port "discovery" {
            static = 10001
          }
          port "portal" {
            static = 8880
          }
        }
      }

      service {
        name = "unifi"
        port = "https"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "https"
          interval = "10s"
          timeout  = "2s"
        }

      }

    } #TASK

  } # GROUP

}