resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

locals {
  external_secrets_namespace      = "external-secrets"
  external_secrets_serviceaccount = "external-secrets-sa"
}

resource "aws_iam_policy" "external_secrets_ssm_policy" {
  count       = var.attach_ssm ? 1 : 0
  name        = "${var.name_prefix}-external-secrets-ssm-policy"
  description = "Allow External Secrets Operator to read secrets from SSM Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/nonprod/sample-app/*"
      }
    ]
  })
}

data "aws_iam_policy_document" "external_secrets_assume_role" {
  count = var.attach_ssm ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.external_secrets_namespace}:${local.external_secrets_serviceaccount}"]
    }
  }
}

resource "aws_iam_role" "external_secrets_irsa_role" {
  count              = var.attach_ssm ? 1 : 0
  name               = "${var.name_prefix}-external-secrets-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "external_secrets_ssm_attach" {
  count      = var.attach_ssm ? 1 : 0
  role       = aws_iam_role.external_secrets_irsa_role[0].name
  policy_arn = aws_iam_policy.external_secrets_ssm_policy[0].arn
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name_prefix}-node-group"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_desired
    min_size     = var.node_min
    max_size     = var.node_max
  }

  instance_types = var.instance_types
  capacity_type  = var.capacity_type
}

# ============================================================
# Fetch EKS Node Group EC2 instances (needed for NLB attachments)
# ============================================================

data "aws_autoscaling_group" "eks_nodes_asg" {
  name = aws_eks_node_group.this.resources[0].autoscaling_groups[0].name
}

data "aws_instances" "eks_node_instances" {
  instance_tags = {
    "aws:autoscaling:groupName" = data.aws_autoscaling_group.eks_nodes_asg.name
  }
}
