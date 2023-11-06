data "aws_iam_policy_document" "this" {
  statement {
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${var.prefix}-bucket", "arn:aws:s3:::${var.prefix}-bucket/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.prefix}-policy"
  policy = data.aws_iam_policy_document.this.json
}

