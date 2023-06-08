#!/usr/bin/env bash


# install zip unzip ca-certificates curl wget apt-transport-https lsb-release gnupg jq
apt-get -y update
apt-get -y --allow-unauthenticated install zip unzip ca-certificates curl wget apt-transport-https lsb-release gnupg jq

zip --version
echo "✅ zip installed"
unzip --version
echo "✅ unzip installed"
jq
echo "✅ jq installed"

# install az cli
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

az acr helm install-cli -y --client-version 3.12.0

az aks install-cli --client-version 1.25.10 --kubelogin-version 0.0.29


# setup Docker installation from https://docs.docker.com/engine/install/ubuntu/
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null


apt-get -y update
apt-get -y install  python3-pip
apt-get -y --allow-unauthenticated install docker-ce docker-ce-cli containerd.io docker-compose-plugin

az --version
echo "✅ az-cli installed"
kubectl version --short
echo "✅ kubectl installed"
docker -v
echo "✅ docker installed"
helm version
echo "✅ helm installed"
python3 --version
echo "✅ python3 installed"

# install yq from https://github.com/mikefarah/yq#install
YQ_VERSION="v4.33.3"
YQ_BINARY="yq_linux_amd64"
wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - |\
  tar xz && mv ${YQ_BINARY} /usr/bin/yq

yq --version
echo "✅ yq installed"

# install SOPS from https://github.com/mozilla/sops
SOPS_VERSION="v3.7.3"
SOPS_BINARY="3.7.3_amd64.deb"
wget https://github.com/mozilla/sops/releases/download/v3.7.3/sops_3.7.3_amd64.deb
apt install -y $PWD/sops_3.7.3_amd64.deb
sops -v
echo "✅ sops installed"

# prepare machine for k6 large load test

sysctl -w net.ipv4.ip_local_port_range="1024 65535"
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.tcp_timestamps=1
ulimit -n 250000