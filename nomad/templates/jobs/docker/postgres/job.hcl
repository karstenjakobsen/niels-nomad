job "postgres" {

  region = "${region}"
  datacenters = "${datacenters}"
  type = "system"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "20m"
    progress_deadline = "30m"
    auto_revert = false
    canary = 0
  }

  group "postgres" {

    count = 1

    restart {
      attempts = 4
      interval = "1m"
      delay = "5s"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 5000
    }

    task "postgres" {

      driver = "docker"

      config {
        image = "postgres:9.6.5"
        port_map {
          db = 5432
        }
        dns_servers = [
          "172.17.0.1"
        ]
        volumes = [
          "postgres_datadir:/var/lib/postgresql/data",
          "/utxo:/opt/data"
        ]

      }

      resources {
        cpu    = 250
        memory = 256
        network {
          mbits = 5
          port "db" {
            static = 5432
          }
        }
      }

      service {
        name = "postgres"
        port = "db"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "db"
          interval = "10s"
          timeout  = "2s"
        }

      }

    } #TASK

  } # GROUP

}