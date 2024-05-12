job "traefik" {
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      mode = "host"
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v2.9"  # Adjust version accordingly
        args  = ["--api.insecure=true", "--providers.consulcatalog", "--entrypoints.web.address=:80", "--entrypoints.websecure.address=:443"]

        ports = ["web", "websecure"]
      }

      service {
        name = "traefik"
        port = "web"
        tags = ["traefik"]
        check {
          type     = "http"
          path     = "/ping"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 500  # Adjust according to your needs
        memory = 512  # Adjust according to your needs
      }

      env {
        "CONSUL_HTTP_ADDR"       = "127.0.0.1:8500"   # Adjust to point to your Consul cluster
        "CONSUL_CACERT"          = "/path/to/consul/ca.pem"
        "CONSUL_CLIENT_CERT"     = "/path/to/consul/client-cert.pem"
        "CONSUL_CLIENT_KEY"      = "/path/to/consul/client-key.pem"
        "TRAEFIK_LOG_LEVEL"      = "INFO"
        "TRAEFIK_PROVIDERS_CONSULCATALOG_ENDPOINT_ADDRESS" = "127.0.0.1:8500"  # Adjust to your Consul's address
      }
    }
  }
}
