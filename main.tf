module "ubuntu_instance" {
  source = "./ubuntu-do-module"

  do_token     = var.do_token
  ssh-key-name = var.ssh-key-name
  pvt_key      = "${var.home-path}/.ssh/id_rsa"
}

output "public_ip" {
  value = module.ubuntu_instance.public_ip
}

output "ssh_string" {
  value = "ssh -o StrictHostKeyChecking=accept-new ubuntu@${module.ubuntu_instance.public_ip}"
}

resource "null_resource" "file_provisioner" {
  provisioner "file" {
    source      = "scripts/"
    destination = "/home/ubuntu/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = module.ubuntu_instance.public_ip
      private_key = file("~/.ssh/id_rsa")
    }
  }
  depends_on = [module.ubuntu_instance]
}
