locals {
	env = "development"

	project = "project-2"
	project_purpose = "Web Application"
  droplet_user = "root"
	droplet_image = "ubuntu-20-04-x64"
	droplet_region = "nyc3"
	droplet_size = "s-1vcpu-1gb"
	droplet_tags = ["c9", "docker"]
}
