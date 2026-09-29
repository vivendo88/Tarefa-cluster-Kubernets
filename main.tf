terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

provider "virtualbox" {
  # Nenhuma configuração adicional necessária
}

# ============================================
# Nó Gerente (Control Plane)
# ============================================
resource "virtualbox_vm" "manager" {
  count     = 1
  name      = "k8s-manager"
  image     = "https://app.vagrantup.com/ubuntu/boxes/jammy64/versions/20240115.0.0/providers/virtualbox.box"
  cpus      = 2
  memory    = "2048 mib"

  network_adapter {
    type           = "bridged"
    host_interface = "eth0"
  }

  # Opcional: aguarda a VM inicializar antes de prosseguir
  # (útil para o Ansible posteriormente)
  # wait_for_guest_ip_timeout = 300
}

# ============================================
# Nós Workers
# ============================================
resource "virtualbox_vm" "workers" {
  count     = 2
  name      = "k8s-worker-${count.index + 1}"
  image     = "https://app.vagrantup.com/ubuntu/boxes/jammy64/versions/20240115.0.0/providers/virtualbox.box"
  cpus      = 2
  memory    = "1024 mib"

  network_adapter {
    type           = "bridged"
    host_interface = "eth0"
  }
}

# ============================================
# Outputs para uso no inventário do Ansible
# ============================================
output "manager_ip" {
  value       = virtualbox_vm.manager[0].network_adapter[0].ipv4_address
  description = "IP do nó gerente (control plane)"
}

output "workers_ips" {
  value       = [for w in virtualbox_vm.workers : w.network_adapter[0].ipv4_address]
  description = "IPs dos nós workers"
}

output "ansible_inventory" {
  value = <<-EOT
    [manager]
    k8s-manager ansible_host=${virtualbox_vm.manager[0].network_adapter[0].ipv4_address}

    [workers]
    %{ for idx, w in virtualbox_vm.workers ~}
    k8s-worker-${idx + 1} ansible_host=${w.network_adapter[0].ipv4_address}
    %{ endfor ~}

    [nodes:children]
    manager
    workers
  EOT
  description = "Conteúdo pronto para colar no arquivo 'inventory' do Ansible"
}
