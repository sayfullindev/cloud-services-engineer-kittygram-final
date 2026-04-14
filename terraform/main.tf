terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  backend "s3" {
  endpoints = {
    s3 = "https://storage.yandexcloud.net"
  }
  bucket = "s3-sayfullindev"
  region = "ru-central1"
  key    = "tf-state.tfstate"

  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_s3_checksum            = true
}
  required_version = ">= 0.13" // версия, совместимая с провайдером версия Terraform  
}

resource "yandex_vpc_network" "main" {
  name = "network"
}
resource "yandex_vpc_subnet" "main" {
  network_id     = yandex_vpc_network.main.id
  zone           = "ru-central1-a"
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
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "main" {
  name = "vm_kittygram"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8429vdm30a3688t25j"
      size     = 10
    }
  }

  network_interface {
    subnet_id          =   yandex_vpc_subnet.main.id
    nat                = true 
    security_group_ids = [yandex_vpc_security_group.main.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
    user-data = file("cloud-init.yaml")
  }
}
