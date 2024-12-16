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

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nodejs nginx npm",
      "sudo npm install pm2@latest -g",
      "pm2 start hello.js",
      "pm2 kill",
      "pm2 startup systemd",
      "sudo env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu",
      "pm2 save",
      "sudo systemctl start pm2-ubuntu",
      "sudo rm -f /etc/nginx/sites-available/default",
      "sudo mv /home/ubuntu/default /etc/nginx/sites-available/default",
      "sudo systemctl restart nginx"
    ]
  }

  provisioner "shell" {
    inline = ["echo This provisioner runs last"]
  }
}


