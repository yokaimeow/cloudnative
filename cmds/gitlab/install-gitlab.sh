#!/bin/bash

helm repo add gitlab http://charts.gitlab.io/

helm repo update

# 先新建一个泛域名 certificate，values 文件中不使用自带的 certmanager 管理证书

helm install gitlab gitlab/gitlab -n gitlab --create-namespace -f values.yaml --timeout 1200s
