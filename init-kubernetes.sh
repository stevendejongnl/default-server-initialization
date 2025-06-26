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
  sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
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
  MASTER_IP=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
  sudo kubeadm init --apiserver-advertise-address="$MASTER_IP" --apiserver-cert-extra-sans="$MASTER_IP" --pod-network-cidr="$POD_CIDR" --node-name "$NODENAME"
}

setup_kubeconfig() {
  if [ "$(id -u)" -eq 0 ]; then
    export KUBECONFIG=/etc/kubernetes/admin.conf
    echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.bashrc
  else
    export KUBECONFIG=$HOME/.kube/config
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
  fi
}

deploy_calico() {
  echo "Deploying Calico network plugin..."
  kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
}

check_status() {
  kubectl get nodes
}

main() {
  if [ -z "$NODENAME" ]; then
    echo "Error: NODENAME is not set."
    exit 1
  fi

  update_system
  disable_swap
  configure_kernel
  install_containerd
  add_k8s_repo
  install_k8s_tools
  if [ "$NODENAME" == "master" ]; then
    echo "Initializing Kubernetes control plane on master node..."
    init_control_plane
    setup_kubeconfig
    deploy_calico
    check_status
  else
    echo "Joining worker node to Kubernetes cluster..."
    echo "Not implemented in this script. Please run 'kubeadm join' manually."
    echo "after setup kubeconfig"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    for arg in "$@"; do
    case $arg in
      --master)
        NODENAME="master"
        shift
        ;;
      --worker)
        NODENAME="worker"
        shift
        ;;
      *)
        ;;
    esac
  done

  echo "Running init-kubernetes.sh $NODENAME"
  main
fi
