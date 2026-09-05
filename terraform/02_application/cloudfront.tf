resource "aws_cloudfront_distribution" "lwa_cloudfront" {
  origin {
    domain_name = trimsuffix(
      trimprefix(aws_lambda_function_url.lwa_lambda_fn_url.function_url, "https://"),
      "/"
    )
    origin_access_control_id = aws_cloudfront_origin_access_control.lwa_cloudfront_oac.id
    origin_id                = aws_lambda_function_url.lwa_lambda_fn_url.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

  }
  enabled    = true
  web_acl_id = aws_wafv2_web_acl.lwa_waf.arn

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  default_cache_behavior {
    target_origin_id       = aws_lambda_function_url.lwa_lambda_fn_url.id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_disabled.id

    origin_request_policy_id = (
      data.aws_cloudfront_origin_request_policy.lambda_function_url.id
    )

    compress = false
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "cf-${local.name_suffix}"
  }
}

resource "aws_cloudfront_origin_access_control" "lwa_cloudfront_oac" {
  name                              = "cf-oac-${local.name_suffix}"
  origin_access_control_origin_type = "lambda"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "lambda_function_url" {
  name = "Managed-AllViewerExceptHostHeader"
}
