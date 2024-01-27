output "ssl_cert" {
  value = aws_acm_certificate.cert.arn
}

output "ssl_region_cert" {
  value = aws_acm_certificate.region_cert.arn
}
