resource "docker_image" "ghost" {
  name = "ghost:latest"
}

resource "docker_container" "blog" {
	name = "myblog"
	image = "ghost:latest" #docker_image.ghost.latest
	ports { 
		internal = "2368"
		external = "80"
	}
}

