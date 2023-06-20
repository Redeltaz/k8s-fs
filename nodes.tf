resource "aws_network_interface" "master_network_interface" {
  subnet_id       = aws_subnet.public_subnet.id
  private_ips     = ["10.0.0.69"]
  security_groups = [aws_security_group.main_sg.id]
}

resource "aws_network_interface" "worker_network_interface" {
  count           = var.worker_node_number
  subnet_id       = aws_subnet.private_subnet.id
  private_ips     = [cidrhost(var.private_subnet_cidr_block, count.index + 70)]
  security_groups = [aws_security_group.main_sg.id]
}

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.public_key_name
  public_key = tls_private_key.key_pair.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.key_pair.private_key_pem}' >> ./${var.public_key_name}.pem"
  }
}

resource "local_sensitive_file" "pem_file" {
  filename             = pathexpand("./${var.public_key_name}.pem")
  file_permission      = "600"
  directory_permission = "700"
  content              = tls_private_key.key_pair.private_key_pem
}

resource "aws_instance" "master_node" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.key_pair.key_name

  network_interface {
    network_interface_id = aws_network_interface.master_network_interface.id
    device_index         = 0
  }

  tags = {
    Name = "master-node"
  }
}

resource "aws_instance" "worker_node" {
  count         = var.worker_node_number
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.key_pair.key_name

  network_interface {
    network_interface_id = aws_network_interface.worker_network_interface[count.index].id
    device_index         = 0
  }

  tags = {
    Name = "worker-node-${count.index + 1}"
  }
}

resource "aws_eip" "master_eip" {
  instance = aws_instance.master_node.id
}
