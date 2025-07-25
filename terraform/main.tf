terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_volume" "db_data" {
  name = "db_data"
}

resource "docker_network" "app_network" {
  name = "app_network"
}

resource "docker_image" "backend_image" {
  name = "backend:latest"
  build {
    context = "${path.module}/../backend"
  }
}

resource "docker_container" "db" {
  name  = "db"
  image = "postgres:15.8"
  env = [
    "POSTGRES_DB=app_db",
    "POSTGRES_USER=admin",
    "POSTGRES_PASSWORD=securepassword"
  ]

  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/postgresql/data"
  }

  # Montar o init.sql como bind mount
  mounts {
    type      = "bind"
    source    = abspath("${path.module}/../database/init.sql")
    target    = "/docker-entrypoint-initdb.d/init.sql"
    read_only = true
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  restart = "always"
}

resource "docker_container" "backend" {
  name  = "backend"
  image = docker_image.backend_image.name
  ports {
    internal = 5000
    external = 5001
  }
  env = [
    "PORT=5000",
    "DB_HOST=db",
    "DB_PORT=5432",
    "DB_NAME=app_db",
    "DB_USER=admin",
    "DB_PASSWORD=securepassword"
  ]
  networks_advanced {
    name = docker_network.app_network.name
  }
  depends_on = [docker_container.db, docker_image.backend_image]
  restart    = "always"
}

resource "docker_image" "frontend_image" {
  name = "frontend:latest"
  build {
    context = "${path.module}/../frontend"
  }
}

resource "docker_container" "frontend" {
  name  = "frontend"
  image = docker_image.frontend_image.name
  ports {
    internal = 80
    external = 8080
  }
  networks_advanced {
    name = docker_network.app_network.name
  }
  depends_on = [docker_container.backend, docker_image.frontend_image]
  restart    = "always"
}

resource "docker_image" "prometheus_image" {
  name = "prom/prometheus:latest"
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = docker_image.prometheus_image.name
  ports {
    internal = 9090
    external = 9090
  }
  volumes {
    host_path      = "C:/Users/gabri/desafio-devops/monitoring/prometheus.yml"
    container_path = "/etc/prometheus/prometheus.yml"
  }
  networks_advanced {
    name = docker_network.app_network.name
  }
  restart = "always"
}

# Adicionando Grafana
resource "docker_image" "grafana_image" {
  name = "grafana/grafana:latest"
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana_image.name
  ports {
    internal = 3000
    external = 3000
  }
  env = [
    "GF_SECURITY_ADMIN_PASSWORD=admin"
  ]
  networks_advanced {
    name = docker_network.app_network.name
  }
  restart = "always"
}

output "frontend_url" {
  value = "http://localhost:8080"
}

output "prometheus_url" {
  value = "http://localhost:9090"
}

output "grafana_url" {
  value = "http://localhost:3000"
}
