resource "aws_iam_role" "lambda" {
    name = "lambda-${var.project_name}"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Action = "sts:AssumeRole",
            Principal = { Service = "lambda.amazonaws.com"},
            Effect = "Allow"
        }]
    })
}

resource "aws_iam_role_policy" "lambda" {
    role = aws_iam_role.lambda.name
    name = "policy-${var.project_name}"
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Resource = ["*"],
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        }, {
            Effect: "Allow",
            Action: [
                "ec2:DescribeNetworkInterfaces",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:AttachNetworkInterface"
            ],
            Resource: ["*"]
        }]
    })
}
