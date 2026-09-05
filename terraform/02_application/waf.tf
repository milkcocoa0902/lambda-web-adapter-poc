resource "aws_wafv2_web_acl" "lwa_waf" {
  name        = "waf-${local.name_suffix}"
  description = "Global rate limit for the quotes CloudFront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitAllRequests"
    priority = 0

    action {
      block {}
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
