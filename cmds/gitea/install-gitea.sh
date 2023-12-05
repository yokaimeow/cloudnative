#!/bin/bash

helm repo add gitea https://dl.gitea.io/charts

helm repo update

helm install gitea gitea/gitea -n gitea --create-namespace -f values.yaml