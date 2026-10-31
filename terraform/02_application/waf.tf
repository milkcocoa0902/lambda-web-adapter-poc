resource "aws_wafv2_web_acl" "lwa_waf" {
  name        = "waf-${local.name_suffix}"
  description = "Global rate limit for the quotes CloudFront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  custom_response_body {
    key          = "rate_limit"
    content_type = "APPLICATION_JSON"
    content      = jsonencode({ detail = "rate limit exceeded" })
  }

  rule {
    name     = "RateLimitAllRequests"
    priority = 0

    action {
      block {
        custom_response {
          response_code            = 429
          custom_response_body_key = "rate_limit"
          response_header {
            name  = "Retry-After"
            value = "300"
          }
        }
      }
    }

    statement {
      rate_based_statement {
        limit                 = 50
        evaluation_window_sec = 300
        aggregate_key_type    = "CONSTANT"

        scope_down_statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }

            positional_constraint = "STARTS_WITH"
            search_string         = "/"

            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-rate-limit-${local.name_suffix}"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-${local.name_suffix}"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "waf-${local.name_suffix}"
  }
}
