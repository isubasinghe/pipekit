data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20211129"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}


resource "aws_instance" "argo_instance" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = var.ec2_instance_type
  tags = {
    Name = var.ec2_instance_name 
  }
  key_name = var.sshkeyname
  vpc_security_group_ids = ["${aws_security_group.argo_dev.id}"]

  root_block_device {
    delete_on_termination = true 
    iops = 100 
    volume_size = var.ec2_storage_size 
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install.sh",
      "${path.module}/scripts/install_node.sh"
    ]
  }

  connection {
    host = self.public_ip 
    type = "ssh"
    user = "ubuntu"
    password = ""
    private_key = var.sshkey
  }
  
}

