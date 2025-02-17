
### 1. Create secret in OpenShift that contain Azure credentials for both keyvaults

```bash
oc create secret generic azure-vault-secret
--from-literal=AZURE_TENANT_ID="<AZURE_TENANT_ID_FOR_KEYVAULT_1>"
--from-literal=AZURE_CLIENT_ID="<AZURE_CLIENT_ID_FOR_KEYVAULT_1>"
--from-literal=AZURE_CLIENT_SECRET="<AZURE_CLIENT_SECRET_FOR_KEYVAULT_1>"
--from-literal=VAULT_AZUREKEYVAULT_VAULT_NAME="<VAULT_AZUREKEYVAULT_VAULT_NAME_FOR_KEYVAULT_1>"
--from-literal=VAULT_AZUREKEYVAULT_KEY_NAME="<VAULT_AZUREKEYVAULT_KEY_NAME_FOR_KEYVAULT_1>"
--from-literal=AZURE_TENANT_ID_2_="<AZURE_TENANT_ID_FOR_KEYVAULT_2>"
--from-literal=AZURE_CLIENT_ID_2_="<AZURE_CLIENT_ID_FOR_KEYVAULT_2>"
--from-literal=AZURE_CLIENT_SECRET_2_="<AZURE_CLIENT_SECRET_FOR_KEYVAULT_2>"
--from-literal=VAULT_AZUREKEYVAULT_VAULT_NAME_2_="<VAULT_AZUREKEYVAULT_VAULT_NAME_FOR_KEYVAULT_2>"
--from-literal=VAULT_AZUREKEYVAULT_KEY_NAME_2_="<VAULT_AZUREKEYVAULT_KEY_NAME_FOR_KEYVAULT_2>"
```


### 2. Install vault with single autoanseal:

```bash
  ha:
        ...
        # enable_multiseal = true
        ...
        seal "azurekeyvault" {
          name = "primary"
          priority = "1"
        }

        # seal "azurekeyvault" {
        #   name = "secondary"
        #   priority = "2"
        # }
        ...
```


### 3. Init vault 

```bash
kubectl exec -it -n vault vault-0 -- vault operator init 
```

### 4. Enable multi-seal - edit configmap

```bash
kubectl edit cm -n vault vault-config

  ha:
        ...
        enable_multiseal = true
        ...
        seal "azurekeyvault" {
          name = "primary"
          priority = "1"
        }

        # seal "azurekeyvault" {
        #   name = "secondary"
        #   priority = "2"
        # }
        ...
```

### 5. Restart vault

```bash
kubectl delete po -n vault --all
```

### 6. Add secondary unseal

```bash
```bash
kubectl edit cm -n vault vault-config

  ha:
        ...
        enable_multiseal = true
        ...
        seal "azurekeyvault" {
          name = "primary"
          priority = "1"
        }

        seal "azurekeyvault" {
          name = "secondary"
          priority = "2"
        }
        ...
```

### 7. Restart vault

```bash
kubectl delete po -n vault --all
```


### Test

```bash
kubectl get po -n vault

kubectl exec -it -n vault vault-0 -- curl --header "X-Vault-Token: <VAULT_ROOT_TOKEN>" --request GET https://127.0.0.1:8200/v1/sys/sealwrap/rewrap -vk

kubectl exec -it -n vault vault-0 -- curl --header "X-Vault-Token: <VAULT_ROOT_TOKEN>" --request POST https://127.0.0.1:8200/v1/sys/sealwrap/rewrap -vk

kubectl exec -it -n vault vault-0 -- curl --header "X-Vault-Token: <VAULT_ROOT_TOKEN>" --request GET https://127.0.0.1:8200/v1/sys/sealwrap/rewrap -vk

kubectl logs -n vault vault-0
```

