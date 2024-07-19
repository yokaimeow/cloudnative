#!/bin/bash

yum list --showduplicates kubeadm --disableexcludes=kubernetes

ansible all -m shell -a 'yum install -y kubeadm-{{VERSION}} --disableexcludes=kubernetes' -e 'VERSION="1.30.3"'

ansible all -m shell -a 'kubeadm version'