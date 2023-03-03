#!/bin/bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update

kubectl create namespace ingress-nginx

helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --set controller.service.loadBalancerIP=192.168.50.180