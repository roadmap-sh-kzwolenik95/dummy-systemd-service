output "public_ip" {
  value = resource.digitalocean_droplet.ubuntu.ipv4_address
}