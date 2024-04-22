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

yum install -y containerd.io

mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# 修改cgroup Driver为systemd
sed -ri 's#SystemdCgroup = false#SystemdCgroup = true#' /etc/containerd/config.toml

systemctl daemon-reload

systemctl enable containerd --now

#3、Kubernetes部署
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

yum install -y nginx nginx-mod-stream.x86_64

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

cat > /etc/nginx/nginx.conf <<EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 20240;
    use epoll;
}

stream {
    upstream kube-servers {
        hash $remote_addr consistent;
        server k8s-master1.doki.life:6443 weight=5 max_fails=1 fail_timeout=3s;  #这里可以写IP
        server k8s-master2.doki.life:6443 weight=5 max_fails=1 fail_timeout=3s;
        server k8s-master3.doki.life:6443 weight=5 max_fails=1 fail_timeout=3s;
    }
    server {
        listen 8443 reuseport;
        proxy_connect_timeout 3s;
        # 加大timeout
        proxy_timeout 3000s;
        proxy_pass kube-servers;
    }
}
EOF

systemctl enable nginx --now

yum  install -y keepalived


cat > /etc/keepalived/keepalived.conf <<EOF
! Configuration File for keepalived
global_defs {
    router_id 192.168.50.151     #节点ip，master每个节点配置自己的IP
}
vrrp_script chk_nginx {
    script "/etc/keepalived/check_port.sh 8443"
    interval 2
    weight -20
}
vrrp_instance VI_1 {
    state MASTER
    interface ens34                #网卡interface name
    virtual_router_id 251
    priority 100
    advert_int 1
    mcast_src_ip 192.168.50.151    #节点IP
    nopreempt
    authentication {
        auth_type PASS
        auth_pass 11111111
    }
    track_script {
        chk_nginx
    }
    virtual_ipaddress {
        192.168.50.200   #VIP
    }
}
EOF


cat > /etc/keepalived/check_port.sh <<EOF
CHK_PORT=$1
if [ -n "$CHK_PORT" ];then
    PORT_PROCESS=`ss -lt|grep $CHK_PORT|wc -l`
    if [ $PORT_PROCESS -eq 0 ];then
        echo "Port $CHK_PORT Is Not Used,End."
        exit 1
    fi
else
    echo "Check Port Cant Be Empty!"
fi
EOF

systemctl enable --now keepalived

ping -c4 apiserver.doki.life

yum -y install kubeadm kubelet kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet

