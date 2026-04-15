resource "yandex_vpc_network" "main" {
  name = "network"
}

resource "yandex_vpc_subnet" "main" {
  network_id     = yandex_vpc_network.main.id
  zone           = var.zone
  v4_cidr_blocks = ["10.0.0.0/28"]
}

resource "yandex_vpc_security_group" "main" {
  name       = "web-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 8000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}