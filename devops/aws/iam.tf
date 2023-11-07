resource "aws_iam_role" "this" {
  name = "${var.prefix}-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
	"Effect": "Allow",
	"Principal": {
	  "AWS": [
	    "${var.service_arn}",
	    "${var.provider_arn}"
	  ]
	},
	"Action": "sts:AssumeRole",
	"Condition": {
	  "StringEquals": {
	    "sts:ExternalId": "${var.external_id}"
	  }
	}
      }
    ]
  })
}


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
