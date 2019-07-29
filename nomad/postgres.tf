// resource "nomad_job" "postgres" {
//   jobspec = "${data.template_file.postgres.rendered}"
// }
//
// data "template_file" "postgres" {
//
//   template = "${ file("${path.module}/templates/jobs/docker/postgres/job.hcl") }"
//
//   vars {
//     region        = "global"
//     datacenters   = "nyb1"
//   }
//
// }