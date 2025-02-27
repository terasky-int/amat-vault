# **Certificate Creation Guidelines**

For our setup, both **Site A** and **Site B** share the same certificate.  
Therefore, the **SANs (Subject Alternative Names)** in the certificate must include entries from both sites.

**Note:** The certificate must be applied to both sites.

---

### **Required SANs**
```
DNS: vault-0
DNS: vault-1
DNS: vault-2
DNS: *.vault
DNS: *.vault-internal
DNS: *.vault-internal.vault.svc.cluster.local
DNS: Openshift Route URL
DNS: Load Balancer URL
IP Address: 127.0.0.1

```

After setting up the SANs, Generate signed certificate. you should have the following **TLS certificate files**:  
- **Private Key:** `vault.key`  
- **Certificate:** `vault.crt`  
- **CA Certificate:** `vault.ca`  

---

## **Certificate Setup on OpenShift (Site A)**

**All commands should be executed in the `vault` namespace.**

### **1️. First-time Certificate Setup**
To create the TLS secret for the first time, run:

```bash
oc create secret generic vault-ha-tls \
   -n $VAULT_K8S_NAMESPACE \
   --from-file=vault.key=${WORKDIR}/vault.key \
   --from-file=vault.crt=${WORKDIR}/vault.crt \
   --from-file=vault.ca=${WORKDIR}/vault.ca
```

---

### **2️. Certificate Rotation**
If the certificate needs to be updated (due to expiration or changes), follow these steps:

1. **Backup the existing secret:**
   ```bash
   oc get secret vault-ha-tls -o yaml > vault-ha-tls-secret.yaml.bkp
   ```

2. **Delete the existing secret:**
   ```bash
   oc delete secret vault-ha-tls
   ```

3. **Recreate the secret with the new certificate:**
   ```bash
   oc create secret generic vault-ha-tls \
      -n $VAULT_K8S_NAMESPACE \
      --from-file=vault.key=${WORKDIR}/vault.key \
      --from-file=vault.crt=${WORKDIR}/vault.crt \
      --from-file=vault.ca=${WORKDIR}/vault.ca
   ```

---

### **3️. Apply the New Certificate**
To ensure Vault loads the updated certificate, restart the Vault pods:

```bash
oc delete pod vault-0 
oc delete pod vault-1
oc delete pod vault-2 
```

---

## **Validation**
To verify that the certificate update was successful, run:

```bash
vault status
```
✅ **If the command succeeds, the certificate update is applied.**  

🚨 **If the command fails, check:**
1. The **SANs** in the certificate are correct.
2. The **secret was recreated correctly**.
3. The **Vault pods were restarted**.

---

## **Certificate Update on Site B (VM-Based Deployment)**

### **1. Remove Old Certificates**
**Backup** and delete the existing certificates:

```bash
rm -f /Application/vault/tls/*
```

### **2️. Copy the New Certificates**
Place the updated TLS certificates in `/Application/vault/tls/`.

### **3️. Set Correct Ownership**
Ensure Vault has the correct permissions:

```bash
chown vault:vault /Application/vault/tls/*
```

### **4️. Restart Vault Service**
Apply the new certificates by restarting Vault:

```bash
sudo systemctl restart vault
```

---

## **Validation**
To verify the service is running correctly:

```bash
systemctl status vault
```

```bash
vault status
```

✅ **If both commands succeed, the update is applied.**  

🚨 **If the service fails:**
- Restore the old certificates and restart the service.
- Troubleshoot using logs:

  ```bash
  journalctl -u vault -xe
  ```

---

### **Summary**
- **Site A (OpenShift):** Update the secret, restart pods.
- **Site B (VM):** Replace certs, adjust permissions, restart Vault.

This ensures a **seamless certificate update process** while maintaining high availability and security.
