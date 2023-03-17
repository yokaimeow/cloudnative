#!/bin/bash

helm repo add minecraft-server-charts https://itzg.github.io/minecraft-server-charts/

helm repo update

helm install minecraft -n minecraft --create-namespace minecraft-server-charts/minecraft -f values.yaml