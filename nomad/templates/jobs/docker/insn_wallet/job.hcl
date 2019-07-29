job "insn_wallet" {

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

  group "insn" {

    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"      
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 10000
    }

    task "wallet" {

      driver = "docker"

      env {
        RPC_PASSWORD = "tjisisadsshtitty8934passwOerd"
        SEED_NODE = "insn.cryptocoderz.com"
        TX_INDEX = "0"
        MASTERNODE_PRIV_KEY = "2shT5HWdRTg3KYrwHjv9eFsiTdMnMfoEyYL7z7sJBhtz3x2Yhwo"
        EXTERNAL_IP = "104.248.40.220"
      }

      config {
        image = "dexpops/insn-masternode:1.0.5.5"
        port_map {
          wallet = 10255
        }
        dns_servers = [
          "172.17.0.1"
        ]
        volumes = [
          "/var/persistent-data/$${NOMAD_JOB_NAME}-$${NOMAD_TASK_NAME}-volume:/root/.INSN"
        ]
      }

      resources {
        cpu    = 500
        memory = 512
        network {
          mbits = 5
          port "wallet" {} # 10255
        }
      }

      service {
        name = "insn-masternode"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=Host:104.248.40.220",
          "traefik.frontend.entryPoints=insn"
        ]
        port = "wallet"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "wallet"
          interval = "10s"
          timeout  = "2s"
        }

      }

    } #TASK

  } # GROUP

}