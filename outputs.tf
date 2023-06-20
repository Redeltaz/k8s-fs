output "master_node_eip" {
  value = aws_eip.master_eip.public_ip
}
