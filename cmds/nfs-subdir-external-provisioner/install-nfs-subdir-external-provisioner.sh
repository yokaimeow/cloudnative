#!/bin/bash

helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/

helm repo update

helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --namespace=nfs-provisioner --create-namespace --set replicaCount=1 --set storageClass.name=nfs-client --set storageClass.defaultClass=true --set nfs.server=192.168.50.171 --set nfs.path=/volume1/nfs --set storageClass.reclaimPolicy=Retain
