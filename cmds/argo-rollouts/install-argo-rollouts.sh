#!/bin/bash

helm repo add argo https://argoproj.github.io/argo-helm

helm repo update

helm install argorollouts argo/argo-rollouts -n argorollouts --create-namespace -f values.yaml

helm upgrade argorollouts argo/argo-rollouts -n argorollouts -f values.yaml