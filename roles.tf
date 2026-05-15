# Trust policy — lets EC2 assume this role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_s3_reader" {
  name               = "EC2-S3-ReadOnly"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
  description        = "Lets EC2 read from S3 without static credentials"
}

resource "aws_iam_role_policy_attachment" "ec2_s3" {
  role       = aws_iam_role.ec2_s3_reader.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Instance profile — wraps the role so EC2 can use it
resource "aws_iam_instance_profile" "ec2_s3_reader" {
  name = "EC2-S3-ReadOnly-Profile"
  role = aws_iam_role.ec2_s3_reader.name
}