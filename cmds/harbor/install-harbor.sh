#!/bin/bash

helm repo add harbor https://helm.goharbor.io

helm repo update

helm install harbor harbor/harbor -n harbor --create-namespace -f values.yaml
