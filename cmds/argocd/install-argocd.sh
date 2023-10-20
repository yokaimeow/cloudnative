#!/bin/bash

helm repo add argo https://argoproj.github.io/argo-helm

helm repo update

helm install argocd argo/argo-cd -n argo --create-namespace -f values.yaml
