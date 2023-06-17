#!/bin/bash

# All worker update
kubeadm upgrade node

# 一台一台来操作
VERSION="1.27.3"

# exec in controller
kubectl drain k8s-node1.doki.life --ignore-daemonsets

yum install -y kubelet-$VERSION-0 --disableexcludes=kubernetes

systemctl daemon-reload

systemctl restart kubelet

systemctl status kubelet -l | grep active

# exec in controller
kubectl uncordon k8s-node1.doki.life

kubectl get nodes -o wide

# ---

VERSION="1.27.3"

kubectl drain k8s-node2.doki.life --ignore-daemonsets

yum install -y kubelet-$VERSION-0 --disableexcludes=kubernetes

systemctl daemon-reload

systemctl restart kubelet

systemctl status kubelet -l | grep active

kubectl uncordon k8s-node2.doki.life

kubectl get nodes -o wide

# ---

VERSION="1.27.3"

kubectl drain k8s-node3.doki.life --ignore-daemonsets

yum install -y kubelet-$VERSION-0 --disableexcludes=kubernetes

systemctl daemon-reload

systemctl restart kubelet

systemctl status kubelet -l | grep active

kubectl uncordon k8s-node3.doki.life

kubectl get nodes -o wide