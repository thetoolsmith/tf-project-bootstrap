##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################
module "ebs_csi_controller_role" {
  for_each = module.eks

  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.11.1"
  create_role                   = true
  role_name                     = join("-", [each.value.cluster_name, "ebs-csi-controller"])
  provider_url                  = each.value.oidc_provider
  role_policy_arns              = [aws_iam_policy.ebs_csi_controller[each.key].arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.ebs_csi_service_account_namespace}:${local.ebs_csi_service_account_name}"]
}

resource "aws_iam_policy" "ebs_csi_controller" {
  for_each = module.eks

  name_prefix = join("-", [lower(each.value.cluster_name), "ebs-csi"])
  description = "EKS ebs-csi-controller policy for cluster"
  policy = file("${path.module}/ebs_csi_controller_iam_policy.json")
}
