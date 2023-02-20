resource "aws_lambda_function" "app" {
    s3_bucket           = var.bucket_artifacts
    s3_key              = "example-net6/app.zip"
    function_name       = "${var.project_name}"
    handler             = "serverless-netcore"
    source_code_hash    = filebase64sha256("${path.module}/../app.zip")
    runtime             = "dotnet6"
    role                = aws_iam_role.lambda.arn
    publish             = true
    memory_size         = "2048"
}
