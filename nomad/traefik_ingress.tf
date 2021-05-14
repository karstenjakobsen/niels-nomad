# resource "nomad_job" "traefik_ingress" {
#   jobspec = "${data.template_file.traefik_ingress.rendered}"
# }

# data "template_file" "traefik_ingress" {

#   template = "${ file("${path.module}/templates/jobs/docker/traefik_ingress/job.hcl") }"

#   vars = {
#     traefik_conf  = "${ file("${path.module}/templates/jobs/docker/traefik_ingress/files/etc/traefik/traefik.toml") }"
#     region        = "global"
#     datacenters   = "nyb1"
#   }

# }