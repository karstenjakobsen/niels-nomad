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

  constraint {
    attribute = "$${meta.env}"
    value     = "platform"
  }

  group "wordpress" {

    count = 1

    restart {
      attempts = 4
      interval = "1m"
      delay = "5s"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 3000
    }

    task "backup" {

      driver = "docker"

      env = {      
        SCHEDULE = "00 03 * * *"
        DIRS = "/$${NOMAD_JOB_NAME}-$${NOMAD_TASK_NAME}:wordpress"
      }
      
      config {
        image = "karstenjakobsen/docker-cron-backup:latest"        
        volumes = [
          "/var/backup/$${NOMAD_JOB_NAME}-$${NOMAD_TASK_NAME}-volume:/backup",
          "/var/persistent-data/kogsbolle_wordpress_core-wordpress-volume:/$${NOMAD_JOB_NAME}-$${NOMAD_TASK_NAME}"
        ]
      }

      resources {
        cpu    = 250
        memory = 128
        network {
          mbits = 1
        }
      }

    } #TASK

    task "db" {

      driver = "docker"

      env = {      
        MYSQL_DATABASE = "wordpressdb"
        MYSQL_USER = "wpuser"
        MYSQL_PASSWORD = "dehj7u65ffssss"
        MYSQL_ROOT_PASSWORD = "nokia920c"
      }
      
      config {
        image = "${image_mysql}"
        port_map {
          mysql = 3306
        }
        dns_servers = [
          "172.17.0.1"
        ]         
        volumes = [
          "/var/persistent-data/$${NOMAD_JOB_NAME}-$${NOMAD_TASK_NAME}-volume:/var/lib/mysql"
        ]
      }

      resources {
        cpu    = 500
        memory = 256
        network {
          mbits = 5
          port "mysql" {}
        }
      }

      service {
        name = "${service_name_mysql}"        
        port = "mysql"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "mysql"
          interval = "10s"
          timeout  = "2s"
        }

      }

    } #TASK

    task "wordpress" {

      driver = "docker"

      env = {      
        WORDPRESS_DB_HOST = "${service_name_mysql}.service.consul:$${NOMAD_PORT_db_mysql}"
        WORDPRESS_DB_USER = "wpuser"
        WORDPRESS_DB_PASSWORD = "dehj7u65ffssss"
        WORDPRESS_DB_NAME = "wordpressdb"
      }
      
      config {
        image = "${image_wordpress}"
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
        cpu    = 500
        memory = 256
        network {
          mbits = 5
          port "http" {}
        }
      }

      service {
        name =  "${service_name_wordpress}"
        port = "http"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=Host:${service_url_wordpress}.",
          "traefik.frontend.entryPoints=https"
        ]
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