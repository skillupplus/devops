data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = "${var.name}-production-acm"
  }
}

resource "aws_route53_record" "validate_record" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.this.zone_id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.validate_record.fqdn]
}
