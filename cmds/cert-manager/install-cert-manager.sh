#!/bin/bash

helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install cert-manager --namespace cert-manager --version v1.11.0 jetstack/cert-manager --set installCRDs=true