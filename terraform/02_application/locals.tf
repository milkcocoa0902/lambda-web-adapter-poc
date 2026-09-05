locals {
  name_suffix = lower(join("-", [
    var.service_name,
    data.aws_region.current.region,
    var.environment,
    var.application_name,
  ]))
}
