job "trading_desk" {

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

  group "x11_bridge" {

    count = 1

    restart {
      attempts = 4
      interval = "1m"
      delay = "10s"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }

    task "x11_bridge" {

      driver = "docker"

      env {
        MODE      = "tcp"
        XPRA_HTML = "yes"
        DISPLAY   = ":14"
      }

      config {
        shm_size = 256
        image = "dexpops/docker-x11-bridge:v0.0.1-build-4"
        port_map {
          ws = 10000
        }
        dns_servers = [
          "172.17.0.1"
        ]
        volumes = [
          "/tmp/.X11-unix:/tmp/.X11-unix"
        ]
      }

      resources {
        cpu    = 2500
        memory = 512
        network {
          mbits = 10
          port "ws" {}
        }
      }

      service {
        name = "x11-bridge"
        port = "ws"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=Host:blockdx.karstenjakobsen.dk",
          "traefik.frontend.entryPoints=https"
        ]
        check {
          name     = "alive"
          type     = "tcp"
          port     = "ws"
          interval = "10s"
          timeout  = "2s"
        }

      }

    } # TASK

  } # GROUP

  group "blocknetdx" {

    count = 1

    restart {
      attempts = 4
      interval = "1m"
      delay = "10s"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 800
    }

    task "blocknetdx" {

      driver = "docker"

      env {
        DISPLAY = ":14"
    		BLOCKNETDX_SNAPSHOT = "/utxo/BlocknetDX.zip"
        BLOCKNETDX_RPC_USER = "test"
        BLOCKNETDX_RPC_PASSWORD = "1234"
      }

      config {
        image = "dexpops/docker-x11-blockdx:v0.0.1-build-21"
        volumes = [
          "/tmp/.X11-unix:/tmp/.X11-unix",
      		"/utxo/BlocknetDX.zip:/utxo/BlocknetDX.zip"
        ]
        port_map {
          rpc = 41414
        }
        dns_servers = [
          "172.17.0.1"
        ]
      }

      resources {
        cpu    = 500
        memory = 1024
        network {
          mbits = 10
          port "rpc" {}
        }
      }

      service {
        name = "blocknetdx-qt"
        port = "rpc"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "rpc"
          interval = "10s"
          timeout  = "2s"
        }

      }

    } # TASK

  } # GROUP

}