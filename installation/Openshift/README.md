# **Installing and Upgrading Vault on OpenShift with Helm**

This guide outlines the best practices for deploying **HashiCorp Vault** on **OpenShift**, including security hardening recommendations.

---

## **Prerequisites**

### **1. Create the Vault Namespace**
Ensure the `vault` project (namespace) exists before proceeding:

```bash
oc new-project vault
```

### **2. Create a Secret for Vault Enterprise License**
Store your Vault license as a Kubernetes secret:

```bash
oc create secret generic vault-enterprise-license --from-file=license=./path/to/your/vault.hclic --namespace vault
```

### **3. Create a Secret for Azure Auto-Unseal**
For Vault auto-unseal using **Azure Key Vault**, create the required secrets. More details can be found [here](../../docs/multi_auto_unseal.md).

```bash
oc create secret generic azure-vault-secret \
--from-literal=AZURE_TENANT_ID="<AZURE_TENANT_ID_FOR_KEYVAULT_1>" \
--from-literal=AZURE_CLIENT_ID="<AZURE_CLIENT_ID_FOR_KEYVAULT_1>" \
--from-literal=AZURE_CLIENT_SECRET="<AZURE_CLIENT_SECRET_FOR_KEYVAULT_1>" \
--from-literal=VAULT_AZUREKEYVAULT_VAULT_NAME="<VAULT_AZUREKEYVAULT_VAULT_NAME_FOR_KEYVAULT_1>" \
--from-literal=VAULT_AZUREKEYVAULT_KEY_NAME="<VAULT_AZUREKEYVAULT_KEY_NAME_FOR_KEYVAULT_1>" \
--from-literal=AZURE_TENANT_ID_secondary="<AZURE_TENANT_ID_FOR_KEYVAULT_secondary>" \
--from-literal=AZURE_CLIENT_ID_secondary="<AZURE_CLIENT_ID_FOR_KEYVAULT_secondary>" \
--from-literal=AZURE_CLIENT_SECRET_secondary="<AZURE_CLIENT_SECRET_FOR_KEYVAULT_secondary>" \
--from-literal=VAULT_AZUREKEYVAULT_VAULT_NAME_secondary="<VAULT_AZUREKEYVAULT_VAULT_NAME_FOR_KEYVAULT_secondary>" \
--from-literal=VAULT_AZUREKEYVAULT_KEY_NAME_secondary="<VAULT_AZUREKEYVAULT_KEY_NAME_FOR_KEYVAULT_secondary>"
```

### **4. Create a Secret for TLS Certificates**
Ensure that the required **TLS certificates** are created and stored in a secret. See [certificate creation](./../../docs/certificate_creation.md) for details.

---

## **Installing Vault on OpenShift**

Follow these steps to install Vault using **Helm**.

### **1. Review the Helm Values**
Before installation, review the **[values.yaml](./values.yaml)** file to align the configuration with your requirements.

Key parameters to verify:
- **Route settings** (for OpenShift ingress)
- **Vault configurations** (storage, HA setup, security settings)

### **2. Install Vault Using Helm**

Notice that the current values file is applicable for version 0.29.0.

```bash
helm upgrade -i vault path_to_helm_chart -f your-values-file.yaml --namespace vault
```
Alternatively, you can use the **Jenkins pipeline** to deploy the configuration.

**Importnet Note**: In order to configure multi unseal HA, read this [article](../../docs/multi_auto_unseal.md).

### **3. Initialize Vault (First-Time Setup)**
For first-time installations, initialize Vault:

```bash
oc exec vault-0 -- vault operator init
```
⚠ **Important:** Store the **root token** and **recovery keys** securely.

### **4. Verify the Vault Cluster**
Check if Vault is running and unsealed:

```bash
oc exec vault-0 -- vault status
```

Since **auto-unseal** is enabled, Vault should already be unsealed. You can also verify access by logging in:

```bash
oc exec vault-0 -- vault login <root_token>
```

---

## **Upgrading Vault**

### **1. Modify the Values File**
Before upgrading, **update** the `values.yaml` file with the required changes. Ensure the settings align with the desired configuration.

### **2. Upgrade the Vault Helm Deployment**
Apply the new configuration using Helm:

```bash
helm upgrade -i vault path_to_helm_chart -f your-values-file.yaml --namespace vault
```
Alternatively, trigger the **Jenkins pipeline** with the updated values.

### **3. Restart Vault Pods to Apply Changes**
```bash
oc delete pod vault-0
oc delete pod vault-1
oc delete pod vault-2
```

---

## **Validating the Installation or Upgrade**

### **1. Ensure All Pods Are Running**
```bash
oc get pods -n vault
```

### **2. Check Vault Status**
```bash
oc exec vault-0 -- vault status
```

### **3. Verify Auto-Unseal**
Ensure that Vault **automatically unseals** by restarting a pod and checking its status:

```bash
oc delete pod vault-0
oc get pods -n vault
oc exec vault-0 -- vault status
```
If auto-unseal is working, the pod should start **unsealed**.

### **4. Validate Vault Cluster Membership**
Ensure all Vault pods are part of the same cluster:

```bash
oc exec vault-0 -- vault login <token>
oc exec vault-0 -- vault operator raft list-peers
```
All Vault pods should be listed in the **Raft peer list**.

---

This guide ensures a **secure and production-ready Vault deployment** on OpenShift with best practices in place.