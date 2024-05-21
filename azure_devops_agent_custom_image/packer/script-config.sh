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

# install zip unzip ca-certificates curl wget apt-transport-https lsb-release gnupg jq
apt-get -y update
apt-get -y --allow-unauthenticated install zip unzip ca-certificates curl wget apt-transport-https lsb-release gnupg jq

check_command "zip"
check_command "unzip"
check_command "jq"

# install az cli
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

check_command "az"

# install helm
az acr helm install-cli -y --client-version 3.14.2

check_command "helm"

# install kubectl
az aks install-cli --client-version 1.27.12 --kubelogin-version 0.1.3

check_command "kubectl"

# setup DOCKER installation from https://docs.docker.com/engine/install/ubuntu/
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get -y update
apt-get -y install python3-pip

check_command "python3"

# DOCKER & DOCKER COMPOSE
apt-get -y --allow-unauthenticated install docker-ce docker-ce-cli containerd.io docker-compose-plugin

check_command "docker"

# install YQ from https://github.com/mikefarah/yq#install
YQ_VERSION="v4.43.1"
YQ_BINARY="yq_linux_amd64"
wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - |\
  tar xz && mv ${YQ_BINARY} /usr/bin/yq

check_command "yq"

# install SOPS from https://github.com/mozilla/sops
SOPS_VERSION="3.8.1"
wget "https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_amd64.deb"
apt install -y "$PWD/sops_${SOPS_VERSION}_amd64.deb"

check_command "sops"

# install Velero
VELERO_VERSION=v1.13.2
wget https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/velero-${VELERO_VERSION}-linux-amd64.tar.gz && \
tar -zxvf velero-${VELERO_VERSION}-linux-amd64.tar.gz && \
sudo mv velero-${VELERO_VERSION}-linux-amd64/velero /usr/bin/velero

check_command "velero"

# install packer
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && \
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" $$ \
sudo apt-get update && sudo apt-get install -y packer


# install azure az repos
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
AZ_DIST=$(lsb_release -cs)
echo "Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/azure-cli.sources
sudo apt-get update
# prepare machine for k6 large load test

sysctl -w net.ipv4.ip_local_port_range="1024 65535"
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.tcp_timestamps=1
ulimit -n 250000
