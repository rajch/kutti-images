#!/bin/sh
set -e

#########################################################
# The variables DOCKER_VERSION and KUBE_VERSION control
# the version of Docker and Kubernetes installed.
# Currently supported values for KUBE_VERSION ARE:
#   - 1.18.2-00
#   - 1.17.5-00
#   - 1.16.9-00
#
# Currently supported values for DOCKER_VERSION are:
#   - 19.03.8
#   - 18.09.9
#
# Kubernetes 1.14 and 1.15 support docker up to 18.09 
# only. Uncomment the next line to use that by default
#
# DOCKER_VERSION=${DOCKER_VERSION:-18.09.3}
#########################################################

if [ $(id -ur) -ne 0 ]; then
    echo $0 can only be run as root. Use sudo.
    exit 1
fi

## Enable iptables to see bridged traffic
echo "Enable iptables to see bridged traffic..."
echo "-----------------------------------------"
cat <<EOSYSCTLCNF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOSYSCTLCNF
sysctl --system
echo "-----------------------------------------"

## Install system tools
echo "Adding system utilities, vim and curl..."
echo "----------------------------------------"
apt update
apt purge -y vim-tiny
apt install -y apt-transport-https bash-completion vim curl
echo "----------------------------------------"
echo "Done."
echo

## Install docker
echo "Installing docker..."
echo "--------------------"
if [ "" = "$DOCKER_VERSION" ]; then
    echo "Latest version."
    curl -L http://get.docker.com | /bin/sh
else
    echo "Version $DOCKER_VERSION"
    curl -L http://get.docker.com | VERSION=$DOCKER_VERSION /bin/sh
fi
echo
echo "Adding daemon.json for configuring cgroup driver..."
cat<<EOCD >/etc/docker/daemon.json
{
    "exec-opts": [ "native.cgroupdriver=systemd" ]
}
EOCD
echo
echo "Restarting docker..."
systemctl restart docker
echo "Adding user user1 to docker group..."
adduser user1 docker
echo "Adding user kuttiadmin to docker group..."
adduser kuttiadmin docker
echo "--------------------"
echo "Done."
echo

## Install kubelet, kubeadm, kubectl
echo "Installing kubelet, kubeadm and kubectl..."
echo "------------------------------------------"
echo "Adding kubernetes apt key..."
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo
echo "Adding kubernetes apt repository..."
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
echo
echo "Installing kubelet, kubeadm and kubectl"
if [ "" = "$KUBE_VERSION" ]; then
    echo "Latest version."
    apt-get install -y kubelet kubeadm kubectl
else
    echo "Version $KUBE_VERSION"
    apt-get install -y kubelet=$KUBE_VERSION kubeadm=$KUBE_VERSION kubectl=$KUBE_VERSION
fi
apt-mark hold kubelet kubeadm kubectl
echo "------------------------------------------"
echo "Done."

## Add kubectl autocomplete
[ -d /etc/bash_completion.d ] || mkdir -p /etc/bash_completion.d
echo "Installing kubectl autocomplete..."
kubectl completion bash >/etc/bash_completion.d/kubectl
echo "Done."
