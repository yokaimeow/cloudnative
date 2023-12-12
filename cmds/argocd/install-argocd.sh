#!/bin/bash

helm repo add argo https://argoproj.github.io/argo-helm

helm repo update

helm install argocd argo/argo-cd -n argocd --create-namespace -f values.yaml

helm upgrade argocd argo/argo-cd -n argocd -f values.yaml
