locals {
	env = "production"

	project = "project-1"
	project_purpose = "Web Application"
	domain = "yourdomain.com.br"
  droplet_user = "root"
	droplet_image = "ubuntu-20-04-x64"
	droplet_region = "nyc3"
	droplet_size = "s-1vcpu-1gb"
	droplet_tags = ["nginx", "docker"]
}
