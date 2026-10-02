terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# 1. Volume base Ubuntu Noble
resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-noble-base.qcow2"
  pool   = "default"
  source = var.ubuntu_image_url
  format = "qcow2"
}

# 2. Disco do Manager: 8 GB
resource "libvirt_volume" "manager_disk" {
  name           = "k8s-manager-disk.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 8589934592 # 8 GB
}

# 3. Discos dos 2 Workers: 8 GB cada
resource "libvirt_volume" "worker_disk" {
  count          = 2
  name           = "k8s-worker-${count.index + 1}-disk.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 8589934592 # 8 GB
}

# 4. Cloud-Init individual do Manager
resource "libvirt_cloudinit_disk" "manager_init" {
  name = "manager-init.iso"
  pool = "default"
  user_data = <<-EOT
    #cloud-config
    hostname: k8s-manager
    manage_etc_hosts: true
    users:
      - name: ubuntu
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        shell: /bin/bash
        ssh_authorized_keys:
          - ${chomp(file(var.ssh_public_key))}
    ssh_pwauth: true
    disable_root: false
    chpasswd:
      list: |
        ubuntu:ubuntu
      expire: False
  EOT
}

# 5. Cloud-Init individual dos Workers
resource "libvirt_cloudinit_disk" "worker_init" {
  count = 2
  name  = "worker-${count.index + 1}-init.iso"
  pool  = "default"
  user_data = <<-EOT
    #cloud-config
    hostname: k8s-worker-${count.index + 1}
    manage_etc_hosts: true
    users:
      - name: ubuntu
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        shell: /bin/bash
        ssh_authorized_keys:
          - ${chomp(file(var.ssh_public_key))}
    ssh_pwauth: true
    disable_root: false
    chpasswd:
      list: |
        ubuntu:ubuntu
      expire: False
  EOT
}

# VM Manager: 1024 MB de RAM
resource "libvirt_domain" "k8s_manager" {
  name   = "k8s-manager"
  memory = 1024
  vcpu   = 1

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.manager_disk.id
  }

  cloudinit = libvirt_cloudinit_disk.manager_init.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

# VMs Workers: 1024 MB de RAM cada
resource "libvirt_domain" "k8s_worker" {
  count  = 2
  name   = "k8s-worker-${count.index + 1}"
  memory = 1024
  vcpu   = 1

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.worker_disk[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.worker_init[count.index].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
