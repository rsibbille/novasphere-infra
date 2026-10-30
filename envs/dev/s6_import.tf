removed {
  from = aws_security_group.imported_demo

  lifecycle {
    destroy = false
  }
}
