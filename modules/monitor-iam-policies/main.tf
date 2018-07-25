resource "aws_iam_role_policy" "auto_discover_cluster" {
  name   = "auto-discover-monitor-targets"
  role   = "${var.iam_role_id}"
  policy = "${data.aws_iam_policy_document.auto_discover_cluster.json}"
}

data "aws_iam_policy_document" "auto_discover_monitor_targets" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:Describe*",
      "elasticloadbalancing:Describe*",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:Describe*"
      "autoscaling:Describe*",
    ]

    resources = ["*"]
  }
}