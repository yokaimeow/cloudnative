#!/bin/bash

helm repo add harbor https://helm.goharbor.io

helm repo update

# 先新建一个泛域名 certificate

helm install harbor harbor/harbor -n harbor --create-namespace -f values.yaml
