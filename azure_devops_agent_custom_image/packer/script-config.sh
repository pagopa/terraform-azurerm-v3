#!/usr/bin/env bash

function check_command(){
  if command -v "$1";
  then
    echo "✅ $1 installed"
  else
    echo "❌ $1 NOT installed"
    exit 1
  fi
}

### install zip unzip ca-certificates curl wget apt-transport-https lsb-release gnupg jq
apt-get -y update
apt-get -y --allow-unauthenticated install zip unzip ca-certificates curl wget apt-transport-https lsb-release gnupg jq

check_command "zip"
check_command "unzip"
check_command "jq"

### AZ CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

check_command "az"

### HELM
az acr helm install-cli -y --client-version 3.16.3

check_command "helm"

### KUBECTL
# https://kubernetes.io/releases/
# https://github.com/Azure/kubelogin/releases
az aks install-cli --client-version 1.29.11 --kubelogin-version 0.1.4

check_command "kubectl"
check_command "kubelogin"

### DOCKER & DOCKER COMPOSE
# setup DOCKER installation from https://docs.docker.com/engine/install/ubuntu/
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get -y update
apt-get -y install python3-pip

check_command "python3"

apt-get -y --allow-unauthenticated install docker-ce docker-ce-cli containerd.io docker-compose-plugin

check_command "docker"

### YQ from https://github.com/mikefarah/yq#install
YQ_VERSION="v4.44.5"
YQ_BINARY="yq_linux_amd64"
wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - |\
  tar xz && mv ${YQ_BINARY} /usr/bin/yq

check_command "yq"

### SOPS from https://github.com/mozilla/sops
SOPS_VERSION="3.9.1"
wget "https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_amd64.deb"
apt install -y "$PWD/sops_${SOPS_VERSION}_amd64.deb"

check_command "sops"

### Velero
VELERO_VERSION=v1.13.2
wget https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/velero-${VELERO_VERSION}-linux-amd64.tar.gz && \
tar -zxvf velero-${VELERO_VERSION}-linux-amd64.tar.gz && \
sudo mv velero-${VELERO_VERSION}-linux-amd64/velero /usr/bin/velero

check_command "velero"

### Packer
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null && \
sudo apt-get update && \
sudo apt-get install -y packer

check_command "packer"

### TEMPORAL
TEMPORAL_VERSION=1.1.2
wget https://github.com/temporalio/cli/releases/download/v${TEMPORAL_VERSION}/temporal_cli_${TEMPORAL_VERSION}_linux_amd64.tar.gz && \
tar -zxvf temporal_cli_${TEMPORAL_VERSION}_linux_amd64.tar.gz && \
sudo mv temporal /usr/bin/temporal

check_command "temporal"

### ARGOCD
ARGOCD_VERSION=2.13.1
wget https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64 && \
chmod +x argocd-linux-amd64 && \
sudo mv argocd-linux-amd64 /usr/bin/argocd

check_command "argocd"

### NodeJS 20.x
if [ -f /usr/share/keyrings/nodesource.gpg ]; then
    echo "Removing existing NodeSource GPG key..."
    rm -f /usr/share/keyrings/nodesource.gpg
fi

if [ -f /etc/apt/sources.list.d/nodesource.list ]; then
    echo "Removing existing NodeSource repository configuration..."
    rm -f /etc/apt/sources.list.d/nodesource.list
fi

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
    gpg --dearmor -o /usr/share/keyrings/nodesource.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | \
    tee /etc/apt/sources.list.d/nodesource.list > /dev/null

apt-get update
apt-get install -y nodejs

check_command "node"
check_command "npm"

echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

### prepare machine for k6 large load test
sysctl -w net.ipv4.ip_local_port_range="1024 65535"
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.tcp_timestamps=1
ulimit -n 250000
