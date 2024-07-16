locals {
  ebs_csi_service_account_namespace = "kube-system"
  ebs_csi_service_account_name = var.unique_name

  short_region = {
    us-east-1    = "use1"
    us-east-2    = "use2"
    us-west-1    = "usw1"
    us-west-2    = "usw2"
    us-central-1 = "usc1"
    us-central-2 = "usc2"
  }

  istio_charts_url = "https://istio-release.storage.googleapis.com/charts"

  cluster_addons_changes = {
    for k, v in var.cluster : k => {
      aws-ebs-csi-driver = {
        service_account_role_arn = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/${var.unique_name}-${k}-${local.short_region[data.aws_region.current.name]}-ebs-csi-controller"
      }
    }
  }

}

