# Role Trusts
data "aws_iam_policy_document" "CrossAccountA_TrustsDoc" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

# IAM Policy Document
data "aws_iam_policy_document" "CrossAccountA_PolicyDoc" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "${aws_iam_role.CrossAccountB_Role.arn}",
    ]
  }
}

# IAM Policy
resource "aws_iam_policy" "CrossAccountA_Policy" {
  name   = "cross_account_access_policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CrossAccountA_PolicyDoc.json}"
}


# IAM Role
resource "aws_iam_role" "CrossAccountA_Role" {
  name               = "cross_account_access_role"
  assume_role_policy = "${data.aws_iam_policy_document.CrossAccountB_TrustsDoc.json}"
}

# Role Policy Attachement
resource "aws_iam_role_policy_attachment" "CrossAccountA_PolicyAttach" {
    role       = "${aws_iam_role.CrossAccountA_Role.name}"
    policy_arn = "${aws_iam_policy.CrossAccountA_Policy.arn}"
}

# Instance Role
resource "aws_iam_instance_profile" "CrossAccountA_InstanceRole" {
  name    = "cross_account_access_instance_role"
  role    = "${aws_iam_role.CrossAccountA_Role.name}"
}
