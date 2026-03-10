#!/bin/bash
# Esta primera línea guarda un log de todo lo que pasa acá por si algo falla
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Descarga e instala K3s (detecta automáticamente que es ARM y baja la versión correcta)
curl -sfL https://get.k3s.io | sh -

sleep 15

# K3s guarda su configuración como root. Hacemos una copia para que tu usuario 'ubuntu' pueda usar el comando 'kubectl' sin tener que poner 'sudo' todo el tiempo.
mkdir -p /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Le decimos a esta sesión dónde está la config para poder instalar ArgoCD ahora mismo
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Creamos el espacio de trabajo (namespace) exclusivo para ArgoCD
kubectl create namespace argocd

# Descargamos y aplicamos la última versión estable de ArgoCD directo desde su repo oficial
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
