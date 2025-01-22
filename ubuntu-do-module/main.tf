data "digitalocean_images" "available" {
  filter {
    key    = "distribution"
    values = ["Ubuntu"]
  }
  filter {
    key    = "regions"
    values = ["fra1"]
  }
  filter {
    key      = "name"
    values   = ["LTS"]
    match_by = "substring"
  }
  filter {
    key    = "type"
    values = ["base"]
  }
  sort {
    key       = "created"
    direction = "desc"
  }
}

resource "digitalocean_droplet" "ubuntu" {
  image  = data.digitalocean_images.available.images[0].slug
  name   = "web-1"
  region = var.region
  size   = var.size
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # configure non root user
      "useradd -m -s /bin/bash ubuntu",
      "usermod -aG sudo ubuntu",
      "rsync --archive --chown=ubuntu:ubuntu ~/.ssh /home/ubuntu",
      "echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo",
    ]
  }
}
data "http" "my_ip" {
  url = "http://checkip.amazonaws.com"
}

resource "digitalocean_firewall" "all-only-my-ip" {
  name = "all-only-my-ip"

  droplet_ids = [digitalocean_droplet.ubuntu.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "1-65535"
    source_addresses = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "1-65535"
    source_addresses = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
