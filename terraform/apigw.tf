# ==========================================
# API Gateway HTTP API + VPC Link + NLB
# ==========================================

resource "aws_security_group" "apigw_vpc_link_sg" {
  name        = "${var.name_prefix}-apigw-vpc-link-sg"
  description = "Security group for API Gateway VPC Link"
  vpc_id      = module.networking.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-apigw-vpc-link-sg"
  })
}

resource "aws_lb" "apigw_nlb" {
  name               = "${var.name_prefix}-apigw-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = module.networking.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-apigw-nlb"
  })
}

resource "aws_lb_target_group" "ingress_nodeport_tg" {
  name        = "${var.name_prefix}-ingress-tg"
  port        = 30080
  protocol    = "TCP"
  vpc_id      = module.networking.vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = "30080"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ingress-tg"
  })
}

resource "aws_lb_target_group_attachment" "eks_nodes" {
  count            = length(module.eks.node_group_instance_ids)
  target_group_arn = aws_lb_target_group.ingress_nodeport_tg.arn
  target_id        = module.eks.node_group_instance_ids[count.index]
  port             = 30080
}

resource "aws_lb_listener" "tcp_listener" {
  load_balancer_arn = aws_lb.apigw_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress_nodeport_tg.arn
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.name_prefix}-http-api"
  protocol_type = "HTTP"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-http-api"
  })
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${var.name_prefix}-vpc-link"
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [aws_security_group.apigw_vpc_link_sg.id]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-link"
  })
}

resource "aws_apigatewayv2_integration" "nlb_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "HTTP_PROXY"

  connection_type = "VPC_LINK"
  connection_id   = aws_apigatewayv2_vpc_link.this.id

  integration_method = "ANY"
  integration_uri    = aws_lb_target_group.ingress_nodeport_tg.arn
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.nlb_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}
