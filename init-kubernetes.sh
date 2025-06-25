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
  sudo apt-get install -y apt-transport-https ca-certificates curl
  sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
}

install_k8s_tools() {
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl
}

init_control_plane() {
  POD_CIDR="${1:-10.244.0.0/16}"
  sudo kubeadm init --pod-network-cidr="$POD_CIDR"
}

setup_kubeconfig() {
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

deploy_flannel() {
  kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
}

join_worker_node() {
  echo "Enter the kubeadm join command received from the control-plane:"
}

check_status() {
  kubectl get nodes
}

main() {
  update_system
  disable_swap
  configure_kernel
  install_containerd
  add_k8s_repo
  install_k8s_tools

  echo "Base installation finished."
  echo "Use the following functions for next steps:"
  echo "  init_control_plane <pod-cidr>"
  echo "  setup_kubeconfig"
  echo "  deploy_flannel"
  echo "  join_worker_node"
  echo "  check_status"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
