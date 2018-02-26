# Trusts
# See https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html for possible conditions to increase security
data "aws_iam_policy_document" "CrossAccountB_TrustsDoc" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      identifiers = ["${aws_iam_role.CrossAccountA_Role.arn}"]
      type = "AWS"
    }
  }
}

# IAM Role
resource "aws_iam_role" "CrossAccountB_Role" {
  name               = "service_cross_account_access"
  assume_role_policy = "${data.aws_iam_policy_document.CrossAccountB_TrustsDoc.json}"
}

# Attach Policy
resource "aws_iam_role_policy_attachment" "AccountB_Access" {
  role        = "${aws_iam_role.CrossAccountB_Role.name}"
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}
