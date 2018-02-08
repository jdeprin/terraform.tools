# Trusts
data "aws_iam_policy_document" "AccountB_TrustsDoc" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      AWS = "AccountA_RoleARN"
    }
  }
}

# IAM Role
resource "aws_iam_role" "AccountB_Role" {
  name               = "service_cross_account_access"
  assume_role_policy = "${data.aws_iam_policy_document.AccountB_TrustsDoc.json}"
}

# Attach Policy
resource "aws_iam_role_policy_attachment" "AccountB_Access" {
  role      = "${aws_iam_role.AccountB_Role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}
