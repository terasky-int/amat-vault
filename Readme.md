# Vault Installation Guide

Before installing the vault preform the following steps:

---

## Setup Vault enterprise

oc create secret generic vault-enterprise-license --from-file=license=./path/to/your/vault.hclic --namespace vault


---

## Vault TLS Setup Guide

This guide outlines the steps to set up TLS for Vault in a Kubernetes environment.

#### 1. Create a Working Directory
```bash
mkdir /tmp/vault
```

#### 2. Set Environment Variables
Export the required variables for the setup:
```bash
export VAULT_K8S_NAMESPACE="vault" \
export VAULT_HELM_RELEASE_NAME="vault" \
export VAULT_SERVICE_NAME="vault-internal" \
export K8S_CLUSTER_NAME="cluster.local" \
export WORKDIR=/tmp/vault
```

#### 3. Generate a Private Key
Generate a private key for Vault:
```bash
openssl genrsa -out ${WORKDIR}/vault.key 2048
```

#### 4. Create a CSR Configuration File
Create a `vault-csr.conf` file with the following content:
```bash
cat > ${WORKDIR}/vault-csr.conf <<EOF
[req]
default_bits = 2048
prompt = no
encrypt_key = yes
default_md = sha256
distinguished_name = kubelet_serving
req_extensions = v3_req
[ kubelet_serving ]
O = system:nodes
CN = system:node:*.${VAULT_K8S_NAMESPACE}.svc.${K8S_CLUSTER_NAME}
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.${VAULT_SERVICE_NAME}
DNS.2 = *.${VAULT_SERVICE_NAME}.${VAULT_K8S_NAMESPACE}.svc.${K8S_CLUSTER_NAME}
DNS.3 = *.${VAULT_K8S_NAMESPACE}
IP.1 = 127.0.0.1
EOF
```
> **Note**: Make sure you update the csr accordingly to your enviornment requirments.

#### 5. Generate a CSR
Generate a Certificate Signing Request (CSR):
```bash
openssl req -new -key ${WORKDIR}/vault.key -out ${WORKDIR}/vault.csr -config ${WORKDIR}/vault-csr.conf
```

#### 6. Create a CSR YAML File
Create a Kubernetes CSR resource:
```bash
cat > ${WORKDIR}/csr.yaml <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
   name: vault.svc
spec:
   signerName: kubernetes.io/kubelet-serving
   expirationSeconds: 8640000
   request: $(cat ${WORKDIR}/vault.csr|base64|tr -d '\n')
   usages:
   - digital signature
   - key encipherment
   - server auth
EOF
```

#### 7. Submit the CSR
Submit the CSR to Kubernetes:
```bash
oc create -f ${WORKDIR}/csr.yaml
```

#### 8. Approve the CSR
Approve the CSR:
```bash
oc certificate approve vault.svc
```

#### 9. Retrieve the Certificate
Retrieve the signed certificate and save it:
```bash
oc get csr vault.svc -o jsonpath='{.status.certificate}' | openssl base64 -d -A -out ${WORKDIR}/vault.crt
```

#### 10. Retrieve the Cluster CA Certificate
Extract the Kubernetes cluster's CA certificate:
```bash
oc config view \
--raw \
--minify \
--flatten \
-o jsonpath='{.clusters[].cluster.certificate-authority-data}' \
| base64 -d > ${WORKDIR}/vault.ca
```

#### 11. Create the Namespace
Create the namespace for Vault if not already exists:
```bash
oc new-project $VAULT_K8S_NAMESPACE
```

#### 12. Create the TLS Secret
Create a Kubernetes secret to store the TLS certificates:
```bash
oc create secret generic vault-ha-tls \
   -n $VAULT_K8S_NAMESPACE \
   --from-file=vault.key=${WORKDIR}/vault.key \
   --from-file=vault.crt=${WORKDIR}/vault.crt \
   --from-file=vault.ca=${WORKDIR}/vault.ca
```

### Cleanup
To remove the generated files:
```bash
rm -rf /tmp/vault
```


---

## Install Vault

Steps to install HashiCorp Vault using Helm on an OpenShift cluster.

* Create a new project/namespace called `vault` in OpenShift.
```bash
oc new-project vault
```

* Add the OpenShift Helm charts repository and update the repository list.
```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm search repo hashicorp/vault --versions
```

* Install or upgrade the Vault Helm chart.
```bash
helm upgrade -i vault hashicorp/vault --version 0.29.0 -f values.yaml --namespace vault --create-namespace
```