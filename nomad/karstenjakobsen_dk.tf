resource "nomad_job" "karstenjakobsen_dk" {
  jobspec = "${data.template_file.karstenjakobsen_dk.rendered}"
}

data "template_file" "karstenjakobsen_dk" {

  template = "${ file("${path.module}/templates/jobs/docker/karstenjakobsen_dk/job.hcl") }"

  vars = {
    region        = "global"
    datacenters   = "nyb1"
  }

}