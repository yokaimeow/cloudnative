#!/bin/bash

# main exec

kubeadm upgrade plan

kubeadm config images pull

kubeadm upgrade apply v1.34.1

#other controler node exec
kubeadm config images pull

kubeadm upgrade node

kubectl get nodes -o wide

# 一台一台来操作
VERSION="1.34.1"

kubectl drain k8s-master1.doki.life --ignore-daemonsets

yum install -y kubelet-$VERSION kubectl-$VERSION --disableexcludes=kubernetes

systemctl daemon-reload

systemctl restart kubelet

systemctl status kubelet -l | grep active

kubectl uncordon k8s-master1.doki.life

kubectl get nodes -o wide

# ---

VERSION="1.34.1"

kubectl drain k8s-master2.doki.life --ignore-daemonsets

yum install -y kubelet-$VERSION kubectl-$VERSION --disableexcludes=kubernetes

systemctl daemon-reload

systemctl restart kubelet

systemctl status kubelet -l | grep active

kubectl uncordon k8s-master2.doki.life

kubectl get nodes -o wide

# ---

VERSION="1.34.1"

kubectl drain k8s-master3.doki.life --ignore-daemonsets

yum install -y kubelet-$VERSION kubectl-$VERSION --disableexcludes=kubernetes

systemctl daemon-reload

systemctl restart kubelet

systemctl status kubelet -l | grep active

kubectl uncordon k8s-master3.doki.life

kubectl get nodes -o wide
