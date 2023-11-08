data "aws_iam_policy_document" "assume_role_with_external_id" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.service_arn, var.provider_arn]
    }
    actions = [
      "sts:AssumeRole",
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.prefix}-provider-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_with_external_id.json
}

data "aws_iam_policy_document" "allow_access_to_s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetLifecycleConfiguration",
      "s3:PutLifecycleConfiguration"
    ]
    resources = ["arn:aws:s3:::${var.prefix}-bucket", "arn:aws:s3:::${var.prefix}-bucket/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [aws_iam_role.this.arn]
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.prefix}-provider-policy"
  policy = data.aws_iam_policy_document.allow_access_to_s3.json
}

resource "aws_iam_policy_attachment" "this" {
  name       = "${var.prefix}-provider-policy-attachment"
  roles      = ["${aws_iam_role.this.name}"]
  policy_arn = "${aws_iam_policy.this.arn}"
}
