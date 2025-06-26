#!/bin/bash
set -e

update_system() {
  sudo apt-get update && sudo apt-get upgrade -y
}

disable_swap() {
  sudo swapoff -a
  sudo sed -i '/ swap / s/^/#/' /etc/fstab
}

configure_kernel() {
  sudo modprobe overlay
  sudo modprobe br_netfilter
  sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
  sudo sysctl --system
}

install_containerd() {
  sudo apt-get install -y containerd
  sudo mkdir -p /etc/containerd
  sudo containerd config default | sudo tee /etc/containerd/config.toml
  sudo systemctl restart containerd
  sudo systemctl enable containerd
}

add_k8s_repo() {
  sudo apt-get install -y apt-transport-https ca-certificates curl gpg
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
}

install_k8s_tools() {
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl
}

init_control_plane() {
  POD_CIDR=10.244.0.0/16
  sudo kubeadm init --pod-network-cidr="$POD_CIDR"
}

setup_kubeconfig() {
  if [ "$(id -u)" -eq 0 ]; then
    export KUBECONFIG=/etc/kubernetes/admin.conf
  else
    export KUBECONFIG=$HOME/.kube/config
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
  fi
}

# deploy_flannel() {
#   kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml --validate=false
# }

# check_status() {
#   kubectl get nodes
# }

main() {
  update_system
  disable_swap
  configure_kernel
  install_containerd
  add_k8s_repo
  install_k8s_tools
  init_control_plane
  setup_kubeconfig
  # deploy_flannel
  # check_status
}

main
