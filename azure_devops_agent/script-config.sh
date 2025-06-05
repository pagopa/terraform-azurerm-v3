#!/usr/bin/env bash

# install zip unzip

apt-get -y update
apt-get -y install zip unzip

# install az cli from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions

apt-get -y update
apt-get -y install ca-certificates curl wget apt-transport-https lsb-release gnupg

curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    tee /etc/apt/sources.list.d/azure-cli.list

apt-get -y update
apt-get -y install azure-cli

# install python package index (pip)

apt-get -y install python-pip

# install docker from https://docs.docker.com/engine/install/ubuntu/

curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get -y update
apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# install kubectl from https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management

curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

apt-get -y update
apt-get -y install kubectl

# install helm from https://helm.sh/docs/intro/install/#from-apt-debianubuntu

curl https://baltocdn.com/helm/signing.asc | apt-key add -

echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

apt-get -y update
apt-get -y install helm

# install yq from https://github.com/mikefarah/yq#install

YQ_VERSION="v4.27.2"
YQ_BINARY="yq_linux_amd64"
wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - |\
  tar xz && mv ${YQ_BINARY} /usr/bin/yq

# install zip unzip

apt-get -y update
apt-get -y install zip unzip

# install SOPS from https://github.com/mozilla/sops
SOPS_VERSION="v3.7.3"
SOPS_BINARY="3.7.3_amd64.deb"

wget https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops_${SOPS_BINARY} |apt install -y $PWD/sops_${SOPS_BINARY}

# install jq

apt-get -y update
apt-get -y install jq

# install SDKManager with Java and Maven
apt-get -y install curl
curl -s "https://get.sdkman.io" | bash

# reload sdk manager bin
source "/root/.sdkman/bin/sdkman-init.sh"

JAVA_VERSION="21.0.7-tem"
MAVEN_VERSION="3.9.9"

sdk install java ${JAVA_VERSION}    # Install java
sdk install maven ${MAVEN_VERSION}  # Install maven

# prepare machine for k6 large load test

sysctl -w net.ipv4.ip_local_port_range="1024 65535"
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.tcp_timestamps=1
ulimit -n 250000
