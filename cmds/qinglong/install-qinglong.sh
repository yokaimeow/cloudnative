#!/bin/bash

helm repo add truecharts https://charts.truecharts.org/

helm repo update

helm install qinglong -n qinglong truecharts/qinglong --version 4.0.20 --create-namespace
