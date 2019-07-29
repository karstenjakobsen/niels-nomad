resource "nomad_job" "unifi_controller" {
  jobspec = "${data.template_file.unifi_controller.rendered}"
}

data "template_file" "unifi_controller" {

  template = "${ file("${path.module}/templates/jobs/docker/unifi_controller/job.hcl") }"

  vars = {
    region        = "global"
    datacenters   = "nyb1"
    image         = "linuxserver/unifi-controller:amd64-5.10.25-ls26"
  }

}