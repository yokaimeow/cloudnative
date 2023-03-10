#!/bin/bash

cat <<EOF > .env
api-token=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
EOF

cat <<EOF > kustomization.yaml
resources:
  - letsencrypt-issuer.yaml
namespace: cert-manager
secretGenerator:
  - name: cloudflare-api-token-secret
    envs:
      - .env # token 就存放在这里，这个文件不要提交到 Git 仓库中
generatorOptions:
  disableNameSuffixHash: true
EOF

# letsencrypt-issuer.yaml
cat <<EOF > cloudflare-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns01
spec:
  acme:
    privateKeySecretRef:
      name: letsencrypt-dns01
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
      - dns01:
          cloudflare:
            email: xxxxxx@163.com # 替换成你的 cloudflare 邮箱账号
            apiTokenSecretRef:
              key: api-token
              name: cloudflare-api-token-secret # 引用保存 cloudflare 认证信息的 Secret
EOF

# 所生成的 Secret 可以使用下面的命令来检查

kubectl kustomize ./

# 如无问题，运行如下命令，创建 issuer
kubectl apply -k ./

# 查看 Let't Encrypt 注册状态
kubectl describe clusterissuer letsencrypt-dns01

# 创建 certificate 文件
cat <<EOF > cloudflare-certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: domain-com
  namespace: cert-manager
spec:
  dnsNames:
    - "*.domain.com" # 要签发证书的域名，替换成你自己的
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-dns01 # 引用 ClusterIssuer，名字和 letsencrypt-issuer.yaml 中保持一致
  secretName: letsencrypt-tls # 最终签发出来的证书会保存在这个 Secret 里面
EOF

kubectl apply -f cloudflare-certificate.yaml

# 查看证书是否签发成功

kubectl get certificate