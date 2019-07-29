job "bitcoind" {

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

  group "bitcoind" {

    count = 1

    restart {
      attempts = 4
      interval = "1m"
      delay = "10s"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 20000
    }

    task "bitcoind" {

      // rpcuser=bitcoinrpc
      // rpcpassword=password1234
      // rpcallowip=::/0
      // server=1
      // wallet=1
      // listen=1
      // port=8333
      // rpcport=8332
      // addresstype=legacy
      // changetype=legacy
      // deprecatedrpc=signrawtransaction

      driver = "docker"

      env {
        DISPLAY = ":14"
        BITCOIN_NETWORK   = "${btc_network}"
        BITCOIN_SNAPSHOT  ="/bitcoin_utxo_565305.tar"
        BITCOIN_EXTRA_ARGS = <<EOF
wallet=1
listen=1
port=8333
rpcport=8332
EOF
      }

      config {
        image = "dexpops/docker-bitcoind:v0.17.1-build-23"
        port_map {
          btc = 8333
          rpc = 8332
        }
        dns_servers = [
          "172.17.0.1"
        ]
        volumes = [
          "/tmp/.X11-unix:/tmp/.X11-unix",
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

  } # GROUP

}