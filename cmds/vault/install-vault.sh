#!/bin/bash

helm repo add hashicorp https://helm.releases.hashicorp.com

helm repo update

helm install vault hashicorp/vault -n vault --create-namespace -f values.yaml

kubectl exec -n vault --stdin=true --tty=true vault-0 -- vault operator init
