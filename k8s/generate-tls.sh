#!/bin/bash
# Generate self-signed TLS certificate and create Kubernetes secret

echo "Generating self-signed TLS certificate..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/CN=wisecow.local/O=wisecow"

echo "Creating Kubernetes TLS secret..."

kubectl create secret tls wisecow-tls \
  --cert=tls.crt \
  --key=tls.key \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Cleaning up temporary files..."
rm -f tls.key tls.crt

echo "TLS secret created successfully!"
kubectl get secret wisecow-tls
