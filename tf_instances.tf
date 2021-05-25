##################################################################################
# INSTANCES
##################################################################################


resource "aws_instance" "nginx" {
  count                  = var.instance_count[terraform.workspace]
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = var.instance_size[terraform.workspace]
  subnet_id              = aws_subnet.Public[count.index % var.subnet_count[terraform.workspace]].id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  key_name               = var.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start"
    ]
  }

  tags = merge(local.common_tags, { Name = "${var.billing_code_tag}-${local.env_name}-nginx${count.index + 1}" })
}


resource "aws_instance" "db" {
  count                  = var.instance_count[terraform.workspace]
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = var.instance_size[terraform.workspace]
  subnet_id              = aws_subnet.Public[count.index % var.subnet_count[terraform.workspace]].id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  key_name               = var.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }


  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "ls -a"

    ]
  }

  tags = merge(local.common_tags, { Name = "${var.billing_code_tag}-${local.env_name}-db${count.index + 1}" })
}

