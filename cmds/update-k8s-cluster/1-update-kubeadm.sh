#!/bin/bash

yum list --showduplicates kubeadm --disableexcludes=kubernetes

ansible all -m shell -a 'yum install -y kubeadm-{{VERSION}}-0 --disableexcludes=kubernetes' -e 'VERSION="1.27.2"'

ansible all -m shell -a 'kubeadm version'