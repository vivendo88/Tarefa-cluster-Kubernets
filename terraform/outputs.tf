output "manager_ip" {
  value = libvirt_domain.k8s_manager.network_interface[0].addresses[0]
}

output "workers_ip" {
  value = [for vm in libvirt_domain.k8s_worker : vm.network_interface[0].addresses[0]]
}

resource "local_file" "ansible_inventory" {
  filename = "../ansible/hosts.yaml"
  content  = <<-EOT
all:
  children:
    master:
      hosts:
        k8s-manager:
          ansible_host: ${libvirt_domain.k8s_manager.network_interface[0].addresses[0]}
    workers:
      hosts:
        k8s-worker-1:
          ansible_host: ${libvirt_domain.k8s_worker[0].network_interface[0].addresses[0]}
        k8s-worker-2:
          ansible_host: ${libvirt_domain.k8s_worker[1].network_interface[0].addresses[0]}
    k8s_cluster:
      children:
        master:
        workers:
  EOT
}
