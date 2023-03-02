#!/bin/bash

helm repo add metallb https://metallb.github.io/metallb

helm repo update

kubectl create namespace metallb

helm install metallb metallb/metallb --namespace=metallb

cat > simple_pool_adv_l2.yaml <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: example
  namespace: metallb
spec:
  addresses:
  - 192.168.50.180-192.168.50.185
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb
EOF

kubectl apply -f simple_pool_adv_l2.yaml