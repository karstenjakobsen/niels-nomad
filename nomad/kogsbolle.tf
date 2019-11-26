# -------------------------------------------
# JOBS
# -------------------------------------------
# resource "nomad_job" "kogsbolle_wordpress_core" {
#   jobspec = "${data.template_file.wordpress_core.rendered}"
# }

# resource "nomad_job" "landsbyskole" {
#   jobspec = "${data.template_file.landsbyskole.rendered}"
# }

# data "template_file" "wordpress_core" {

#   template = "${ file("${path.module}/templates/jobs/docker/wordpress/job.hcl") }"

#   vars = {
#     region                  = "global"
#     datacenters             = "nyb1"
#     job_name                = "kogsbolle_wordpress_core"
#     service_name_wordpress  = "kogsbolle-wordpress-1"
#     service_name_mysql      = "kogsbolle-mysql-1"
#     service_url_wordpress   = "kogsbolle-1.karstenjakobsen.dk"
#     image_wordpress         = "wordpress:latest"
#     image_mysql             = "mysql:5.7"
#     volume_name             = "kogsbolle_wordpress_core-wordpress-volume"
#     mysql_database          = "wordpressdb"
#     mysql_user              = "wpuser"
#     mysql_password          = "dehj7u65ffssss"
#     mysql_root_password     = "nokia920c"
#   }

# }

# data "template_file" "landsbyskole" {

#   template = "${ file("${path.module}/templates/jobs/docker/wordpress/job.hcl") }"

#   vars = {
#     region                  = "global"
#     datacenters             = "nyb1"
#     job_name                = "landsbyskole_wordpress_core"
#     service_name_wordpress  = "landsbyskole-wordpress"
#     service_name_mysql      = "landsbyskole-mysql"
#     service_url_wordpress   = "landsbyskole.karstenjakobsen.dk"
#     image_wordpress         = "wordpress:5.2.2-php7.3-apache"
#     image_mysql             = "mysql:5.7"
#     volume_name             = "landsbyskole_wordpress_volume"
#     mysql_database          = "wordpressdb"
#     mysql_user              = "wpuser"
#     mysql_password          = "IU6765EsPo"
#     mysql_root_password     = "nokia920c"
#   }

# }

