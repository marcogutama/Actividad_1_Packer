packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-linux-nginx"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # Copiar hello.js
  provisioner "file" {
    source      = "hello.js"
    destination = "/home/ubuntu/hello.js"
  }

  # Copiar default.txt
  provisioner "file" {
    source      = "default.txt"
    destination = "/home/ubuntu/default"
  }

  # Copiar el script setup-nginx.sh
  provisioner "file" {
    source      = "setup-nginx.sh"
    destination = "/home/ubuntu/setup-nginx.sh"
  }  

  # Ejecutar el script setup-nginx.sh
  provisioner "shell" {
    inline = [
      "chmod +x /home/ubuntu/setup-nginx.sh",
      "sudo /home/ubuntu/setup-nginx.sh"
    ]
  }

}


