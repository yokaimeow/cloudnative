#!/bin/bash

cat <<EOF > ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-tls
  namespace: qinglong
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-dns01"
spec:
  tls:
  - hosts:
    - qinglong.domain.com        # 替换为您的域名。
    secretName:  letsencrypt-tls
  rules:
  - host: qinglong.domain.com    # 替换为您的域名。
    http:
      paths:
      - path: /
        backend:
          service:
            name: qinglong  # 替换为您的后端服务名。
            port:
              number: 10176  # 替换为您的服务端口。
        pathType: ImplementationSpecific
EOF

kubectl apply -f ingress.yaml
