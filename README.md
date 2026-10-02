# Tutorial para implantar cluster Kubernetes com uma VM gerente e duas VMs workers com QEMU + KVM

## 1. Atualização e Instalação de Dependências

Realize o update dos pacotes da VM e instale as ferramentas necessárias:

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl unzip gnupg software-properties-common git python3-pip python3-venv
```

##2. Adição do Repositório HashiCorp

Adicione o repositório oficial da HashiCorp para instalar o Terraform:


```bash

wget -O- [https://apt.releases.hashicorp.com/gpg](https://apt.releases.hashicorp.com/gpg) | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] [https://apt.releases.hashicorp.com](https://apt.releases.hashicorp.com) $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

wget -O- [https://apt.releases.hashicorp.com/gpg](https://apt.releases.hashicorp.com/gpg) | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] [https://apt.releases.hashicorp.com](https://apt.releases.hashicorp.com) $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

```
## 3. Instalação e Verificação do Terraform

```bash
sudo apt-get update && sudo apt-get install terraform -y

```
Verifique a versão instalada:

```bash
terraform -version

```
##4. Instalação e Configuração do QEMU/KVM

Instale o virtualizador e seus componentes, habilite o serviço e adicione seu usuário ao grupo libvirt:


```bash
sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $USER && newgrp libvirt

```
Nota: Reinicie a VM após este passo.

Altere as permissões do diretório de imagens:

```bash
sudo chmod 755 /var/lib/libvirt/images
sudo chown -R libvirt-qemu:kvm /var/lib/libvirt/images
sudo chmod 644 /var/lib/libvirt/images/*.qcow2

```
Edite o arquivo de configuração do libvirt:

```bash
sudo nano /etc/libvirt/qemu.conf

```
Descomente e edite as linhas para ficarem assim:

```bash
security_driver = "none"
user = "root"
group = "root"

```
Reinicie o serviço do libvirt para aplicar as alterações:

```bash
sudo systemctl restart libvirtd

```
## 5. Instalação de Dependências e Ansible

Instale os pré-requisitos e o Ansible:
```bash


```
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common wget
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

```
<img width="1885" height="499" alt="4-nstalado Ansible" src="https://github.com/user-attachments/assets/98c6803b-4240-48cd-b170-0565db983ef5" />


Gere a chave SSH:

```bash
ssh-keygen -t rsa -b 4096 -N "" -f /root/.ssh/id_rsa

```
<img width="643" height="292" alt="3-Geradochave " src="https://github.com/user-attachments/assets/bde915b4-2b34-4568-8c03-e34bb7300721" />


## 6. Criando a Estrutura do Projeto
1) Crie o diretório cluster-k8s:

```bash

mkdir cluster-k8s
cd cluster-k8s

```
Dentro do diretório cluster-k8s, crie os diretórios terraform e ansible e adicione os arquivos conforme a árvore abaixo:
```bash
cluster-k8s/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── ansible/
    ├── ansible.cfg
    ├── vars.yaml
    └── k8s_deploy.yaml

```
## 7. Executando o Processo de Criação das VMs

Dentro do diretório terraform, execute os comandos:

```bash
cd terraform
```

```bash
terraform init

```
<img width="700" height="468" alt="5 1-Iniciado-terraform" src="https://github.com/user-attachments/assets/ed2192be-3f66-4024-900f-cb7eb125112b" />


```bash
terraform validate
```

<img width="595" height="71" alt="5 2- Validando arquivo terraform" src="https://github.com/user-attachments/assets/63c47462-8843-4d5e-b220-5864d618133f" />

```bash
terraform apply -auto-approve

```<img width="1446" height="902" alt="5-criando-as-VMS" src="https://github.com/user-attachments/assets/02c7e982-f014-4a56-a291-70e7abcde4cc" />


Pool default marked as autostarted

Aguarde a finalização da criação das máquinas virtuais.

<img width="1031" height="866" alt="5 3-Vmsrodando" src="https://github.com/user-attachments/assets/ce962817-a5f1-4a53-8884-fb6389c70a91" />




## 8. Implantação do Cluster Kubernetes

Dentro do diretório ansible, execute a playbook:

```bash
cd ../ansible
ansible-playbook k8s_deploy.yaml

```

<img width="812" height="1899" alt="6-executando ansible" src="https://github.com/user-attachments/assets/7edb3471-b6dd-468d-a3ba-55c51a2cbd2b" />


## 9. Acessando a VM Manager

Obtenha o IP da máquina k8s-manager:

```bash
sudo virsh net-dhcp-leases default

```

Acesse via SSH:

```bash
ssh ubuntu@<IP_DO_K8S_MANAGER>

```


<img width="1260" height="472" alt="7-acessando-vm-manager" src="https://github.com/user-attachments/assets/93b400f8-aaaa-42f7-abd9-449e4dfb6865" />

Execute o comando do Kubernetes para verificar os nós do cluster:


```bash
kubectl get nodes -o wide

```

<img width="1464" height="129" alt="8-verificando-cluster kubernets" src="https://github.com/user-attachments/assets/1e612fa8-1aa9-40d2-941e-92bff2d825d7" />











sudo apt update
sudo apt install -y virtualbox virtualbox-qt


Instale as dependências básicas:
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common wget

Baixe e adicione a chave GPG da HashiCorp:
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg


Adicione o repositório oficial da HashiCorp:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" | sudo tee /etc/apt/sources.list.d/hashicorp.list





sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install -y terraform


sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible


ssh-keygen -t rsa -b 4096 -C "seu_email@exemplo.com"


wget -O ~/.ssh/vagrant https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant
chmod 600 ~/.ssh/vagrant


Comando para remover tudo 
VBoxManage unregistervm --delete "k8s-manager"
VBoxManage unregistervm --delete "k8s-worker-1"
VBoxManage unregistervm --delete "k8s-worker-2"

terraform destroy -auto-approve

#comando para desativar libvirt caso tenha qemu na maquina
sudo modprobe -r kvm_intel kvm
sudo systemctl stop libvirtd 2>/dev/null
sudo modprobe -r kvm_intel kvm
