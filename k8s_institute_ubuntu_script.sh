#!/bin/bash
# Welcome to https://www.k8s.institue
# This script has been tested and verified. 
# Should work on Ubuntu 18.04+ systems

# Swap off ; disable swap config from /etc/fstab
swapoff -a 
# Make sure you disable swap permenentaly. following command works fine on my Ubuntu system
sed -i '/swap/d' /etc/fstab 

apt-get update -y
#apt-get upgrade -y
apt-get install -y net-tools wget vim

#
# 
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
#######
# Make sure there is no other version of docker installed
apt-get remove -y docker.io

# Install docker-ce 
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
# Add docker's official GPG Key

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# Verify 
sudo apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update -y
apt-get install docker-ce docker-ce-cli containerd.io -y
systemctl enable docker; systemctl start docker

#
# setup apt repo to install kubernetes 
#

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
VER=1.20.2
sudo apt-get update
sudo apt-get install -y kubelet=${VER}-00 kubeadm=${VER}-00 kubectl=${VER}-00
sudo apt-mark hold kubelet kubeadm kubectl

# Disable SELinux - Required for CentOS
#setenforce 0
#sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Install kubelet, kubeadm and kubectl

systemctl enable kubelet; systemctl start kubelet

# initialize kubernetes cluster with kubeadm init

kubeadm init --pod-network-cidr 172.16.0.0/20 --apiserver-advertise-address 10.10.10.76

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown -R vagrant.vagrant /home/vagrant/.kube

sleep 10
kubectl cluster-info
sleep 5

kubectl get all -n kube-system

# Now lets setup calico opensource networking and network security solution for containers, vm, and host-based workloads. 

#curl https://docs.projectcalico.org/manifests/calico.yaml -o calico.yaml
#sleep 2
#kubectl apply -f calico.yaml

# For a one node kubernetes implementation we need to remove default taints so that we can deploy other resources 
kubectl taint node $HOSTNAME node-role.kubernetes.io/master:NoSchedule-
kubectl taint node $HOSTNAME node.kubernetes.io/not-ready:NoSchedule-

# Thanks for trying. https://www.k8s.institute https://k8s.institute http://www.ninit.tech
