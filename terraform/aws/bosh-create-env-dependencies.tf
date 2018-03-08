resource "null_resource" "bosh_iaas_specific_dependencies" {
  depends_on = [
    "aws_instance.jumpbox",
    "aws_nat_gateway.global_nat_gw",
  ]
}
