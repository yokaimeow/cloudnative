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

提前准备好configmap的配置，github上面有提供一个参考文件，layer2模式需要的配置并不多，这里我们只做最基础的一些参数配置定义即可：

protocol这一项我们配置为layer2
addresses这里我们可以使用CIDR来批量配置（198.51.100.0/24），也可以指定首尾IP来配置（192.168.0.150-192.168.0.200），这里我们指定一段和k8s节点在同一个子网的IP