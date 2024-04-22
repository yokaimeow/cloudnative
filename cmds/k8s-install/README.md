# Kubeadm 安装 Kubernetes 集群

## 目录

### 安装

- controller 脚本是安装： 控制节点

- worker 脚本是安装： 工作节点

- 生成安装配置文件

```shell
kubeadm config print init-defaults > kubeadm-init.yaml

apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.50.151 #master ip
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  name: k8s-master1.doki.life #master node name
  taints: null
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.k8s.io
kind: ClusterConfiguration
kubernetesVersion: 1.30.0
controlPlaneEndpoint: apiserver.doki.life:8443 #apiserver
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
  podSubnet: 10.244.0.0/16 #pod sub net
scheduler: {}
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
```

- 安装

```shell
# 预拉取镜像
kubeadm config images pull --config kubeadm-init.yaml

kubeadm init --config kubeadm-init.yaml --upload-certs | tee kubeadm-init.log

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

- 根据生成的 token 在对应的节点上运行

### 参考

- [Kubeadm搭建高可用(k8s)Kubernetes v1.24.0集群](https://www.cnblogs.com/hahaha111122222/p/16287595.html)