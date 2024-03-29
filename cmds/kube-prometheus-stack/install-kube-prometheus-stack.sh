#!/bin/bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm install prom prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f values.yaml
