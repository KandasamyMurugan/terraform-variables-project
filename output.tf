output "ec2_public_ip" {
  value       = aws_instance.vari_instance.public_ip
  description = "The public IP of the instance"
}