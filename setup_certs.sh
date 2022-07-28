#!/bin/bash
  
mkdir -p certs/{ca,dashboards,opensearch}


# Choose an appropriate DN
CERTS_DN="/C=UN/ST=UN/L=UN/O=UN"

# Generate root CA (ignore if you already have one)
openssl genrsa -out certs/ca/ca.key 2048
openssl req -new -x509 -sha256 -days 1095 -subj "$CERTS_DN/CN=CA" -key certs/ca/ca.key -out certs/ca/ca.pem

# Admin
openssl genrsa -out certs/ca/admin-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/ca/admin-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/ca/admin.key
openssl req -new -subj "$CERTS_DN/CN=ADMIN" -key certs/ca/admin.key -out certs/ca/admin.csr
openssl x509 -req -in certs/ca/admin.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/ca/admin.pem

# Opensearch
openssl genrsa -out certs/opensearch/opensearch-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/opensearch/opensearch-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/opensearch/opensearch.key
openssl req -new -subj "$CERTS_DN/CN=opensearch" -key certs/opensearch/opensearch.key -out certs/opensearch/opensearch.csr
openssl x509 -req -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:opensearch") -in certs/opensearch/opensearch.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/opensearch/opensearch.pem

# OpenSearch Dashboards
openssl genrsa -out certs/dashboards/dashboards-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/dashboards/dashboards-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/dashboards/dashboards.key
openssl req -new -subj "$CERTS_DN/CN=dashboards" -key certs/dashboards/dashboards.key -out certs/dashboards/dashboards.csr
openssl x509 -req -in certs/dashboards/dashboards.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/dashboards/dashboards.pem

# Cleanup
rm certs/ca/admin-temp.key certs/ca/admin.csr
rm certs/opensearch/opensearch-temp.key certs/opensearch/opensearch.csr
rm certs/dashboards/dashboards-temp.key certs/dashboards/dashboards.csr

# Adjusting permissions
chmod 700 certs/{ca,dashboards,opensearch}
chmod 700 certs/{ca/*,dashboards/*,opensearch/*}

