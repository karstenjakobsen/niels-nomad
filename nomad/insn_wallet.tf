# resource "nomad_job" "insn_wallet" {
#   jobspec = "${data.template_file.insn_wallet.rendered}"
# }

# data "template_file" "insn_wallet" {

#   template = "${ file("${path.module}/templates/jobs/docker/insn_wallet/job.hcl") }"

#   vars = {
#     region        = "global"
#     datacenters   = "nyb1"
#   }

# }