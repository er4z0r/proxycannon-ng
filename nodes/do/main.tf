provider "digitalocean" {
  token = var.do_token
}


data "digitalocean_ssh_key" "pentest" {
  name  = element(var.ssh_keys, count.index)
  count = length(var.ssh_keys)
}

data "digitalocean_project" "proxycannon_project" {
  name = var.do_project
}

resource "digitalocean_droplet" "vpn_server" {
  image              = "ubuntu-18-04-x64"
  name               = "proxycannon-server"
  region             = var.do_region
  size               = var.do_droplet_size
  ssh_keys           = data.digitalocean_ssh_key.pentest.*.fingerprint
  private_networking = true
  tags               = ["proxycannon-server"]

  connection {
      host     = self.ipv4_address
      type     = "ssh"
      user     = "root"
      private_key = file("${var.private_key}")
  } 

  # upload the config files
  provisioner "file" {
    source      = "${path.module}/configs/control_server"
    destination = "/tmp/"
  }

  # upload the config files
  provisioner "file" {
    source      = "${path.module}/scripts/control_server"
    destination = "/tmp/"
  }


  # execute our provisioning scripts
  provisioner "remote-exec" {
    inline = ["cd /tmp/control_server", "sh install.sh"]
  } 

  # download keys for vpn server using an INSECURE scp command
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.private_key} root@${self.ipv4_address}:~/client-config.tar.gz . && tar xvzf client-config.tar.gz "
  }

  # copy the vpn config template  
  provisioner "local-exec" {
    command = "cp ${path.module}/configs/client/proxycannon-client.conf client-config/"
  }

  # modify client config with remote IP of this server
  provisioner "local-exec" {
    command = "sed -i 's/REMOTE_PUB_IP/${self.ipv4_address}/' proxycannon-client.conf"
    working_dir = "client-config"
  }

}

# resource "digitalocean_droplet" "exit_node" {
#   image              = "ubuntu-18-04-x64"
#   name               = "exit-node-${count.index + 1}"
#   region             = var.do_region
#   size               = var.do_droplet_size
#   ssh_keys           = data.digitalocean_ssh_key.pentest.*.fingerprint
#   count              = var.node_count
#   private_networking = true
#   tags               = ["exit-node"]

#   connection {
#       host     = self.ipv4_address
#       type     = "ssh"
#       user     = "root"
#       private_key = file("${var.private_key}")
#   }


#   # upload our provisioning scripts
#   provisioner "file" {
#     source      = "${path.module}/configs/exit_node"
#     destination = "/tmp/"
#   }

#   # execute our provisioning scripts
#   provisioner "remote-exec" {
#     script = "${path.module}/configs/exit_node/node_setup.bash"
#   }

# }

resource "digitalocean_project_resources" "proxycannon_resources" {
  project   = data.digitalocean_project.proxycannon_project.id
  # resources = concat(digitalocean_droplet.exit_node.*.urn, [digitalocean_droplet.vpn_server.urn])
  resources = [digitalocean_droplet.vpn_server.urn]
}
