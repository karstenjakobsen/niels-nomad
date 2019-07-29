# -------------------------------------------
# JOBS
# -------------------------------------------
resource "nomad_job" "kogsbolle_wordpress_core" {
  jobspec = "${data.template_file.wordpress_core.rendered}"
}


# resource "nomad_job" "kogsbolle_wordpress_core_2" {
#   jobspec = "${data.template_file.wordpress_core_2.rendered}"
# }

data "template_file" "wordpress_core" {

  template = "${ file("${path.module}/templates/jobs/docker/wordpress/job.hcl") }"

  vars = {
    region                  = "global"
    datacenters             = "nyb1"
    job_name                = "kogsbolle_wordpress_core"
    service_name_wordpress  = "kogsbolle-wordpress-1"
    service_name_mysql      = "kogsbolle-mysql-1"
    service_url_wordpress   = "kogsbolle-1.karstenjakobsen.dk"
    image_wordpress         = "wordpress:latest"
    image_mysql             = "mysql:5.7"
  }

}

# data "template_file" "wordpress_core_2" {

#   template = "${ file("${path.module}/templates/jobs/docker/wordpress/job.hcl") }"

#   vars = {
#     region                  = "global"
#     datacenters             = "nyb1"
#     job_name                = "kogsbolle_wordpress_core_2"
#     service_name_wordpress  = "kogsbolle-wordpress-2"
#     service_name_mysql      = "kogsbolle-mysql-2"
#     service_url_wordpress   = "kogsbolle-2.karstenjakobsen.dk"
#     image_wordpress         = "wordpress:5.2.2-php7.3-apache"
#     image_mysql             = "mysql:5.7"
#   }

# }
