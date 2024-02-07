output "id" {
  description = "The created or target Security Group ID"
  value       = aws_security_group.default[0].id
}

output "arn" {
  description = "The created Security Group ARN (null if using existing security group)"
  value       = aws_security_group.default[0].arn
}

output "name" {
  description = "The created Security Group Name (null if using existing security group)"
  value       = aws_security_group.default[0].name
}
