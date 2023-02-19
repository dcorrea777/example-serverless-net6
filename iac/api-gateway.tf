resource "aws_api_gateway_rest_api" "app" {
    name        = var.project_name
    description = "example"
}

resource "aws_api_gateway_stage" "app" {
    stage_name              = "v1"
    rest_api_id             = aws_api_gateway_rest_api.app.id
    deployment_id           = aws_api_gateway_deployment.app.id
}

resource "aws_api_gateway_deployment" "app" {
    rest_api_id = aws_api_gateway_rest_api.app.id
    triggers = {
        # NOTE: The configuration below will satisfy ordering considerations,
        #       but not pick up all future REST API changes. More advanced patterns
        #       are possible, such as using the filesha1() function against the
        #       Terraform configuration file(s) or removing the .id references to
        #       calculate a hash against whole resources. Be aware that using whole
        #       resources will show a difference after the initial implementation.
        #       It will stabilize to only change when resources change afterwards.
        redeployment = sha1(jsonencode([
            aws_api_gateway_resource.app.id,
            aws_api_gateway_method.app.id,
            aws_api_gateway_integration.app.id
        ]))
    }
    lifecycle {
        create_before_destroy = true
    }

    variables = {
        deployed_at = timestamp()
    }
}

resource "aws_lambda_permission" "api_gateway" {
    statement_id    = "AllowExecutionFromAPIGateway"
    action          = "lambda:InvokeFunction"
    function_name   = aws_lambda_function.app.function_name
    principal       = "apigateway.amazonaws.com"
    source_arn      = "${aws_api_gateway_rest_api.app.execution_arn}/*/*"
}

resource "aws_api_gateway_method_settings" "all" {
    rest_api_id = aws_api_gateway_rest_api.app.id
    stage_name  = aws_api_gateway_stage.app.stage_name
    method_path = "*/*"
    settings {
        metrics_enabled = true
        logging_level   = "ERROR"
    }
}

# Configurações do endpoint PROXY
resource "aws_api_gateway_resource" "app" {
    rest_api_id = aws_api_gateway_rest_api.app.id
    parent_id   = aws_api_gateway_rest_api.app.root_resource_id
    path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "app" {
    http_method     = "ANY"
    authorization   = "None"
    resource_id     = aws_api_gateway_resource.app.id
    rest_api_id     = aws_api_gateway_rest_api.app.id
    request_parameters = {
        "method.request.path.proxy" = true
    }
}

resource "aws_api_gateway_integration" "app" {
    http_method             = aws_api_gateway_method.app.http_method
    resource_id             = aws_api_gateway_resource.app.id
    rest_api_id             = aws_api_gateway_rest_api.app.id
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${var.aws_account_id}:function:${var.project_name}/invocations"
}
