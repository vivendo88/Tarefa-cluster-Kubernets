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
