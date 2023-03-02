```shell
# 查看kube-proxy中的strictARP配置
$ kubectl get configmap -n kube-system kube-proxy -o yaml | grep strictARP
      strictARP: false

# 手动修改strictARP配置为true
$ kubectl edit configmap -n kube-system kube-proxy
configmap/kube-proxy edited

# 使用命令直接修改并对比不同
$ kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl diff -f - -n kube-system

# 确认无误后使用命令直接修改并生效
$ kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system

# 重启kube-proxy确保配置生效
$ kubectl rollout restart ds kube-proxy -n kube-system

# 确认配置生效
$ kubectl get configmap -n kube-system kube-proxy -o yaml | grep strictARP
      strictARP: true
```

修改 kube-proxy 中的 strictARP 配置后进行安装

### 参考

- [负载均衡器之MatelLB](https://tinychen.com/20220519-k8s-06-loadbalancer-metallb/)