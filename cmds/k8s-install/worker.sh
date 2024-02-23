#!/bin/bash

#关闭防火墙
systemctl stop firewalld && systemctl disable firewalld

#添加hosts解析
cat >> /etc/hosts << EOF
192.168.50.200 apiserver.doki.life
192.168.50.151 k8s-master1.doki.life
192.168.50.152 k8s-master2.doki.life
192.168.50.153 k8s-master3.doki.life
192.168.50.161 k8s-node1.doki.life
192.168.50.162 k8s-node2.doki.life
192.168.50.163 k8s-node3.doki.life
192.168.50.171 nfs.doki.life
EOF

#永久关闭seLinux(需重启系统生效)
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#关闭swap
swapoff -a  # 临时关闭
sed -i 's/.*swap.*/#&/g' /etc/fstab

#安装应用
yum install -y lvm2 vim wget

#加载IPVS模块
yum -y install ipset ipvsadm


modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
modprobe overlay
modprobe br_netfilter

#2、部署开机自启模块
cat <<EOF | sudo tee /etc/modules-load.d/selfinit.conf
overlay
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
EOF

cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
vm.swappiness=0 # 禁止使用 swap 空间，只有当系统 OOM 时才允许使用它
vm.overcommit_memory=1 # 不检查物理内存是否够用
vm.panic_on_oom=0 # 开启 OOM
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF

sysctl --system

wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo

yum install -y containerd.io-1.6.21-3.1.el9.x86_64

mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# 修改cgroup Driver为systemd
sed -ri 's#SystemdCgroup = false#SystemdCgroup = true#' /etc/containerd/config.toml

systemctl daemon-reload

systemctl enable containerd --now

#3、Kubernetes部署
cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
EOF

yum -y install kubeadm-1.27.3-0 kubelet-1.27.3-0 kubectl-1.27.3-0

systemctl enable --now kubelet

