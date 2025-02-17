# Performance Replication

Based on this [article](https://developer.hashicorp.com/vault/tutorials/enterprise/performance-replication)

## Steps:

## On Primary site:

1. 

```bash
vault policy write superpolicy -<<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF
```

2. 

```bash
vault auth enable userpass
```

3. 

```bash
vault write auth/userpass/users/superuser password="XXXXXX" policies="superpolicy"
```

4. 

```bash
vault write -f sys/replication/performance/primary/enable
```

5. 

```bash
vault write sys/replication/performance/primary/secondary-token id=secondary -format=json
```


## On Secondary site:

1. 

```bash
vault write sys/replication/performance/secondary/enable token=<PRIMARY_WARPING_TOKEN> primary_api_addr=<PRIMARY ADDRESS>
```

2. 

```bash
vault login -method=userpass username=superuser
```

3. 

```bash
vault read -format=json sys/replication/status | jq
```

4. Login with the user we created on the primary site

```bash
vault login -method=userpass username=superuser
```