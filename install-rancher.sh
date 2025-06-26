#!/bin/bash
set -e

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

kubectl create namespace cattle-system || true

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.1/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true

kubectl wait --namespace cert-manager --for=condition=Ready pods --all --timeout=180s

HOSTNAME=$(hostname -i | awk '{print $1}')
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=$HOSTNAME \
  --set bootstrapPassword=admin

kubectl wait --namespace cattle-system --for=condition=Ready pods --all --timeout=180s

echo -e "\nRancher installation complete."
