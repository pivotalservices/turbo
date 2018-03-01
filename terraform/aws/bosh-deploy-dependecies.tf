resource "null_resource" "bosh_deploy_dependencies" {
  depends_on = [
    "aws_elb.credhub-elb",
    "aws_elb.uaa-elb",
    "aws_elb.concourse-elb",
  ]
}
