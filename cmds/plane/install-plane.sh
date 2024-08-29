#!/bin/bash

helm repo add makeplane https://helm.plane.so/

helm repo update

helm install plane makeplane/plane-ce -n plane --create-namespace -f values.yaml --timeout 60m --wait --wait-for-jobs

helm upgrade plane makeplane/plane-ce -n plane -f values.yaml --timeout 60m --wait --wait-for-jobs