resource "yandex_compute_instance" "main" {
  name                      = "vm_kittygram"
  zone                      = var.zone
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.main.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.main.id]
  }

  metadata = {
    user-data = templatefile("cloud-init.yaml", {
      ssh_public_key = var.ssh_public_key
    })
  }
}
