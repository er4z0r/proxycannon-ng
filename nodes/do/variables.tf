variable "do_token" {
  description = "Your DigitalOcean Personal Access Token"
}

# launch nodes in this region.
variable "do_region" {
  description = "Region that the droplets will be started in"
  default     = "fra1"
}

variable "do_droplet_size" {
  description = "Name (slug) for the droplet size"
  default     = "s-1vcpu-1gb"
}

variable "do_project" {
  description = "Name of the existing DO project to associate our resources with"
  default = "proxycannon-ng"
}


variable "node_count" {
  description = "Number of exit-node instances to launch"
  default     = 2
}

variable ssh_keys {
  description = "Names of the SSH pubkeys to add (must be registered with DO)"
  type        = list(string)
}

variable "private_key" {
  description = "Private key location, so Terraform can connect to new droplets"
}

