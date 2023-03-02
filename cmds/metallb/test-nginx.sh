#!/bin/bash

cat > nginx-quic-lb.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: nginx-quic

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-lb
  namespace: nginx-quic
spec:
  selector:
    matchLabels:
      app: nginx-lb
  replicas: 4
  template:
    metadata:
      labels:
        app: nginx-lb
    spec:
      containers:
      - name: nginx-lb
        image: tinychen777/nginx-quic:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80

---

apiVersion: v1
kind: Service
metadata:
  name: nginx-lb-service
  namespace: nginx-quic
spec:
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  selector:
    app: nginx-lb
  ports:
  - protocol: TCP
    port: 80 # match for service access port
    targetPort: 80 # match for pod access port
  type: LoadBalancer
  loadBalancerIP: 192.168.50.180
EOF

kubectl apply -f nginx-quic-lb.yaml