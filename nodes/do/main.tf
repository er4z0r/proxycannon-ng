provider "digitalocean" {
  token = var.do_token
}


data "digitalocean_ssh_key" "pentest" {
  name = element(var.ssh_keys, count.index)
  count = length(var.ssh_keys)
}

#create new project for every client
resource "digitalocean_project" "proxycannon-ng" {
  name        = "proxycannon-ng"
  description = "Project to extend the proxycannon-ng project to use DO"
  purpose =   "Class project / Educational purposes"
  resources = digitalocean_droplet.exit_node.*.urn
}

resource "digitalocean_droplet" "vpn_server" {
  image  = "ubuntu-18-04-x64"
  name   = "vpn-server"
  region = var.do_region
  size   = var.do_droplet_size
  ssh_keys = data.digitalocean_ssh_key.pentest.*.fingerprint
  private_networking = true
  tags = ["vpn-server"]
}

resource "digitalocean_droplet" "exit_node" {
  image  = "ubuntu-18-04-x64"
  name   = "exit-node-${count.index+1}"
  region = var.do_region
  size   = var.do_droplet_size
  ssh_keys = data.digitalocean_ssh_key.pentest.*.fingerprint
  count = var.node_count
  private_networking = true
  tags = ["exit-node"]
}
