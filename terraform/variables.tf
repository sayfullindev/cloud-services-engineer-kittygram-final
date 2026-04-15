variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "Yandex Cloud availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "image_id" {
  description = "Boot disk (Ubuntu 24.04 LTS)"
  type        = string
  default     = "fd8429vdm30a3688t25j"
}