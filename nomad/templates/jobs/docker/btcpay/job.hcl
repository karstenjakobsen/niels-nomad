job "btcpay" {

  region = "${region}"
  datacenters = "${datacenters}"
  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "20m"
    progress_deadline = "30m"
    auto_revert = false
    canary = 0
  }

  group "btcpay" {

    count = 1

    restart {
      attempts = 4
      interval = "1m"
      delay = "5s"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 50000
    }

    task "btcpayserver" {

      driver = "docker"

      env {
        BTCPAY_POSTGRES= "User ID=postgres;Host=postgres.service.consul.;Port=5432;Database=btcpayservermainnet"
        BTCPAY_NETWORK= "mainnet"
        BTCPAY_BIND= "0.0.0.0:$${NOMAD_PORT_http}"
        BTCPAY_ROOTPATH= "/"
        BTCPAY_SSHCONNECTION= "root@host.docker.internal"
        BTCPAY_DEBUGLOG= "btcpay.log"
        BTCPAY_CHAINS= "btc"
        BTCPAY_BTCEXPLORERURL= "http://nbxplorer.service.consul:$${NOMAD_PORT_nbxplorer_http}/"
      }

      config {
        image = "btcpayserver/btcpayserver:1.0.3.79"
        port_map {
          http = 49392
        }
        dns_servers = [
          "172.17.0.1"
        ]
        volumes = [
          "btcpay_datadir:/datadir",
          "/var/lib/nomad/alloc/$${NOMAD_ALLOC_ID}/nbxplorer/nbxplorer_datadir:/root/.nbxplorer"
        ]

      }

      resources {
        cpu    = 400
        memory = 512
        network {
          mbits = 5
          port "http" {
            static = 49392
          }
        }
      }

      service {
        name = "btcpay"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=Host:btcpay.karstenjakobsen.dk",
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

    task "bitcoind" {

      driver = "docker"

      env {
        BITCOIN_NETWORK   = "${btc_network}"
        BITCOIN_SNAPSHOT  ="/bitcoin_utxo_565305.tar"
        BITCOIN_EXTRA_ARGS = <<EOF
rpcport=$${NOMAD_PORT_rpc}
rpcallowip=0.0.0.0/0
port=$${NOMAD_PORT_btc}
disablewallet=0
whitelist=0.0.0.0/0
EOF
      }

      config {
        image = "dexpops/docker-bitcoind:v0.17.1-build-19"
        port_map {
          btc = 8333
          rpc = 8332
        }
        dns_servers = [
          "172.17.0.1"
        ]
        volumes = [
          "bitcoin_datadir:/data",
          "/utxo/bitcoin_utxo.tar:/bitcoin_utxo_565305.tar:ro"
        ]

      }

      resources {
        cpu    = 1750
        memory = 2048
        network {
          mbits = 20
          port "btc" {
            static = 8333
          }
          port "rpc" {
            static = 8332
          }
        }
      }

      service {
        name = "bitcoind"
        port = "rpc"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "rpc"
          interval = "10s"
          timeout  = "2s"
        }

      }

    } #TASK

    task "nbxplorer" {

      driver = "docker"

      env {
        NBXPLORER_NETWORK = "${btc_network}"
        NBXPLORER_BIND = "0.0.0.0:$${NOMAD_PORT_http}"
        NBXPLORER_CHAINS = "btc"
        NBXPLORER_BTCRPCURL = "http://$${NOMAD_ADDR_bitcoind_rpc}/"
        NBXPLORER_BTCNODEENDPOINT = "$${NOMAD_ADDR_bitcoind_btc}"
      }

      config {
        image = "nicolasdorier/nbxplorer:2.0.0.15"
        port_map {
          http = 32838
        }
        dns_servers = [
          "172.17.0.1"
        ]
        volumes = [
          "nbxplorer_datadir:/datadir",
          "/var/lib/nomad/alloc/$${NOMAD_ALLOC_ID}/bitcoind/bitcoin_datadir:/root/.bitcoin"
        ]

      }

      resources {
        cpu    = 250
        memory = 256
        network {
          mbits = 5
          port "http" {
            static = 32838
          }
        }
      }

      service {
        name = "nbxplorer"
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