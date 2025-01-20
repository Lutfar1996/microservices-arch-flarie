# Create the API Gateway REST API
resource "aws_api_gateway_rest_api" "flarie_api" {
  name        = "flarie-api"
  description = "API Gateway for ALB integration"
}

# Create a Resource for POST method (Path for POST request)
resource "aws_api_gateway_resource" "flarie_post_resource" {
  rest_api_id = aws_api_gateway_rest_api.flarie_api.id
  parent_id   = aws_api_gateway_rest_api.flarie_api.root_resource_id
  path_part   = "postpath"  # Define path for POST request (e.g., /postpath)
}

# Create POST method for the resource
resource "aws_api_gateway_method" "flarie_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.flarie_api.id
  resource_id   = aws_api_gateway_resource.flarie_post_resource.id
  http_method   = "POST"
  authorization = "NONE"  # No authorization for testing
}

# Integrate the POST method with the ALB DNS
resource "aws_api_gateway_integration" "flarie_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.flarie_api.id
  resource_id             = aws_api_gateway_resource.flarie_post_resource.id
  http_method             = aws_api_gateway_method.flarie_post_method.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://flarie-alb-118310800.us-east-1.elb.amazonaws.com"  # ALB DNS
}

# Deploy the API Gateway (This creates a deployment for the API)
resource "aws_api_gateway_deployment" "flarie_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.flarie_api.id
  stage_name  = "prod"  # Define your stage (e.g., prod)

  # Add a depends_on to ensure the method is created before the deployment
  depends_on = [aws_api_gateway_method.flarie_post_method]
}

# Create API Gateway Stage (This maps the deployment to a specific stage)
resource "aws_api_gateway_stage" "flarie_api_stage" {
  deployment_id = aws_api_gateway_deployment.flarie_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.flarie_api.id
  stage_name    = "prod"
}
