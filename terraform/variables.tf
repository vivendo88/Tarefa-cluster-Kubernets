variable "ssh_public_key" {
  description = "Caminho da chave publica SSH"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
  description = "Caminho da chave privada SSH"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ubuntu_image_url" {
  description = "URL da imagem cloud do Ubuntu 24.04"
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}
